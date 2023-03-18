//
//  UIColor.swift
//  Muk
//
//  Created by JINSEOK on 2023/03/15.
//

import UIKit

/// Hex Code로 나타낸 색상
enum HexCode: String {
    case backGorund = "e2eafc"
    case tabBarBackground = "edf2fb"
    case unselected = "c1d3fe"
    case selected = "788bff"
    
    var color: UIColor {
        return UIColor(hexCode: self.rawValue)
    }
}

extension UIColor {
    /// Hex Code를 통한 색상 변환
    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
}
