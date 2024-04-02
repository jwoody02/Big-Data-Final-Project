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
