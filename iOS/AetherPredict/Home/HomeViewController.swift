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
    
    private func animateInViews() {
        UIView.animate(withDuration: 0.3) {
            // TODO: forcast views
        }
    }
    private func setupUI() {

        view.addSubview(locationLabel)
        view.addSubview(currentWeatherCard)
        view.addSubview(hourlyForcastView)

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
            hourlyForcastView.heightAnchor.constraint(equalToConstant: CGFloat(WeatherCollectionViewCell.HOURLY_FORECAST_HEIGHT))
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
