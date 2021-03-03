//
//  AMAlbums.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/5.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import Foundation


// MARK: - AMAlbums
class AMAlbums: AMResponseProtocol {
    let href: String?
    let next: String?
    let data: [AMAlbum]?

    init(href: String?, next: String?, data: [AMAlbum]?) {
        self.data = data
        self.href = href
        self.next = next
    }
}

// MARK: - AMAlbum
class AMAlbum: AMProtocol {
    static var codableClass: AMAlbums.Type = AMAlbums.self
    
    static var description: String = "albums"
    
    let id, type, href: String?
    let attributes: PurpleAttributes?
    let relationships: AMAlbumRelationships?

    init(id: String?, type: String?, href: String?, attributes: PurpleAttributes?, relationships: AMAlbumRelationships?) {
        self.id = id
        self.type = type
        self.href = href
        self.attributes = attributes
        self.relationships = relationships
    }
}

// MARK: - PurpleAttributes
class PurpleAttributes: Codable {
    let artwork: AMArtwork?
    let artistName: String?
    let isSingle: Bool?
    let url: String?
    let isComplete: Bool?
    let genreNames: [String]?
    let trackCount: Int?
    let isMasteredForItunes: Bool?
    let releaseDate: String?
    let name: String?
    let recordLabel, copyright: String?
    let playParams: AMPlayParams?
    let isCompilation: Bool?

    init(artwork: AMArtwork?, artistName: String?, isSingle: Bool?, url: String?, isComplete: Bool?, genreNames: [String]?, trackCount: Int?, isMasteredForItunes: Bool?, releaseDate: String?, name: String?, recordLabel: String?, copyright: String?, playParams: AMPlayParams?, isCompilation: Bool?) {
        self.artwork = artwork
        self.artistName = artistName
        self.isSingle = isSingle
        self.url = url
        self.isComplete = isComplete
        self.genreNames = genreNames
        self.trackCount = trackCount
        self.isMasteredForItunes = isMasteredForItunes
        self.releaseDate = releaseDate
        self.name = name
        self.recordLabel = recordLabel
        self.copyright = copyright
        self.playParams = playParams
        self.isCompilation = isCompilation
    }
}

// MARK: - Relationships
class AMAlbumRelationships: Codable {
    let artists: AMArtists?
    let tracks: AMTracks?

    init(artists: AMArtists?, tracks: AMTracks?) {
        self.artists = artists
        self.tracks = tracks
    }
}

