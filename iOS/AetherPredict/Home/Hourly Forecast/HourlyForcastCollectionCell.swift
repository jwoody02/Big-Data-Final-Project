//
//  HourlyForcastCollectionCell.swift
//  AetherPredict
//
//  Created by Jordan Wood on 3/31/24.
//

import Foundation
import UIKit
import WeatherKit

class WeatherCollectionViewCell: UICollectionViewCell {
    static let identifier = "WeatherCollectionViewCell"
    static let HOURLY_FORECAST_HEIGHT = 110
    public let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .nunito(ofSize: 12, weight: .medium)
        label.textColor = .secondaryTint
        return label
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .nunito(ofSize: 16, weight: .medium)
        label.textColor = .primaryTint
        return label
    }()
    
    private let weatherConditionView: WeatherConditionView = {
        let wcv = WeatherConditionView()
        return wcv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(timeLabel)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(weatherConditionView)
        contentView.backgroundColor = .clear
        setupConstraints()
    }

    private func setupConstraints() {
        weatherConditionView.translatesAutoresizingMaskIntoConstraints = false
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            temperatureLabel.translatesAutoresizingMaskIntoConstraints = false

        let conditionViewWH: CGFloat = 50
            NSLayoutConstraint.activate([
                weatherConditionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                weatherConditionView.widthAnchor.constraint(equalToConstant: conditionViewWH),
                weatherConditionView.heightAnchor.constraint(equalToConstant: conditionViewWH),
                weatherConditionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

                timeLabel.topAnchor.constraint(equalTo: weatherConditionView.bottomAnchor, constant: 8),
                timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
                timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

                temperatureLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 0),
                temperatureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
                temperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

            ])
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func configure(with model: HourWeather) {
        
        // update time label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ha"
        timeLabel.text = dateFormatter.string(from: model.date)
        
        // update temp label
        let temperatureInFahrenheit = Measurement(value: model.temperature.value, unit: UnitTemperature.celsius).converted(to: .fahrenheit).value
        temperatureLabel.text = String(format: "%.0f°", temperatureInFahrenheit)
        
        // update weather condition view
        let name = model.symbolName
        let isImageNonFillable = name == "wind" || name == "snowflake" || name == "snow"
        guard let conditionImage = UIImage(systemName: isImageNonFillable ? name : name + ".fill") else { return }
        let conditionConfig = WeatherSymbolConfigurationManager.configuration(forCondition: isImageNonFillable ? name : name + ".fill")

        let precipitationChance = model.precipitationChance
        weatherConditionView.updateWith(image: conditionImage, symbolConfig: conditionConfig, precipitationChance: precipitationChance)
    }

}
