//
//  WeeklyForcastView.swift
//  AetherPredict
//
//  Created by Jordan Wood on 3/31/24.
//

import Foundation
import UIKit
import WeatherKit

class WeeklyForecastCollectionView: UIView, UICollectionViewDataSource {
    
    public static let DAY_FORCAST_COUNT = 10 // how many days to show forecast for
    private var weeklyForecast: [DayWeather] = []
    private var weeklyLowValue: Double = 0
    private var weeklyHighValue: Double = 0
    public var currentTempCelcius: Double = 0

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: Int(UIScreen.main.bounds.width), height: WeeklyWeatherCollectionViewCell.WEEKLY_FORECAST_HEIGHT)
        layout.minimumLineSpacing = 4
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(WeeklyWeatherCollectionViewCell.self, forCellWithReuseIdentifier: WeeklyWeatherCollectionViewCell.identifier)
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weeklyForecast.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeeklyWeatherCollectionViewCell.identifier, for: indexPath) as? WeeklyWeatherCollectionViewCell else {
            fatalError("Unable to dequeue WeeklyWeatherCollectionViewCell")
        }
        
        // ui config
        cell.configure(with: weeklyForecast[indexPath.row])
        
        // custom day label text
        if indexPath.row == 0 {
            cell.dayLabel.text = "Today"
            cell.temperatureRangeView.setCurrentValue(currentTempCelcius)
        } else if indexPath.row == 1 {
            cell.dayLabel.text = "Tomorrow"
            cell.temperatureRangeView.setCurrentValue(nil)
        }
        
        // temperature range view
        cell.temperatureRangeView.setHighValueForWeek(self.weeklyHighValue)
        cell.temperatureRangeView.setLowValueForWeek(self.weeklyLowValue)
        
        return cell
    }

    // Call this method to update the collection view with new data
    func update(with forecast: [DayWeather]) {
        self.weeklyLowValue = forecast.map { $0.lowTemperature.value }.min() ?? 0
        self.weeklyHighValue = forecast.map { $0.highTemperature.value }.max() ?? 0
        self.weeklyForecast = forecast
        collectionView.reloadData()
    }
}
