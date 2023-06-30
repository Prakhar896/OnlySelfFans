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

struct ContentViewListSectionHeader: View {
    @ObservedObject var appManager: AppManager
    
    var body: some View {
        HStack {
            Text("Current Notifications")
            Spacer()
            Button {
                appManager.refresh()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        }
    }
}

struct ContentView: View {
    @StateObject var appManager: AppManager = AppManager()
    
    @State var showWelcomeScreen = false
    @State var showingNewNotificationScreen = false
    
    var loadedNotifications: [Notification]? {
        appManager.loadedNotifications
    }
    var notificationStoredCurrently: Bool {
        loadedNotifications != nil && loadedNotifications?.count != 0
    }
    
    var body: some View {
        NavigationView {
            List {
                if notificationStoredCurrently {
                    Section {
                        ForEach(loadedNotifications ?? [], id: \.id) { notif in
                            Text(notif.title)
                        }
                    } header: {
                        ContentViewListSectionHeader(appManager: appManager)
                    }
                } else {
                    Section {
                        Text("No notifications currently active.")
                            .bold()
                            .padding(10)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .multilineTextAlignment(.center)
                    } header: {
                        ContentViewListSectionHeader(appManager: appManager)
                    }
                }
            }
            .navigationTitle("OnlySelfFans")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingNewNotificationScreen = true
                    } label: {
                        Text("Schedule")
                    }
                }
            }
            .sheet(isPresented: $showWelcomeScreen) {
                WelcomeView()
            }
            .sheet(isPresented: $showingNewNotificationScreen) {
                NewNotificationView(appManager: appManager)
            }
        }
        .onAppear {
            appManager.refresh()
            if AppManager.checkIfFirstLaunch() {
                showWelcomeScreen.toggle()
            }
        }
    }
    
    func makeFormattedDatetime(for notification: Notification) -> String? {
        if let triggerDatetime = notification.triggerDatetime {
                return triggerDatetime.formatted()
        }
        
        return nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
