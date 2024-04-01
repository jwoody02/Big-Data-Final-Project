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
        label.font = .nunito(ofSize: 13, weight: .medium)
        label.textColor = .secondaryTint
        return label
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .nunito(ofSize: 17, weight: .medium)
        label.textColor = .primaryTint
        return label
    }()
    
    private let conditionImageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .foregroundColor
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()
    private let conditionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let precipitationChanceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .nunito(ofSize: 10, weight: .bold)
        label.textColor = .cyan
        return label
    }()
    private var conditionImageViewTopConstraint: NSLayoutConstraint = NSLayoutConstraint()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(timeLabel)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(conditionImageContainer)
        contentView.addSubview(conditionImageView)
        contentView.addSubview(precipitationChanceLabel)
        contentView.backgroundColor = .clear
        setupConstraints()
    }

    private func setupConstraints() {
            conditionImageView.translatesAutoresizingMaskIntoConstraints = false
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        conditionImageContainer.translatesAutoresizingMaskIntoConstraints = false
        precipitationChanceLabel.translatesAutoresizingMaskIntoConstraints = false
        conditionImageViewTopConstraint = conditionImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20) // Default value

        let conditionPadding: CGFloat = 10
        let conditionImageWH: CGFloat = 30
            NSLayoutConstraint.activate([
                
                conditionImageContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                conditionImageContainer.widthAnchor.constraint(equalToConstant: conditionImageWH + (conditionPadding * 2)),
                conditionImageContainer.heightAnchor.constraint(equalToConstant: conditionImageWH + (conditionPadding * 2)),
                conditionImageContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                
                conditionImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                conditionImageView.widthAnchor.constraint(equalToConstant: conditionImageWH),
                conditionImageView.heightAnchor.constraint(equalToConstant: conditionImageWH),

                timeLabel.topAnchor.constraint(equalTo: conditionImageContainer.bottomAnchor, constant: 4),
                timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
                timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

                temperatureLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 0),
                temperatureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
                temperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

                precipitationChanceLabel.bottomAnchor.constraint(equalTo: conditionImageContainer.bottomAnchor, constant: -2),
                precipitationChanceLabel.leadingAnchor.constraint(equalTo: conditionImageContainer.leadingAnchor, constant: 0),
                precipitationChanceLabel.trailingAnchor.constraint(equalTo: conditionImageContainer.trailingAnchor, constant: 0),
                
                conditionImageViewTopConstraint
            ])
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func configure(with model: HourWeather) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ha"
        timeLabel.text = dateFormatter.string(from: model.date)
        
        let temperatureInFahrenheit = Measurement(value: model.temperature.value, unit: UnitTemperature.celsius).converted(to: .fahrenheit).value
        temperatureLabel.text = String(format: "%.0f°", temperatureInFahrenheit)
        
        let name = model.symbolName
        let isImageNonFillable = name == "wind" || name == "snowflake"
        conditionImageView.image = UIImage(systemName: isImageNonFillable ? name : name + ".fill")
        conditionImageView.preferredSymbolConfiguration = WeatherSymbolConfigurationManager.configuration(forCondition: isImageNonFillable ? name : name + ".fill")

        let precipitationChance = model.precipitationChance
        if precipitationChance > 0.0 {
            precipitationChanceLabel.text = String(format: "%.0f%%", precipitationChance * 100)
            conditionImageViewTopConstraint.constant = 15
        } else {
            precipitationChanceLabel.text = ""
            conditionImageViewTopConstraint.constant = 20
        }
        
        contentView.layoutIfNeeded()
    }

}
