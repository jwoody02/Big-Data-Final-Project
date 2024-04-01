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
    static let MAXIMIZED_HEIGHT: CGFloat = 340

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
        button.titleLabel?.font = .nunito(ofSize: 12, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true

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
    }

    private func setupConstraints() {
        cardHeightConstraint.isActive = true
        cardHeightConstraint.constant = CurrentWeatherCard.MINIMIZED_HEIGHT

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
            
            feelsLikeLabel.topAnchor.constraint(equalTo: currentConditionsLabel.bottomAnchor, constant: 5),
            feelsLikeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            feelsLikeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            conditionImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            conditionImageView.centerYAnchor.constraint(equalTo: temperatureValueLabel.centerYAnchor, constant: 10),
            conditionImageView.widthAnchor.constraint(equalToConstant: 100),
            conditionImageView.heightAnchor.constraint(equalToConstant: 100),
            
            showMoreButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            showMoreButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
        ])
    }

    public func minimize() {
        self.cardHeightConstraint.constant = CurrentWeatherCard.MINIMIZED_HEIGHT
        self.showMoreButton.imageView?.transform = .identity
        self.showMoreButton.setTitle("Show more ", for: .normal)
    }

    public func maximize() {
        self.cardHeightConstraint.constant = CurrentWeatherCard.MAXIMIZED_HEIGHT
        self.showMoreButton.imageView?.transform = CGAffineTransform(rotationAngle: .pi)
        self.showMoreButton.setTitle("Show less ", for: .normal)
    }

    public func toggle() {
        if cardHeightConstraint.constant == CurrentWeatherCard.MINIMIZED_HEIGHT {
            maximize()
        } else {
            minimize()
        }
    }

    public func updateWith(_ currentWeather: CurrentWeather) {
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

        // Additional Values (Wind Speed, UV Index)
        let roundedWindSpeed = Int(round(windSpeedObject.value))
        // TODO: - Set wind speed

        let UVIndex = uvIndex.value
        // TODO: - Set UV Index
        
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
}
