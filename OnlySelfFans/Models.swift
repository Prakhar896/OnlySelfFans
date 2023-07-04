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
        
        // ***DEPRECATED*** (Expiry strategy is ditched)
//        var loadedNotifs = Notification.loadFromFile() ?? []
//        loadedNotifs = loadedNotifs.filter { notif in
//            if notif.id == identifier {
//                if notif.timeIntervalBased { // notification has been sent and expired
//                    return false // exclude notif
//                } else if !notif.repeats {
//                        return false // notification with non-repeating interval sent and expired, hence exclude
//                } else {
//                    return true // notification has repeating interval, sent; include
//                }
//            } else {
//                return true // notification is not the one just sent
//            }
//        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .banner])
    }
}

class AppManager: ObservableObject {
    @Published var loadedNotifications: [Notification]
    
    init() {
        loadedNotifications = Notification.loadFromFile() ?? []
        refresh()
    }
    
    func refresh(reloadFromFile: Bool = true) {
        loadedNotifications = Notification.loadFromFile() ?? []
    }
    
    func hardReset() {
        UserDefaults.resetDefaults()
        UserDefaults.standard.synchronize()
        Notification.saveToFile(notifications: [])
        loadedNotifications = []
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        exit(0)
    }
    
    func reActivateNotification(withID notificationID: String) {
        if let targetNotif = loadedNotifications.first(where: { $0.id == notificationID}) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
            AppManager.addNotification(withNotificationModel: targetNotif)
            let index = loadedNotifications.firstIndex(where: { $0.id == notificationID})!
            loadedNotifications[index].created = Date.now
            Notification.saveToFile(notifications: loadedNotifications)
//            refresh()
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
    
    static func addNotification(withNotificationModel notification: Notification, _ persist: Bool = true) {
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
        
        // ***DEPRECATED***
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
        if persist {
            var loadedNotifs = Notification.loadFromFile() ?? []
            loadedNotifs.insert(notification, at: 0)
            Notification.saveToFile(notifications: loadedNotifs)
        }
    }
}

struct Notification: Codable {
    var id: String
    var title: String
    var body: String
    var triggerDatetime: Date?
    var triggerIntervalDuration: Double?
    var repeats: Bool
    var created: Date
    
    var description: String {
        var desc = ""
        if !timeIntervalBased {
            desc = ((triggerDatetime ?? Date.now) > Date.now ? "Triggers on ": "Sent on ") + (triggerDatetime?.formatted() ?? "UNAVAILABLE")
        } else {
            desc = (repeats ? "Repeats every ": "Once in ") + "\(Int(triggerIntervalDuration ?? 0.0)) seconds"
        }
        
        return desc
    }
    
    init(id: String, title: String, body: String, triggerIntervalDuration: Double? = nil, repeats: Bool) {
        self.id = id
        self.title = title
        self.body = body
        self.triggerDatetime = nil
        self.triggerIntervalDuration = triggerIntervalDuration
        self.repeats = repeats
        self.created = Date.now
    }
    
    init(id: String, title: String, body: String, triggerDatetime: Date? = nil) {
        self.id = id
        self.title = title
        self.body = body
        self.triggerDatetime = triggerDatetime
        self.triggerIntervalDuration = nil
        self.repeats = false
        self.created = Date.now
    }
    
    var timeIntervalBased: Bool {
        if triggerDatetime == nil && triggerIntervalDuration != nil {
            return true
        } else {
            return false
        }
    }
    
    // ***DEPRECATED***
    static func save(notification: Notification) {
        if let data = try? JSONEncoder().encode(notification) {
            UserDefaults.standard.set(data, forKey: "CurrentNotification")
        }
    }
    
    // ***DEPRECATED***
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


extension UserDefaults {
    static func resetDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}
