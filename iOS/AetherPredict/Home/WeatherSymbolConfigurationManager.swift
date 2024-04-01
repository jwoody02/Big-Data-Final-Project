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
        let defaultConfiguration = UIImage.SymbolConfiguration(paletteColors: [.systemGray5])
        
        switch systemName {
        case "sun.max.fill":
            // Sunny: Sun is yellow
            return UIImage.SymbolConfiguration(paletteColors: [.orangishYellow])
        case "cloud.fill", "cloud":
            // Cloudy: Cloud is light gray
            return UIImage.SymbolConfiguration(paletteColors: [.systemGray5])
        case "cloud.drizzle.fill", "cloud.rain.fill":
            // Rain: Cloud is light gray, raindrops are blue
            return UIImage.SymbolConfiguration(paletteColors: [.systemGray5, .cyan])
        case "cloud.bolt.rain.fill":
            // Thunderstorm: Cloud is dark gray, lightning is yellow, rain is blue
            return UIImage.SymbolConfiguration(paletteColors: [.darkGray, .orangishYellow, .cyan])
        case "cloud.snow.fill", "snow":
            // Snow: Cloud is light gray, snowflakes are white
            return UIImage.SymbolConfiguration(paletteColors: [.systemGray5, .primaryTint])
        case "cloud.fog.fill":
            // Fog: Cloud is light gray (considering white background)
            return UIImage.SymbolConfiguration(paletteColors: [.systemGray5])
        case "thermometer.sun.fill":
            // Hot temperature: Thermometer mercury is red, sun is yellow
            return UIImage.SymbolConfiguration(paletteColors: [.red, .orangishYellow])
        case "moon.stars.fill":
            // Clear night: Moon is light yellow, stars are white
            return UIImage.SymbolConfiguration(paletteColors: [.primaryTint])
        case "cloud.sun.fill":
            // Partly Cloudy Day: Sun is yellow, cloud is light gray
            return UIImage.SymbolConfiguration(paletteColors: [.systemGray5, .orangishYellow])
        case "wind":
            // Wind: Wind symbol is light gray
            return UIImage.SymbolConfiguration(paletteColors: [.systemGray4])
        case "smoke.fill":
            // Smoke/Haze: Smoke is light gray
            return UIImage.SymbolConfiguration(paletteColors: [.systemGray3])
        case "tornado":
            // Tornado: Tornado is dark gray
            return UIImage.SymbolConfiguration(paletteColors: [.darkGray])
        case "hurricane":
            // Hurricane: Hurricane symbol is dark blue
            return UIImage.SymbolConfiguration(paletteColors: [.cyan])
        case "cloud.hail.fill":
            // Hail: Cloud is light gray, hailstones are white
            return UIImage.SymbolConfiguration(paletteColors: [.systemGray5, .primaryTint])
        default:
            return defaultConfiguration
        }
    }
}
