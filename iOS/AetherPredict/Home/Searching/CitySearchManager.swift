//
//  CitySearchManager.swift
//  AetherPredict
//
//  Created by Jordan Wood on 4/2/24.
//

import Foundation
import os.log
struct City {
    let name: String
    let state: String
    let population: Int
    let lat: String
    let lon: String
}


class CitySearchManager {
    private var cities: [City] = []
    private let queue = DispatchQueue(label: "com.yourapp.citysearchmanager")
    private var fuse: Fuse = Fuse()
    private var currentSearchToken: UUID?

    init() {
        loadCities()
    }

    private func loadCities() {
        guard let filePath = Bundle.main.path(forResource: "us-top-1k-cities", ofType: "csv") else { return }
        do {
            let data = try String(contentsOfFile: filePath)
            let rows = data.components(separatedBy: "\n")
            self.cities = rows.compactMap { row -> City? in
                let columns = row.components(separatedBy: ",")
                guard columns.count == 5,
                      let population = Int(columns[2]) else {
                    return nil
                }
                return City(name: columns[0], state: columns[1], population: population, lat: columns[3], lon: columns[4])
            }
        } catch {
            os_log(.fault, "Error reading CSV file: \(error)")
        }
    }
    
    func search(with term: String, completion: @escaping ([City]) -> Void) {
        let searchToken = UUID()
        currentSearchToken = searchToken

        queue.async {
            // Assuming the fuse.search method allows for configuration to search through multiple fields, adapt as necessary.
            let results = self.fuse.search(term, in: self.cities.map { "\($0.name) \($0.state)" })

            let matchedCities = results.map { self.cities[$0.index] }.prefix(20)

            DispatchQueue.main.async {
                guard self.currentSearchToken == searchToken else { return }
                completion(Array(matchedCities))
            }
        }
    }
}
