//
//  DetailedStatsView.swift
//  AetherPredict
//
//  Created by Jordan Wood on 4/3/24.
//

import Foundation
import UIKit
import WeatherKit
class DetailedStatsView: UIView {
    
    // MARK: - UI
    
    private let sunriseView = MetricView(title: "Sunrise", value: "", measureType: "")
    private let sunsetView = MetricView(title: "Sunset", value: "", measureType: "")
    private let highLowTempView = MetricView(title: "High/Low", value: "", measureType: "")
    private let uvIndexView = MetricView(title: "UV Index", value: "", measureType: "")
    private let pressureView = MetricView(title: "Pressure", value: "", measureType: "hPa")
    private let precipitationView = MetricView(title: "Precipitation", value: "", measureType: "%")
    private let humidityView = MetricView(title: "Humidity", value: "", measureType: "%")
    private let windView = MetricView(title: "Wind", value: "", measureType: "mph")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(sunriseView)
        addSubview(sunsetView)
        addSubview(highLowTempView)
        addSubview(uvIndexView)
        addSubview(pressureView)
        addSubview(precipitationView)
        addSubview(humidityView)
        addSubview(windView)

        NSLayoutConstraint.activate([
            sunriseView.topAnchor.constraint(equalTo: topAnchor),
            sunriseView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sunriseView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            sunsetView.topAnchor.constraint(equalTo: sunriseView.bottomAnchor, constant: 8),
            sunsetView.leadingAnchor.constraint(equalTo: leadingAnchor),
            sunsetView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            highLowTempView.topAnchor.constraint(equalTo: sunsetView.bottomAnchor, constant: 8),
            highLowTempView.leadingAnchor.constraint(equalTo: leadingAnchor),
            highLowTempView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            uvIndexView.topAnchor.constraint(equalTo: highLowTempView.bottomAnchor, constant: 8),
            uvIndexView.leadingAnchor.constraint(equalTo: leadingAnchor),
            uvIndexView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            pressureView.topAnchor.constraint(equalTo: uvIndexView.bottomAnchor, constant: 8),
            pressureView.leadingAnchor.constraint(equalTo: leadingAnchor),
            pressureView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            precipitationView.topAnchor.constraint(equalTo: pressureView.bottomAnchor, constant: 8),
            precipitationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            precipitationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            humidityView.topAnchor.constraint(equalTo: precipitationView.bottomAnchor, constant: 8),
            humidityView.leadingAnchor.constraint(equalTo: leadingAnchor),
            humidityView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            windView.topAnchor.constraint(equalTo: humidityView.bottomAnchor, constant: 8),
            windView.leadingAnchor.constraint(equalTo: leadingAnchor),
            windView.trailingAnchor.constraint(equalTo: trailingAnchor),
            windView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    public func resetMetrics() {
        sunriseView.value = ""
        sunsetView.value = ""
        highLowTempView.value = "-- / --"
        uvIndexView.value = ""
        pressureView.value = ""
        precipitationView.value = ""
        humidityView.value = ""
        windView.value = ""
    }
    
    public func updateWith(currentWeather: CurrentWeather, dayForecast: DayWeather) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        sunriseView.value = formatter.string(from: dayForecast.sun.sunrise ?? Date())
        sunsetView.value = formatter.string(from: dayForecast.sun.sunset ?? Date())

        let highLowString = "↑\(dayForecast.highTemperature.value) ↓\(dayForecast.lowTemperature.value)"
        highLowTempView.value = highLowString

        uvIndexView.value = "\(currentWeather.uvIndex.value)"
        pressureView.value = "\(currentWeather.pressure.value)"
        precipitationView.value = "\(dayForecast.precipitationChance)"
        humidityView.value = "\(currentWeather.humidity)"
        windView.value = "\(currentWeather.wind.speed.value)"
    }
}
