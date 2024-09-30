//
//  Token.swift
//  CloudDoor
//
//  Created by dean on 30. 9. 24.
//
import SwiftUI

struct TokenResponse: Decodable {
    var access_token: String
}

struct Location: Decodable, Identifiable {
    var name: String
    var id: String
}

struct GetUserLocationsResponse: Decodable {
    var result: [Location]
}

struct OpenDoorResponseResult: Decodable {
    var id: String
}

struct OpenDoorResponse: Decodable {
    var result: OpenDoorResponseResult
}

enum ApiError: Error {
    case runtimeError(String)
}

class API {
    let url: String
    let username: String
    let password: String

    init(url: String, username: String, password: String) {
        self.url = url
        self.username = username
        self.password = password
    }
    
    static func initFromConfiguration(configuration: Configuration) -> API {
        let values = configuration.get()
        return API(url: values.hostname, username: values.username, password: values.password)
    }
    
    private func request(method: String, path: String, contentType: String?, data: String?, token: String?) async throws -> Data {
        let url = URL(string: "\(self.url)\(path)")!
        var request = URLRequest(url: url)
        
        if let contentType = contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.httpMethod = method
        
        if let data = data {
            request.httpBody = data.data(using: String.Encoding.utf8)
        }
        
        let (returnedData, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode != 200 {
                throw ApiError.runtimeError("Response failed with '\(httpResponse.statusCode)': \(returnedData)")
            }
        } else {
            throw ApiError.runtimeError("Response failed without status code: \(returnedData)")
        }
        
        return returnedData
    }

    func getToken() async throws -> String {
        let data = "client_id=DoorCloudWebApp&grant_type=password&username=\(username)&password=\(password)"
        let response = try await self.request(method: "POST", path: "/token", contentType: "application/x-www-form-urlencoded", data: data, token: nil)
        
        do {
            let decoded = try JSONDecoder().decode(TokenResponse.self, from: response)
            return decoded.access_token
        } catch {
            print("Unexpected error: \(error).")
            throw error
        }
    }
    
    func getLocations(token: String) async throws -> [Location] {
        let response = try await self.request(method: "GET", path: "/api/Location/GetUserLocations", contentType: nil, data: nil, token: token)

        do {
            let decoded = try JSONDecoder().decode(GetUserLocationsResponse.self, from: response)
            return decoded.result
        } catch {
            print("Unexpected error: \(error).")
            throw error
        }
    }
    
    func openDoor(token: String, accessPointId: String) async throws -> OpenDoorResponse {
        let data = "accessPointId=\(accessPointId)"
        let response = try await self.request(method: "POST", path: "/api/Location/OpenDoorOnLocation", contentType: nil, data: data, token: token)

        do {
            return try JSONDecoder().decode(OpenDoorResponse.self, from: response)
        } catch {
            print("Unexpected error: \(error).")
            throw error
        }
    }
}
