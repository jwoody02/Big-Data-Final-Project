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
        updatePrecipitationEvents(with: hourForcast)
        updatePrecipitationForcast(with: minuteForcast)
        updateHourlyForcast(with: hourForcast)
        updateWeeklyForcast(with: dayWeather)
    }
    
    /**
        Updates the basic weather information such as temperature, condition, humidity, wind, etc
    */
    private func updateBasicWeatherInfo(with currentWeather: CurrentWeather) {
        let updatedAtTimestamp = currentWeather.date
        let temperatureObject = currentWeather.temperature // change this to .apparentTemperature for a 'feels like' temp
        let conditionDescription = currentWeather.condition.description
        let conditionImageName = currentWeather.symbolName
        let humidityValue = currentWeather.humidity
        let windSpeedObject = currentWeather.wind.speed
        let uvIndex = currentWeather.uvIndex
        
        // TODO: - Update temperature, condition icon, humidity, wind, etc
    }
    
    /**
        Updates precipation labels and icons based on the current weather forecast
    */
    private func updatePrecipitationEvents(with current: Forecast<HourWeather>) {
        let preciptationChance = current.forecast.first?.precipitationChance ?? 0.0
        let preciptationAmountObject = current.forecast.first
        let precipitationType = preciptationAmountObject?.precipitation ?? .none // none, hail, mixed, rain, sleet, snow
        
        // sf symbol to show
        var precipitationLogo = ""
        switch precipitationType {
            case .none:
                break
            case .hail:
                precipitationLogo = "cloud.hail"
                break
            case .mixed:
                precipitationLogo = "cloud.sleet"
                break
            case .rain:
                precipitationLogo = "umbrella.fill"
                break
            case .sleet:
                precipitationLogo = "cloud.sleet"
                break
            case .snow:
                precipitationLogo = "snowflake"
                break

        }


        // TODO: - Update for 'raining' 'snow' and other events
    }
    
    /**
        Updates the minute by minute precipitation forcast for the next hour
    */
    private func updatePrecipitationForcast(with: Forecast<MinuteWeather>?) {
        // TODO: - minute by minute rain forcast for next hour under the temperature
    }

    /**
        Updates the hourly forcast for the next 24 hours
    */
    private func updateHourlyForcast(with: Forecast<HourWeather>) {
    }


    /**
        Updates the daily forcast for the next 7 days
    */
    private func updateWeeklyForcast(with: Forecast<DayWeather>) {
        // TODO: - weekly forecast?
    }
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
