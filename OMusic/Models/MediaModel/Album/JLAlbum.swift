//
//  JLAlbum.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/7.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import WCDBSwift


class JLAlbum: JLMediaProtocol {
            
    private(set) var id: NSInteger?
    
    internal var updateTime: Date?
    
    private(set) var createTime: Date?
    
    private(set) var name: String?
    
    private(set) var amjsonData: Data?
    
    private(set) var tracks: [JLTrack]?
    
    private(set) var artist: JLArtist?
    
    private(set) var coverUrl: URL?
            
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
    
    private(set) var amId: String?
        
    static let tableDescription = "Albums"
    
    internal var isAutoIncrement: Bool = true

    internal var lastInsertedRowID: Int64 = 0 {
        didSet {
            self.id = NSInteger(lastInsertedRowID)
        }
    }
    
    private(set) var amAlbum: AMAlbum? = nil
    
    
    init?(amAlbum: AMAlbum, artist: JLArtist? = nil, tracks: [JLTrack]? = nil) {
        guard let urlString = amAlbum.attributes?.artwork?.url else {
            return nil
        }
        
        if let object:JLAlbum = JLDatabase.shared.getObject(amId: amAlbum.id) {
            self.id = object.id
            self.createTime = object.createTime
            self.updateTime = Date()
            
            self.artist = artist ?? object.artist
            self.tracks = tracks ?? object.tracks
            self.amjsonData = try? JSONEncoder().encode(amAlbum)
            self.amId = amAlbum.id
            self.amAlbum = amAlbum
            self.name = amAlbum.attributes?.name ?? "未知专辑"
            self.artist = artist
            self.coverUrl = URL.init(string: urlString)
            
            self.isLiked = object.isLiked
            self.likedTime = object.likedTime

            self.lastInsertedRowID = object.lastInsertedRowID
                        
        } else {
            self.createTime = Date()
            self.updateTime = Date()
            self.artist = artist
            self.tracks = tracks
            self.amjsonData = try? JSONEncoder().encode(amAlbum)
            self.amId = amAlbum.id
            self.amAlbum = amAlbum
            self.name = amAlbum.attributes?.name ?? "未知专辑"
            self.artist = artist
            self.coverUrl = URL.init(string: urlString)
            
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
            if item.codingTableKey as! JLAlbum.CodingKeys == Self.CodingKeys.tracks || item.codingTableKey as! JLAlbum.CodingKeys == Self.CodingKeys.artist {
                return false
            } else {
                return true
            }
        }

        guard let object: JLAlbum = JLDatabase.shared.getObject(id: id!, on: property) else {
            return nil
        }
        
        self.updateTime = object.updateTime
        self.createTime = object.createTime
        self.name = object.name
        self.amjsonData = object.amjsonData
        self.coverUrl = object.coverUrl
        self.isLiked = object.isLiked
        self.likedTime = object.likedTime
        self.lastInsertedRowID = object.lastInsertedRowID
        self.amAlbum = (object.amjsonData != nil) ? try? JSONDecoder().decode(AMAlbum.self, from: object.amjsonData!):nil
        self.amId = object.amId
    }

}



//MARK: JLAlbum.Equatable

extension JLAlbum: Equatable {
    
    static func == (lhs: JLAlbum, rhs: JLAlbum) -> Bool {
        if lhs.id == rhs.id {
            return true
        } else {
            return false
        }
    }
    
}



//MARK: 模型绑定

extension JLAlbum {
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = JLAlbum
        static let objectRelationalMapping: TableBinding<JLAlbum.CodingKeys> = .init(CodingKeys.self)
        
        case id
        case updateTime
        case createTime
        case name
        case amjsonData
        case tracks
        case artist
        case coverUrl
        case isLiked
        case amId
        case likedTime
        
        static var columnConstraintBindings: [JLAlbum.CodingKeys : ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
//                createTime: ColumnConstraintBinding(isNotNull: true),
//                updateTime: ColumnConstraintBinding(isNotNull: true),
//                isLiked: ColumnConstraintBinding(isNotNull: true, defaultTo: false),
//                name: ColumnConstraintBinding(isNotNull: true),
//                amId: ColumnConstraintBinding(isNotNull: true),
            ]
        }
    }

}



