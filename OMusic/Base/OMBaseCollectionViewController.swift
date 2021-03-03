//
//  OMBaseCollectionViewController.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/10/12.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit

class OMBaseCollectionViewController: UICollectionViewController {
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(collectionViewLayout: UICollectionViewLayout.init())
    }
    
    init(title: String, backgroundColor: UIColor, collectionViewLayout: UICollectionViewLayout) {
        super.init(collectionViewLayout: collectionViewLayout)
        self.title = title
        collectionView.backgroundColor = backgroundColor
        self.view.backgroundColor = backgroundColor
    }
    
    
    //MARK: Delegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let showNavBarOffsetY = CGFloat(50)
        print(contentOffsetY)
        //navigationBar alpha
        if contentOffsetY <= showNavBarOffsetY  {
            let navAlpha = (contentOffsetY+20)/10
            navBarBgAlpha = navAlpha
        }
    }

}
