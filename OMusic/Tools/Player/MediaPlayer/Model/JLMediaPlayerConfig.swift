//
//  JLMediaPlayerConfig.swift
//  OMusic
//
//  Created by Jonathan Lu on 2021/1/6.
//

import UIKit

public struct JLMediaPlayerConfig {

    public var urlStr: String           // 播放URL
    public var uniqueID: String?        // 唯一ID，如果为nil，则为urlString

    public init(urlStr: String, uniqueID: String?, isVideo: Bool = false, isVideoOutputEnabled: Bool = false) {
        self.urlStr = urlStr
        self.uniqueID = uniqueID
    }

    public static var `default`: JLMediaPlayerConfig {
        return JLMediaPlayerConfig(urlStr: "fakeURL.com", uniqueID: nil)
    }

}
