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

enum LocationOption {
    case currentLocation
    case other(CLLocation)
}

public class HomeViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - UI
    var alreadyGotCurrentLocation = false
    var locationOption: LocationOption = .currentLocation

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        if #available(iOS 17.4, *) {
            scrollView.bouncesVertically = true
        }
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

    private let searchField: UITextField = {
        let sf = UITextField()
        sf.font = .nunito(ofSize: 18, weight: .medium)
        sf.textColor = .primaryTint
        sf.backgroundColor = .backgroundColor
        sf.placeholder = "Search for a city"
        sf.attributedPlaceholder = NSAttributedString(string: "Search for a city", attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryTint])
        sf.alpha = 0
        sf.clearButtonMode = .never
        
        // Create a custom clear button
        let clearButton = UIButton(type: .custom)
        if let clearImage = UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysTemplate) {
            clearButton.setImage(clearImage, for: .normal)
            clearButton.tintColor = .secondaryTint
            clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
        }
        
        sf.rightView = clearButton
        sf.rightViewMode = .whileEditing
        
        return sf
    }()

    @objc func clearTextField() {
        searchField.text = ""
    }


    private let searchResultsView: SearchResultsTableView = {
        let srv = SearchResultsTableView()
        srv.translatesAutoresizingMaskIntoConstraints = false
        srv.alpha = 0
        return srv
    }()

    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.secondaryTint, for: .normal)
        button.titleLabel?.font = .nunito(ofSize: 18, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
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

        // add search action
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
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
        contentView.addSubview(searchField)
        contentView.addSubview(cancelButton)
        contentView.addSubview(searchResultsView)
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

        let weeklyForecastHeight = CGFloat((WeeklyForecastCollectionView.DAY_FORCAST_COUNT + 4) * WeeklyWeatherCollectionViewCell.WEEKLY_FORECAST_HEIGHT)
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

            weeklyForcastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50)

        ])

        // put search field just off screen
        searchField.frame = CGRect(x: view.frame.width, y: searchButton.frame.minY - 5, width: view.frame.width - 80 - 70, height: 35)
        NSLayoutConstraint.activate([
            searchResultsView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 0),
            searchResultsView.leadingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            searchResultsView.trailingAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            searchResultsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        searchResultsView.didSelectPlace = { [weak self] city in
            guard let self = self else { return }
            self.cancelSearch()
            let clLocation = CLLocation(latitude: Double(city.lat) ?? 0, longitude: Double(city.lon) ?? 0)
            self.locationOption = .other(clLocation)
            self.locationLabel.text = "\(city.name), \(city.state)"
            self.currentWeatherCard.resetViews()
            self.weeklyForcastView.update(with: [])
            self.hourlyForcastView.update(with: [])
            self.weatherService.fetchWeather(for: clLocation) { result in
                
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
        searchField.addTarget(self, action: #selector(searchFieldDidChange), for: .editingChanged)

        cancelButton.addTarget(self, action: #selector(cancelSearch), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.centerYAnchor.constraint(equalTo: searchButton.centerYAnchor, constant: 0),
            cancelButton.widthAnchor.constraint(equalToConstant: 60),
            cancelButton.heightAnchor.constraint(equalToConstant: 35),
            cancelButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20)
        ])
    }


    public func updateUIWith(currentForecast: CurrentWeather, minuteForcast: Forecast<MinuteWeather>?, hourForcast: Forecast<HourWeather>, dayWeather: Forecast<DayWeather>) {
        currentWeatherCard.updateWith(currentForecast)

        // Update hourly forecast for the next 24 hours
        let now = Date()
        let currentCalendar = Calendar.current
        let startOfCurrentHour = currentCalendar.dateInterval(of: .hour, for: now)?.start ?? now

        hourlyForcastView.update(with: Array(hourForcast.forecast.filter { forecast in
            let forecastDate = forecast.date
            return forecastDate >= startOfCurrentHour && forecastDate <= currentCalendar.date(byAdding: .hour, value: 24, to: startOfCurrentHour)!
        }))

        // Update weekly forecast
        let today = Calendar.current.startOfDay(for: Date())
        let filteredForecasts = dayWeather.forecast.filter { $0.date >= today }
        let sliceCount = min(filteredForecasts.count, WeeklyForecastCollectionView.DAY_FORCAST_COUNT)
        let slicedForecasts = filteredForecasts.prefix(sliceCount)
        weeklyForcastView.currentTempCelcius = currentForecast.temperature.value
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

    // MARK: - Search
    @objc func searchFieldDidChange() {
        guard let text = searchField.text, !text.isEmpty else {
            searchResultsView.showResultsForSearchString("")
            return
        }

       searchResultsView.showResultsForSearchString(text)
    }

    // called when search button is tapped
    @objc func searchButtonTapped() {
        // Hide all our weather views and move search button to far left
        searchButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            self.currentWeatherCard.alpha = 0
            self.hourlyForcastView.alpha = 0
            self.weeklyForcastView.alpha = 0
            self.locationLabel.alpha = 0
            self.floatingLocationLabel.alpha = 0
            self.searchField.alpha = 1
            self.searchResultsView.alpha = 1
            self.cancelButton.alpha = 1
            self.searchButton.transform = CGAffineTransform(translationX: -self.view.frame.width + 80, y: 0)
            self.searchField.transform = CGAffineTransform(translationX: -self.view.frame.width + 60, y: 0)
        } completion: { _ in
            // make searchField first responder
            self.searchField.becomeFirstResponder()
        }
    }

    // called when cancel button is tapped
    @objc func cancelSearch() {
        searchButton.isUserInteractionEnabled = true
        locationOption = .currentLocation
        UIView.animate(withDuration: 0.3) {
            self.currentWeatherCard.alpha = 1
            self.hourlyForcastView.alpha = 1
            self.weeklyForcastView.alpha = 1
            self.locationLabel.alpha = 1
            self.floatingLocationLabel.alpha = 1
            self.searchField.alpha = 0
            self.searchResultsView.alpha = 0
            self.cancelButton.alpha = 0
            self.searchButton.transform = .identity
            self.searchField.transform = .identity
        } completion: { _ in
            self.searchField.resignFirstResponder()
        }
    }
}
