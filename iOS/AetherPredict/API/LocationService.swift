//
//  LocationService.swift
//  AetherPredict
//
//  Created by Jordan Wood on 3/14/24.
//

import Foundation
import CoreLocation

public class LocationService: NSObject, CLLocationManagerDelegate {
    
    public static let shared = LocationService()
    private let locationManager = CLLocationManager()
    private var locationCompletion: ((Result<CLLocation, Error>) -> Void)?
    
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // Request location authorization and pass back response
    public func requestAuthorizationAndGetCurrentLocation(completion: @escaping (Result<CLLocation, Error>) -> Void) {
        self.locationCompletion = completion
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            completion(.failure(NSError(domain: "LocationService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location services are not enabled."])))
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation()
            locationCompletion?(.success(location))
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        locationCompletion?(.failure(error))
    }
    
    // Fetch location using IP address via the ip-api (that way user may not have to provide access to location however maybe we shouldnt use)
    public func getLocationByIPAddress(completion: @escaping (Result<CLLocation, Error>) -> Void) {
        guard let url = URL(string: "http://ip-api.com/json/?fields=lat,lon") else {
            completion(.failure(NSError(domain: "LocationService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid API endpoint."])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "LocationService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid response from API."])))
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let latitude = json?["lat"] as? CLLocationDegrees, let longitude = json?["lon"] as? CLLocationDegrees {
                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    DispatchQueue.main.async {
                        completion(.success(location))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "LocationService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Could not parse JSON."])))
                    }
                }
            } catch let error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
