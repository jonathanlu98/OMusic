//
//  OMPlayerImageCollectionViewCell.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/2/27.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit

class OMPlayerImageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    private(set) var imageUrl: URL?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(item: JLTrack) {
        self.fetchImage(URL.amCoverUrl(string: item.amTrack?.attributes?.artwork?.url ?? "", size: 885))
    }
    
    private func fetchImage(_ url:URL?) {
        self.imageUrl = url
        self.imageView.fetchImage(url, placeholderImage: nil, nil)
    }
    
    

}
