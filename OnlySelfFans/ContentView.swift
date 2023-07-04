//
//  ContentView.swift
//  OnlySelfFans
//
//  Created by Prakhar Trivedi on 25/6/23.
//

import SwiftUI

struct ContentViewListSectionHeader: View {
    @ObservedObject var appManager: AppManager
    @Binding var reloader: Bool
    
    var body: some View {
        HStack {
            Text("All Notifications")
            Spacer()
            Button {
                appManager.refresh()
                reloader.toggle()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        }
    }
}

struct NotificationCellView: View {
    var notif: Notification
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(notif.title)
                .bold()
            Text(notif.description)
                .font(.caption)
        }
        .padding(5)
    }
}

struct ContentView: View {
    @StateObject var appManager: AppManager = AppManager()
    
    @State var reloader: Bool = false
    
    @State var showWelcomeScreen = false
    @State var showingNewNotificationScreen = false
    @State var notifDetailIsActive = false
    
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
                            NavigationLink(destination: NotificationDetailView(appManager: appManager, id: notif.id)) {
                                NotificationCellView(notif: notif)
                            }
                        }
                        .onDelete(perform: removeNotifs)
                    } header: {
                        ContentViewListSectionHeader(appManager: appManager, reloader: $reloader)
                    } footer: {
                        Text("Tip: Swipe left on a notification to delete it quickly.")
                    }
                } else {
                    Section {
                        Text("No notifications created.")
                            .bold()
                            .padding(10)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .multilineTextAlignment(.center)
                    } header: {
                        ContentViewListSectionHeader(appManager: appManager, reloader: $reloader)
                    }
                }
            }
            .navigationTitle("OnlySelfFans")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        appManager.hardReset()
                    } label: {
                        Text("Reset")
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingNewNotificationScreen = true
                    } label: {
                        Text("New")
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
    
    func removeNotifs(at offsets: IndexSet) {
        let temp = appManager.loadedNotifications
        appManager.loadedNotifications.remove(atOffsets: offsets)
        Notification.saveToFile(notifications: appManager.loadedNotifications)
        
        // Get IDs of notifications that were removed
        let remainingNotifIDs = appManager.loadedNotifications.map { $0.id }
        let previousNotifIDs = temp.map { $0.id }
        
        var removedNotifIDs: [String] = []
        for id in previousNotifIDs {
            if !remainingNotifIDs.contains(id) {
                removedNotifIDs.append(id)
            }
        }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: removedNotifIDs)
//        appManager.refresh()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// ***DEPRECATED***
//enum NotificationAction: String {
//    case dismiss
//    case reminder
//}
//
//enum NotificationCategory: String {
//    case general
//}
