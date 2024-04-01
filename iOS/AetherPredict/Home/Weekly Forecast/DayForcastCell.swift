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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(weatherConditionView)
        contentView.backgroundColor = .clear
        setupConstraints()
    }

    private func setupConstraints() {
        weatherConditionView.translatesAutoresizingMaskIntoConstraints = false

        let conditionViewWH: CGFloat = 50
            NSLayoutConstraint.activate([
                weatherConditionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                weatherConditionView.widthAnchor.constraint(equalToConstant: conditionViewWH),
                weatherConditionView.heightAnchor.constraint(equalToConstant: conditionViewWH),
                weatherConditionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
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
    }
}
