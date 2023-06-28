//
//  NewNotificationView.swift
//  OnlySelfFans
//
//  Created by Prakhar Trivedi on 27/6/23.
//

import SwiftUI

struct NewNotificationView: View {
    @ObservedObject var appManager: AppManager
    @Environment(\.dismiss) var dismiss
    
    @State var title: String = ""
    @State var bodyText: String = ""
    @State var selectedMode = "Interval"
    @State var intervalDuration = 60
    @State var repeats = true
    @State var triggerDatetime: Date = Date.now
    
    @State var showingMoreInfoPopup = false
    @State var showingErrorAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    
    let triggerModes = ["Interval", "Date and Time"]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Enter notification title", text: $title)
                } header: {
                    Text("Title")
                } footer: {
                    Text("The title will be the most prominently visible item in your notification.")
                }
                
                Section {
                    TextField("Enter notification body", text: $bodyText, axis: .vertical)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3, reservesSpace: true)
                } header: {
                    Text("Body")
                } footer: {
                    Text("The main content displayed in your notification.")
                }
                
                Section {
                    Picker("Trigger Mode", selection: $selectedMode.animation()) {
                        ForEach(triggerModes, id: \.self) { mode in
                            Text(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .bold()
                } header: {
                    Text("Trigger Configuration")
                }
                
                Section {
                    if selectedMode == "Interval" {
                        HStack {
                            Text("Interval Duration")
                            TextField("e.g 300 seconds", value: $intervalDuration, format: .number)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        HStack {
                            Toggle(isOn: $repeats) {
                                Text("Repeats Continuously")
                            }
                        }
                    } else {
                        HStack {
                            DatePicker("Select Datetime", selection: $triggerDatetime, in: Date.now..., displayedComponents: [.date, .hourAndMinute])
                        }
                    }
                } footer: {
                    Button {
                        showingMoreInfoPopup = true
                    } label: {
                        Text("Learn More...")
                    }
                }
                
                // Create button section
                Section {
                    Button {
                        verifyAndCreate()
                    } label: {
                        Text("Create")
                            .fontWeight(.heavy)
                            .foregroundColor(.accentColor)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .background(Color.accentColor.opacity(0.4))
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .disabled(title == "" || bodyText == "")
                }
            }
            .navigationTitle("New Notification")
            .sheet(isPresented: $showingMoreInfoPopup) {
                MoreInformationView()
                    .presentationDetents([.medium, .large])
            }
            .alert(alertTitle, isPresented: $showingErrorAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
            
            
        }
    }
    
    func verifyAndCreate() {
        if selectedMode == "Interval" {
            // Input Validation
            if repeats && intervalDuration < 60 {
                alertTitle = "Time Interval Must Be At Least 60"
                alertMessage = "You have toggled Repeats Continuously to be on. This requires the time interval duration to be at least 60 seconds. Please try again."
                showingErrorAlert = true
                return
            }
            
            // Add with interval trigger
            AppManager.addNotification(
                withNotificationModel: Notification(
                    id: UUID().uuidString,
                    title: title,
                    body: bodyText,
                    triggerIntervalDuration: Double(intervalDuration),
                    repeats: repeats
                )
            )
            dismiss()
        } else {
            // Add with datetime trigger
            AppManager.addNotification(
                withNotificationModel: Notification(
                    id: UUID().uuidString,
                    title: title,
                    body: bodyText,
                    triggerDatetime: triggerDatetime
                )
            )
            dismiss()
        }
    }
}

struct MoreInformationView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Q. What is a trigger configuration?")
                    .font(.title3.weight(.bold))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 30)
                Text("**Note that notifications will *not* appear when the app is open.**\n\nThere's two ways to configure how your notification gets triggered - date and time based or interval based.\n\nIn the date and time mode, set a specific date and time upon which your notification will be triggered and displayed in your notification center. You *cannot* repeat these types of notifications.\n\nIn the interval-based mode, you have to set a specific duration of seconds. Exactly that number of seconds after the creation of the notification, it will be triggered. This type of notification can be repeated continuously, but, the interval is required to be at least 60 seconds.")
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Help")
            .presentationDetents([.medium])
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(minHeight: 28)
                            .foregroundColor(.gray.opacity(0.6))
                    }
                }
            }
        }
    }
}

struct NewNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NewNotificationView(appManager: AppManager())
    }
}

struct MoreInformationView_Previews: PreviewProvider {
    static var previews: some View {
        MoreInformationView()
    }
}
