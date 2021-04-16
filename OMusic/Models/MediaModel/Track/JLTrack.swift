//
//  JLTrack.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/5.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import WCDBSwift

class JLTrack: JLMediaProtocol {
            
    private(set) var id: Int?
    
    internal var updateTime: Date?

    private(set) var createTime: Date?
    
    private(set) var amjsonData: Data?
    
    private(set) var amId: String?
    
    private(set) var name: String?
    
    private(set) var artists: [JLArtist]?
    
    private(set) var album: JLAlbum?
    
    private(set) var isrc: String?
    
    private(set) var url: URL?
    
    var recentPlayTime: Date? {
        didSet {
            try? JLDatabase.database.update(table: Self.tableDescription, on: [Self.CodingKeys.recentPlayTime], with: self, where: Self.CodingKeys.amId == self.amId!)
        }
    }
                    
    var isLiked: Bool? = false {
        didSet {
            if isLiked ?? false {
                likedTime = Date()
            } else {
                likedTime = nil
            }
            try? JLDatabase.database.update(table: Self.tableDescription, on: [Self.CodingKeys.isLiked, Self.CodingKeys.likedTime], with: self, where: Self.CodingKeys.amId == self.amId!)
        }
        

        
    }
    
    private(set) var likedTime: Date?
    
    static let tableDescription = "Tracks"
        
    internal var isAutoIncrement: Bool = true
    
    internal var lastInsertedRowID: Int64 = 0 {
        didSet {
            self.id = NSInteger(lastInsertedRowID)
        }
    }
    
    var amTrack: AMTrack?
    

    init?(amTrack: AMTrack, artists: [JLArtist]? = nil, album: JLAlbum? = nil) {
        guard let url = amTrack.attributes?.previews?.first?.url else {
            return nil
        }
        if let object:JLTrack = JLDatabase.shared.getObject(amId: amTrack.id) {
            self.id = object.id
            self.createTime = object.createTime
            self.updateTime = Date.init()
            
            self.amTrack = amTrack
            self.url = URL.init(string: url)
            self.amjsonData = try? JSONEncoder().encode(amTrack)
            self.isrc = amTrack.attributes?.isrc
            self.amId = amTrack.id
            self.name = amTrack.attributes?.name ?? object.name
            
            self.artists = artists ?? object.artists
            self.album = album ?? object.album
            self.isLiked = object.isLiked
            self.likedTime = object.likedTime
            self.recentPlayTime = object.recentPlayTime
            self.lastInsertedRowID = object.lastInsertedRowID
            
        } else {
            self.createTime = Date.init()
            self.updateTime = Date.init()
            self.amTrack = amTrack
            self.url = URL.init(string: url)
            self.amjsonData = try? JSONEncoder().encode(amTrack)
            self.isrc = amTrack.attributes?.isrc
            self.amId = amTrack.id
            self.name = amTrack.attributes?.name ?? "未知歌曲"
            self.artists = artists
            self.album = album
            
        }
        
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
        var property = Self.CodingKeys.all
        //自定义映射不再映射属性中的自定义映射
        property = property.filter { (item) -> Bool in
            if item.codingTableKey as! JLTrack.CodingKeys == Self.CodingKeys.album || item.codingTableKey as! JLTrack.CodingKeys == Self.CodingKeys.artists {
                return false
            } else {
                return true
            }
        }
        guard let object: JLTrack = JLDatabase.shared.getObject(id: id!, on: property) else {
            return nil
        }
        self.createTime = object.createTime
        self.updateTime = object.updateTime
        self.amjsonData = object.amjsonData
        self.amId = object.amId
        self.name = object.name
//        self.artists = object.artists
//        self.album = object.album
        self.isrc = object.isrc
        self.url = object.url
        self.isLiked = object.isLiked
        self.likedTime = object.likedTime
        self.recentPlayTime = object.recentPlayTime
        self.lastInsertedRowID = object.lastInsertedRowID
        self.amTrack = (object.amjsonData != nil) ? try? JSONDecoder().decode(AMTrack.self, from: object.amjsonData!):nil
    }
    
}



//MARK: JLTrack.Equatable

extension JLTrack: Equatable {
    
    static func == (lhs: JLTrack, rhs: JLTrack) -> Bool {
        if lhs.id == rhs.id {
            return true
        } else {
            return false
        }
    }
    
}



//MARK: 模型绑定

extension JLTrack {
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = JLTrack
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case id
        case createTime
        case updateTime
        case name
        case artists
        case album
        case amjsonData
        case url
        case isLiked
        case isrc
        case amId
        case likedTime
        case recentPlayTime
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
//                createTime: ColumnConstraintBinding(isNotNull: true),
//                updateTime: ColumnConstraintBinding(isNotNull: true),
//                isLiked: ColumnConstraintBinding(isNotNull: true, defaultTo: false),
//                url: ColumnConstraintBinding(isNotNull: true),
//                name: ColumnConstraintBinding(isNotNull: true),
//                amId: ColumnConstraintBinding(isNotNull: true),
            ]
        }
    }
    
}

