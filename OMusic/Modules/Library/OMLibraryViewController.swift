//
//  OMLibraryViewController.swift
//  OMusic
//
//  Created by 陆佳鑫 - 个人 on 2021/4/11.
//  Copyright © 2021 Jonathan Lu. All rights reserved.
//

import UIKit
import MJRefresh

class OMLibraryViewController: UIViewController {
    
    @IBOutlet weak private var titleLabel: UILabel!
    
    @IBOutlet weak private var trackTableView: UITableView!
    
    @IBOutlet weak private var tableViewBottom: NSLayoutConstraint!
    
    private let queue: DispatchQueue = DispatchQueue.init(label: "OMusic.recentPlayData.queue")
    
    private(set) var items: [JLTrack] = []
    
    override func viewDidLoad() {
        self.setupUI()
        self.setupTableView()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.pullData(offset: 0)
        self.tableViewBottom.constant = CGFloat(OMPlayer.shared.menuView.isHidden ? 0:PLAYER_MENU_VIEW_HEIGHT)
    }
    
    
    private func setupUI() {
        self.view.backgroundColor = OMTheme.getColor(lightColor: .white, darkColor: .black)
        self.titleLabel.textColor = OMTheme.getTextColor()
    }
    
    
    private func setupTableView() {
        self.trackTableView.separatorStyle = .none
        self.trackTableView.showsVerticalScrollIndicator = false
        self.trackTableView.delegate = self
        self.trackTableView.dataSource = self
        self.trackTableView.register(UINib.init(nibName: SongCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: SongCellReuseIdentifier)
        
        self.trackTableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: { [weak self] in
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
                weakSelf.items = JLDatabase.shared.getLikedTracks(offset: offset)
                if weakSelf.items.count < 20 {
                    DispatchQueue.main.async {
                        weakSelf.trackTableView.mj_footer?.isHidden = true
                    }
                }
            } else {
                weakSelf.items.append(contentsOf: JLDatabase.shared.getRecentPlayTracks(offset: offset))
                if weakSelf.items.count%20 != 0 {
                    DispatchQueue.main.async {
                        weakSelf.trackTableView.mj_footer?.isHidden = true
                    }                }
            }
            DispatchQueue.main.async {
                weakSelf.trackTableView.mj_footer?.endRefreshing()
                weakSelf.trackTableView.reloadData()
                weakSelf.trackTableView.layoutIfNeeded()
            }
        }

    }

}


extension OMLibraryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:OMSearchListTableViewSongCell = tableView.dequeueReusableCell(withIdentifier: SongCellReuseIdentifier, for: indexPath) as! OMSearchListTableViewSongCell
        guard let data = items[indexPath.row].amjsonData, let item = try? JSONDecoder().decode(AMTrack.self, from: data) else {
            return cell
        }
        self.items[indexPath.row].amTrack = item
        cell.setupCell(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        OMPlayer.shared.play(from: item)
        OMPlayer.shared.openPlayerViewControllerIfNeed()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        item.isLiked = false
        self.items.remove(at: indexPath.row)
        tableView.reloadData()
        tableView.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "取消收藏"
    }
    
}
