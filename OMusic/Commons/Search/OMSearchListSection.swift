//
//  OMSearchListSection.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/2/25.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import Foundation
import RxDataSources

//单元格类型
enum OMSearchListSectionItem {
    case ArtistSectionItem(item: AMArtist)
    case AlbumSectionItem(item: AMAlbum)
    case SongSectionItem(item: AMTrack)
    case MoreSectionItem(type: OMSearchMoreType)
}
 
//自定义Section的结构体
struct OMSearchListSection {
    var header: String
    var items: [OMSearchListSectionItem]
}



//
extension OMSearchListSection : SectionModelType {
    typealias Item = OMSearchListSectionItem
    init(original: OMSearchListSection, items: [Item]) {
        self = original
        self.items = items
    }
}
