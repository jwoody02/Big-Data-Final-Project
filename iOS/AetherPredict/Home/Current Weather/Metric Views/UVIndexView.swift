//
//  UVIndexView.swift
//  AetherPredict
//
//  Created by Jordan Wood on 4/4/24.
//

import Foundation
import UIKit

class UVIndexView: MetricView {
        let greenToRedView = GreenToRedView()
        let uvIndexLabel: UILabel = {
            let label = UILabel()
            label.font = .nunito(ofSize: 14, weight: .bold)
            label.textAlignment = .center
            label.textColor = .primaryTint
            label.backgroundColor = .foregroundColor
            return label
        }()
        override init(title: String, value: String, measureType: String) {
            super.init(title: title, value: value, measureType: measureType)

            // hide value label
            valueLabel.isHidden = true
            
            greenToRedView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(greenToRedView)
            
            NSLayoutConstraint.activate([
                greenToRedView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                greenToRedView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                greenToRedView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
                greenToRedView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
            ])

            uvIndexLabel.translatesAutoresizingMaskIntoConstraints = false
            addSubview(uvIndexLabel)
        }
        
        public func updateWithUVIndex(_ uvIndex: Int) {
            var uvIndexColor: UIColor = .clear
            switch uvIndex {
            case 0...2:
                uvIndexColor = .green
            case 3...4:
                uvIndexColor = .yellow
            case 5...6:
                uvIndexColor = .orange
            case 7...10:
                uvIndexColor = .red
            default:
                break
            }
            uvIndexLabel.text = "\(uvIndex)"
            uvIndexLabel.textColor = uvIndexColor

            // calculate offset from center based on uvIndex, we want the uvIndexLabel to show up on top of the correct segment
            let offsetFromCenter = (uvIndex - 1) * Int(greenToRedView.bounds.width) / 8
            uvIndexLabel.centerXAnchor.constraint(equalTo: greenToRedView.leadingAnchor, constant: CGFloat(offsetFromCenter)).isActive = true
            uvIndexLabel.centerYAnchor.constraint(equalTo: greenToRedView.centerYAnchor).isActive = true
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}
