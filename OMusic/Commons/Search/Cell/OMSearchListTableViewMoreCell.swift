//
//  OMSearchListTableViewMoreCell.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/2/7.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit

enum OMSearchMoreType {
    case track
    case album
    case artist
    
    func cellItemName() -> String {
        switch self {
        case .track:
            return "搜索所有单曲"
        case .album:
            return "搜索所有专辑"
        case .artist:
            return "搜索所有歌手"
        }
    }
    
    
    /// 关联的数据类型
    func relevanceObjectResponseClass() -> AnyClass {
        switch self {
        case .track:
            return AMTracks.self
        case .album:
            return AMAlbums.self
        case .artist:
            return AMArtists.self
        }
    }
    
}

class OMSearchListTableViewMoreCell: UITableViewCell {

    @IBOutlet weak private var titleLabel: UILabel!
    var type: OMSearchMoreType! {
        didSet {
            self.titleLabel.text = type.cellItemName()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = UIView.init(frame: self.frame)
        self.selectedBackgroundView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3037510702)
        
        self.titleLabel.textColor = OMTheme.getTextColor()
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
