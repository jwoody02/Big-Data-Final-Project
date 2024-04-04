//
//  UVIndexView.swift
//  AetherPredict
//
//  Created by Jordan Wood on 4/4/24.
//

import Foundation
import UIKit

class UVIndexView: MetricView {
        override init(title: String, value: String, measureType: String) {
            super.init(title: title, value: value, measureType: measureType)

            // hide value label
            valueLabel.isHidden = true

        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
}