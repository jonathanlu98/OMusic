//
//  OMHomeRecentPlayCollectionViewCell.swift
//  OMusic
//
//  Created by 陆佳鑫 - 个人 on 2021/4/11.
//  Copyright © 2021 Jonathan Lu. All rights reserved.
//

import UIKit

class OMHomeRecentPlayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var trackNameLabel: UILabel!
    
    @IBOutlet weak var artistNameLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.trackNameLabel.textColor = OMTheme.getTextColor()
        self.artistNameLabel.textColor = THEME_GRAY_COLOR
        
    }
    
    func configCell(_ item: JLTrack) {
        self.trackNameLabel.text = item.name
        self.artistNameLabel.text = item.artists?.first?.name ?? item.amTrack?.attributes?.artistName
        if item.amTrack == nil && item.amjsonData != nil {
            item.amTrack = try? JSONDecoder().decode(AMTrack.self, from: item.amjsonData!)
        }
        let url = URL.amCoverUrl(string: item.amTrack?.attributes?.artwork?.url ?? "", size: 360)
        self.imageView.fetchImage(url) { (image, succeed) in }
    }
    

}
