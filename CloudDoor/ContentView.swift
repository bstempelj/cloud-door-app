//
//  ContentView.swift
//  CloudDoor
//
//  Created by dean on 29. 9. 24.
//

import SwiftUI

struct ContentView: View {
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var showAlert = false
    @State var locations: [Location] = []
    
    func refresh() {
        Task {
            do {
                let api = API.initFromConfiguration(configuration: Configuration())
                let token = try await api.getToken()
                self.locations = try await api.getLocations(token: token)
            } catch {
                alertTitle = "Error"
                alertMessage = "\(error)"
                showAlert = true
            }
        }
    }

    var body: some View {
        VStack {
            List(locations) { index in
                HStack {
                    Text(index.name)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    Task {
                        do {
                            let api = API.initFromConfiguration(configuration: Configuration())
                            let token = try await api.getToken()
                            let _ = try await api.openDoor(token: token, accessPointId: index.id)
                            
                            alertTitle = "Success"
                            alertMessage = "Door '\(index.name)' opened"
                            showAlert = true
                        } catch {
                            alertTitle = "Error"
                            alertMessage = "\(error)"
                            showAlert = true
                        }
                    }
                }
            }
            Button("Refresh") {
                refresh()
            }
        }
        .padding()
        .onAppear {
            refresh()
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text(self.alertTitle), message: Text(self.alertMessage), dismissButton: .default(Text("OK")))
        })
    }
}

#Preview {
    ContentView()
}
