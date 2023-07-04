//
//  NotificationDetailView.swift
//  OnlySelfFans
//
//  Created by Prakhar Trivedi on 30/6/23.
//

import SwiftUI

struct ParameterView: View {
    var parameterName: String
    var parameterValue: String
    var isBodyText: Bool = false
    
    var body: some View {
        if !isBodyText {
            HStack {
                Text(parameterName)
                Spacer()
                Text(parameterValue)
//                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.trailing)
            }
        } else {
            Text(parameterName + "\n\n" + parameterValue)
        }
    }
}

struct NotificationDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var appManager: AppManager
    var id: String
    
    @State var showingReactivateConfirmationAlert = false
    
    var givenNotification: Notification? {
        appManager.loadedNotifications.first { $0.id == id }
    }
    
    var errorView: some View {
        List {
            Text("An error occurred in getting details for that notification.")
                .font(.title3.weight(.bold))
                .padding(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center)
        }
        .navigationTitle("An Error Ocurred")
    }
    
    var body: some View {
        if let givenNotification = givenNotification {
            List {
                ParameterView(parameterName: "Title:", parameterValue: givenNotification.title)
                ParameterView(parameterName: "Body:", parameterValue: givenNotification.body, isBodyText: true)
                
                if givenNotification.timeIntervalBased {
                    ParameterView(parameterName: "Interval Duration:", parameterValue: String(givenNotification.triggerIntervalDuration ?? 0.0))
                    ParameterView(parameterName: "Repeats", parameterValue: givenNotification.repeats ? "Yes": "No")
                } else {
                    ParameterView(parameterName: "Trigger Datetime:", parameterValue: givenNotification.triggerDatetime?.formatted() ?? "UNAVAILABLE")
                }
                
                ParameterView(parameterName: "Created:", parameterValue: givenNotification.created.formatted(date: .abbreviated, time: .standard))
                
                // Re-activate button section
                Section {
                    Button {
                        appManager.reActivateNotification(withID: givenNotification.id)
                        showingReactivateConfirmationAlert = true
                    } label: {
                        Text("Re-activate")
                            .fontWeight(.heavy)
                            .foregroundColor(.accentColor)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .background(Color.accentColor.opacity(0.4))
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            }
            .navigationTitle(givenNotification.title)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [givenNotification.id])
                        appManager.loadedNotifications.removeAll { $0.id == givenNotification.id }
                        Notification.saveToFile(notifications: appManager.loadedNotifications)
                        dismiss()
                    } label: {
                        Text("Delete")
                            .foregroundColor(.red)
                    }
                }
            }
            .alert("Notification Re-activated", isPresented: $showingReactivateConfirmationAlert) {
                Button("OK") {}
            } message: {
                Text("This notification has been re-activated successfully! It will now trigger as if it was just created.")
            }

        } else {
            errorView
        }
    }
}

struct NotificationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationDetailView(appManager: AppManager(), id: "nil")
    }
}
