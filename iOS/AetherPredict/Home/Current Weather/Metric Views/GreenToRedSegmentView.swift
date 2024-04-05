//
//  GreenToRedSegmentView.swift
//  AetherPredict
//
//  Created by Jordan Wood on 4/4/24.
//

import Foundation
import UIKit

class GreenToRedView: UIView {
    
    private let segmentColors: [UIColor] = [
        .green, .green,     // First 2 segments are green
        .yellow, .yellow,  // Next 2 segments are yellow
        .orange, .orange,   // Next 2 segments are orange
        .red, .red   // Next 2 segments are red
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSegments()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSegments()
    }
    
    private func setupSegments() {
        let segmentWidth = (self.bounds.width / CGFloat(segmentColors.count))
        var xPosition: CGFloat = 0
        
        for color in segmentColors {
            let segmentView = UIView(frame: CGRect(x: xPosition, y: 0, width: segmentWidth, height: self.bounds.height))
            segmentView.backgroundColor = color
            self.addSubview(segmentView)
            
            xPosition += segmentWidth + 2
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Remove all subviews to clear the previous state
        self.subviews.forEach { $0.removeFromSuperview() }
        // Setup the segments again to adjust for the new size
        setupSegments()
    }
}
