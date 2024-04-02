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
    private let queue = DispatchQueue(label: "com.aether.citysearchmanager")
    private var currentSearchToken: UUID?

    
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
    
    func search(with term: String, completion: @escaping ([City]) -> Void) {
        let searchToken = UUID()
        currentSearchToken = searchToken

        queue.async {
            // Perform fuzzy search. Assume `search` method returns array of `Fusable` objects or similar.
            let fuseResults = self.fuse.search(term, in: self.cities.map { $0.name })

            // Assuming `fuseResults` contains indices or objects that allow fetching the matched items.
            let matchedCities = fuseResults.map { self.cities[$0.index] }.prefix(20)

            DispatchQueue.main.async {
                // Ignore results if this isn't the latest search
                guard self.currentSearchToken == searchToken else { return }
                completion(Array(matchedCities))
            }
        }
    }

}
