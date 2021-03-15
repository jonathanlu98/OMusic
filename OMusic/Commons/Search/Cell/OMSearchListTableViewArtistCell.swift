//
//  OMSearchListTableViewArtistCell.swift
//  JLSptfy
//
//  Created by Jonathan Lu on 2020/2/5.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import RxSwift
import SDWebImage

//enum ItemType {
//    case Track
//    case Playlist
//    case Album
//    case Artist
//}



class OMSearchListTableViewArtistCell: UITableViewCell {
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var iconImageView: UIImageView!
    private(set) var item: AMArtist!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = UIView.init(frame: self.frame)
        self.selectedBackgroundView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3037510702)
    }
    
    func setupCell(item: AMArtist) {
        self.item = item
        self.titleLabel.text = item.attributes?.name
        fetchImage(URL.amCoverUrl(string: item.attributes?.url, size: CGSize.init(width: 144, height: 144)), imageView: self.iconImageView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}



