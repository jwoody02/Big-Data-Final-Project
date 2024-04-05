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
    
    // Keep a reference to the centerX constraint
    var uvLabelCenterXConstraint: NSLayoutConstraint?

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
        uvIndexLabel.centerYAnchor.constraint(equalTo: greenToRedView.centerYAnchor).isActive = true
    }
    
    public func updateWithUVIndex(_ uvIndex: Int) {
        var uvIndexColor: UIColor = .clear
        switch uvIndex {
        case 0...2:
            uvIndexColor = .green
        case 3...5:
            uvIndexColor = .yellow
        case 6...7:
            uvIndexColor = .orange
        case 8...10:
            uvIndexColor = .red
        default:
            uvIndexColor = .gray // Handle default case to avoid clear color
        }
        uvIndexLabel.text = "\(uvIndex)"
        uvIndexLabel.textColor = uvIndexColor

        // Deactivate the previous constraint
        if let uvLabelCenterXConstraint = uvLabelCenterXConstraint {
            uvLabelCenterXConstraint.isActive = false
        }

        // Calculate offset from center based on uvIndex
        let offsetFromCenter = (uvIndex - 1) * Int(greenToRedView.bounds.width) / 8
        UIView.animate(withDuration: 0.3, animations: {
            self.uvLabelCenterXConstraint = self.uvIndexLabel.centerXAnchor.constraint(equalTo: self.greenToRedView.leadingAnchor, constant: CGFloat(offsetFromCenter))
            self.uvLabelCenterXConstraint?.isActive = true
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
