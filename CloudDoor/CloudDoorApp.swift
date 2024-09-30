//
//  CloudDoorApp.swift
//  CloudDoor
//
//  Created by dean on 29. 9. 24.
//

import SwiftUI

@main
struct CloudDoorApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("Doors", systemImage: "door.french.closed")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
    }
}
