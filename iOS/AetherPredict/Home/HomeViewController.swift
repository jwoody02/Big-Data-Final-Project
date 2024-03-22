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
    private let lastUpdatedLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.alpha = 0
        return label
    }()
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "NaN°"
        label.font = .systemFont(ofSize: 50, weight: .regular)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 1
        label.alpha = 0
        return label
    }()
    private let conditionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        imageView.alpha = 0
        return imageView
    }()
    private let currentConditionsLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.textColor = .label
        label.numberOfLines = 2
        label.alpha = 0
        return label
    }()

    private let currentMetricsView: CurrentMetricsView = {
        let cmv = CurrentMetricsView()
        return cmv
    }()

    // reduce the amount of WeatherKit requests
    private var previousLocation: CLLocation? = nil
    
    // managers
    private let locationManager = CLLocationManager()
    private let weatherService = WeatherServiceWrapper.shared
    private let firePredictService = FirePredictService.shared

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Setup initial UI
        view.backgroundColor = .systemBackground
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
            self.lastUpdatedLabel.alpha = 1
            self.temperatureLabel.alpha = 1
            self.conditionImageView.alpha = 1
            self.currentConditionsLabel.alpha = 1
        }
    }
    private func setupUI() {
        lastUpdatedLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        conditionImageView.translatesAutoresizingMaskIntoConstraints = false
        currentConditionsLabel.translatesAutoresizingMaskIntoConstraints = false
        currentMetricsView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(lastUpdatedLabel)
        view.addSubview(temperatureLabel)
        view.addSubview(conditionImageView)
        view.addSubview(currentConditionsLabel)
        view.addSubview(currentMetricsView)

        NSLayoutConstraint.activate([
            lastUpdatedLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            lastUpdatedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            temperatureLabel.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 8),
            temperatureLabel.centerYAnchor.constraint(equalTo: conditionImageView.centerYAnchor, constant: 0),
            
            conditionImageView.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            conditionImageView.topAnchor.constraint(equalTo: lastUpdatedLabel.bottomAnchor, constant: 30),
            conditionImageView.widthAnchor.constraint(equalToConstant: 80),
            conditionImageView.heightAnchor.constraint(equalToConstant: 80),
            
            currentConditionsLabel.topAnchor.constraint(equalTo: conditionImageView.bottomAnchor, constant: 30),
            currentConditionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            currentConditionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            currentMetricsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentMetricsView.topAnchor.constraint(equalTo: currentConditionsLabel.bottomAnchor, constant: 20),

        ])
    }

    public func updateUIWith(currentForecast: CurrentWeather, minuteForcast: Forecast<MinuteWeather>?, hourForcast: Forecast<HourWeather>, dayWeather: Forecast<DayWeather>) {
        updateBasicWeatherInfo(with: currentForecast)
        updatePrecipitationEvents(with: hourForcast)
        updatePrecipitationForcast(with: minuteForcast)
        updateHourlyForcast(with: hourForcast)
        updateWeeklyForcast(with: dayWeather)
        animateInViews()
    }
    
    /**
        Updates the basic weather information such as temperature, condition, humidity, wind, etc
    */
    private func updateBasicWeatherInfo(with currentWeather: CurrentWeather) {
        let updatedAtTimestamp = currentWeather.date
        let temperatureObject = currentWeather.temperature // change this to .apparentTemperature for a 'feels like' temp
        let conditionDescription = currentWeather.condition.description
        let conditionImageName = currentWeather.symbolName
        let windSpeedObject = currentWeather.wind.speed
        let uvIndex = currentWeather.uvIndex
        
        // Convert temperature from Celsius to Fahrenheit
        let temperatureInCelsius = Measurement(value: temperatureObject.value, unit: UnitTemperature.celsius)
        let temperatureInFahrenheit = temperatureInCelsius.converted(to: .fahrenheit).value
        
        // Update temperature and condition labels
        temperatureLabel.text = String(format: "%.0f°", temperatureInFahrenheit)
        conditionImageView.image = UIImage(systemName: conditionImageName)
        currentConditionsLabel.text = conditionDescription
        lastUpdatedLabel.text = DateFormatter.localizedString(from: updatedAtTimestamp, dateStyle: .none, timeStyle: .short)


        // Update metrics
        currentMetricsView.setMetricValue(forKey: .fireRisk, value: "Low", iconName: "flame.fill", primaryColor: .systemGreen)
        currentMetricsView.setMetricValue(forKey: .uvIndex, value: "\(uvIndex.value)", iconName: "sun.max", primaryColor: .purple.withAlphaComponent(CGFloat((uvIndex.value + 2) / 10)))
        
        let roundedWindSpeed = Int(round(windSpeedObject.value))
        currentMetricsView.setMetricValue(forKey: .windSpeed, value: "\(roundedWindSpeed)mph", iconName: "wind", primaryColor: .systemGreen)
        
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
        @unknown default:
            break
        }

        
        currentMetricsView.setMetricValue(forKey: .precipitationChance, value: "\(String(preciptationChance * 100).replacingOccurrences(of: ".0", with: ""))%", iconName: precipitationLogo, primaryColor: .blue)
        currentMetricsView.setMetricValue(forKey: .precipitationAmount, value: "\(String(preciptationAmountObject?.precipitationAmount.value ?? 0))\"", iconName: "drop.fill", primaryColor: .blue)
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
        os_log(.info, "Received 'didUpdateLocations' message from CLLocationManager")

        // prevent multiple requests for the same location (reducing costs basically)
        if let previousLocation = previousLocation, previousLocation.coordinate.latitude == unwrappedLocation.coordinate.latitude && previousLocation.coordinate.longitude == unwrappedLocation.coordinate.longitude {
            os_log(.debug, "Ignoring 'didUpdateLocations' message as the current user's location is the same as last time")
            return
        }
        
        self.previousLocation = unwrappedLocation
        weatherService.fetchWeather(for: unwrappedLocation) { [weak self] result in
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
