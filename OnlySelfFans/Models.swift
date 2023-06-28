//
//  Models.swift
//  OnlySelfFans
//
//  Created by Prakhar Trivedi on 26/6/23.
//

import Foundation
import UserNotifications

class UserNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        print("Notification with ID '\(identifier)' was received.")
        
        Notification.removeCurrentNotificationKey()
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .banner])
    }
}

class AppManager: ObservableObject {
    @Published var loadedNotification: Notification?
    
    init() {
        refresh()
    }
    
    func refresh() {
        loadedNotification = Notification.loadCurrentNotification()
        
        // expire notif from persistence
        var expire = false
        if let loadedNotification = loadedNotification {
            if !loadedNotification.timeIntervalBased {
                if let triggerDatetime = loadedNotification.triggerDatetime {
                    if triggerDatetime < Date.now {
                        expire = true
                    }
                }
            }
        }
        
        if expire {
            Notification.removeCurrentNotificationKey()
            loadedNotification = nil
        }
    }
    
    static func checkIfFirstLaunch() -> Bool {
        if UserDefaults.standard.bool(forKey: "LaunchedBefore") == true {
            return false
        } else {
            return true
        }
    }
    
    static func firstLaunchCompleted() {
        UserDefaults.standard.set(true, forKey: "LaunchedBefore")
    }
    
    static func addNotification(withNotificationModel notification: Notification) {
        let center = UNUserNotificationCenter.current()
        
        // create content
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        //        content.categoryIdentifier = NotificationCategory.general.rawValue // for notification action categories
        
        // create trigger
        var intervalBasedTrigger: UNTimeIntervalNotificationTrigger? = nil
        var dateBasedTrigger: UNCalendarNotificationTrigger? = nil
        
        if notification.timeIntervalBased {
            intervalBasedTrigger = UNTimeIntervalNotificationTrigger(timeInterval: notification.triggerIntervalDuration ?? 60, repeats: notification.repeats)
        } else {
            var components = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: notification.triggerDatetime ?? Date.now)
            dateBasedTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: notification.repeats)
        }
        
        // create a request
        let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: notification.timeIntervalBased ? intervalBasedTrigger: dateBasedTrigger)
        
        // actions
        //        let dismiss = UNNotificationAction(identifier: NotificationAction.dismiss.rawValue, title: "Dismiss", options: [])
        //
        //        let reminder = UNNotificationAction(identifier: NotificationAction.reminder.rawValue, title: "Reminder", options: [])
        //
        //        let generalCategory = UNNotificationCategory(identifier: NotificationCategory.general.rawValue, actions: [dismiss, reminder], intentIdentifiers: [], options: [])
        //
        //        center.setNotificationCategories([generalCategory])
        
        // add
        center.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        // persist notification
        Notification.save(notification: notification)
    }
}

struct Notification: Codable {
    var id: String
    var title: String
    var body: String
    var triggerDatetime: Date?
    var triggerIntervalDuration: Double?
    var repeats: Bool
    
    init(id: String, title: String, body: String, triggerIntervalDuration: Double? = nil, repeats: Bool) {
        self.id = id
        self.title = title
        self.body = body
        self.triggerDatetime = nil
        self.triggerIntervalDuration = triggerIntervalDuration
        self.repeats = repeats
    }
    
    init(id: String, title: String, body: String, triggerDatetime: Date? = nil) {
        self.id = id
        self.title = title
        self.body = body
        self.triggerDatetime = triggerDatetime
        self.triggerIntervalDuration = nil
        self.repeats = false
    }
    
    var timeIntervalBased: Bool {
        if triggerDatetime == nil && triggerIntervalDuration != nil {
            return true
        } else {
            return false
        }
    }
    
    static func save(notification: Notification) {
        if let data = try? JSONEncoder().encode(notification) {
            UserDefaults.standard.set(data, forKey: "CurrentNotification")
        }
    }
    
    static func loadCurrentNotification() -> Notification? {
        if let data = UserDefaults.standard.data(forKey: "CurrentNotification") {
            if let decodedNotif = try? JSONDecoder().decode(Notification.self, from: data) {
                return decodedNotif
            }
        }
        
        return nil
    }
    
    static func removeCurrentNotificationKey() {
        UserDefaults.standard.removeObject(forKey: "CurrentNotification")
    }
    
    static func saveToFile(notifications: [Notification]) {
        let plistName = "notifications"
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent(plistName).appendingPathExtension("plist")
        
        let propertyListEncoder = PropertyListEncoder()
        let encodedNotifs = try? propertyListEncoder.encode(notifications)
        
        try? encodedNotifs?.write(to: archiveURL, options: .noFileProtection)
    }
    
    static func loadFromFile() -> [Notification]? {
        let plistName = "notifications"
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent(plistName).appendingPathExtension("plist")
        
        let propertyListDecoder = PropertyListDecoder()
        
        guard let retrievedNotifsData = try? Data(contentsOf: archiveURL) else { return nil }
        guard let decodedNotifs = try? propertyListDecoder.decode(Array<Notification>.self, from: retrievedNotifsData) else { return nil }
        return decodedNotifs
    }
}
