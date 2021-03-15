//
//  OMSearchListTableViewAlbumCell.swift
//  JLSptfy
//
//  Created by Jonathan Lu on 2020/2/7.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit


class OMSearchListTableViewAlbumCell: UITableViewCell {

    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var subTitleLabel: UILabel!
    private(set) var item: AMAlbum!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = UIView.init(frame: self.frame)
        self.selectedBackgroundView?.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3037510702)
    }
    
    func setupCell(item: AMAlbum) {
        self.item = item
        self.titleLabel.text = item.attributes?.name
        self.subTitleLabel.text! = "Album · "+(item.attributes?.artistName ?? "-")
        fetchImage(URL.amCoverUrl(string: item.attributes?.artwork?.url, size: CGSize.init(width: 144, height: 144)), imageView: self.iconImageView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
