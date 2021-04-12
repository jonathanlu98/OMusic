//
//  AMSearchModel.swift
//  OMusic
//
//  Created by 陆佳鑫 - 个人 on 2021/3/13.
//  Copyright © 2021 Jonathan Lu. All rights reserved.
//

import Foundation

class AMSearchResponse: Codable {
    
    let results: AMSearchItems?
    
    init(results: AMSearchItems?) {
        self.results = results
    }
    
}


class AMSearchItems: Codable {
    
    let songs: AMTracks?
    let albums: AMAlbums?
    let artists: AMArtists?
    
    init(songs: AMTracks?, albums: AMAlbums?, artists: AMArtists?) {
        self.songs = songs
        self.albums = albums
        self.artists = artists
    }
    
    public func getSearchItems<T: AMObjectResponseProtocol>() -> T? {
        switch T.MediaClass.urlPathDescription {
        case .tracks:
            return self.songs as? T
        case .albums:
            return self.albums as? T
        case .artists:
            return self.artists as? T
        }
    }

}
