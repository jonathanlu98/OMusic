//
//  AMModel.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/5/5.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import Foundation

// MARK: - AMArtwork
class AMArtwork: Codable {
    let width, height: Int?
    let url, bgColor, textColor1, textColor2: String?
    let textColor3, textColor4: String?

    init(width: Int?, height: Int?, url: String?, bgColor: String?, textColor1: String?, textColor2: String?, textColor3: String?, textColor4: String?) {
        self.width = width
        self.height = height
        self.url = url
        self.bgColor = bgColor
        self.textColor1 = textColor1
        self.textColor2 = textColor2
        self.textColor3 = textColor3
        self.textColor4 = textColor4
    }
}

// MARK: - AMPlayParams
class AMPlayParams: Codable {
    let id, kind: String?

    init(id: String?, kind: String?) {
        self.id = id
        self.kind = kind
    }
}



