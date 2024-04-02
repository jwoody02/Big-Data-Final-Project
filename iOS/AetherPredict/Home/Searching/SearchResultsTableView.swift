//
//  SearchResultsTableView.swift
//  AetherPredict
//
//  Created by Jordan Wood on 4/1/24.
//

import Foundation
import UIKit
import MapKit

class SearchResultsTableView: UIView, UITableViewDataSource, UITableViewDelegate {
   
    var places: [MKMapItem] = []
    let searchLock = NSLock()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlaceCell")
        tableView.backgroundColor = .clear
        return tableView
    }()
    var searchterm = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showResultsForSearchString(_ searchTerm: String) {
        // TODO
    }

     // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath)
        let place = places[indexPath.row]
        cell.textLabel?.text = place.name
        cell.textLabel?.textColor = .primaryTint
        cell.textLabel?.font = .nunito(ofSize: 16, weight: .medium)
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        configureCell(cell: cell, with: place, searchTerm: searchterm)
        return cell
    }
    
    func configureCell(cell: UITableViewCell, with place: MKMapItem, searchTerm: String) {
        let fullText = place.name ?? ""
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Define attributes
        let primaryAttributes = [NSAttributedString.Key.foregroundColor: UIColor.primaryTint]
        let secondaryAttributes = [NSAttributedString.Key.foregroundColor: UIColor.secondaryTint]
        
        // Apply secondary color to the entire text initially
        attributedString.addAttributes(secondaryAttributes, range: NSRange(location: 0, length: attributedString.length))
        
        // Highlight matching characters with primary color
        searchTerm.lowercased().forEach { char in
            let str = String(char)
            var range = (fullText.lowercased() as NSString).range(of: str)
            while range.location != NSNotFound {
                attributedString.addAttributes(primaryAttributes, range: range)
                let nextLocation = range.location + range.length
                if nextLocation < fullText.count {
                    range = (fullText.lowercased() as NSString).range(of: str, options: [], range: NSRange(location: nextLocation, length: fullText.count - nextLocation))
                } else {
                    break
                }
            }
        }
        
        // Assuming your cell has a UILabel named 'label'
        cell.textLabel?.attributedText = attributedString
    }
    
}
