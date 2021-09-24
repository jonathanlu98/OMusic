//
//  MIFont.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/4/30.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit

class MIFont: NSObject {
    
    public struct LanProWeight : Hashable {
        private(set) var description: String
        
        private init(description: String) {
            self.description = description
        }
    }
    
    static public func lanProFont(size: CGFloat,weight: MIFont.LanProWeight) -> UIFont {
        return UIFont.init(name: weight.description, size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }


}

extension MIFont.LanProWeight {

    static let extraLight: MIFont.LanProWeight = MIFont.LanProWeight(description: "MILanProVF-ExtraLight")

    static let thin: MIFont.LanProWeight = MIFont.LanProWeight(description: "MILanProVF-ExtraLight")

    static let light: MIFont.LanProWeight = MIFont.LanProWeight(description: "MILanProVF-Light")
    
    static let normal: MIFont.LanProWeight = MIFont.LanProWeight(description: "MILanProVF-Normal")

    static let regular: MIFont.LanProWeight = MIFont.LanProWeight(description: "MILanProVF-Regular")

    static let medium: MIFont.LanProWeight = MIFont.LanProWeight(description: "MILanProVF-Medium")

    static let demibold: MIFont.LanProWeight = MIFont.LanProWeight(description: "MILanProVF-DemiBold")
    
    static let semibold: MIFont.LanProWeight = MIFont.LanProWeight(description: "MILanProVF-SemiBold")

    static let bold: MIFont.LanProWeight = MIFont.LanProWeight(description: "MILanProVF-Bold")

    static let heavy: MIFont.LanProWeight = MIFont.LanProWeight(description: "MILanProVF-Heavy")

}
