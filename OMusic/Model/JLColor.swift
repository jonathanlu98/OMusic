//
//  JLColor.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/21.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import WCDBSwift
import SwiftHEXColors



class JLColor: ColumnCodable {

    
    private(set) var hexString: String
    
    private(set) var alpha: Float
    
    fileprivate var alphaString: String? {
        get {
            return String.init(format: "%.2f", alpha)
        }
    }
    
    public init?(hexString: String, alpha: Float = 1) {
        guard let _ = UIColor.init(hexString: hexString, alpha: alpha) else {
            return nil
        }
        self.hexString = hexString
        self.alpha = alpha
        
    }
    
    public func getColor() -> UIColor? {
        return UIColor.init(hexString: hexString, alpha: alpha)
    }
    
    public func archivedValue() -> FundamentalValue {
        guard let data = try? JSONEncoder().encode([
            "hex": hexString,
            "alpha": alphaString]) else {
            return FundamentalValue(nil)
        }
        return FundamentalValue(data)
    }
    
    public static var columnType: ColumnType {
        return .BLOB
    }
    
    public required convenience init?(with value: FundamentalValue) {
        let data = value.dataValue
        guard data.count > 0 else {
            return nil
        }
        guard let dictionary = try? JSONDecoder().decode([String: String].self, from: data) else {
            return nil
        }
        
        guard let hexString = dictionary["hex"], let alphaString = dictionary["alpha"] else {
            return nil
        }
        self.init(hexString: hexString, alpha: Float(alphaString) ?? 1)
        
    }
}

