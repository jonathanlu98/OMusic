//
//  JLCarouselView.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/9/17.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class JLCarouselView<JLCarouselViewCellType, JLCarouseDataType>: UICollectionView {
    typealias JLCarouselViewCellType = UICollectionViewCell
    typealias JLCarouseDataType = JLMediaProtocol
    
    private(set) var data: [JLCarouseDataType]?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    
    
    
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = frame.size
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = .zero
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    
    
}


extension JLCarouselView: JLTableHeaderViewProtocol {
    
    var a_alpha: CGFloat {
        return alphaView.alpha
    }
    
    var alphaView: UIView {
        let view = UIView.init(frame: self.bounds)
        view.alpha = 0.2
        return view
    }
    
}


//extension JLCarouselView: UICollectionViewDelegate {
//
//}
