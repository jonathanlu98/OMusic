//
//  JLMedia.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/7.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import WCDBSwift

class JLMedia: NSObject {
    
    /// 类型
    public struct ContentType: Hashable {
        private(set) var description: String
        
        private init(description: String) {
            self.description = description
        }
    }
    
    public struct AudioFormat: Hashable, ColumnCodable {
        
        static var columnType: ColumnType {
            return .text
        }
        
        private(set) var description: String
        
        public init(description: String) {
            self.description = description
        }
        
        internal init?(with value: FundamentalValue) {
            let data = value.stringValue
            guard data.count > 0 else {
                return nil
            }
            self.description = data
        }
        
        internal func archivedValue() -> FundamentalValue {
            return FundamentalValue(description)
        }
    }
    
}



protocol JLMediaProtocol: AnyObject, TableCodable, ColumnCodable {
    
    var id: NSInteger? { get }
    var updateTime: Date? { get }
    var createTime: Date? { get }
    var isValid: Bool { get }
    static var tableDescription: String { get }
}



//MARK: 自定义字段映射类型

extension JLMediaProtocol {
    func archivedValue() -> FundamentalValue {
        guard let data = try? JSONEncoder().encode([
            "table": Self.tableDescription,
            "id": String(id ?? -1)]) else {
            return FundamentalValue(nil)
        }
        return FundamentalValue(data)
    }
    
    static var columnType: ColumnType {
        return .BLOB
    }
}


extension JLMedia.ContentType {
    
    static let album: JLMedia.ContentType = JLMedia.ContentType(description: "album")
    static let artist: JLMedia.ContentType = JLMedia.ContentType(description: "artist")
    static let track: JLMedia.ContentType = JLMedia.ContentType(description: "track")
    static let playlist: JLMedia.ContentType = JLMedia.ContentType(description: "playlist")
}

extension JLMedia.AudioFormat {
    
    static let MP3: JLMedia.AudioFormat = .init(description: "mp3")
    static let AAC: JLMedia.AudioFormat = .init(description: "aac")
    static let M4A: JLMedia.AudioFormat = .init(description: "m4a")
    static let WAV: JLMedia.AudioFormat = .init(description: "wav")
    static let FLAC: JLMedia.AudioFormat = .init(description: "flac")
    static let AIFF: JLMedia.AudioFormat = .init(description: "aiff")
}


