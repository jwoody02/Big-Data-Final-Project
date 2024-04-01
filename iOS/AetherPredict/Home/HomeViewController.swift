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

public class HomeViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    // This label will be shown fixed at the top when original locationLabel is scrolled out of view
    private let floatingLocationLabel: UILabel = {
        let label = UILabel()
        label.font = .nunito(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.textColor = .primaryTint
        label.numberOfLines = 1
        label.isHidden = true // Initially hidden
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

    private let searchButton: UIButton = {
    let button = UIButton()
    let icon = UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate)
    button.setImage(icon, for: .normal)
    button.tintColor = .primaryTint
        button.contentMode = .scaleAspectFit
        button.imageView?.contentMode = .scaleAspectFit
    button.translatesAutoresizingMaskIntoConstraints = false
    button.contentHorizontalAlignment = .right
    button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
    return button
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
        
        // Add and setup the scrollView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.delegate = self
        
        // Floating label setup
        view.addSubview(floatingLocationLabel)
        
        // Add subviews to contentView instead of view
        contentView.addSubview(locationLabel)
        contentView.addSubview(searchButton)
        contentView.addSubview(currentWeatherCard)
        contentView.addSubview(hourlyForcastView)
        contentView.addSubview(weeklyForcastView)
        
        // ScrollView constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        
        // Floating Location Label constraints
        NSLayoutConstraint.activate([
            floatingLocationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            floatingLocationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            floatingLocationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            floatingLocationLabel.heightAnchor.constraint(equalTo: locationLabel.heightAnchor),
        ])
        
        let weeklyForecastHeight = CGFloat(WeeklyForecastCollectionView.DAY_FORCAST_COUNT * WeeklyWeatherCollectionViewCell.WEEKLY_FORECAST_HEIGHT)
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.topAnchor, constant: 0),
            locationLabel.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            locationLabel.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            searchButton.centerYAnchor.constraint(equalTo: locationLabel.centerYAnchor),
            searchButton.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            searchButton.leadingAnchor.constraint(equalTo: locationLabel.leadingAnchor, constant: 0),
            searchButton.heightAnchor.constraint(equalToConstant: 35),
            
            currentWeatherCard.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 20),
            currentWeatherCard.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            currentWeatherCard.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            hourlyForcastView.topAnchor.constraint(equalTo: currentWeatherCard.bottomAnchor, constant: 20),
            hourlyForcastView.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            hourlyForcastView.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            hourlyForcastView.heightAnchor.constraint(equalToConstant: CGFloat(WeatherCollectionViewCell.HOURLY_FORECAST_HEIGHT)),
            
            weeklyForcastView.topAnchor.constraint(equalTo: hourlyForcastView.bottomAnchor, constant: 10),
            weeklyForcastView.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            weeklyForcastView.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            weeklyForcastView.heightAnchor.constraint(equalToConstant: weeklyForecastHeight),
            
            weeklyForcastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)

        ])
    }
    
    
    public func updateUIWith(currentForecast: CurrentWeather, minuteForcast: Forecast<MinuteWeather>?, hourForcast: Forecast<HourWeather>, dayWeather: Forecast<DayWeather>) {
        currentWeatherCard.updateWith(currentForecast)
        
        // Update hourly forecast for the next 24 hours
        hourlyForcastView.update(with: Array(hourForcast.forecast.filter { forecast in
            let forecastDate = forecast.date
            return forecastDate >= Date() && forecastDate <= Calendar.current.date(byAdding: .hour, value: 24, to: Date())!
        }))
        
        // Update weekly forecast to start from today and include only up to DAY_FORCAST_COUNT days
        let today = Calendar.current.startOfDay(for: Date())
        let filteredForecasts = dayWeather.forecast.filter { $0.date >= today }
        let sliceCount = min(filteredForecasts.count, WeeklyForecastCollectionView.DAY_FORCAST_COUNT)
        let slicedForecasts = filteredForecasts.prefix(sliceCount)
        
        weeklyForcastView.update(with: Array(slicedForecasts))
    }

    
    // MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let locationLabelFrame = self.view.convert(locationLabel.frame, from: locationLabel.superview)
        if locationLabelFrame.minY < view.safeAreaInsets.top {
            // Show floating label when original label is out of view
            floatingLocationLabel.isHidden = false
            floatingLocationLabel.text = locationLabel.text
        } else {
            // Hide floating label when original label is in view
            floatingLocationLabel.isHidden = true
        }
    }
}
