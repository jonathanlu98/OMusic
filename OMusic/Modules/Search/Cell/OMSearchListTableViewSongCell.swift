//
//  OMSearchListTableViewSongCell.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/2/7.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit


class OMSearchListTableViewSongCell: UITableViewCell {
    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subTitleLabel: UILabel!
    private(set) var item:AMTrack!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = UIView.init(frame: self.frame)
        self.selectedBackgroundView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3037510702)
        
        self.titleLabel.textColor = OMTheme.getTextColor()
    }
    
    func setupCell(item: AMTrack) {
        self.item = item
        self.titleLabel.text = item.attributes?.name
        self.subTitleLabel.text! = ("单曲 · "+(item.attributes?.artistName ?? "-"))
        fetchImage(URL.amCoverUrl(string: item.attributes?.artwork?.url ?? "", size: 144), imageView: self.iconImageView)
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
