//
//  WeatherService.swift
//  AetherPredict
//
//  Created by Jordan Wood on 3/14/24.
//

import Foundation
import WeatherKit


public class WeatherService {

    public static let shared = WeatherService()

    private let weatherKit = Weather
    private let locationService = LocationService.shared

}
