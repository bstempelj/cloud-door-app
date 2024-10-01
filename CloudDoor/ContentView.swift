//
//  ContentView.swift
//  CloudDoor
//
//  Created by dean on 29. 9. 24.
//

import CoreLocation
import SwiftUI

struct ContentView: View {
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var showAlert = false
    @State var locations: [LocationWithDistance] = []
    
    @ObservedObject var locationManager = LocationManager()
    
    func refresh() {
        Task {
            do {
                let api = API.initFromConfiguration(configuration: Configuration())
                let token = try await api.getToken()
                let locations = try await api.getLocations(token: token)
                
                self.locations = getLocationsWithDistance(locations: locations, distanceToLocation: locationManager.location)
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
                    Text("\(index.location.name) \(optionalDistanceToString(distance: index.distance))").foregroundStyle(index.inRadius ? .black : .gray)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onReceive(locationManager.$location) { value in
                    let rawLocations = self.locations.map { $0.location }
                    self.locations = getLocationsWithDistance(locations: rawLocations, distanceToLocation: value)
                }
                .onTapGesture {
                    if let distance = index.distance {
                        let radius = index.location.geolocations[0].radius
                        if distance > radius {
                            alertTitle = "Error"
                            alertMessage = "Door '\(index.location.name)' too far away (\(distance)m > \(radius)m)"
                            showAlert = true
                        } else {
                            Task {
                                do {
                                    let api = API.initFromConfiguration(configuration: Configuration())
                                    let token = try await api.getToken()
                                    let _ = try await api.openDoor(token: token, accessPointId: index.id)
                                    
                                    alertTitle = "Success"
                                    alertMessage = "Door '\(index.location.name)' opened"
                                    showAlert = true
                                } catch {
                                    alertTitle = "Error"
                                    alertMessage = "\(error)"
                                    showAlert = true
                                }
                            }
                        }
                    } else {
                        alertTitle = "Error"
                        alertMessage = "Cannot open door, since location of the device is not known"
                        showAlert = true
                    }
                }
            }
            if let placemark = locationManager.placemark {
                Text("Location: \(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? ""), \(placemark.locality ?? "")")
            } else {
                Text("Location: unknown")
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
