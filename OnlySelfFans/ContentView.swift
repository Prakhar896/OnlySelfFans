//
//  ContentView.swift
//  OnlySelfFans
//
//  Created by Prakhar Trivedi on 25/6/23.
//

import SwiftUI

enum NotificationAction: String {
    case dismiss
    case reminder
}

enum NotificationCategory: String {
    case general
}

struct ContentView: View {
    @State var showWelcomeScreen = false
    
    var body: some View {
        NavigationView {
            List {
                Text("test")
            }
            .navigationTitle("OnlySelfFans")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Schedule Notification") {
                        setNotification()
                    }
                }
            }
            .onAppear {
                if AppManager.checkIfFirstLaunch() {
                    showWelcomeScreen.toggle()
                }
            }
            .sheet(isPresented: $showWelcomeScreen) {
                WelcomeView()
            }
        }
    }
    
    func setNotification() {
        let center = UNUserNotificationCenter.current()
        
        // create content
        let content = UNMutableNotificationContent()
        content.title = "STOP TEXTING NUPUR"
        content.body = "STOP TEXTING WHOEVER YOUVE BEEN TEXTING FOR THE PAST 2 HOURS"
        content.categoryIdentifier = NotificationCategory.general.rawValue
        
        // create trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        // create a request
        let request = UNNotificationRequest(identifier: "identifier", content: content, trigger: trigger)
        
        // action
        let dismiss = UNNotificationAction(identifier: NotificationAction.dismiss.rawValue, title: "Dismiss", options: [])
        
        let reminder = UNNotificationAction(identifier: NotificationAction.reminder.rawValue, title: "Reminder", options: [])
        
        let generalCategory = UNNotificationCategory(identifier: NotificationCategory.general.rawValue, actions: [dismiss, reminder], intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([generalCategory])
        
        // add
        center.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
