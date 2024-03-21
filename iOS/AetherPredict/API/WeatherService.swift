//
//  WeatherService.swift
//  AetherPredict
//
//  Created by Jordan Wood on 3/14/24.
//
import Foundation
import WeatherKit
import CoreLocation

public class WeatherServiceWrapper {

    public static let shared = WeatherServiceWrapper()

    private let weatherService = WeatherService()

    private init() {}

    // Fetch weather for a specified city or location name
    public func fetchWeatherForLocation(named locationName: String, completion: @escaping (Result<(CurrentWeather, Forecast<MinuteWeather>?, Forecast<HourWeather>, Forecast<DayWeather>), Error>) -> Void) {
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

    // Fetch weather for a CLLocation
    public func fetchWeather(for location: CLLocation, completion: @escaping (Result<(CurrentWeather, Forecast<MinuteWeather>?, Forecast<HourWeather>, Forecast<DayWeather>), Error>) -> Void) {
        Task {
            do {
                let (current, minute, hourly, daily) = try await weatherService.weather(for: location, including: .current, .minute, .hourly, .daily)
                completion(.success((current, minute, hourly, daily)))
            } catch {
                completion(.failure(error))
            }
        }
    }

}
