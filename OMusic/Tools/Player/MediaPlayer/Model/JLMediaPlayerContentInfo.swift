//
//  JLMediaPlayerContentInfo.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/12/6.
//

import UIKit

public struct JLMediaPlayerContentInfo: JLMediaBaseModel {

    var uniqueID: String
    
    var mimeType: String
    
    var contentLength: Int64
    
    var updated: Int64 = 0
    
    var isByteRangeAccessSupported: Bool = false

    static func isNotExpired(updated: Int64) -> Bool {
        let expiredTimeInterval = 3600
        return Int64(Date().timeIntervalSince1970) - updated <= expiredTimeInterval
    }

}
