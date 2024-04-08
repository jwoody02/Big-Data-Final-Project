//
//  SunLocationView.swift
//  AetherPredict
//
//  Created by Jordan Wood on 4/4/24.
//

import Foundation
import UIKit


class SunView: UIView {
    
    private let sunImageView = UIImageView()
    private let pathLayer = CAShapeLayer()
    private let sunPathLayer = CAShapeLayer()
    
    

    private let leftBall: UIView = {
        let view = UIView()
        view.backgroundColor = .primaryTint
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let rightBall: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryTint
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        clipsToBounds = true
    }
    
    private func setupView() {
        // Path for the entire arc
        pathLayer.strokeColor = UIColor.secondaryTint.cgColor
        pathLayer.lineWidth = 3
        pathLayer.fillColor = nil
        pathLayer.lineDashPattern = [2, 3] // Dashed pattern
        layer.addSublayer(pathLayer)
        
        // Path for the current sun position (solid line)
        sunPathLayer.strokeColor = UIColor.primaryTint.cgColor
        sunPathLayer.lineWidth = 3
        sunPathLayer.fillColor = nil
        layer.addSublayer(sunPathLayer)
        
        // Set up the sun image view
        sunImageView.image = UIImage(systemName: "sun.max.fill") // Use your own sun image asset
        sunImageView.tintColor = .orangishYellow
        sunImageView.contentMode = .scaleAspectFit
        sunImageView.translatesAutoresizingMaskIntoConstraints = false // Use Auto Layout
        addSubview(sunImageView)
        
        addSubview(leftBall)
        addSubview(rightBall)
        
        // Constraints for the sunImageView to keep it centered
        NSLayoutConstraint.activate([
            sunImageView.widthAnchor.constraint(equalToConstant: 24),
            sunImageView.heightAnchor.constraint(equalTo: sunImageView.widthAnchor),
            sunImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            leftBall.widthAnchor.constraint(equalToConstant: 6),
            leftBall.heightAnchor.constraint(equalTo: leftBall.widthAnchor),
            leftBall.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            leftBall.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1),

            rightBall.widthAnchor.constraint(equalToConstant: 6),
            rightBall.heightAnchor.constraint(equalTo: rightBall.widthAnchor),
            rightBall.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            rightBall.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1)
        ])
    }
    
    func updateSunPosition(currentTime: Date, sunrise: Date, sunset: Date) {
        let totalDaylightSeconds = sunset.timeIntervalSince(sunrise)
        let currentSeconds = currentTime.timeIntervalSince(sunrise)
        var sunPositionRatio = currentSeconds / totalDaylightSeconds
        
        // If it is past sunset, keep the sun at the end of the path
        if currentTime > sunset {
            sunPositionRatio = 1.0
        }
        
        // Ensure the ratio is between 0 and 1
        let clampedRatio = min(max(sunPositionRatio, 0), 1)
        // Calculate the position of the sun on the arc
        let arcCenter = CGPoint(x: bounds.midX, y: bounds.maxY)
        let radius = (bounds.width - 8) / 2
        let angle = CGFloat(clampedRatio) * .pi // Angle ranges from 0 to π (half circle)
        
        let sunXPosition = arcCenter.x - radius * cos(angle)
        let sunYPosition = arcCenter.y - radius * sin(angle)
        
        // Update the sun image position
        sunImageView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.sunImageView.center = CGPoint(x: sunXPosition, y: sunYPosition)
        })
        
        // Update the sun path (solid line) to reflect the path taken so far
        let sunPath = UIBezierPath(arcCenter: arcCenter, radius: radius,
                                   startAngle: .pi, endAngle: angle + .pi, clockwise: false)
        pathLayer.path = sunPath.cgPath
        
        // Update the full path (dashed line) to show the remaining path
        if currentTime <= sunset {
            let fullPath = UIBezierPath(arcCenter: arcCenter, radius: radius,
                                        startAngle: angle + .pi, endAngle: 0, clockwise: false)
            sunPathLayer.path = fullPath.cgPath
        } else {
            // If it's past sunset, don't show the dashed line
            sunPathLayer.path = nil
        }
    }
    
    override func layoutSubviews() {
           super.layoutSubviews()
       }
}
