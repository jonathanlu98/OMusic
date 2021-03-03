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
    
    static let database = Database.init(withPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]+"/Database/main.db")
    
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
    
    func insert<T: JLMediaProtocol>(_ object: T) {
        do {
            try JLDatabase.database.insert(objects: object, intoTable: T.tableDescription)
        } catch {
            print(error)
        }
    }
    
    func getObject<T: JLMediaProtocol>(id:Int) -> T? {
        let object: T? = try? JLDatabase.database.getObject(on: [T.Properties.init(stringValue: "id")!], fromTable: T.tableDescription, where: T.Properties.init(stringValue: "id")! == id)
        return object
    }
    
    
}
