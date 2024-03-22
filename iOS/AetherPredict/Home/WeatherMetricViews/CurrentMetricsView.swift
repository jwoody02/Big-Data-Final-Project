//
//  CurrentMetricsView.swift
//  AetherPredict
//
//  Created by Jordan Wood on 3/21/24.
//

import Foundation
import UIKit

enum WeatherMetric: String {
    case temperature = "Temperature"
    case humidity = "Humidity"
    case windSpeed = "Wind Speed"
    case precipitationChance = "PrecipitationChance"
    case precipitationAmount = "PrecipitationAmount"
    case uvIndex = "UV Index"
    case airQuality = "Air Quality"
    case fireRisk = "Fire Risk"
}

class CurrentMetricsView: UIView {
    
    private var metricsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private var metricViews: [String: WeatherMetricView] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(metricsStackView)
        
        NSLayoutConstraint.activate([
            metricsStackView.topAnchor.constraint(equalTo: topAnchor),
            metricsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            metricsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            metricsStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        metricsStackView.layoutIfNeeded()
    }
    
    private func addMetricView(key: WeatherMetric, primaryColor: UIColor, iconName: String?) {
        let metricView = WeatherMetricView()
        metricView.setPrimaryColor(to: primaryColor)
        metricView.setSystemIcon(named: iconName)
        metricViews[key.rawValue] = metricView
        metricsStackView.addArrangedSubview(metricView)
        
        // Adjusting stack view for overflow into new rows if necessary
        if metricsStackView.frame.width > bounds.width {
            metricsStackView.axis = .vertical
            metricsStackView.distribution = .equalCentering
        }
    }
    
    func setMetricValue(forKey key: WeatherMetric, value: String, iconName: String, primaryColor color: UIColor) {
        if let metricView = metricViews[key.rawValue] {
            metricView.setSystemIcon(named: iconName)
            metricView.setTextLabel(to: value)
        } else {
            // If the metric does not exist, add it.
            addMetricView(key: key, primaryColor: color, iconName: iconName)
            metricViews[key.rawValue]?.setTextLabel(to: value)
        }
        
        // Automatically hide if the value indicates it should be hidden
        if value == "0" || value == "0%" || value == "0.0\"" || value == "0mph" {
            metricViews[key.rawValue]?.isHidden = true
        } else {
            metricViews[key.rawValue]?.isHidden = false
        }
    }
    
    // Example function to hide a specific metric
    func hideMetric(forKey key: WeatherMetric) {
        metricViews[key.rawValue]?.isHidden = true
    }
}
