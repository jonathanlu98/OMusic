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
    
    var isValid: Bool = false
    
    private(set) var id: NSInteger?
    
    private(set) var updateTime: Date?
    
    private(set) var createTime: Date?
    
    private(set) var name: String? {
        didSet {
            updateTime = Date()
        }
    }
    
    private(set) var tracks: [JLTrack]? {
        didSet {
            updateTime = Date()
        }
    }
    
    private(set) var remark: String? {
        didSet {
            updateTime = Date()
        }
    }
    
    private(set) var coverUrl: URL? {
        didSet {
            updateTime = Date()
        }
    }
    
    private(set) var playCount: NSInteger = 0
    
    private(set) var isLiked: Bool = false
    
    static let tableDescription = "Playlists"
    
    internal var isAutoIncrement: Bool = true
    
    internal var lastInsertedRowID: Int64 = 0 {
        didSet {
            self.id = NSInteger(lastInsertedRowID)
        }
    }
    
    init(name: String, coverUrl: URL? = nil, remark: String? = nil, tracks: [JLTrack]? = nil) {
        self.name = name
        self.createTime = Date()
        self.updateTime = Date()
        self.coverUrl = coverUrl
        self.remark = remark
        self.tracks = tracks
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
        self.isValid = true
        self.createTime = object.createTime
        self.updateTime = object.updateTime
        self.name = object.name
        self.coverUrl = object.coverUrl
        self.remark = object.remark
        self.tracks = object.tracks
        self.playCount = object.playCount
        self.lastInsertedRowID = object.lastInsertedRowID
        self.isLiked = object.isLiked
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
        case remark
        case coverUrl
        case playCount
        case isLiked
        
        static var columnConstraintBindings: [JLPlaylist.CodingKeys : ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
                createTime: ColumnConstraintBinding(isNotNull: true),
                updateTime: ColumnConstraintBinding(isNotNull: true),
                playCount: ColumnConstraintBinding(isNotNull: true, defaultTo: 0),
                isLiked: ColumnConstraintBinding(isNotNull: true, defaultTo: false),
                name: ColumnConstraintBinding(isNotNull: true)
            ]
        }
    }

}



