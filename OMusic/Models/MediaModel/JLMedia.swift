//
//  JLMedia.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/7.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import WCDBSwift


protocol JLMediaProtocol: AnyObject, TableCodable, ColumnCodable {
    
    var id: NSInteger? { get }
    var updateTime: Date? { get set }
    var createTime: Date? { get }
    static var tableDescription: String { get }
    var isLiked: Bool? { get set }
    var likedTime: Date? { get }
}


//MARK: 自定义字段映射类型

extension JLMediaProtocol {
    func archivedValue() -> FundamentalValue {
        guard let data = try? JSONEncoder().encode([
            "table": Self.tableDescription,
            "id": String(id ?? -1)]) else {
            return FundamentalValue(nil)
        }
        return FundamentalValue(data)
    }
    
    static var columnType: ColumnType {
        return .BLOB
    }
}



