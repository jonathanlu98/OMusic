//
//  AMProtocol.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/7.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import Foundation

protocol AMProtocol: Codable {
    associatedtype CodableClass: AMResponseProtocol
    static var description: String { get }
    static var codableClass: CodableClass.Type { get }
    var id: String? { get }
}

protocol AMResponseProtocol: Codable {
    associatedtype MediaClass: AMProtocol
    var data: [MediaClass]? { get }
}


extension AMProtocol {
    
}

