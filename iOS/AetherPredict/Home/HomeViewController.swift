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
    // MARK: - UI
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Current Location"
        label.font = .nunito(ofSize: 18, weight: .medium)
        label.textAlignment = .left
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let currentWeatherCard: CurrentWeatherCard = {
        let cmv = CurrentWeatherCard()
        cmv.translatesAutoresizingMaskIntoConstraints = false
        return cmv
    }()

    // reduce the amount of WeatherKit requests
    private var previousLocation: CLLocation? = nil
    private var previousCity: String? = nil
    
    // managers
    private let locationManager = CLLocationManager()
    private let weatherService = WeatherServiceWrapper.shared
    private let firePredictService = FirePredictService.shared

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Setup initial UI
        view.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1.0)
        setupUI()

        // Request location
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.startUpdatingLocation()
    }
    
    private func animateInViews() {
        UIView.animate(withDuration: 0.3) {
            // TODO: forcast views
        }
    }
    private func setupUI() {

        view.addSubview(locationLabel)
        view.addSubview(currentWeatherCard)

        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            locationLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            locationLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            currentWeatherCard.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 10),
            currentWeatherCard.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            currentWeatherCard.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }
    
    func updateCache(currentWeather: CurrentWeather, locationString: String) {
//        UserDefaults.standard.set(locationString, forKey: "last_updated_location")
//        UserDefaults.standard.set(currentWeather, forKey: "last_updated_weather")
    }

    public func updateUIWith(currentForecast: CurrentWeather, minuteForcast: Forecast<MinuteWeather>?, hourForcast: Forecast<HourWeather>, dayWeather: Forecast<DayWeather>) {
        updateCache(currentWeather: currentForecast, locationString: "Current Location")
        currentWeatherCard.updateWith(currentForecast)
        // updatePrecipitationEvents(with: hourForcast)
        updatePrecipitationForcast(with: minuteForcast)
        updateHourlyForcast(with: hourForcast)
        updateWeeklyForcast(with: dayWeather)
        animateInViews()
    }
    

    
    /**
        Updates precipation labels and icons based on the current weather forecast
    */
    // private func updatePrecipitationEvents(with current: Forecast<HourWeather>) {
    //     let preciptationChance = current.forecast.first?.precipitationChance ?? 0.0
    //     let preciptationAmountObject = current.forecast.first
    //     let precipitationType = preciptationAmountObject?.precipitation ?? .none // none, hail, mixed, rain, sleet, snow
        
    //     // sf symbol to show
    //     var precipitationLogo = ""
    //     switch precipitationType {
    //         case .none:
    //             break
    //         case .hail:
    //             precipitationLogo = "cloud.hail"
    //             break
    //         case .mixed:
    //             precipitationLogo = "cloud.sleet"
    //             break
    //         case .rain:
    //             precipitationLogo = "umbrella.fill"
    //             break
    //         case .sleet:
    //             precipitationLogo = "cloud.sleet"
    //             break
    //         case .snow:
    //             precipitationLogo = "snowflake"
    //             break
    //     @unknown default:
    //         break
    //     }

        
    //     currentMetricsView.setMetricValue(forKey: .precipitationChance, value: "\(String(preciptationChance * 100).replacingOccurrences(of: ".0", with: ""))%", iconName: precipitationLogo, primaryColor: .blue)
    //     currentMetricsView.setMetricValue(forKey: .precipitationAmount, value: "\(String(preciptationAmountObject?.precipitationAmount.value ?? 0))\"", iconName: "drop.fill", primaryColor: .blue)
    // }
    
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


// delegate for getting current weather information
extension HomeViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let unwrappedLocation = manager.location else { return }
        
        os_log(.info, "Received 'didUpdateLocations' message from CLLocationManager")

        // prevent multiple requests for the same location (reducing costs basically)
        if let previousLocation = self.previousLocation, previousLocation.coordinate.latitude == unwrappedLocation.coordinate.latitude && previousLocation.coordinate.longitude == unwrappedLocation.coordinate.longitude {
            os_log(.debug, "Ignoring 'didUpdateLocations' message as the current user's location is the same as last time")
            return
        }
        
        // prevent multiple requests from same city
        unwrappedLocation.fetchCityAndCountry { [weak self] city, _, error in
            guard let city = city, error == nil, let self = self else { return }
            
            if self.previousCity ?? "" == city {
                os_log(.debug, "Ignoring 'didUpdateLocations' message as the user's city is same as before")
                return
            }
            
            self.previousLocation = unwrappedLocation
            self.previousCity = city
            self.locationLabel.text = city
            
            self.weatherService.fetchWeather(for: unwrappedLocation) { [weak self] result in
                // prevent memory leak
                guard let self = self else { return }
                
                // Update ui for weather object
                switch result {
                case .success(let (current, minute, hourly, daily)):
                    os_log(.info, "Updating UI with weather information")
                    DispatchQueue.main.async {
                        self.updateUIWith(currentForecast: current, minuteForcast: minute, hourForcast: hourly, dayWeather: daily)
                    }
                    break
                case .failure(let error):
                    os_log(.error, "Error fetching weather: %@", error.localizedDescription)
                    
                    // show error to user
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "Failed to fetch weather data.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    break
                }
            }
        }
        
    }
}

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}
