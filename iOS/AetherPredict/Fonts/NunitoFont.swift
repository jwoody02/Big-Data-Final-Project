//
//  NunitoFont.swift
//  AetherPredict
//
//  Created by Jordan Wood on 3/31/24.
//

import Foundation
import UIKit

extension UIFont {
    
    enum NunitoWeight {
        case light
        case medium
        case bold
        
        var fontName: String {
            switch self {
            case .light:
                return "Nunito-Light"
            case .medium:
                return "Nunito-Medium"
            case .bold:
                return "Nunito-Bold"
            }
        }
    }
    
    static func nunito(ofSize size: CGFloat, weight: NunitoWeight) -> UIFont {
        return UIFont(name: weight.fontName, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}

