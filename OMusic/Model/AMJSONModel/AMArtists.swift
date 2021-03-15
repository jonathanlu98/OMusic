//
//  AMArtists.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/5.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import Foundation


// MARK: - AMArtists
class AMArtists: AMObjectResponseProtocol {
    let href: String?
    let next: String?
    let data: [AMArtist]?

    init(href: String?, next: String?, data: [AMArtist]?) {
        self.next = next
        self.href = href
        self.data = data
    }
}

// MARK: - AMArtist
class AMArtist: AMObjectProtocol {
    typealias MediaClass = AMArtists.Type
        
    static var responseCodableClass: AMArtists.Type = AMArtists.self
    
    static var urlPathDescription:urlPathDescriptionType = .artists

    let id, type, href: String?
    let attributes: AMArtistAttributes?
    let relationships: AMArtistRelationships?

    init(id: String?, type: String?, href: String?, attributes: AMArtistAttributes?, relationships: AMArtistRelationships?) {
        self.id = id
        self.type = type
        self.href = href
        self.attributes = attributes
        self.relationships = relationships
    }
}

// MARK: - AMArtistAttributes
class AMArtistAttributes: Codable {
    let editorialNotes: AMArtistEditorialNotes?
    let genreNames: [String]?
    let url: String?
    let name: String?

    init(editorialNotes: AMArtistEditorialNotes?, genreNames: [String]?, url: String?, name: String?) {
        self.editorialNotes = editorialNotes
        self.genreNames = genreNames
        self.url = url
        self.name = name
    }
}

// MARK: - AMArtistEditorialNotes
class AMArtistEditorialNotes: Codable {
    let short: String?

    init(short: String?) {
        self.short = short
    }
}

// MARK: - AMArtistRelationships
class AMArtistRelationships: Codable {
    let albums: AMAlbums?
    
    init(albums: AMAlbums?) {
        self.albums = albums
    }
}

//// MARK: - AMArtistAlbums
//class AMArtistAlbums: Codable {
//    let href, next: String?
//    let data: [AMArtistAlbumsDatum]?
//
//    init(href: String?, next: String?, data: [AMArtistAlbumsDatum]?) {
//        self.href = href
//        self.next = next
//        self.data = data
//    }
//}
//
//// MARK: - AMArtistAlbumsDatum
//class AMArtistAlbumsDatum: Codable {
//    let id: String?
//    let type: String?
//    let href: String?
//
//    init(id: String?, type: String?, href: String?) {
//        self.id = id
//        self.type = type
//        self.href = href
//    }
//}
