//
//  AMAlbums.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/5.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import Foundation


// MARK: - AMAlbums
class AMAlbums: AMObjectResponseProtocol {
    let href: String?
    let next: String?
    var data: [AMAlbum]?

    init(href: String?, next: String?, data: [AMAlbum]?) {
        self.data = data
        self.href = href
        self.next = next
    }
}

// MARK: - AMAlbum
class AMAlbum: AMObjectProtocol {
    static var responseCodableClass: AMAlbums.Type = AMAlbums.self
    
    static var urlPathDescription:urlPathDescriptionType = .albums

    let type, href: String?
    let id: String
    let attributes: PurpleAttributes?
    let relationships: AMAlbumRelationships?

    init(id: String, type: String?, href: String?, attributes: PurpleAttributes?, relationships: AMAlbumRelationships?) {
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
class AMAlbumRelationships: AMRelationshipsProtocol {
    let artists: AMArtists?
    let tracks: AMTracks?

    init(artists: AMArtists?, tracks: AMTracks?) {
        self.artists = artists
        self.tracks = tracks
    }
    
    func getRelaionshipsObjects(_ completion: @escaping () -> Void) {
        if !OMArrayIsEmpty(tracks?.data) {
            AMFetchManager.shared.getAMObjects(by: (tracks?.data!.map({ (item) -> String in
                return item.id
            }))!, from: AMTrack.self) { [weak self] (fullTracks, ids, error) in
                guard let weakSelf = self else {
                    return
                }
                if !OMArrayIsEmpty(fullTracks) {
                    weakSelf.tracks?.data = fullTracks
                }
                if !OMArrayIsEmpty(weakSelf.artists?.data) {
                    AMFetchManager.shared.getAMObjects(by: (weakSelf.artists?.data!.map({ (item) -> String in
                        return item.id
                    }))!, from: AMArtist.self) { (fullArtists, a_ids, a_error) in
                        if !OMArrayIsEmpty(fullArtists) {
                            weakSelf.artists?.data = fullArtists
                        }
                        completion()
                    }
                } else {
                    completion()
                }
            }
        }
    }
}

