//
//  DayForcastCell.swift
//  AetherPredict
//
//  Created by Jordan Wood on 4/1/24.
//

import Foundation
import Foundation
import UIKit
import WeatherKit

class WeeklyWeatherCollectionViewCell: UICollectionViewCell {
    static let identifier = "WeatherCollectionViewCell"
    static let WEEKLY_FORECAST_HEIGHT = 70
    
    private let weatherConditionView: WeatherConditionView = {
        let wcv = WeatherConditionView()
        return wcv
    }()

    private let conditionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .nunito(ofSize: 12, weight: .medium)
        label.textColor = .secondaryTint
        return label
    }()

    public let dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .nunito(ofSize: 14, weight: .medium)
        label.textColor = .primaryTint
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(weatherConditionView)
        contentView.addSubview(conditionLabel)
        contentView.addSubview(dayLabel)
        contentView.backgroundColor = .clear
        setupConstraints()
    }

    private func setupConstraints() {
        weatherConditionView.translatesAutoresizingMaskIntoConstraints = false
        conditionLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.translatesAutoresizingMaskIntoConstraints = false

        let conditionViewWH: CGFloat = 50
            NSLayoutConstraint.activate([
                weatherConditionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                weatherConditionView.widthAnchor.constraint(equalToConstant: conditionViewWH),
                weatherConditionView.heightAnchor.constraint(equalToConstant: conditionViewWH),
                weatherConditionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

                dayLabel.leadingAnchor.constraint(equalTo: weatherConditionView.trailingAnchor, constant: 10),
                dayLabel.bottomAnchor.constraint(equalTo: weatherConditionView.centerYAnchor, constant: 0),
                
                conditionLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 0),
                conditionLabel.leadingAnchor.constraint(equalTo: weatherConditionView.trailingAnchor, constant: 10),

            ])
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public func configure(with model: DayWeather) {
        // update weather condition view
        let name = model.symbolName
        let isImageNonFillable = name == "wind" || name == "snowflake"
        guard let conditionImage = UIImage(systemName: isImageNonFillable ? name : name + ".fill") else { return }
        let conditionConfig = WeatherSymbolConfigurationManager.configuration(forCondition: isImageNonFillable ? name : name + ".fill")

        let precipitationChance = model.precipitationChance
        weatherConditionView.updateWith(image: conditionImage, symbolConfig: conditionConfig, precipitationChance: precipitationChance)

        // update day label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dayLabel.text = dateFormatter.string(from: model.date)

        // update condition label
        conditionLabel.text = model.condition.description
    }
}
