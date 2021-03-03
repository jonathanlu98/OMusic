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
    
    private(set) var isValid: Bool = false
    
    private(set) var id: NSInteger?
    
    private(set) var updateTime: Date?
    
    private(set) var createTime: Date?
    
    private var amjsonData: Data? {
        didSet {
            updateTime = Date()
            guard let data = amjsonData else {
                return
            }
            amArtist = try? JSONDecoder().decode(AMArtists.self, from: data)
            isMatched = true
            name = amArtist?.data?.first?.attributes?.name ?? name
        }
    }
    
    private(set) var name: String?
    
    private(set) var albums: [JLAlbum]? {
        didSet {
            updateTime = Date()
            guard let albums = albums else {
                self.songCount = 0
                return
            }
            var count = 0
            for album in albums {
                count = count+(album.tracks?.count ?? 0)
            }
            self.songCount = count
        }
    }
    
    private(set) var coverUrl: URL?
    
    private(set) var isLiked: Bool = false
    
    private(set) var songCount: NSInteger = 0
    
    private(set) var playCount: NSInteger = 0
    
    private(set) var isMatched: Bool = false
    
    static let tableDescription = "Artists"
    
    internal var isAutoIncrement: Bool = true
    
    internal var lastInsertedRowID: Int64 = 0 {
        didSet {
            self.id = NSInteger(lastInsertedRowID)
        }
    }
    
    private(set) var amArtist: AMArtists? = nil
    
    private init() {
        //
    }
    
    init(name: String, albums:[JLAlbum]? = nil, coverUrl: URL? = nil, amjsonData: Data? = nil) {
        self.albums = albums
        self.createTime = Date()
        self.updateTime = Date()
        self.coverUrl = coverUrl
        guard let data = amjsonData else {
            return
        }
        self.amjsonData = data
        self.amArtist = try? JSONDecoder().decode(AMArtists.self, from: data)
        self.isMatched = true
        self.name = amArtist?.data?.first?.attributes?.name ?? name
    }
    
    required init?(with value: FundamentalValue) {
        let data = value.dataValue
        guard data.count > 0 else {
            return nil
        }
        guard let dictionary = try? JSONDecoder().decode([String: String].self, from: data) else {
            return nil
        }
        id = NSInteger.init(dictionary["id"] ?? "-1") ?? -1
        
        guard let object: JLArtist = JLDatabase.shared.getObject(id: id!) else {
            return
        }
        self.isValid = true
        self.id = object.id
        self.createTime = object.createTime
        self.updateTime = object.updateTime
        self.amjsonData = object.amjsonData
        self.coverUrl = object.coverUrl
        self.isMatched = (object.amjsonData != nil) ? true:false
        self.name = object.name
        self.albums = object.albums
        var count = 0
        for album in object.albums ?? [] {
            count = count+(album.tracks?.count ?? 0)
        }
        self.songCount = count
        self.isLiked = object.isLiked
        self.playCount = object.playCount
        self.lastInsertedRowID = object.lastInsertedRowID
        self.amArtist = (object.amjsonData != nil) ? try? JSONDecoder().decode(AMArtists.self, from: object.amjsonData!):nil
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
        case songCount
        case playCount
        case isLiked
        case coverUrl
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
                createTime: ColumnConstraintBinding(isNotNull: true),
                updateTime: ColumnConstraintBinding(isNotNull: true),
                playCount: ColumnConstraintBinding(isNotNull: true, defaultTo: 0),
                isLiked: ColumnConstraintBinding(isNotNull: true, defaultTo: false),
                songCount: ColumnConstraintBinding(isNotNull: true, defaultTo: 0),
                name: ColumnConstraintBinding(isNotNull: true)
            ]
        }
    }
    
}

