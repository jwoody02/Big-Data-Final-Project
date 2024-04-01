//
//  TemperatureRangeView.swift
//  AetherPredict
//
//  Created by Jordan Wood on 4/1/24.
//

import Foundation
import UIKit

class TemperatureRangeView: UIView {

    private var lowValueForWeek: Double = 0
    private var highValueForWeek: Double = 0
    private var lowValue: Double = 0 {
        didSet {
            lowerValueLabel.text = String(format: "%.0f°", lowValue)
            updateGradientRelativityView()
        }
    }
    private var highValue: Double = 0 {
        didSet {
            upperValueLabel.text = String(format: "%.0f°", highValue)
            updateGradientRelativityView()
        }
    }

    // MARK: - Label UI Elements
    private let lowerValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .nunito(ofSize: 15, weight: .medium)
        label.textColor = .secondaryTint
        return label
    }()

    private let upperValueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .nunito(ofSize: 15, weight: .medium)
        label.textColor = .primaryTint
        return label
    }()

    private let backgroundProgressBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryTint.withAlphaComponent(0.4)
        view.layer.cornerRadius = 1.5
        return view
    }() 

    private let gradientProgressBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 1.5
        view.clipsToBounds = true
        return view
    }()

    private var gradientLayer: CAGradientLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(lowerValueLabel)
        addSubview(upperValueLabel)
        addSubview(backgroundProgressBarView)
        addSubview(gradientProgressBarView)
        backgroundColor = .clear
        setupConstraints()
        setupGradientLayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupConstraints() {
        lowerValueLabel.translatesAutoresizingMaskIntoConstraints = false
        upperValueLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundProgressBarView.translatesAutoresizingMaskIntoConstraints = false
        gradientProgressBarView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            lowerValueLabel.topAnchor.constraint(equalTo: topAnchor),
            lowerValueLabel.leadingAnchor.constraint(equalTo: leadingAnchor),

            upperValueLabel.topAnchor.constraint(equalTo: lowerValueLabel.topAnchor),
            upperValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            backgroundProgressBarView.topAnchor.constraint(equalTo: lowerValueLabel.bottomAnchor, constant: 10),
            backgroundProgressBarView.leadingAnchor.constraint(equalTo: lowerValueLabel.leadingAnchor),
            backgroundProgressBarView.trailingAnchor.constraint(equalTo: upperValueLabel.trailingAnchor),
            backgroundProgressBarView.heightAnchor.constraint(equalToConstant: 3)
        ])
        
        NSLayoutConstraint.activate([
            gradientProgressBarView.topAnchor.constraint(equalTo: backgroundProgressBarView.topAnchor),
            gradientProgressBarView.bottomAnchor.constraint(equalTo: backgroundProgressBarView.bottomAnchor),
            gradientProgressBarView.leadingAnchor.constraint(equalTo: backgroundProgressBarView.leadingAnchor),
            gradientProgressBarView.trailingAnchor.constraint(equalTo: backgroundProgressBarView.trailingAnchor)
        ])
    }

    func setLowCelciusValue(_ value: Double) {
        lowValue = Measurement(value: value, unit: UnitTemperature.celsius).converted(to: .fahrenheit).value
    }

    func setHighCelciusValue(_ value: Double) {
        highValue = Measurement(value: value, unit: UnitTemperature.celsius).converted(to: .fahrenheit).value
    }

    func setLowValueForWeek(_ value: Double) {
        lowValueForWeek = Measurement(value: value, unit: UnitTemperature.celsius).converted(to: .fahrenheit).value
        updateGradientRelativityView()
    }

    func setHighValueForWeek(_ value: Double) {
        highValueForWeek = Measurement(value: value, unit: UnitTemperature.celsius).converted(to: .fahrenheit).value
        updateGradientRelativityView()
    }
    
    private func setupGradientLayer() {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.secondaryTint.cgColor, UIColor.primaryTint.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientProgressBarView.layer.insertSublayer(gradient, at: 0)
        self.gradientLayer = gradient
    }

    public func updateGradientRelativityView() {
        guard let backgroundWidth = backgroundProgressBarView.superview?.bounds.width, backgroundWidth > 0 else {
            return
        }
        
        let weeklyRange = max(highValueForWeek - lowValueForWeek, 1) // Ensure weeklyRange is not zero, using 1 as minimum to avoid division by zero.
        let leftPercentage = max(0, min((lowValue - lowValueForWeek) / weeklyRange, 1)) // Clamp result between 0 and 1.
        let rightPercentage = max(0, min((highValue - lowValueForWeek) / weeklyRange, 1)) // Clamp result between 0 and 1.

        // Calculate width and X position of the gradient based on percentages.
        // These calculations ensure the width is never negative and the X position is within the view bounds.
        let xPos = backgroundWidth * CGFloat(leftPercentage)
        let width = max(0, backgroundWidth * CGFloat(rightPercentage) - xPos) // Ensure width is not negative.

        // Update the frame of gradientProgressBarView based on calculated values.
        gradientProgressBarView.frame = CGRect(x: xPos, y: backgroundProgressBarView.frame.minY, width: width, height: backgroundProgressBarView.bounds.height)
        gradientLayer?.frame = gradientProgressBarView.bounds

        // Set the corner radius for the gradient view.
        gradientProgressBarView.layer.cornerRadius = backgroundProgressBarView.layer.cornerRadius
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundProgressBarView.layer.cornerRadius = 1.5
        updateGradientRelativityView() // Ensure gradient updates when view layout changes
    }

}
