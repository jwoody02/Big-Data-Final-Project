//
//  MetricView.swift
//  AetherPredict
//
//  Created by Jordan Wood on 4/3/24.
//

import Foundation
import UIKit

class MetricView: UIView {
    
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .nunito(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.textColor = .secondaryTint
        return label
    }()
    
    public let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .nunito(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.textColor = .primaryTint
        return label
    }()
    
    
    var title: String = "" {
        didSet {
            titleLabel.text = title.uppercased()
        }
    }
    
    var value: String = "" {
        didSet {
            updateValueLabel()
        }
    }
    
    var measureType: String = "" {
        didSet {
            updateValueLabel()
        }
    }
    
    init(title: String, value: String, measureType: String) {
        super.init(frame: .zero)
        self.title = title
        self.value = value
        self.measureType = measureType
        self.titleLabel.text = self.title
        self.translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        self.isHidden = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func updateValueLabel() {
        valueLabel.text = "\(value)\(measureType)"
    }
}
