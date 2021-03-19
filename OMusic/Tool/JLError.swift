//
//  JLError.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/6/17.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import Foundation

public let JLErrorDomain = "JLErrorDomain"

struct JLErrorCode {
    static let ValueNotFound = 777
    static let ValueUnavailable = 778
    static let JSONDecodeFailed = 779
    static let AMObjectsNotFound = 780
    
    static let AMAccountMangerHeaderNotFound = 781
    static let AMAccountMangerHeaderNotFoundError:NSError = NSError.init(domain: JLErrorDomain, code: JLErrorCode.AMAccountMangerHeaderNotFound, userInfo: [NSLocalizedDescriptionKey:"授权出现问题。"])

    static let AMAccountMangerStorefrontNotFound = 782
    static let AMAccountMangerStorefrontNotFoundError:NSError = NSError.init(domain: JLErrorDomain, code: JLErrorCode.AMAccountMangerStorefrontNotFound, userInfo: [NSLocalizedDescriptionKey:"未能从Apple Store中读取你所在的地区。"])

    static let UrlStringNotMatch = 783
    static let UrlStringNotMatchError:NSError = NSError.init(domain: JLErrorDomain, code: UrlStringNotMatch, userInfo: [NSLocalizedDescriptionKey:"传递的URL与规则不匹配。"])
    
    }

