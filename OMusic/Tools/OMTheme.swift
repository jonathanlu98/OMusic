//
//  OMTheme.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/3.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit

class OMTheme: NSObject {

    static var currentStyle: Style {
        get {
            guard let rawValue = UserDefaults.standard.value(forKey: "THEME_STYLE") else {
                let defaults = UserDefaults.standard
                defaults.set(OMTheme.Style.system.rawValue, forKey: "THEME_STYLE")
                defaults.synchronize()
                return .system
            }
            return .init(rawValue: rawValue as! Int)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue.rawValue, forKey: "THEME_STYLE")
            defaults.synchronize()
        }
    }
    
    public struct Style : Hashable, Equatable, RawRepresentable {
        public let rawValue: Int
        
        internal init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
    }
    
    static func getTextColor(lightColor: UIColor = THEME_TEXTBLACK_COLOR, darkColor: UIColor = UIColor.white) -> UIColor {
        return getColor(lightColor: lightColor, darkColor: darkColor)
    }
    
    static func getColor(lightColor: UIColor, darkColor: UIColor) -> UIColor {
        switch currentStyle {
        case .light:
            return lightColor
        case .dark:
            return darkColor
        case .system:
            return UIColor { (trainCollection) -> UIColor in
                if trainCollection.userInterfaceStyle == .dark {
                    return darkColor
                } else {
                    return lightColor
                }
            }
        default:
            return lightColor
        }
    }
    
    static func setColorAlpha(color: UIColor, alpha: CGFloat) -> UIColor {
        switch currentStyle {
        case .light, .dark:
            return color.setAlpha(alpha)
        case .system:
            return UIColor { (trainCollection) -> UIColor in
                return color.resolvedColor(with: UITraitCollection.current)
            }
        default:
            return color.setAlpha(alpha)
        }
    }
    
    static func getSFImage(title: String, pointSize: CGFloat, weight: UIImage.SymbolWeight) -> UIImage? {
        guard !title.isEmpty else {
            return nil
        }
        let image = UIImage.init(systemName: title, withConfiguration: UIImage.SymbolConfiguration.init(pointSize: pointSize, weight: weight))
        return image
    }
    
        
}


extension OMTheme.Style {
    static let light:OMTheme.Style = .init(rawValue: 0)
    static let dark:OMTheme.Style = .init(rawValue: 1)
    static let system:OMTheme.Style = .init(rawValue: 2)
}


