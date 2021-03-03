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
    
    private(set) var isValid: Bool = false
    
    private(set) var id: NSInteger?
    
    private(set) var updateTime: Date?
    
    private(set) var createTime: Date?
    
    private(set) var name: String
    
    private var amjsonData: Data? {
        didSet {
            updateTime = Date()
            guard let data = amjsonData else {
                return
            }
            amAlbum = try? JSONDecoder().decode(AMAlbums.self, from: data)
            isMatched = true
            name = amAlbum?.data?.first?.attributes?.name ?? "ERROR_NAME"
            if let color = amAlbum?.data?.first?.attributes?.artwork?.bgColor {
                backgroundColor = JLColor.init(hexString: color)
                
            } else {
                backgroundColor = nil
            }
            guard let urlString = amAlbum?.data?.first?.attributes?.artwork?.url else {
                coverUrl = nil
                return
            }
            coverUrl =  URL.init(string: urlString)
        }
    }
    
    private(set) var tracks: [JLTrack]? {
        didSet {
            updateTime = Date()
        }
    }
    
    private(set) var artist: JLArtist?
    
    private(set) var coverUrl: URL?
    
    private(set) var backgroundColor: JLColor?
    
    private(set) var playCount: NSInteger = 0
    
    private(set) var isLiked: Bool = false
    
    private(set) var isMatched: Bool = false
    
    static let tableDescription = "Albums"
    
    internal var isAutoIncrement: Bool = true

    internal var lastInsertedRowID: Int64 = 0 {
        didSet {
            self.id = NSInteger(lastInsertedRowID)
        }
    }
    
    private(set) var amAlbum: AMAlbums? = nil
    
    init(name: String, amAlbum: AMAlbums? = nil, artist: JLArtist? = nil, tracks: [JLTrack]? = nil) {
        self.name = name
        self.createTime = Date()
        self.updateTime = Date()
        self.artist = artist
        self.tracks = tracks
        guard let amAlbum = amAlbum else {
            return
        }
        self.amjsonData = try? JSONEncoder().encode(amAlbum)
        self.amAlbum = amAlbum
        self.isMatched = true
        self.name = amAlbum.data?.first?.attributes?.name ?? "ERROR_NAME"
        if let color = amAlbum.data?.first?.attributes?.artwork?.bgColor {
            backgroundColor = JLColor.init(hexString: color)
        }
        if let artistData = amAlbum.data?.first?.relationships?.artists {
            self.artist = JLArtist.init(name: self.name, amjsonData: try? JSONEncoder().encode(artistData))
        }
        guard let urlString = amAlbum.data?.first?.attributes?.artwork?.url else {
            coverUrl = nil
            return
        }
        coverUrl =  URL.init(string: urlString)
        
    }
    
    init(amAlbum: AMAlbums) {
        self.createTime = Date()
        self.updateTime = Date()
        self.amAlbum = amAlbum
        self.isMatched = true
        self.name = amAlbum.data?.first?.attributes?.name ?? "EEROR_NAME"
        self.amjsonData = try? JSONEncoder().encode(amAlbum)
        if let color = amAlbum.data?.first?.attributes?.artwork?.bgColor {
            backgroundColor = JLColor.init(hexString: color)
        }
        if let artistData = amAlbum.data?.first?.relationships?.artists {
            self.name =  artistData.data?.first?.attributes?.name ?? name
            self.artist = JLArtist.init(name: self.name, amjsonData: try? JSONEncoder().encode(artistData))
        }
        guard let urlString = amAlbum.data?.first?.attributes?.artwork?.url else {
            coverUrl = nil
            return
        }
        self.coverUrl =  URL.initPercent(string: urlString)
    }
    
//    required init(from decoder: Decoder) throws {
//        //
//    }
    
    required init?(with value: FundamentalValue) {
        let data = value.dataValue
        guard data.count > 0 else {
            return nil
        }
        guard let dictionary = try? JSONDecoder().decode([String: String].self, from: data) else {
            return nil
        }
        id = NSInteger.init(dictionary["id"] ?? "-1") ?? -1
        guard let object: JLAlbum = JLDatabase.shared.getObject(id: id!) else {
            return nil
        }
        self.isValid = true
        self.id = object.id
        self.updateTime = object.updateTime
        self.createTime = object.createTime
        self.name = object.name
        self.amjsonData = object.amjsonData
        self.tracks = object.tracks
        self.artist = object.artist
        self.coverUrl = object.coverUrl
        self.backgroundColor = object.backgroundColor
        self.playCount = object.playCount
        self.isLiked = object.isLiked
        self.isMatched = (object.amjsonData != nil) ? true:false
        self.lastInsertedRowID = object.lastInsertedRowID
        self.amAlbum = (object.amjsonData != nil) ? try? JSONDecoder().decode(AMAlbums.self, from: object.amjsonData!):nil
        
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
        case playCount
        case isLiked
        case backgroundColor
        
        static var columnConstraintBindings: [JLAlbum.CodingKeys : ColumnConstraintBinding]? {
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



