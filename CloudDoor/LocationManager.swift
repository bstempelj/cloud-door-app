//
//  LocationManager.swift
//  CloudDoor
//
//  Created by dean on 30. 9. 24.
//

import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var placemark: CLPlacemark?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.startUpdatingLocation()
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        self.location = location
        
        self.reverseGeocode()
    }
    
    private func reverseGeocode() {
        if let location = self.location {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location,
                                            completionHandler: { (placemarks, error) in
                if error == nil {
                    self.placemark = placemarks?[0]
                }
                else {
                    self.placemark = nil
                }
            })
        }
    }
}
