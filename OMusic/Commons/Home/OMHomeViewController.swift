//
//  OMHomeViewController.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/9/16.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import Masonry

class OMHomeViewController: OMBaseCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "OMHomeViewController_Cell")
    }
    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OMHomeViewController_Cell", for: indexPath)
        cell.backgroundColor = UIColor.red
        return cell
    }
    
    

}
