//
//  WeatherConditionView.swift
//  AetherPredict
//
//  Created by Jordan Wood on 4/1/24.
//

import Foundation
import UIKit

class WeatherConditionView: UIView {
    
    private let containerBackgroundView: UIView = {
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
        label.font = .nunito(ofSize: 8, weight: .bold)
        label.textColor = .cyan
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.cyan.withAlphaComponent(0.1).cgColor
        label.backgroundColor = .backgroundColor
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.2
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.isHidden = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerBackgroundView)
        addSubview(conditionImageView)
        addSubview(precipitationChanceLabel)
        backgroundColor = .clear
        setupConstraints()
        self.clipsToBounds = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupConstraints() {
        containerBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        conditionImageView.translatesAutoresizingMaskIntoConstraints = false
        precipitationChanceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            containerBackgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerBackgroundView.widthAnchor.constraint(equalTo: widthAnchor),
            containerBackgroundView.heightAnchor.constraint(equalTo: widthAnchor),

            conditionImageView.centerXAnchor.constraint(equalTo: containerBackgroundView.centerXAnchor),
            conditionImageView.centerYAnchor.constraint(equalTo: containerBackgroundView.centerYAnchor),
            conditionImageView.widthAnchor.constraint(equalToConstant: 30),
            conditionImageView.heightAnchor.constraint(equalToConstant: 30),

            precipitationChanceLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 6),
            precipitationChanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 6),
            precipitationChanceLabel.heightAnchor.constraint(equalToConstant: 18),
            precipitationChanceLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 26)
        ])
    }

    public func updateWith(image: UIImage, symbolConfig: UIImage.SymbolConfiguration?, precipitationChance: Double) {
        conditionImageView.image = image
        conditionImageView.preferredSymbolConfiguration = symbolConfig
        let roundedPrecipitationChance = (precipitationChance * 10).rounded() / 10
        if roundedPrecipitationChance > 0 {
            precipitationChanceLabel.text = "\(Int(roundedPrecipitationChance * 100))%"
            precipitationChanceLabel.isHidden = false
        } else {
            precipitationChanceLabel.text = ""
            precipitationChanceLabel.isHidden = true
        }
    }
}
