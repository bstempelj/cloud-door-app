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
    @State var showAlertWithCancel = false

    @State private var username: String
    @State private var password: String
    @State private var hostname: String
    
    let testingHost = "https://cloud-door-mock.test.dejanlevec.com"
    let productionHost = "https://api.doorcloud.com"
    let configuration = Configuration()
    
    init() {
        let values = configuration.get()
        self.username = values.username
        self.password = values.password
        self.hostname = values.hostname == "" ? self.productionHost : values.hostname
    }

    func fillTestAccountInfo() {
        self.username = "user@example.com"
        self.password = "password"
        self.hostname = testingHost
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
                        alertTitle = "Warning"
                        alertMessage = "You are about to replace existing account info with test account info."
                        showAlertWithCancel = true
                    }
                }
            }
            .navigationTitle("Settings")
            .alert(alertTitle, isPresented: $showAlertWithCancel, actions: {
                Button("Cancel", role: .cancel) {}
                Button("OK", role: .destructive) {
                    fillTestAccountInfo()
                }
            }, message: {
                Text(alertMessage)
            })
            .alert(alertTitle, isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(alertMessage)
            })
        }
    }
}

#Preview {
    SettingsView()
}
