//
//  CitySearchManager.swift
//  AetherPredict
//
//  Created by Jordan Wood on 4/2/24.
//

import Foundation
struct City: Codable {
    let name: String
    let lat: String
    let lng: String
    let country: String
    let admin1: String
    let admin2: String
}


class CitySearchManager {
    private let fuse = Fuse()
    private var cities: [City] = []
    private let queue = DispatchQueue(label: "com.aether.citysearchmanager", attributes: .concurrent)
    
    init() {
        loadCities()
    }
    
    private func loadCities() {
        if let url = Bundle.main.url(forResource: "cities", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            cities = (try? decoder.decode([City].self, from: data)) ?? []
        }
    }
    
    func search(text: String, completion: @escaping ([City]) -> Void) {
        queue.async {
            let results = self.fuse.search(text, in: self.cities.map { $0.name })
            let matchedCities = results.map { self.cities[$0.index] }.prefix(20)
            DispatchQueue.main.async {
                completion(Array(matchedCities))
            }
        }
    }
}
