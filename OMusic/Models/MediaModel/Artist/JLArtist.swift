//
//  JLArtist.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/7.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import WCDBSwift

class JLArtist: JLMediaProtocol {
        
    private(set) var amId: String?
    
    private(set) var id: NSInteger?
    
    internal var updateTime: Date?

    private(set) var createTime: Date?
    
    private(set) var amjsonData: Data?
    
    private(set) var name: String?
    
    private(set) var albums: [JLAlbum]?
    
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
                
    static let tableDescription = "Artists"
    
    internal var isAutoIncrement: Bool = true
    
    internal var lastInsertedRowID: Int64 = 0 {
        didSet {
            self.id = NSInteger(lastInsertedRowID)
        }
    }
    
    private(set) var amArtist: AMArtist? = nil
    
    
    init?(amArtist: AMArtist, albums: [JLAlbum]? = nil) {
        guard let name = amArtist.attributes?.name else {
            return nil
        }
        if let object:JLArtist = JLDatabase.shared.getObject(amId: amArtist.id) {
            self.id = object.id
            self.createTime = object.createTime
            self.updateTime = Date()
            
            self.amArtist = amArtist
            self.amjsonData = try? JSONEncoder().encode(amArtist)
            self.name = name
            self.albums = albums ?? object.albums
            self.amId = amArtist.id
            self.coverUrl = URL.init(string: amArtist.attributes?.coverUrl ?? "")

            self.isLiked = object.isLiked
            self.likedTime = object.likedTime

            self.lastInsertedRowID = object.lastInsertedRowID
                        
        } else {
            self.createTime = Date.init()
            self.updateTime = Date.init()
            self.amArtist = amArtist
            self.amjsonData = try? JSONEncoder().encode(amArtist)
            self.name = name
            self.albums = albums
            self.amId = amArtist.id
            self.coverUrl = URL.init(string: amArtist.attributes?.coverUrl ?? "")
            
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
            if item.codingTableKey as! JLArtist.CodingKeys == Self.CodingKeys.albums {
                return false
            } else {
                return true
            }
        }
        guard let object: JLArtist = JLDatabase.shared.getObject(id: id!, on: property) else {
            return nil
        }
        self.createTime = object.createTime
        self.updateTime = object.updateTime
        self.amjsonData = object.amjsonData
        self.coverUrl = object.coverUrl
        self.name = object.name
        self.amId = object.amId
//        self.albums = object.albums
        self.isLiked = object.isLiked
        self.likedTime = object.likedTime
        self.lastInsertedRowID = object.lastInsertedRowID
        self.amArtist = (object.amjsonData != nil) ? try? JSONDecoder().decode(AMArtist.self, from: object.amjsonData!):nil
    }
    
    
}




//MARK: JLArtist.Equatable

extension JLArtist: Equatable {
    
    static func == (lhs: JLArtist, rhs: JLArtist) -> Bool {
        if lhs.id == rhs.id {
            return true
        } else {
            return false
        }
    }
    
}



//MARK: 模型绑定

extension JLArtist {
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = JLArtist
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case id
        case createTime
        case updateTime
        case name
        case albums
        case amjsonData
        case isLiked
        case coverUrl
        case amId
        case likedTime

        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
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

