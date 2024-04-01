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
        let defaultConfiguration = UIImage.SymbolConfiguration(paletteColors: [.secondaryLabel])
        
        switch systemName {
        case "sun.max.fill":
            // Sunny: Sun is yellow
            return UIImage.SymbolConfiguration(paletteColors: [.yellow])
        case "cloud.fill", "cloud":
            // Cloudy: Cloud is light gray
            return UIImage.SymbolConfiguration(paletteColors: [.lightGray])
        case "cloud.drizzle.fill", "cloud.rain.fill":
            // Rain: Cloud is light gray, raindrops are blue
            return UIImage.SymbolConfiguration(paletteColors: [.lightGray, .blue])
        case "cloud.bolt.rain.fill":
            // Thunderstorm: Cloud is dark gray, lightning is yellow, rain is blue
            return UIImage.SymbolConfiguration(paletteColors: [.darkGray, .yellow, .blue])
        case "cloud.snow.fill", "snow":
            // Snow: Cloud is light gray, snowflakes are white
            return UIImage.SymbolConfiguration(paletteColors: [.lightGray, .white])
        case "cloud.fog.fill":
            // Fog: Cloud is light gray (considering white background)
            return UIImage.SymbolConfiguration(paletteColors: [.lightGray])
        case "thermometer.sun.fill":
            // Hot temperature: Thermometer mercury is red, sun is yellow
            return UIImage.SymbolConfiguration(paletteColors: [.red, .yellow])
        case "moon.stars.fill":
            // Clear night: Moon is light yellow, stars are white
            return UIImage.SymbolConfiguration(paletteColors: [.yellow, .white])
        // Add more conditions as needed
        default:
            return defaultConfiguration
        }
    }
}
