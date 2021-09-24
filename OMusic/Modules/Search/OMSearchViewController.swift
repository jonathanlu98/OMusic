//
//  OMSearchViewController.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/2/5.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import PanModal
import ProgressHUD

class OMSearchViewController: UIViewController {
    
    @IBOutlet weak private var titleLabel: UILabel!
    
    @IBOutlet weak private var searchBar: UISearchBar!
    
    @IBOutlet weak private var searchListTableView: UITableView!
    
    private var searchText: String?
    
    private var items: [OMSearchListSection] = []
    
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tableViewBottom.constant = CGFloat(OMPlayer.shared.menuView.isHidden ? 0:-PLAYER_MENU_VIEW_HEIGHT)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.searchTextField.textColor = OMTheme.getTextColor()
        self.searchBar.searchTextField.font = MIFont.lanProFont(size: 13, weight: .regular)
        self.searchBar.searchTextField.placeholder = "输入关键字"
        self.searchBar.delegate = self
        
        self.view.backgroundColor = OMTheme.getColor(lightColor: UIColor.white, darkColor: UIColor.black)

        self.titleLabel.textColor = OMTheme.getTextColor()
        
        handleTableView()
    }
    
    
    private func handleTableView() {
        //注册cell
        self.searchListTableView.register(UINib.init(nibName: ArtistCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: ArtistCellReuseIdentifier)
        self.searchListTableView.register(UINib.init(nibName: AlbumCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: AlbumCellReuseIdentifier)
        self.searchListTableView.register(UINib.init(nibName: SongCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: SongCellReuseIdentifier)
        self.searchListTableView.register(UINib.init(nibName: MoreCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: MoreCellReuseIdentifier)
        
        
        
        self.searchListTableView.delegate = self
        self.searchListTableView.dataSource = self
        
    }
    
    
    
    /// 处理获取的json数据
    /// - Parameters:
    ///   - json: json
    ///   - limit: 当前limit
    ///   - text: section文本
    private func handleSectionData(searchItems: AMSearchItems) -> [OMSearchListSection] {
        
        var sections = [OMSearchListSection]()
        
        let artistSectionItems = searchItems.artists?.data?.map({ (item) -> OMSearchListSectionItem in
            return .ArtistSectionItem(item: item)
        })
        let albumSectionItems = searchItems.albums?.data?.map({ (item) -> OMSearchListSectionItem in
            return .AlbumSectionItem(item: item)
        })
        let songSectionItems = searchItems.songs?.data?.map({ (item) -> OMSearchListSectionItem in
            return .SongSectionItem(item: item)
        })
        
        var moreSectionItems = [OMSearchListSectionItem]()

        if ((searchItems.artists?.next) != nil) {
            moreSectionItems.append( .MoreSectionItem(type: .artist))
        }
        
        if ((searchItems.albums?.next) != nil) {
            moreSectionItems.append( .MoreSectionItem(type: .album))
        }
        
        if ((searchItems.songs?.next) != nil) {
            moreSectionItems.append( .MoreSectionItem(type: .track))
        }

        if artistSectionItems != nil && artistSectionItems!.count > 0 {
            sections.append(OMSearchListSection(header: "歌手", items: artistSectionItems!))
        }
        if songSectionItems != nil && songSectionItems!.count > 0 {
            sections.append(OMSearchListSection(header: "单曲", items: songSectionItems!))
        }
        if albumSectionItems != nil && albumSectionItems!.count > 0 {
            sections.append(OMSearchListSection(header: "专辑", items: albumSectionItems!))
        }
        if moreSectionItems.count != 0 {
            sections.append(OMSearchListSection(header: "", items: moreSectionItems))
        }
        
        return sections
    }
    
    

}


//MARK: UITableView Delegate & Datasource

extension OMSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.items.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.items[indexPath.section].items[indexPath.row] {
            
        case .ArtistSectionItem(let artistItem):
            let cell = tableView.dequeueReusableCell(withIdentifier: ArtistCellReuseIdentifier,
            for: indexPath) as! OMSearchListTableViewArtistCell
            cell.setupCell(item: artistItem)
            return cell
            
        case .AlbumSectionItem(let albumItem):
            let cell = tableView.dequeueReusableCell(withIdentifier: AlbumCellReuseIdentifier,
            for: indexPath) as! OMSearchListTableViewAlbumCell
            cell.setupCell(item: albumItem)
            return cell
        case .SongSectionItem(let songItem):
            let cell = tableView.dequeueReusableCell(withIdentifier: SongCellReuseIdentifier,
            for: indexPath) as! OMSearchListTableViewSongCell
            cell.setupCell(item: songItem)
            return cell
        case .MoreSectionItem(let type):
            let cell = tableView.dequeueReusableCell(withIdentifier: MoreCellReuseIdentifier,
            for: indexPath) as! OMSearchListTableViewMoreCell
            cell.type = type
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.items[section].header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.section].items[indexPath.row]
        
        switch item {
            
        case .ArtistSectionItem(_):
            break
            
        case .AlbumSectionItem(let item):
            ProgressHUD.show(interaction: false)
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
            ProgressHUD.show(interaction: false)
            AMFetchManager.shared.getObject(by: item.id, from: AMTrack.self) { (object, error) in
                if error != nil {
                    ProgressHUD.showError(error?.localizedDescription, image: nil, interaction: false)
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
            
        case .MoreSectionItem(let type):
            guard let searchText = self.searchText else {
                return
            }
            switch type {
            case .track:
                let vc = OMSearchMoreTableViewController<AMTracks>.init(style: UITableView.Style.plain, searchText: searchText)
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case .album:
                let vc = OMSearchMoreTableViewController<AMAlbums>.init(style: UITableView.Style.plain, searchText: searchText)
                self.navigationController?.pushViewController(vc, animated: true)
                break
            case .artist:
                let vc = OMSearchMoreTableViewController<AMArtists>.init(style: UITableView.Style.plain, searchText: searchText)
                self.navigationController?.pushViewController(vc, animated: true)
                break
            }
            break
            
        }
    }
}



//MARK: UISearchBarDelegate

extension OMSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if (searchBar.text != nil && searchBar.text != "") {
            let text = searchBar.text!
            self.searchText = text
            ProgressHUD.show(interaction: false)
            AMFetchManager.shared.requestMutiSearch(text: text) { [weak self] (items, error) in
                ProgressHUD.dismiss()
                guard let weakSelf = self else {
                    return;
                }
                if (items != nil) {
                    weakSelf.items = self?.handleSectionData(searchItems: items!) ?? []
                } else {
                    weakSelf.items = []
                }
                weakSelf.searchListTableView.reloadData()
                weakSelf.searchListTableView.layoutIfNeeded()
            }
        }
    }
}
