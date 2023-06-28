//
//  OnlySelfFansApp.swift
//  OnlySelfFans
//
//  Created by Prakhar Trivedi on 25/6/23.
//

import SwiftUI

@main
struct OnlySelfFansApp: App {
    
    private var delegate: UserNotificationDelegate = UserNotificationDelegate()
    
    init() {
        let center = UNUserNotificationCenter.current()
        center.delegate = delegate
        center.requestAuthorization(options: [.alert, .sound, .badge]) { result, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
