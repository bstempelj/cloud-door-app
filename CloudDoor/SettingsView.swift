//
//  SettingsView.swift
//  CloudDoor
//
//  Created by dean on 30. 9. 24.
//

import SwiftUI

struct SettingsView: View {
    @State private var username: String
    @State private var password: String
    @State private var hostname: String
    let configuration = Configuration()
    
    init() {
        let values = configuration.get()
        self.username = values.username
        self.password = values.password
        self.hostname = values.hostname
    }

    var body: some View {
        VStack {
            Form {
                LabeledContent {
                    TextField(text: $username) {
                        Text("User name (email)")
                    }
                } label: {
                  Text("User name")
                }.keyboardType(UIKeyboardType.emailAddress)
                LabeledContent {
                    SecureField(text: $password) {
                        Text("Password")
                    }
                } label: {
                  Text("Password")
                }
                LabeledContent {
                    TextField(text: $hostname) {
                        Text("Hostname")
                    }
                } label: {
                  Text("Hostname")
                }
                Button("Test & update") {
                    Task {
                        let api = API(url: self.hostname, username: username, password: password)
                        
                        do {
                            let _ = try await api.getToken()
                            
                            configuration.set(username: username, password: password, hostname: hostname)
                        } catch {
                            print("Error: \(error).")
                        }
                    }
                }
            }
            
            Button("Reset to production host") {
                self.hostname = "https://api.doorcloud.com"
            }
            Button("Reset to test host") {
                self.hostname = "http://192.168.0.222:1323"
            }
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
