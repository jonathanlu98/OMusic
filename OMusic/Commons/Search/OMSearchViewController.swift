//
//  OMSearchViewController.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/2/5.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import PanModal

class OMSearchViewController: UIViewController {
    
    @IBOutlet weak private var titleLabel: UILabel!
    
    @IBOutlet weak private var searchBar: UISearchBar!
    
    @IBOutlet weak private var searchListTableView: UITableView!
    
    private var searchText: String?
    
    /// 处理后的数据（RX）
    fileprivate var data = BehaviorRelay.init(value: [OMSearchListSection]())
    
    /// tableView的数据源（RX）
    fileprivate var dataSource = RxTableViewSectionedReloadDataSource<OMSearchListSection>(
        //设置单元格
        configureCell: { dataSource, tableView, indexPath, item in
            switch dataSource[indexPath] {
                
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
        },
        //设置分区头标题
        titleForHeaderInSection: { ds, index in

            return ds.sectionModels[index].header
        }
    )
    
    let dispose = DisposeBag()
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true

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
        searchListTableView.register(UINib.init(nibName: ArtistCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: ArtistCellReuseIdentifier)
        searchListTableView.register(UINib.init(nibName: AlbumCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: AlbumCellReuseIdentifier)
        searchListTableView.register(UINib.init(nibName: SongCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: SongCellReuseIdentifier)
        searchListTableView.register(UINib.init(nibName: MoreCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: MoreCellReuseIdentifier)
        
        //数据绑定
        self.data.bind(to: self.searchListTableView.rx.items(dataSource: dataSource)).disposed(by: dispose)
        //cell点击事件
        searchListTableView.rx.modelSelected(OMSearchListSectionItem.self).subscribe(onNext: { (item) in
            switch item {
                
            case .ArtistSectionItem(let item):
                break
                
            case .AlbumSectionItem(let item):
                break
                
            case .SongSectionItem(let item):
                break
                
            case .MoreSectionItem(let type):
                guard let searchText = self.searchText else {
                    return
                }
                switch type {
                case .track:
                    let vc = OMSearchMoreTableViewController<AMTracks>.init(style: UITableView.Style.plain, searchText: searchText, type: type)
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case .album:
                    let vc = OMSearchMoreTableViewController<AMAlbums>.init(style: UITableView.Style.plain, searchText: searchText, type: type)
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                case .artist:
                    let vc = OMSearchMoreTableViewController<AMArtists>.init(style: UITableView.Style.plain, searchText: searchText, type: type)
                    self.navigationController?.pushViewController(vc, animated: true)
                    break
                }
                break
                
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: dispose)
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


//MARK: UISearchBarDelegate

extension OMSearchViewController: UISearchBarDelegate {
    

    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if (searchBar.text != nil && searchBar.text != "") {
            let text = searchBar.text!
            self.searchText = text
            AMFetchManager.shared.requestMutiSearch(text: text) { [weak self] (items, error) in
                guard let weakSelf = self else {
                    return;
                }
                if (items != nil) {
                    Observable
                        .just(
                            self?.handleSectionData(searchItems: items!) ?? []
                        )
                        .delay(TimeInterval(0.2), scheduler: MainScheduler.instance)
                        .asDriver(onErrorDriveWith: Driver.empty()).drive(weakSelf.data).disposed(by: weakSelf.dispose)
                } else {
                    Observable
                    .just(
                        []
                    )
                    .delay(TimeInterval(0.2), scheduler: MainScheduler.instance)
                        .asDriver(onErrorDriveWith: Driver.empty()).drive(weakSelf.data).disposed(by: weakSelf.dispose)
                }
            }
        }
    }
    
    
    
}
