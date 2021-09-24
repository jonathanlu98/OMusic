//
//  JLMacroDefinition.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/4/30.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit


let THEME_GREEN_COLOR = #colorLiteral(red: 0.1176470588, green: 0.8431372549, blue: 0.3764705882, alpha: 1)
let THEME_TEXTBLACK_COLOR = #colorLiteral(red: 0.2039215686, green: 0.1921568627, blue: 0.1803921569, alpha: 1)
let THEME_GRAY_COLOR = #colorLiteral(red: 0.6588235294, green: 0.6549019608, blue: 0.6509803922, alpha: 1)
let THEME_LIGHTGRAY_COLOR = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
let THEME_RED_COLOR = #colorLiteral(red: 0.9960784314, green: 0.2862745098, blue: 0.2352941176, alpha: 1)
let THEME_BLACK_COLOR = #colorLiteral(red: 0.1411764706, green: 0.1411764706, blue: 0.1411764706, alpha: 1)

let PLAYER_MENU_VIEW_HEIGHT = 94

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height

let SAFE_AREA_BOTTOM = UIApplication.shared.windows.first!.safeAreaInsets.bottom

/// 字符串是否为空
func OMStringIsEmpty(_ string: String?) -> Bool {
    return (string == nil || string!.isEmpty)
}

/// 数组是否为空
func OMArrayIsEmpty(_ array: Array<Any>?) -> Bool {
    return (array == nil || array!.isEmpty)
}

/// 字典是否为空，这里需要传递Key类型
func OMDictionaryIsEmpty<T: Hashable>(_ dictionary: Dictionary<T, Any>?) -> Bool {
    return (dictionary == nil || dictionary!.keys.isEmpty)
}



let SongCellReuseIdentifier = NSStringFromClass(OMSearchListTableViewSongCell.self).components(separatedBy: ".").last!
let ArtistCellReuseIdentifier = NSStringFromClass(OMSearchListTableViewArtistCell.self).components(separatedBy: ".").last!
let AlbumCellReuseIdentifier = NSStringFromClass(OMSearchListTableViewAlbumCell.self).components(separatedBy: ".").last!
let MoreCellReuseIdentifier = NSStringFromClass(OMSearchListTableViewMoreCell.self).components(separatedBy: ".").last!

let PlayerImageCollectionViewCellReuseIdentifier = NSStringFromClass(OMPlayerImageCollectionViewCell.self).components(separatedBy: ".").last!

let HomeRecentPlayCollectionViewCellReuseIdentifier = NSStringFromClass(OMHomeRecentPlayCollectionViewCell.self).components(separatedBy: ".").last!
