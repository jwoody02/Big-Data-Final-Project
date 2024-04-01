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
    public let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Current Location"
        label.font = .nunito(ofSize: 18, weight: .medium)
        label.textAlignment = .left
        label.textColor = .primaryTint
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let currentWeatherCard: CurrentWeatherCard = {
        let cmv = CurrentWeatherCard()
        cmv.translatesAutoresizingMaskIntoConstraints = false
        return cmv
    }()
    
    private let hourlyForcastView: HourlyForecastCollectionView = {
        let hfv = HourlyForecastCollectionView()
        hfv.translatesAutoresizingMaskIntoConstraints = false
        return hfv
    }()
    
    private let weeklyForcastView: WeeklyForecastCollectionView = {
        let wfv = WeeklyForecastCollectionView()
        wfv.translatesAutoresizingMaskIntoConstraints = false
        return wfv
    }()

    // reduce the amount of WeatherKit requests
    var previousLocation: CLLocation? = nil
    var previousCity: String? = nil
    
    // managers
    let locationManager = CLLocationManager()
    let weatherService = WeatherServiceWrapper.shared
    private let firePredictService = FirePredictService.shared

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Setup initial UI
        view.backgroundColor = .backgroundColor
        setupUI()

        // Request location
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        manager.startUpdatingLocation()
    }
    
    private func setupUI() {

        view.addSubview(locationLabel)
        view.addSubview(currentWeatherCard)
        view.addSubview(hourlyForcastView)
        view.addSubview(weeklyForcastView)

        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            locationLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            locationLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            currentWeatherCard.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 20),
            currentWeatherCard.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            currentWeatherCard.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            hourlyForcastView.topAnchor.constraint(equalTo: currentWeatherCard.bottomAnchor, constant: 10),
            hourlyForcastView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            hourlyForcastView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            hourlyForcastView.heightAnchor.constraint(equalToConstant: CGFloat(WeatherCollectionViewCell.HOURLY_FORECAST_HEIGHT)),
            
            weeklyForcastView.topAnchor.constraint(equalTo: hourlyForcastView.bottomAnchor, constant: 10),
            weeklyForcastView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            weeklyForcastView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            weeklyForcastView.heightAnchor.constraint(equalToConstant: CGFloat(WeeklyForecastCollectionView.DAY_FORCAST_COUNT))
        ])
    }
    

    public func updateUIWith(currentForecast: CurrentWeather, minuteForcast: Forecast<MinuteWeather>?, hourForcast: Forecast<HourWeather>, dayWeather: Forecast<DayWeather>) {
        currentWeatherCard.updateWith(currentForecast)
        hourlyForcastView.update(with: Array(hourForcast.forecast.filter { forecast in
            let forecastDate = forecast.date
            return forecastDate >= Date() && forecastDate <= Calendar.current.date(byAdding: .hour, value: 24, to: Date())!
        }))
    }
}
