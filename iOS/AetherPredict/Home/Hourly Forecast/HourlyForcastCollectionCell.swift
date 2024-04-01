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
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .nunito(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .nunito(ofSize: 16, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let conditionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemBackground
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(timeLabel)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(conditionImageView)
        contentView.backgroundColor = .clear
        setupConstraints()
    }

    private func setupConstraints() {
            conditionImageView.translatesAutoresizingMaskIntoConstraints = false
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            temperatureLabel.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                conditionImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
                conditionImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                conditionImageView.widthAnchor.constraint(equalToConstant: 40),
                conditionImageView.heightAnchor.constraint(equalToConstant: 40),

                timeLabel.topAnchor.constraint(equalTo: conditionImageView.bottomAnchor, constant: 4),
                timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
                timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

                temperatureLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
                temperatureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
                temperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
                temperatureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            ])
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func configure(with model: HourWeather) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ha" // Adjust the date format as needed
        timeLabel.text = dateFormatter.string(from: model.date)
        
        temperatureLabel.text = "\(Int(model.temperature.value))°"
        
        let name = model.symbolName
        let isImageNonFillable = name == "wind" || name == "snowflake"
        conditionImageView.image = UIImage(systemName: isImageNonFillable ? name : name + ".fill")
        conditionImageView.preferredSymbolConfiguration = WeatherSymbolConfigurationManager.configuration(forCondition: isImageNonFillable ? name : name + ".fill")
    }
}
