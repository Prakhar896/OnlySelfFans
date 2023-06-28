//
//  NewNotificationView.swift
//  OnlySelfFans
//
//  Created by Prakhar Trivedi on 27/6/23.
//

import SwiftUI

struct NewNotificationView: View {
    @ObservedObject var appManager: AppManager
    
    @State var title: String = ""
    @State var bodyText: String = ""
    
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
            }
            .navigationTitle("New Notification")
        }
    }
}

struct NewNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NewNotificationView(appManager: AppManager())
    }
}
