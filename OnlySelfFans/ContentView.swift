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
    @StateObject var appManager: AppManager = AppManager()
    
    @State var showWelcomeScreen = false
    @State var showingNewNotificationScreen = false
    
    var loadedNotification: Notification? {
        appManager.loadedNotification
    }
    var notificationStoredCurrently: Bool {
        loadedNotification != nil
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
                        HStack {
                            Text("Current Notification")
                            Spacer()
                            Button {
                                appManager.refresh()
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }
                        }
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
//                        AppManager.addNotification(withNotificationModel: Notification(
//                            id: "identifier",
//                            title: "stop texting",
//                            body: "pls stop using ig for ur own sake",
//                            triggerIntervalDuration: 5,
//                            repeats: false
//                        ))
//                        print("scheduled notification!")
//                        appManager.loadedNotification = Notification.loadCurrentNotification()
                        
                        showingNewNotificationScreen = true
                    } label: {
                        Text("Schedule")
                    }
                }
            }
            .onAppear {
                appManager.refresh()
                if AppManager.checkIfFirstLaunch() {
                    showWelcomeScreen.toggle()
                }
            }
            .sheet(isPresented: $showWelcomeScreen) {
                WelcomeView()
            }
            .sheet(isPresented: $showingNewNotificationScreen) {
                NewNotificationView(appManager: appManager)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
