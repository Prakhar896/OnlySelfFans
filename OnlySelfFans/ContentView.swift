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
    @State var loadedNotification = Notification.loadCurrentNotification()
    
    var notificationStoredCurrently: Bool {
        return loadedNotification != nil
    }
    
    var currentNotificationTriggerDatetimeStringFormatted: String? {
        if let loadedNotification = loadedNotification {
            if let triggerDatetime = loadedNotification.triggerDatetime {
                return triggerDatetime.formatted()
            }
        }
        
        return nil
    }
    
    var body: some View {
        NavigationView {
            List {
                if notificationStoredCurrently {
                    Section {
                        Text("Title: \(loadedNotification?.title ?? "Load Error")")
                        Text("Body:\n\n\(loadedNotification?.body ?? "Load Error")")
                            .frame(minHeight: 50)
                        
                        if loadedNotification!.timeIntervalBased {
                            Text("Time Interval: \(Int(loadedNotification?.triggerIntervalDuration ?? 0)) seconds")
                        } else {
                            Text("Trigger Datetime: \(currentNotificationTriggerDatetimeStringFormatted ?? "Load Error")")
                        }
                    } header: {
                        Text("Current Notification")
                    }
                } else {
                    Section {
                        Text("No notification currently active.")
                            .bold()
                            .padding(10)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .navigationTitle("OnlySelfFans")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        AppManager.addNotification(withNotificationModel: Notification(
                            id: "identifier",
                            title: "stop texting",
                            body: "pls stop using ig for ur own sake",
                            triggerIntervalDuration: 5,
                            repeats: false
                        ))
                        print("scheduled notification!")
                        loadedNotification = Notification.loadCurrentNotification()
                    } label: {
                        Text("Schedule")
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
