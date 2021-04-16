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
    
    static let database = Database.init(withPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!+"/Database/main.db")
    
    static let shared = JLDatabase()
    
    override private init() {
        super.init()
    }
    
    func initializeTable() {
        do {
            try JLDatabase.database.create(table: "Tracks", of: JLTrack.self)
            try JLDatabase.database.create(table: "Playlists", of: JLPlaylist.self)
            try JLDatabase.database.create(table: "Albums", of: JLAlbum.self)
            try JLDatabase.database.create(table: "Artists", of: JLArtist.self)
        } catch {
            print(error)
        }
    }
    
    func insertIfNotExist<T: JLMediaProtocol>(_ object: T) {
        do {
            try JLDatabase.database.insertOrReplace(objects: object, intoTable: T.tableDescription)
        } catch {
            print(error)
        }
    }
    
    func getObject<T: JLMediaProtocol>(id:Int, on: [PropertyConvertible]? = nil) -> T? {
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
    
    func getObject<T: JLMediaProtocol>(amId: String) -> T? {
        var object: T?
        do {
            object = try JLDatabase.database.getObject(fromTable: T.tableDescription, where: T.Properties.init(stringValue: "amId")! == amId)
        } catch _ {
            return nil
        }
        return object
    }
    
    func getRecentPlayTracks(limit: Int = 20, offset: Int = 0) -> [JLTrack] {
        var result:[JLTrack] = []
        do {
            result = try JLDatabase.database.getObjects(fromTable: JLTrack.tableDescription, where: JLTrack.CodingKeys.recentPlayTime.isNotNull(), orderBy: [JLTrack.CodingKeys.recentPlayTime.asOrder(by: .descending)], limit: limit, offset: offset)
        } catch _ {
            return result
        }
        return result
    }
    
    
    func getLikedTracks(limit: Int = 20, offset: Int = 0) -> [JLTrack] {
        var result:[JLTrack] = []
        do {
            result = try JLDatabase.database.getObjects(fromTable: JLTrack.tableDescription, where: JLTrack.CodingKeys.isLiked == true, orderBy: [JLTrack.CodingKeys.likedTime.asOrder(by: .descending)], limit: limit, offset: offset)
        } catch _ {
            return result
        }
        return result
    }
    
}
