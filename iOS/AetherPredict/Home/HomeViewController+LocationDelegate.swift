//
//  HomeViewController+LocationDelegate.swift
//  AetherPredict
//
//  Created by Jordan Wood on 4/1/24.
//

import Foundation
import CoreLocation
import os.log
import UIKit

// delegate for getting current weather information
extension HomeViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if alreadyGotCurrentLocation { return }
        guard let unwrappedLocation = manager.location else { return }
        self.alreadyGotCurrentLocation = true
        
        os_log(.info, "Received 'didUpdateLocations' message from CLLocationManager")

        // prevent multiple requests for the same location (reducing costs basically)
        if let previousLocation = self.previousLocation, previousLocation.coordinate.latitude == unwrappedLocation.coordinate.latitude && previousLocation.coordinate.longitude == unwrappedLocation.coordinate.longitude {
            os_log(.debug, "Ignoring 'didUpdateLocations' message as the current user's location is the same as last time")
            return
        }
        
        // prevent multiple requests from same city
        unwrappedLocation.fetchCityAndCountry { [weak self] city, _, error in
            guard let city = city, error == nil, let self = self else { return }
            
            if self.previousCity ?? "" == city {
                os_log(.debug, "Ignoring 'didUpdateLocations' message as the user's city is same as before")
                return
            }
            
            self.previousLocation = unwrappedLocation
            self.previousCity = city
            self.locationLabel.text = city
            
            self.weatherService.fetchWeather(for: unwrappedLocation) { [weak self] result in
                // prevent memory leak
                guard let self = self else { return }
                
                // Update ui for weather object
                switch result {
                case .success(let (current, minute, hourly, daily)):
                    os_log(.info, "Updating UI with weather information")
                    DispatchQueue.main.async {
                        self.updateUIWith(currentForecast: current, minuteForcast: minute, hourForcast: hourly, dayWeather: daily)
                    }
                    break
                case .failure(let error):
                    os_log(.error, "Error fetching weather: %@", error.localizedDescription)
                    
                    // show error to user
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Error", message: "Failed to fetch weather data.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    break
                }
            }
        }
        
    }
}

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}
