//
//  JLPlaylist.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/4.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import Foundation
import WCDBSwift


class JLPlaylist: JLMediaProtocol {
        
    private(set) var id: NSInteger?
    
    internal var updateTime: Date?

    private(set) var createTime: Date?
    
    private(set) var name: String?
    
    private(set) var tracks: [JLTrack]?
    
    var isLiked: Bool? = false {
        didSet {
            if isLiked ?? false {
                likedTime = Date()
            } else {
                likedTime = nil
            }
            try? JLDatabase.database.update(table: Self.tableDescription, on: [Self.CodingKeys.isLiked, Self.CodingKeys.likedTime], with: self, where: Self.CodingKeys.id == self.id ?? 0)
        }
        
    }
    
    private(set) var likedTime: Date?
    
    static let tableDescription = "Playlists"
    
    internal var isAutoIncrement: Bool = true
    
    internal var lastInsertedRowID: Int64 = 0 {
        didSet {
            self.id = NSInteger(lastInsertedRowID)
        }
    }
    
    init(name: String, tracks: [JLTrack]? = nil) {
        self.name = name
        self.createTime = Date()
        self.updateTime = Date()
        self.tracks = tracks
        
        JLDatabase.shared.insertIfNotExist(self)
    }
    
    required init?(with value: FundamentalValue) {
        let data = value.dataValue
        guard data.count > 0 else {
            return nil
        }
        guard let dictionary = try? JSONDecoder().decode([String: String].self, from: data) else {
            return nil
        }
        self.id = NSInteger.init(dictionary["id"] ?? "-1") ?? -1
        guard let object: JLPlaylist = JLDatabase.shared.getObject(id: id!) else {
            return
        }
        self.createTime = object.createTime
        self.updateTime = object.updateTime
        self.name = object.name
        self.tracks = object.tracks
        self.isLiked = object.isLiked
        self.likedTime = object.likedTime
        self.lastInsertedRowID = object.lastInsertedRowID
    }
}



//MARK: JLPlaylist.Equatable

extension JLPlaylist: Equatable {
    
    static func == (lhs: JLPlaylist, rhs: JLPlaylist) -> Bool {
        if lhs.id == rhs.id {
            return true
        } else {
            return false
        }
    }
    
}



//MARK: 模型绑定

extension JLPlaylist {
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = JLPlaylist
        static let objectRelationalMapping: TableBinding<JLPlaylist.CodingKeys> = .init(CodingKeys.self)
        
        case id
        case updateTime
        case createTime
        case name
        case tracks
        case isLiked
        case likedTime
        
        static var columnConstraintBindings: [JLPlaylist.CodingKeys : ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
//                createTime: ColumnConstraintBinding(isNotNull: true),
//                updateTime: ColumnConstraintBinding(isNotNull: true),
//                playCount: ColumnConstraintBinding(isNotNull: true, defaultTo: 0),
//                isLiked: ColumnConstraintBinding(isNotNull: true, defaultTo: false),
//                name: ColumnConstraintBinding(isNotNull: true)
            ]
        }
    }

}



