//
//  JLTrack.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/5.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import WCDBSwift
import ID3TagEditor

class JLTrack: JLMediaProtocol {
    
    private(set) var isValid: Bool = false
    
    private(set) var id: NSInteger?
    
    private(set) var updateTime: Date?
    
    private(set) var createTime: Date?
    
    private var amjsonData: Data?
    
    private(set) var am_id: String?
    
    private(set) var name: String
    
    private(set) var artists: [JLArtist]?
    
    private(set) var album: JLAlbum?
    
    private(set) var isrc: String?
    
    private(set) var url: URL?
    
    private(set) var duration: Double = 0
    
    private(set) var audioFormat: JLMedia.AudioFormat?
    
    private(set) var playCount: NSInteger = 0
    
    private(set) var isLocal: Bool = true
    
    private(set) var isLiked: Bool = false
    
    static let tableDescription = "Tracks"
    
    private(set) var isMatched: Bool = false
    
    internal var isAutoIncrement: Bool = true
    
    internal var lastInsertedRowID: Int64 = 0 {
        didSet {
            self.id = NSInteger(lastInsertedRowID)
        }
    }
    
    private(set) var amTrack: AMTrack?
    

    init(name: String, type: JLMedia.AudioFormat, url:URL, duration: Double, amTrack: AMTrack? = nil) {
        self.createTime = Date.init()
        self.updateTime = Date.init()
        self.name = name
        self.url = url
        self.audioFormat = type
        self.duration = duration
        guard let amTrack = amTrack else {
            return
        }
        self.amTrack = amTrack
        self.amjsonData = try? JSONEncoder().encode(amTrack)
        self.isrc = amTrack.attributes?.isrc
        self.am_id = amTrack.id
        self.isMatched = true
        self.name = amTrack.attributes?.name ?? name
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
        
        guard let object: JLTrack = JLDatabase.shared.getObject(id: id!) else {
            return nil
        }
        self.isValid = true
        self.createTime = object.createTime
        self.updateTime = object.updateTime
        self.amjsonData = object.amjsonData
        self.am_id = object.am_id
        self.name = object.name
        self.artists = object.artists
        self.album = object.album
        self.isrc = object.isrc
        self.url = object.url
        self.duration = object.duration
        self.audioFormat = object.audioFormat
        self.playCount = object.playCount
        self.isLocal = object.isLocal
        self.isMatched = (object.amjsonData != nil) ? true:false
        self.isLiked = object.isLiked
        self.lastInsertedRowID = object.lastInsertedRowID
        self.amTrack = (object.amjsonData != nil) ? try? JSONDecoder().decode(AMTrack.self, from: object.amjsonData!):nil
    }
    
    public func changeName(name: String) {
        
    }
    
    public func changeAMTrack(amTrack: AMTrack, completion: (Bool) -> Void) {
        self.amTrack = amTrack
        updateTime = Date()
        self.amjsonData = try? JSONEncoder().encode(amTrack)
        self.isrc = amTrack.attributes?.isrc
        self.isMatched = true
        self.name = amTrack.attributes?.name ?? name
        self.am_id = amTrack.id
        //FIXME: 缺少更新artist、album
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
        case duration
        case audioFormat
        case playCount
        case isLocal
        case isLiked
        case isrc
        
        static var columnConstraintBindings: [CodingKeys: ColumnConstraintBinding]? {
            return [
                id: ColumnConstraintBinding(isPrimary: true, isAutoIncrement: true),
                createTime: ColumnConstraintBinding(isNotNull: true),
                updateTime: ColumnConstraintBinding(isNotNull: true),
                playCount: ColumnConstraintBinding(isNotNull: true, defaultTo: 0),
                isLiked: ColumnConstraintBinding(isNotNull: true, defaultTo: false),
                isLocal: ColumnConstraintBinding(isNotNull: true, defaultTo: true),
                url: ColumnConstraintBinding(isNotNull: true),
                name: ColumnConstraintBinding(isNotNull: true),
                audioFormat: ColumnConstraintBinding(isNotNull: true),
                duration: ColumnConstraintBinding(isNotNull: true, defaultTo: 0)
            ]
        }
    }
    
}

