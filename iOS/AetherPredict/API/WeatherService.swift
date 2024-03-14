//
//  WeatherService.swift
//  AetherPredict
//
//  Created by Jordan Wood on 3/14/24.
//
import Foundation
import WeatherKit
import CoreLocation

public class WeatherService {

    public static let shared = WeatherService()

    private let weatherService = WeatherService()
    private let locationService = LocationService.shared

    private init() {}

    // Fetch weather for the current location
    public func fetchCurrentLocationWeather(completion: @escaping (Result<Weather, Error>) -> Void) {
        locationService.getCurrentLocation { [weak self] result in
            switch result {
            case .success(let location):
                self?.fetchWeather(for: location, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // Fetch weather for a specified city or zipcode
    public func fetchWeatherForLocation(named locationName: String, completion: @escaping (Result<Weather, Error>) -> Void) {
        CLGeocoder().geocodeAddressString(locationName) { [weak self] (placemarks, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let location = placemarks?.first?.location else {
                completion(.failure(NSError(domain: "WeatherService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to find location"])))
                return
            }
            self?.fetchWeather(for: location, completion: completion)
        }
    }

    private func fetchWeather(for location: CLLocation, completion: @escaping (Result<Weather, Error>) -> Void) {
        weatherService.weather(for: location.coordinate, including: [.current, .hourly, .daily]) { result in
            switch result {
            case .success(let weather):
                completion(.success(weather))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
