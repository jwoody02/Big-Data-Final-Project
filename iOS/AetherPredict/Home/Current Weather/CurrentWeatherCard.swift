//
//  CurrentWeatherCard.swift
//  AetherPredict
//
//  Created by Jordan Wood on 3/31/24.
//

import Foundation
import UIKit
import WeatherKit
import os.log

class CurrentWeatherCard: UIView {

    static let MINIMIZED_HEIGHT: CGFloat = 180
    static let MAXIMIZED_HEIGHT: CGFloat = 360

    var cardHeightConstraint = NSLayoutConstraint()

    // MARK: - UI Elements
    private let lastUpdatedLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .nunito(ofSize: 13, weight: .medium)
        label.textAlignment = .left
        label.textColor = .secondaryTint
        label.numberOfLines = 1
        label.alpha = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let temperatureValueLabel: UILabel = {
        let label = UILabel()
        label.text = "--°"
        label.font = .nunito(ofSize: 48, weight: .medium)
        label.textAlignment = .left
        label.textColor = .primaryTint
        label.numberOfLines = 1
        label.alpha = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let conditionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .primaryTint
        imageView.image = UIImage(systemName: "icloud.slash.fill")
        imageView.alpha = 1
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let feelsLikeLabel: UILabel = {
        let label = UILabel()
        label.text = "Feels like --°"
        label.font = .nunito(ofSize: 14, weight: .light)
        label.textAlignment = .left
        label.textColor = .primaryTint
        label.numberOfLines = 1
        label.alpha = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let currentConditionsLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .nunito(ofSize: 14, weight: .light)
        label.textAlignment = .left
        label.textColor = .primaryTint
        label.numberOfLines = 2
        label.alpha = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let showMoreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show more ", for: .normal) // Space is intentional for spacing between text and image
        
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 8, weight: .regular)
        let chevronImage = UIImage(systemName: "chevron.down", withConfiguration: symbolConfiguration)?.withTintColor(.secondaryTint, renderingMode: .alwaysOriginal)
        button.setImage(chevronImage, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft // This puts the image to the left of the text
        
        button.tintColor = .secondaryTint
        button.titleLabel?.font = .nunito(ofSize: 12, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let sunLocationView: SunView = {
       let locView = SunView()
        locView.translatesAutoresizingMaskIntoConstraints = false
        locView.isHidden = true
        
        return locView
    }()

    // MARK: - Detailed Stats View

    // Row 1
    let sunriseView = MetricView(title: "Sunrise", value: "", measureType: "")
    let daylightView = MetricView(title: "Daylight", value: "", measureType: "")
    let sunsetView = MetricView(title: "Sunset", value: "", measureType: "")

    // Row 2
    let highLowTempView = MetricView(title: "High/Low", value: "", measureType: "")
    let uvIndexView = UVIndexView(title: "UV Index", value: "", measureType: "")
    let fireChanceView = FireChanceView(title: "Fire Risk", value: "", measureType: "")

    // Row 3
    let precipitationChanceView = MetricView(title: "Precipitation", value: "", measureType: "%")
    let humidityView = MetricView(title: "Humidity", value: "", measureType: "%")
    let windView = MetricView(title: "Wind", value: "", measureType: "")
    
    var detailedViews: [UIView] = []
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        detailedViews = [
            sunriseView,
            daylightView,
            sunsetView,
            highLowTempView,
            uvIndexView,
            fireChanceView,
            precipitationChanceView,
            humidityView,
            windView,
            sunLocationView
        ]

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(currentWeatherCardTapped))
        self.addGestureRecognizer(tapGesture)

        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        cardHeightConstraint = heightAnchor.constraint(equalToConstant: CurrentWeatherCard.MINIMIZED_HEIGHT)

        backgroundColor = .foregroundColor
        layer.cornerRadius = 16

        addSubview(lastUpdatedLabel)
        addSubview(temperatureValueLabel)
        addSubview(conditionImageView)
        addSubview(currentConditionsLabel)
        addSubview(feelsLikeLabel)
        addSubview(showMoreButton)

        addSubview(sunriseView)
        addSubview(daylightView)
        addSubview(sunsetView)

        addSubview(highLowTempView)
        addSubview(uvIndexView)
        addSubview(fireChanceView)

        addSubview(precipitationChanceView)
        addSubview(humidityView)
        addSubview(windView)
        
        addSubview(sunLocationView)

    }

    private func setupConstraints() {
        cardHeightConstraint.isActive = true
        cardHeightConstraint.constant = CurrentWeatherCard.MINIMIZED_HEIGHT

        let detailedStatsViewPadding: CGFloat = 16
        let detailedStatsViewWidth: CGFloat = ((UIScreen.main.bounds.width - 40 - (detailedStatsViewPadding * 4)) / 3)
        let deatiledStatsViewHeight: CGFloat = 40
        NSLayoutConstraint.activate([
            lastUpdatedLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            lastUpdatedLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            lastUpdatedLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            temperatureValueLabel.topAnchor.constraint(equalTo: lastUpdatedLabel.bottomAnchor, constant: 0),
            temperatureValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            temperatureValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            currentConditionsLabel.topAnchor.constraint(equalTo: temperatureValueLabel.bottomAnchor, constant: 15),
            currentConditionsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            currentConditionsLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            feelsLikeLabel.topAnchor.constraint(equalTo: currentConditionsLabel.bottomAnchor, constant: 0),
            feelsLikeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            feelsLikeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            feelsLikeLabel.heightAnchor.constraint(equalToConstant: 20),

            conditionImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            conditionImageView.centerYAnchor.constraint(equalTo: temperatureValueLabel.centerYAnchor, constant: 10),
            conditionImageView.widthAnchor.constraint(equalToConstant: 100),
            conditionImageView.heightAnchor.constraint(equalToConstant: 100),
            
            showMoreButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            showMoreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),

        ])

        NSLayoutConstraint.activate([

            sunriseView.topAnchor.constraint(equalTo: feelsLikeLabel.bottomAnchor, constant: 30),
            sunriseView.widthAnchor.constraint(equalToConstant: detailedStatsViewWidth),
            sunriseView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: detailedStatsViewPadding),
            sunriseView.heightAnchor.constraint(equalToConstant: deatiledStatsViewHeight),

            daylightView.topAnchor.constraint(equalTo: sunriseView.topAnchor, constant: 0),
            daylightView.widthAnchor.constraint(equalToConstant: detailedStatsViewWidth),
            daylightView.leadingAnchor.constraint(equalTo: sunriseView.trailingAnchor, constant: detailedStatsViewPadding),
            daylightView.heightAnchor.constraint(equalToConstant: deatiledStatsViewHeight),
            
            sunLocationView.topAnchor.constraint(equalTo: daylightView.topAnchor, constant: -90),
            sunLocationView.heightAnchor.constraint(equalToConstant: 120),
            sunLocationView.widthAnchor.constraint(equalToConstant: 120),
            sunLocationView.centerXAnchor.constraint(equalTo: centerXAnchor),

            sunsetView.topAnchor.constraint(equalTo: sunriseView.topAnchor, constant: 0),
            sunsetView.widthAnchor.constraint(equalToConstant: detailedStatsViewWidth),
            sunsetView.leadingAnchor.constraint(equalTo: daylightView.trailingAnchor, constant: detailedStatsViewPadding),
            sunsetView.heightAnchor.constraint(equalToConstant: deatiledStatsViewHeight),


            highLowTempView.topAnchor.constraint(equalTo: sunriseView.bottomAnchor, constant: detailedStatsViewPadding),
            highLowTempView.widthAnchor.constraint(equalToConstant: detailedStatsViewWidth),
            highLowTempView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: detailedStatsViewPadding),
            highLowTempView.heightAnchor.constraint(equalToConstant: deatiledStatsViewHeight),

            uvIndexView.topAnchor.constraint(equalTo: highLowTempView.topAnchor, constant: 0),
            uvIndexView.widthAnchor.constraint(equalToConstant: detailedStatsViewWidth),
            uvIndexView.leadingAnchor.constraint(equalTo: highLowTempView.trailingAnchor, constant: detailedStatsViewPadding),
            uvIndexView.heightAnchor.constraint(equalToConstant: deatiledStatsViewHeight),

            fireChanceView.topAnchor.constraint(equalTo: highLowTempView.topAnchor, constant: 0),
            fireChanceView.widthAnchor.constraint(equalToConstant: detailedStatsViewWidth),
            fireChanceView.leadingAnchor.constraint(equalTo: uvIndexView.trailingAnchor, constant: detailedStatsViewPadding),
            fireChanceView.heightAnchor.constraint(equalToConstant: deatiledStatsViewHeight),


            precipitationChanceView.topAnchor.constraint(equalTo: highLowTempView.bottomAnchor, constant: detailedStatsViewPadding),
            precipitationChanceView.widthAnchor.constraint(equalToConstant: detailedStatsViewWidth),
            precipitationChanceView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: detailedStatsViewPadding),
            precipitationChanceView.heightAnchor.constraint(equalToConstant: deatiledStatsViewHeight),

            humidityView.topAnchor.constraint(equalTo: precipitationChanceView.topAnchor, constant: 0),
            humidityView.widthAnchor.constraint(equalToConstant: detailedStatsViewWidth),
            humidityView.leadingAnchor.constraint(equalTo: precipitationChanceView.trailingAnchor, constant: detailedStatsViewPadding),
            humidityView.heightAnchor.constraint(equalToConstant: deatiledStatsViewHeight),

            windView.topAnchor.constraint(equalTo: precipitationChanceView.topAnchor, constant: 0),
            windView.widthAnchor.constraint(equalToConstant: detailedStatsViewWidth),
            windView.leadingAnchor.constraint(equalTo: humidityView.trailingAnchor, constant: detailedStatsViewPadding),
            windView.heightAnchor.constraint(equalToConstant: deatiledStatsViewHeight),
        ])
    }

    
    public func minimize() {
        self.cardHeightConstraint.constant = CurrentWeatherCard.MINIMIZED_HEIGHT
        self.showMoreButton.imageView?.transform = .identity
        self.showMoreButton.setTitle("Show more ", for: .normal)
        for view in detailedViews {
            view.isHidden = true
        }
        
        showMoreButton.isHidden = false
    }

    public func maximize() {
        self.cardHeightConstraint.constant = CurrentWeatherCard.MAXIMIZED_HEIGHT
        self.showMoreButton.imageView?.transform = CGAffineTransform(rotationAngle: .pi)
//        self.showMoreButton.setTitle("Show less ", for: .normal)
        
        for view in detailedViews {
            view.isHidden = false
        }
        
        showMoreButton.isHidden = true
    }

    public func toggle() {
        if cardHeightConstraint.constant == CurrentWeatherCard.MINIMIZED_HEIGHT {
            maximize()
        } else {
            minimize()
        }
    }

    public func updateWith(_ currentWeather: CurrentWeather, _ dayForecast: DayWeather?) {
        let updatedAtTimestamp = currentWeather.date
        let actualTemperatureObject = currentWeather.temperature
        let feelsLikeObject = currentWeather.apparentTemperature
        let conditionDescription = currentWeather.condition.description
        let conditionImageName = currentWeather.symbolName
        let windSpeedObject = currentWeather.wind.speed
        let uvIndex = currentWeather.uvIndex

         // Main Values (Temperature, Condition, Feels Like)
        setUpdatedAt(updatedAtTimestamp) // "9:27 PM"
        setCurrentConditionLabel(to: conditionDescription) // "Cloudy"

        let temperatureInCelsius = Measurement(value: actualTemperatureObject.value, unit: UnitTemperature.celsius)
        let temperatureInFahrenheit = temperatureInCelsius.converted(to: .fahrenheit).value
        setTemperature(to: temperatureInFahrenheit) // Temperature Value
        setConditionImage(named: conditionImageName) // Condition image

        let feelsLikeInCelsius = Measurement(value: feelsLikeObject.value, unit: UnitTemperature.celsius)
        let feelsLikeInFahrenheit = feelsLikeInCelsius.converted(to: .fahrenheit).value
        setFeelsLike(to: feelsLikeInFahrenheit)

        // Detailed Stats 
        if let dayForecast = dayForecast {
            // Row 1
            // Define the formatter for sunrise and sunset times
            let sunriseSunsetFormatter = DateFormatter()
            sunriseSunsetFormatter.dateFormat = "h:mm a"

            // Extract sunrise and sunset times
            if let sunriseTime = dayForecast.sun.sunrise, let sunsetTime = dayForecast.sun.sunset {
                sunLocationView.updateSunPosition(currentTime: Date(), sunrise: sunriseTime, sunset: sunsetTime)
                // Calculate daylight duration in seconds
                let daylightSeconds = sunsetTime.timeIntervalSince(sunriseTime)
                
                // Convert daylight duration to hours and minutes
                let daylightHours = Int(daylightSeconds) / 3600 // Convert seconds to hours
                let daylightMinutes = (Int(daylightSeconds) % 3600) / 60 // Convert remainder to minutes
                
                // Format daylight duration as a string
                let daylightString = "\(daylightHours)h \(daylightMinutes)m"
                
                // Set formatted values for sunrise, sunset, and daylight duration
                sunriseView.value = sunriseSunsetFormatter.string(from: sunriseTime)
                sunsetView.value = sunriseSunsetFormatter.string(from: sunsetTime)
                daylightView.value = daylightString
            } else {
                // Handle cases where sunrise or sunset times are nil
                sunriseView.value = "N/A"
                sunsetView.value = "N/A"
                daylightView.value = "N/A"
            }



            // Row 2
            let farhenheitHigh = Measurement(value: dayForecast.highTemperature.value, unit: UnitTemperature.celsius).converted(to: .fahrenheit).value
            let farhenheitLow = Measurement(value: dayForecast.lowTemperature.value, unit: UnitTemperature.celsius).converted(to: .fahrenheit).value
            let highLowString = "↑\(Int(farhenheitHigh))° ↓\(Int(farhenheitLow))°"
            highLowTempView.value = highLowString

            uvIndexView.updateWithUVIndex(uvIndex.value)
            fireChanceView.updateWithFireChance(.low)

            // Row 3
            precipitationChanceView.value = "\(Int(dayForecast.precipitationChance * 100))"
            humidityView.value = "\(Int(currentWeather.humidity * 100))"
            windView.value = "\(Int(windSpeedObject.value * 0.62))mph \(currentWeather.wind.compassDirection.abbreviation)"
        }

        
    }

    private func setTemperature(to value: Double) {
        temperatureValueLabel.text = String(format: "%.0f°", value)
    }

    private func setConditionImage(named name: String) {
        let isImageNonFillable = name == "wind" || name == "snowflake"
        conditionImageView.image = UIImage(systemName: isImageNonFillable ? name : name + ".fill")
        conditionImageView.preferredSymbolConfiguration = WeatherSymbolConfigurationManager.configuration(forCondition: isImageNonFillable ? name : name + ".fill")
    }

    private func setFeelsLike(to value: Double) {
        let lightAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.nunito(ofSize: 14, weight: .light),
            .foregroundColor: UIColor.primaryTint
        ]
        
        let mediumAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.nunito(ofSize: 14, weight: .medium),
            .foregroundColor: UIColor.primaryTint
        ]
        
        // Create the attributed string for the "Feels like " part
        let feelsLikeAttributedString = NSMutableAttributedString(string: "Feels like ", attributes: lightAttributes)
        
        // Create the attributed string for the temperature value part
        let valueAttributedString = NSAttributedString(string: String(format: "%.0f°", value), attributes: mediumAttributes)
        
        // Append the temperature value part to the "Feels like " part
        feelsLikeAttributedString.append(valueAttributedString)
        
        // Set the attributed text to the label
        feelsLikeLabel.attributedText = feelsLikeAttributedString
    }

    private func setUpdatedAt(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d, h:mm a"
        lastUpdatedLabel.text = "\(dateFormatter.string(from: date))"
    }


    private func setCurrentConditionLabel(to text: String) {
        currentConditionsLabel.text = text
    }

    @objc func currentWeatherCardTapped() {
        // light feedback
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        toggle()
    }


    public func resetViews() {
        lastUpdatedLabel.text = ""
        temperatureValueLabel.text = "--°"
        conditionImageView.image = UIImage(systemName: "icloud.slash.fill")
        conditionImageView.preferredSymbolConfiguration = WeatherSymbolConfigurationManager.configuration(forCondition: "icloud.slash.fill")
        feelsLikeLabel.text = "Feels like --°"
        currentConditionsLabel.text = ""   
    }
}
