//
//  AMProtocol.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/7.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import Foundation


enum urlPathDescriptionType: String {
    case tracks = "songs"
    case albums = "albums"
    case artists = "artists"
}

/// 类型协议
protocol AMObjectProtocol: class, Codable{
    associatedtype ResponseCodableClass: AMObjectResponseProtocol
    static var urlPathDescription: urlPathDescriptionType { get }
    static var responseCodableClass: ResponseCodableClass.Type { get }
    var id: String? { get }
}


/// 请求类型协议
protocol AMObjectResponseProtocol: class, Codable{
    associatedtype MediaClass: AMObjectProtocol
    var data: [MediaClass]? { get }
    var next: String? { get }
}

