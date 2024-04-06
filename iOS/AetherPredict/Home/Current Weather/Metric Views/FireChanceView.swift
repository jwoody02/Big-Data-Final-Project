//
//  FireChanceView.swift
//  AetherPredict
//
//  Created by Jordan Wood on 4/5/24.
//

import Foundation
import UIKit

enum FireChance: String {
    case low = "Low"
    case moderate = "Med"
    case high = "High"
}

class FireChanceView: MetricView {

    // Three segments, green, yellow, red
    private let segmentColors: [UIColor] = [
        UIColor(red: 161/255, green: 251/255, blue: 141/255, alpha: 1.0),
        UIColor(red: 254/255, green: 236/255, blue: 138/255, alpha: 1.0),
        UIColor(red: 255/255, green: 137/255, blue: 137/255, alpha: 1.0)
    ]

    private let fireChanceLabel: UILabel = {
        let label = UILabel()
        label.font = .nunito(ofSize: 8, weight: .bold)
        label.textAlignment = .center
        label.textColor = .primaryTint
        label.backgroundColor = .clear
        return label
    }()

    var currentFireChance: FireChance = .low

    override init(title: String, value: String, measureType: String) {
        super.init(title: title, value: value, measureType: measureType)

        // hide value label
        valueLabel.isHidden = true
        
        fireChanceLabel.translatesAutoresizingMaskIntoConstraints = false
        fireChanceLabel.textAlignment = .center
        addSubview(fireChanceLabel)

        setupSegments()

        self.bringSubviewToFront(fireChanceLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        // Remove all subviews to clear the previous state
        self.subviews.forEach { if $0.tag > 1027 && $0.tag < 1033 { $0.removeFromSuperview() } }
        // Setup the segments again to adjust for the new size
        setupSegments()

        // update the fireChanceLabel frame
        updateWithFireChance(currentFireChance)

        self.bringSubviewToFront(fireChanceLabel)
    }

    func updateFireChanceLabelLocation(for fireChance: FireChance) {
        // find the segment view
        let segmentView = self.viewWithTag(1028 + (fireChance == .low ? 0 : fireChance == .moderate ? 1 : 2))
        let xPosition = segmentView?.frame.origin.x ?? 10
        let segmentWidth = segmentView?.frame.width ?? 0
        fireChanceLabel.frame = CGRect(x: xPosition, y: titleLabel.frame.maxY + 3, width: segmentWidth, height: 10)
    }

    private func setupSegments() {
        let segmentWidth = ((self.bounds.width - 20) / CGFloat(segmentColors.count))
        var xPosition: CGFloat = 10

        var index = 0
        for color in segmentColors {
            // Initially setting up all segments with a height of 5px
            let segmentView = UIView(frame: CGRect(x: xPosition, y: titleLabel.frame.maxY + 8, width: segmentWidth, height: 5))
            segmentView.backgroundColor = color
            segmentView.layer.borderColor = color.cgColor
            segmentView.layer.borderWidth = 2
            segmentView.tag = 1028 + index
            self.addSubview(segmentView)

            xPosition += segmentWidth + 2
            index += 1
        }
    }

    public func updateWithFireChance(_ fireChance: FireChance) {
        currentFireChance = fireChance
        
        var segmentHeights = [FireChance.low: 10, FireChance.moderate: 5, FireChance.high: 5]
        var fireIndex = 0
        switch fireChance {
        case .low:
            break
        case .moderate:
            segmentHeights[.moderate] = 10
            segmentHeights[.low] = 5
            fireIndex = 1
        case .high:
            segmentHeights[.high] = 10
            segmentHeights[.low] = 5
            fireIndex = 2
        }
        fireChanceLabel.text = fireChance.rawValue.uppercased()

        // Adjust segment heights based on the current fireChance
        let segmentWidth = ((self.bounds.width - 20) / CGFloat(segmentColors.count))
        for (index, color) in segmentColors.enumerated() {
            let xPosition = CGFloat(index) * (segmentWidth + 2) + 10
            let segmentView = self.viewWithTag(1028 + index)
            
            let isCurrentSegment = index == fireIndex
            let height = isCurrentSegment ? 10 : 5
            segmentView?.frame = CGRect(x: xPosition, y: titleLabel.frame.maxY + (isCurrentSegment ? 3 : 8), width: segmentWidth, height: CGFloat(height))
            if isCurrentSegment {
                fireChanceLabel.textColor = .foregroundColor
            }
        }


        updateFireChanceLabelLocation(for: fireChance)
    }


}
