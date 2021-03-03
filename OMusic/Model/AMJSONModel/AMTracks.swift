//
//  AMTracks.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/5.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import Foundation

// MARK: - AMTracks
class AMTracks: AMResponseProtocol {
    let href: String?
    let next: String?
    let data: [AMTrack]?

    init(href: String?, next: String?, data: [AMTrack]?) {
        self.next = next
        self.href = href
        self.data = data
    }
}

// MARK: - AMTrack
class AMTrack: AMProtocol {
    static var codableClass: AMTracks.Type = AMTracks.self
    
    static var description: String = "songs"
    
    let id, type, href: String?
    let attributes: AMTrackAttributes?
    let relationships: AMTrackRelationships?

    init(id: String?, type: String?, href: String?, attributes: AMTrackAttributes?, relationships: AMTrackRelationships?) {
        self.id = id
        self.type = type
        self.href = href
        self.attributes = attributes
        self.relationships = relationships
    }
}

// MARK: - AMTrackAttributes
class AMTrackAttributes: Codable {
    let previews: [AMTrackPreview]?
    let artwork: AMArtwork?
    let artistName: String?
    let url: String?
    let discNumber: Int?
    let genreNames: [String]?
    let durationInMillis: Int?
    let releaseDate, name, isrc: String?
    let hasLyrics: Bool?
    let albumName: String?
    let playParams: AMPlayParams?
    let trackNumber: Int?
    let composerName: String?

    init(previews: [AMTrackPreview]?, artwork: AMArtwork?, artistName: String?, url: String?, discNumber: Int?, genreNames: [String]?, durationInMillis: Int?, releaseDate: String?, name: String?, isrc: String?, hasLyrics: Bool?, albumName: String?, playParams: AMPlayParams?, trackNumber: Int?, composerName: String?) {
        self.previews = previews
        self.artwork = artwork
        self.artistName = artistName
        self.url = url
        self.discNumber = discNumber
        self.genreNames = genreNames
        self.durationInMillis = durationInMillis
        self.releaseDate = releaseDate
        self.name = name
        self.isrc = isrc
        self.hasLyrics = hasLyrics
        self.albumName = albumName
        self.playParams = playParams
        self.trackNumber = trackNumber
        self.composerName = composerName
    }
}



// MARK: - AMTrackPreview
class AMTrackPreview: Codable {
    let url: String?

    init(url: String?) {
        self.url = url
    }
}

// MARK: - AMTrackRelationships
class AMTrackRelationships: Codable {
    let albums: AMAlbums?
    let artists: AMArtists?

    init(albums: AMAlbums, artists: AMArtists?) {
        self.albums = albums
        self.artists = artists
    }
}

//// MARK: - AMTrackRelationshipItem
//class AMTrackRelationshipItem: Codable {
//    let href: String?
//    let data: [AMTrackRelationshipItemDatum]?
//
//    init(href: String?, data: [AMTrackRelationshipItemDatum]?) {
//        self.href = href
//        self.data = data
//    }
//}
//
//// MARK: - AMTrackRelationshipItemDatum
//class AMTrackRelationshipItemDatum: Codable {
//    let id, type, href: String?
//
//    init(id: String?, type: String?, href: String?) {
//        self.id = id
//        self.type = type
//        self.href = href
//    }
//}

