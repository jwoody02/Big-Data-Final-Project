//
//  WeatherMetricView.swift
//  AetherPredict
//
//  Created by Jordan Wood on 3/21/24.
//

import Foundation
import UIKit

class WeatherMetricView: UIView {
    
    static let DEFAULT_HEIGHT: CGFloat = 30
    
    var heightConstraint: NSLayoutConstraint?
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        return imageView
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        return label
    }()
    
    var primaryColor: UIColor {
        didSet {
            // Update UI elements that depend on the primary color
            textLabel.textColor = primaryColor
            iconImageView.tintColor = primaryColor
        }
    }
    
    var systemIconName: String? {
        didSet {
            // Update the icon image view
            if let iconName = systemIconName {
                iconImageView.image = UIImage(systemName: iconName)?.withRenderingMode(.alwaysTemplate)
                iconImageView.tintColor = primaryColor
            } else {
                iconImageView.image = nil
            }
        }
    }
    
    init(primaryColor: UIColor, systemIconName: String? = nil) {
        self.primaryColor = primaryColor
        super.init(frame: .zero)
        
        self.systemIconName = systemIconName
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(iconImageView)
        addSubview(textLabel)
        
        // Constraints for iconImageView
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            iconImageView.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        // Constraints for textLabel
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8)
        ])
        
        // Height constraint
        heightConstraint = heightAnchor.constraint(equalToConstant: WeatherMetricView.DEFAULT_HEIGHT)
        heightConstraint?.isActive = true
    }
    
    func setPrimaryColor(to color: UIColor) {
        self.primaryColor = color
    }

    func setSystemIcon(named iconName: String?) {
        self.systemIconName = iconName
    }
    
    func minimize() {
        heightConstraint?.constant = 0
        UIView.animate(withDuration: 0.0) {
            self.superview?.layoutIfNeeded()
        }
    }
    
    func maximize() {
        heightConstraint?.constant = WeatherMetricView.DEFAULT_HEIGHT
        UIView.animate(withDuration: 0.0) {
            self.superview?.layoutIfNeeded()
        }
    }
}
