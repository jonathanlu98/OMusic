//
//  OMSearchMoreTableViewController.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/2/7.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import MJRefresh
import ProgressHUD

class OMSearchMoreTableViewController<T: AMObjectResponseProtocol>: UITableViewController,UIGestureRecognizerDelegate {
        
    /// 搜索关键字
    private let searchText:String
    
    private var itemsResponse: T?
    
    private var items:[OMSearchListSectionItem] = []
    
    private var cellReuseIdentifier: String {
        get {
            switch T.MediaClass.urlPathDescription {
            case .albums:
                return AlbumCellReuseIdentifier
            case .artists:
                return ArtistCellReuseIdentifier
            case .tracks:
                return SongCellReuseIdentifier
            }
        }
    }
    
    init(style:UITableView.Style, searchText:String) {
        self.searchText = searchText
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tableView.contentInset.bottom = CGFloat(OMPlayer.shared.menuView.isHidden ? 0:PLAYER_MENU_VIEW_HEIGHT)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = OMTheme.getColor(lightColor: .white, darkColor: .black)
        
        self.setupBackBar()
        
        self.handleTableView()

    }
    
    /// 添加返回按钮
    private func setupBackBar() {
        let backBarItem = (self.navigationController as! OMNavigationViewController).backitem
        self.navigationItem.setLeftBarButton(backBarItem, animated:true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        backBarItem.action = #selector(backBarAction)
        backBarItem.target = self
        self.title = "关于\"\(self.searchText)\"的结果"
    }
    
    @objc private func backBarAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    /// 处理tableview
    private func handleTableView() {
        
        self.tableView.showsVerticalScrollIndicator = false
        
        self.tableView.backgroundColor = OMTheme.getColor(lightColor: .white, darkColor: .black)
        
        self.tableView.separatorStyle = .none
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(UINib.init(nibName: self.cellReuseIdentifier, bundle: nil), forCellReuseIdentifier: self.cellReuseIdentifier)
        
        self.tableView.mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: {
                self.pullData()
        })
        
        self.getData()

    }
    
    /// 下拉拉取数据
    private func pullData() {
        guard let next:String = self.itemsResponse?.next else {
            self.tableView.mj_footer?.isHidden = true
            return
        }
        AMFetchManager.shared.requestSearchNextPage(next: next, responseObject: T.self) { [weak self] (response, error) in
            guard let weakSelf = self else {
                return
            }
            if (response != nil) {
                weakSelf.itemsResponse = response
                weakSelf.items.append(contentsOf: weakSelf.handleJsonData(response!))
                weakSelf.tableView.reloadData()
                weakSelf.tableView.layoutIfNeeded()
            }
            weakSelf.tableView.mj_footer?.endRefreshing()
        }

    }
    
    /// 获取数据
    private func getData() {
        AMFetchManager.shared.requestSearch(text: self.searchText, offset: 0, responseObject: T.self) { [weak self] (response, error) in
            guard let weakSelf = self else {
                return
            }
            if (response != nil) {
                weakSelf.itemsResponse = response
                weakSelf.items = weakSelf.handleJsonData(response!)
                weakSelf.tableView.reloadData()
                weakSelf.tableView.layoutIfNeeded()
            }
            weakSelf.tableView.mj_footer?.endRefreshing()
        }
    }

    
    /// 处理json数据
    private func handleJsonData<T: AMObjectResponseProtocol>(_ items: T) -> [OMSearchListSectionItem] {
        guard let data = items.data else {
            return []
        }
        switch T.MediaClass.urlPathDescription {
            case .albums:
                return data.map({ (obj) -> OMSearchListSectionItem in
                    return .AlbumSectionItem(item: obj as! AMAlbum)
                })
            case .artists:
                return data.map({ (obj) -> OMSearchListSectionItem in
                    return .ArtistSectionItem(item: obj as! AMArtist)
                })
            case .tracks:
                return data.map({ (obj) -> OMSearchListSectionItem in
                    return .SongSectionItem(item: obj as! AMTrack)
                })
        }
        
    }
    
    //MARK: UITableViewDataSource & UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellReuseIdentifier, for: indexPath)
        switch item {
            case .ArtistSectionItem(let aritem):
                (cell as! OMSearchListTableViewArtistCell).setupCell(item: aritem)
                
            case .AlbumSectionItem(let alitem):
                (cell as! OMSearchListTableViewAlbumCell).setupCell(item: alitem)
            
            case .SongSectionItem(let soitem):
                (cell as! OMSearchListTableViewSongCell).setupCell(item: soitem)
                
            case .MoreSectionItem( _):
                break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        switch item {
        case .ArtistSectionItem(_):
            break
        case .AlbumSectionItem(let item):
            ProgressHUD.show()
            AMFetchManager.shared.getObject(by: item.id, from: AMAlbum.self) { (object, error) in
                guard let object = object else {
                    return
                }
                object.relationships?.getRelaionshipsObjects({
                    let artist:JLArtist? = !OMArrayIsEmpty(object.relationships?.artists?.data) ? JLArtist.init(amArtist: (object.relationships?.artists?.data?.first)!):nil
                    let tracks = object.relationships?.tracks?.data?.map({ (item) -> JLTrack in
                        return JLTrack.init(amTrack: item, artists: (artist == nil ? nil:[artist!]), album: JLAlbum.init(amAlbum: object))!
                    })
                    let album = JLAlbum.init(amAlbum: object, artist: artist, tracks: tracks)
                    ProgressHUD.dismiss()
                    OMPlayer.shared.play(from: album!)
                    OMPlayer.shared.openPlayerViewControllerIfNeed()
                })
            }
            break
        case .SongSectionItem(let item):
            ProgressHUD.show()
            AMFetchManager.shared.getObject(by: item.id, from: AMTrack.self) { (object, error) in
                if error != nil {
                    ProgressHUD.showError(error?.localizedDescription, image: nil, interaction: true)
                } else {
                    guard let object = object else {
                        return
                    }
                    object.relationships?.getRelaionshipsObjects({
                        let artists = object.relationships?.artists?.data?.map({ (item) -> JLArtist in
                            return JLArtist.init(amArtist: item)!
                        })
                        let track = JLTrack.init(amTrack: object, artists: artists, album: OMArrayIsEmpty(object.relationships?.albums?.data) ? nil:JLAlbum.init(amAlbum:(object.relationships?.albums?.data?.first)!))
                        ProgressHUD.dismiss()
                        OMPlayer.shared.play(from: track!)
                        OMPlayer.shared.openPlayerViewControllerIfNeed()
                    })
                }
            }
            break
        case .MoreSectionItem( _):
            break
        }
    }

}



extension OMSearchMoreTableViewController {
    /*解决向右的返回*/
    @nonobjc func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.navigationController?.viewControllers.count ?? 0 <= 1 {
            return false
        } else {
            return true
        }
    }
}
