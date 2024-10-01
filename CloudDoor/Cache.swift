//
//  Cache.swift
//  CloudDoor
//
//  Created by dean on 1. 10. 24.
//
import SwiftUI

// Gracefully store/retrieve data from persistent cache.
class Cache {
    let cachedLocationsKey = "v1-cachedLocations"
    
    private func retrieve<T: Decodable>(key: String) -> T? {
        if let value = UserDefaults.standard.value(forKey: key) {
            if let value = value as? Data {
                let decoder = JSONDecoder()
             
                do {
                    return try decoder.decode(T.self, from: value)
                } catch {
                    print("Non-critical error: \(error).")
                }
            }
        }
        
        return nil
    }
    
    private func store<T: Encodable>(key: String, obj: T) {
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(obj)
            UserDefaults.standard.set(data, forKey: cachedLocationsKey)
        } catch {
            print("Non-critical error: \(error).")
        }
    }

    func getCachedLocations() -> [Location]? {
        self.retrieve(key: cachedLocationsKey)
    }
    
    func setCachedLocations(locations: [Location]) {
        self.store(key: cachedLocationsKey, obj: locations)
    }
}
