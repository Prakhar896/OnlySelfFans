//
//  Models.swift
//  OnlySelfFans
//
//  Created by Prakhar Trivedi on 26/6/23.
//

import Foundation

struct AppManager {
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
}

struct Notification: Codable {
    var title: String
    var body: String
}
