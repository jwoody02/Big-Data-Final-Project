//
//  WeatherSymbolConfigurationManager.swift
//  AetherPredict
//
//  Created by Jordan Wood on 3/31/24.
//

import Foundation
import UIKit

class WeatherSymbolConfigurationManager {
    
    static func configuration(forCondition systemName: String) -> UIImage.SymbolConfiguration {
        let defaultConfiguration = UIImage.SymbolConfiguration(paletteColors: [.customGray])
        
        switch systemName {
        case "sun.max.fill":
            // Sunny: Sun is yellow
            return UIImage.SymbolConfiguration(paletteColors: [.orangishYellow])
        case "cloud.fill", "cloud":
            // Cloudy: Cloud is light gray
            return UIImage.SymbolConfiguration(paletteColors: [.customGray])
        case "cloud.drizzle.fill", "cloud.rain.fill":
            // Rain: Cloud is light gray, raindrops are blue
            return UIImage.SymbolConfiguration(paletteColors: [.customGray, .rainColor])
        case "cloud.bolt.rain.fill":
            // Thunderstorm: Cloud is dark gray, lightning is yellow, rain is blue
            return UIImage.SymbolConfiguration(paletteColors: [.darkGray, .orangishYellow, .rainColor])
        case "cloud.snow.fill", "snow":
            // Snow: Cloud is light gray, snowflakes are white
            return UIImage.SymbolConfiguration(paletteColors: [.customGray, .primaryTint])
        case "cloud.fog.fill":
            // Fog: Cloud is light gray (considering white background)
            return UIImage.SymbolConfiguration(paletteColors: [.customGray])
        case "thermometer.sun.fill":
            // Hot temperature: Thermometer mercury is red, sun is yellow
            return UIImage.SymbolConfiguration(paletteColors: [.red, .orangishYellow])
        case "moon.stars.fill":
            // Clear night: Moon is light yellow, stars are white
            return UIImage.SymbolConfiguration(paletteColors: [.primaryTint])
        case "cloud.sun.fill":
            // Partly Cloudy Day: Sun is yellow, cloud is light gray
            return UIImage.SymbolConfiguration(paletteColors: [.customGray, .orangishYellow])
        case "wind":
            // Wind: Wind symbol is light gray
            return UIImage.SymbolConfiguration(paletteColors: [.customGray])
        case "smoke.fill":
            // Smoke/Haze: Smoke is light gray
            return UIImage.SymbolConfiguration(paletteColors: [.customGray])
        case "tornado":
            // Tornado: Tornado is dark gray
            return UIImage.SymbolConfiguration(paletteColors: [.customGray])
        case "hurricane":
            // Hurricane: Hurricane symbol is dark blue
            return UIImage.SymbolConfiguration(paletteColors: [.rainColor])
        case "cloud.hail.fill":
            // Hail: Cloud is light gray, hailstones are white
            return UIImage.SymbolConfiguration(paletteColors: [.customGray, .primaryTint])
        default:
            return defaultConfiguration
        }
    }
}
