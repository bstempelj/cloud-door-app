//
//  SettingsView.swift
//  CloudDoor
//
//  Created by dean on 30. 9. 24.
//

import SwiftUI

struct SettingsView: View {
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var showAlert = false
    
    @State private var username: String
    @State private var password: String
    @State private var hostname: String
    
    let productionHost = "https://api.doorcloud.com"
    let configuration = Configuration()
    
    init() {
        let values = configuration.get()
        self.username = values.username
        self.password = values.password
        self.hostname = values.hostname == "" ? self.productionHost : values.hostname
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    LabeledContent {
                        TextField("", text: $username, prompt: Text("required"))
                            .keyboardType(UIKeyboardType.emailAddress)
                            .autocapitalization(.none)
                    } label: {
                        Text("Email")
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent {
                        SecureField("", text: $password, prompt: Text("required"))
                    } label: {
                        Text("Password")
                            .foregroundStyle(.secondary)
                    }

                    LabeledContent {
                        TextField("", text: $hostname, prompt: Text("required"))
                            .autocapitalization(.none)
                    } label: {
                        Text("Hostname")
                            .foregroundStyle(.secondary)
                    }
                }

                Button("Test & update") {
                    Task {
                        let api = API(url: self.hostname, username: username, password: password)
                        
                        do {
                            let _ = try await api.getToken()
                            
                            configuration.set(username: username, password: password, hostname: hostname)
                            
                            alertTitle = "Success"
                            alertMessage = "Configuration saved."
                            showAlert = true
                        } catch {
                            alertTitle = "Error"
                            alertMessage = "\(error)"
                            showAlert = true
                        }
                    }
                }

                Section(header: Text("Debug")) {
                    Button("Reset to production host") {
                        self.hostname = self.productionHost
                    }
                    Button("Reset values to test configuration") {
                        self.username = "user@example.com"
                        self.password = "password"
                        self.hostname = "https://cloud-door-mock.test.dejanlevec.com"
                    }
                }
            }
            .navigationTitle("Settings")
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .default(Text("OK")))
            })
        }
    }
}

#Preview {
    SettingsView()
}
