//
//  OMHomeViewController.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/9/16.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import Masonry
import MJRefresh

class OMHomeViewController: UIViewController {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    @IBOutlet private weak var subTitleLabel: UILabel!
    
    @IBOutlet private weak var recentPlayCollectionView: UICollectionView!
    
    @IBOutlet private weak var collectionBottom: NSLayoutConstraint!
    
    @IBOutlet private weak var largeImageGradView: UIView!
    
    private var gradLayer: CAGradientLayer?
    
    @IBOutlet private weak var largeImageView: UIImageView!
    
    private let queue: DispatchQueue = DispatchQueue.init(label: "OMusic.recentPlayData.queue")
    
    private(set) var items: [JLTrack] = []
    
    override func viewDidLoad() {
        self.setupUI()
        self.setupCollectionView()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.pullData(offset: 0)
        self.recentPlayCollectionView.mj_footer?.isHidden = false
        self.collectionBottom.constant = CGFloat(OMPlayer.shared.menuView.isHidden ? 0:PLAYER_MENU_VIEW_HEIGHT)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.items.count > 20 {
            self.items.removeSubrange(20..<self.items.count)
        }
        self.recentPlayCollectionView.reloadData()
    }
    
    
    private func setupUI() {
        self.view.backgroundColor = OMTheme.getColor(lightColor: .white, darkColor: .black)
        self.titleLabel.textColor = OMTheme.getTextColor()
        self.subTitleLabel.textColor = OMTheme.getTextColor()
        
        
    }
    
    private func updateLargeImageView() {
        guard let item = self.items.first else {
            self.largeImageView.image = #imageLiteral(resourceName: "Logo")
            return
        }
        if item.amTrack == nil && item.amjsonData != nil {
            item.amTrack = try? JSONDecoder().decode(AMTrack.self, from: item.amjsonData!)
        }
        let url = URL.amCoverUrl(string: item.amTrack?.attributes?.artwork?.url ?? "", size: Int(SCREEN_WIDTH)*2)
        self.largeImageView.fetchImage(url) { (image, succeed) in }
    }
    
    
    override func viewDidLayoutSubviews() {
        if self.gradLayer == nil {
            self.gradLayer = CAGradientLayer()
            
            self.gradLayer!.colors = [OMTheme.getColor(lightColor: UIColor.init(white: 1, alpha: 0.4), darkColor: UIColor.init(white: 0, alpha: 0.4)).cgColor, OMTheme.getColor(lightColor: UIColor.init(white: 1, alpha: 1), darkColor: UIColor.init(white: 0, alpha: 1)).cgColor]
            self.gradLayer!.locations = [0.0, 1.0]
            self.gradLayer!.startPoint = CGPoint.init(x: 0, y: 0)
            self.gradLayer!.endPoint = CGPoint.init(x: 0, y: 1.0)
            self.gradLayer!.frame = CGRect.init(x: 0, y: 0, width: SCREEN_WIDTH, height: self.largeImageGradView.mj_h)
            self.largeImageGradView.layer.addSublayer(self.gradLayer!)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.gradLayer?.colors = [OMTheme.getColor(lightColor: UIColor.init(white: 1, alpha: 0.4), darkColor: UIColor.init(white: 0, alpha: 0.4)).cgColor, OMTheme.getColor(lightColor: UIColor.init(white: 1, alpha: 1), darkColor: UIColor.init(white: 0, alpha: 1)).cgColor]
            self.gradLayer?.setNeedsDisplay()
        }
    }
    
    private func setupCollectionView() {
        self.recentPlayCollectionView.showsVerticalScrollIndicator = false
        self.recentPlayCollectionView.delegate = self
        self.recentPlayCollectionView.dataSource = self
        self.recentPlayCollectionView.register(UINib.init(nibName: HomeRecentPlayCollectionViewCellReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: HomeRecentPlayCollectionViewCellReuseIdentifier)
        
        
        self.recentPlayCollectionView.mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.pullData(offset: weakSelf.items.count)
        })
    }
    
    
    private func pullData(offset: Int) {
        if offset%20 != 0 || offset > 100 {
            return
        }
        self.queue.async { [weak self] in
            guard let weakSelf = self else {
                return
            }
            if offset == 0 {
                weakSelf.items = JLDatabase.shared.getRecentPlayTracks(offset: offset)
                if weakSelf.items.count < 20 {
                    DispatchQueue.main.async {
                        weakSelf.recentPlayCollectionView.mj_footer?.isHidden = true
                    }
                }
            } else {
                weakSelf.items.append(contentsOf: JLDatabase.shared.getRecentPlayTracks(offset: offset))
                if weakSelf.items.count%20 != 0 {
                    DispatchQueue.main.async {
                        weakSelf.recentPlayCollectionView.mj_footer?.isHidden = true
                    }                }
            }
            DispatchQueue.main.async {
                weakSelf.recentPlayCollectionView.mj_footer?.endRefreshing()
                weakSelf.recentPlayCollectionView.reloadData()
                weakSelf.recentPlayCollectionView.layoutIfNeeded()
                weakSelf.updateLargeImageView()
            }
        }

    }

}


extension OMHomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OMHomeRecentPlayCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeRecentPlayCollectionViewCellReuseIdentifier, for: indexPath) as! OMHomeRecentPlayCollectionViewCell
        cell.configCell(self.items[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        OMPlayer.shared.play(from: item)
        OMPlayer.shared.openPlayerViewControllerIfNeed()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: SCREEN_WIDTH/3.0, height: 144)
    }
    
    
}
