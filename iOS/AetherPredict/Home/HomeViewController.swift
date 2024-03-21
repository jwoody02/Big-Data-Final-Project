//
//  HomeViewController.swift
//  AetherPredict
//
//  Created by Jordan Wood on 3/14/24.
//

import Foundation
import UIKit
import CoreLocation
import WeatherKit
import os.log

public class HomeViewController: UIViewController {
    
    // reduce the amount of WeatherKit requests
    private var previousLocation: CLLocation? = nil
    
    // managers
    private let locationManager = CLLocationManager()
    private let weatherService = WeatherServiceWrapper.shared
    private let firePredictService = FirePredictService.shared

    public override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: - Setup UI + Constraints
        
        
        // Ask for Authorisation from the User for access to location
        self.locationManager.requestWhenInUseAuthorization()

        // Request location
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        
    }
    public func updateUIWith(currentForecast: CurrentWeather, minuteForcast: Forecast<MinuteWeather>?, hourForcast: Forecast<HourWeather>, dayWeather: Forecast<DayWeather>) {
        updateBasicWeatherInfo(with: currentForecast)
        updateSpecialEvents(with: currentForecast)
//        updateRainForcast(with: object)
    }
    
    private func updateBasicWeatherInfo(with currentWeather: CurrentWeather) {
        let weatherDate = currentWeather.date // basically same as just doing Date(), maybe remove?
        let temperatureObject = currentWeather.temperature // change this to .apparentTemperature for 'feels like' temp
        let conditionDescription = currentWeather.condition.description
        let conditionImageName = currentWeather.symbolName
        let humidityValue = currentWeather.humidity
        let windObject = currentWeather.wind
        let uvIndex = currentWeather.uvIndex
        
        // add more as necessary
        
        // TODO: - Update temperature, condition icon, humidity, wind, etc
    }
    
    private func updateSpecialEvents(with current: CurrentWeather) {
        // TODO: - Update for 'raining' 'fire' and other events
    }
    
    private func updateRainForcast(with: Weather) {
        // TODO: - minute by minute rain forcast for next hour under the temperature
    }
    
    private func updateWeeklyForcast(with: Weather) {
        // TODO: - weekly forecast?
    }
    
    // TODO: - Maybe an hourly temperature forcast?
}

extension HomeViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let unwrappedLocation = manager.location else { return }
        os_log(.info, "Received 'didUpdateLocations' message from CLLocationManaager")

        // prevent multiple requests for the same location (reducing costs basically)
        if let previousLocation = previousLocation, previousLocation.coordinate.latitude == unwrappedLocation.coordinate.latitude && previousLocation.coordinate.longitude == unwrappedLocation.coordinate.longitude {
            os_log(.debug, "Ignoring 'didUpdateLocations' message as the current user's location is the same as last time")
            return
        }
        
        weatherService.fetchWeather(for: unwrappedLocation) { [weak self] result in
            // prevent memory leak
            guard let self = self else { return }
            
            // Update ui for weather object
            switch result {
            case .success(let (current, minute, hourly, daily)):
                os_log(.info, "Updating UI with weather information")
                self.updateUIWith(currentForecast: current, minuteForcast: minute, hourForcast: hourly, dayWeather: daily)
                break
            case .failure(let error):
                os_log(.error, "Error fetching weather: %@", error.localizedDescription)
                
                // show error to user
                let alert = UIAlertController(title: "Error", message: "Failed to fetch weather data.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            }
        }
    }
}
