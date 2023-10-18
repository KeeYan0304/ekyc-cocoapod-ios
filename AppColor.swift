//
//  AppColor.swift
//  VeryfyClientSDK
//
//  Created by Kee Chun Yan on 04/10/2023.
//

import Foundation
import UIKit

class K {
    struct Colors {
        static let primaryColor = UIColor(hexString: "#1564C0")
        
        static let outerBgColor = UIColor(hexString: "#F9F9F9")
        
        static let imageBgColor = UIColor(hexString: "#D9D9D9")
        
        static let disableColor = UIColor(hexString: "#626262")
        
        static let completeColor = UIColor(hexString: "#98FFA2")
        
        static let pendingColor = UIColor(hexString: "#B9B9B9")
        
        static let lightGray = UIColor(hexString: "#E9E9E9")
        
        static let attentionColor = UIColor(hexString: "F9EBDF")
        
        static let headerAttentionColor = UIColor(hexString: "FA8B01")
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
