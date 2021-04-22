//
//  JLDatabase.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/20.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import Foundation
import WCDBSwift


class JLDatabase: NSObject {
    
    /// 数据库
    static let database = Database.init(withPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!+"/Database/main.db")
    
    /// 单例对象
    static let shared = JLDatabase()
    
    override private init() {
        super.init()
    }
    
    
    //MARK: Public Method
    
    
    /// 部署数据库表
    public func initializeTable() {
        do {
            try JLDatabase.database.create(table: "Tracks", of: JLTrack.self)
            try JLDatabase.database.create(table: "Playlists", of: JLPlaylist.self)
            try JLDatabase.database.create(table: "Albums", of: JLAlbum.self)
            try JLDatabase.database.create(table: "Artists", of: JLArtist.self)
        } catch {
            print(error)
        }
    }
    
    /// 插入或替换数据
    /// - Parameter object: 满足JLMediaProtocol协议的对象
    public func insertIfNotExist<T: JLMediaProtocol>(_ object: T) {
        do {
            try JLDatabase.database.insertOrReplace(objects: object, intoTable: T.tableDescription)
        } catch {
            print(error)
        }
    }
    
    /// 获取对象，对象需符合JLMediaProtocol协议
    /// - Parameters:
    ///   - id: 对象id
    ///   - on: 包含字段，默认包含所有字段
    /// - Returns: 对象
    public func getObject<T: JLMediaProtocol>(id:Int, on: [PropertyConvertible]? = nil) -> T? {
        var object: T?
        do {
            if on != nil {
                object = try JLDatabase.database.getObject(on: on!, fromTable: T.tableDescription, where: T.Properties.init(stringValue: "id")! == id)
            } else {
                object = try JLDatabase.database.getObject(fromTable: T.tableDescription, where: T.Properties.init(stringValue: "id")! == id)
            }
            
        } catch _ {
            return nil
        }
        return object
    }
    
    /// 获取对象
    /// - Parameter amId: 对象的amId
    /// - Returns: 对象
    public func getObject<T: JLMediaProtocol>(amId: String) -> T? {
        var object: T?
        do {
            object = try JLDatabase.database.getObject(fromTable: T.tableDescription, where: T.Properties.init(stringValue: "amId")! == amId)
        } catch _ {
            return nil
        }
        return object
    }
    
    /// 获取最近播放歌曲
    /// - Parameters:
    ///   - limit: 每次拉取条数，默认20
    ///   - offset: 位移数，默认0
    /// - Returns: JLTrack数组
    public func getRecentPlayTracks(limit: Int = 20, offset: Int = 0) -> [JLTrack] {
        var result:[JLTrack] = []
        do {
            result = try JLDatabase.database.getObjects(fromTable: JLTrack.tableDescription, where: JLTrack.CodingKeys.recentPlayTime.isNotNull(), orderBy: [JLTrack.CodingKeys.recentPlayTime.asOrder(by: .descending)], limit: limit, offset: offset)
        } catch _ {
            return result
        }
        return result
    }
    
    /// 获取收藏歌曲
    /// - Parameters:
    ///   - limit: 每次拉取条数，默认20
    ///   - offset: 位移数，默认0
    /// - Returns: JLTrack数组
    public func getLikedTracks(limit: Int = 20, offset: Int = 0) -> [JLTrack] {
        var result:[JLTrack] = []
        do {
            result = try JLDatabase.database.getObjects(fromTable: JLTrack.tableDescription, where: JLTrack.CodingKeys.isLiked == true, orderBy: [JLTrack.CodingKeys.likedTime.asOrder(by: .descending)], limit: limit, offset: offset)
        } catch _ {
            return result
        }
        return result
    }
    
}
