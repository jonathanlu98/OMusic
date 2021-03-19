//
//  OMSearchMoreTableViewController.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/2/7.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh


let SongCellReuseIdentifier = NSStringFromClass(OMSearchListTableViewSongCell.self).components(separatedBy: ".").last!
let ArtistCellReuseIdentifier = NSStringFromClass(OMSearchListTableViewArtistCell.self).components(separatedBy: ".").last!
let AlbumCellReuseIdentifier = NSStringFromClass(OMSearchListTableViewAlbumCell.self).components(separatedBy: ".").last!
let MoreCellReuseIdentifier = NSStringFromClass(OMSearchListTableViewMoreCell.self).components(separatedBy: ".").last!


class OMSearchMoreTableViewController<T: AMObjectResponseProtocol>: UITableViewController,UIGestureRecognizerDelegate {
        
    /// 搜索关键字
    private let searchText:String
    
    /// 搜索类型
    private let type:OMSearchMoreType
    
    /// 处理后的数据（RX）
    private var data = BehaviorRelay.init(value: [OMSearchListSectionItem]())
    
    private var itemsResponse: T?
    
    private let dispose = DisposeBag()
    
    
    init(style:UITableView.Style, searchText:String, type:OMSearchMoreType) {
        self.searchText = searchText
        self.type = type
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
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
        backBarItem.rx.tap.subscribe(onNext: { (arg0) in
            let () = arg0
            self.navigationController?.popViewController(animated: true)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: dispose)
        self.title = "关于\"\(self.searchText)\"的结果"
    }
    
    
    /// 处理tableview
    private func handleTableView() {
        
        self.tableView.backgroundColor = OMTheme.getColor(lightColor: .white, darkColor: .black)
        
        self.tableView.separatorStyle = .none
        
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        
        switch type {
        case .album:
            self.tableView.register(UINib.init(nibName: AlbumCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: AlbumCellReuseIdentifier)
            self.bindData(cellId: AlbumCellReuseIdentifier, cellType: OMSearchListTableViewAlbumCell.self)
            break
        case .artist:
            self.tableView.register(UINib.init(nibName: ArtistCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: ArtistCellReuseIdentifier)
            self.bindData(cellId: ArtistCellReuseIdentifier, cellType: OMSearchListTableViewArtistCell.self)
            break
        case .track:
            self.tableView.register(UINib.init(nibName: SongCellReuseIdentifier, bundle: nil), forCellReuseIdentifier: SongCellReuseIdentifier)
            self.bindData(cellId: SongCellReuseIdentifier, cellType: OMSearchListTableViewSongCell.self)
            break
        }
        
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
                let items = weakSelf.handleJsonData(response!)
                Observable.just(items).delay(TimeInterval(0.2), scheduler: MainScheduler.instance).asDriver(onErrorDriveWith: Driver.empty()).drive(onNext: { (items) in
                    weakSelf.data.accept(weakSelf.data.value + items)
                }, onCompleted: nil, onDisposed: nil).disposed(by: weakSelf.dispose)
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
                Observable
                    .just(
                        weakSelf.handleJsonData(response!)
                    )
                    .delay(TimeInterval(0.2), scheduler: MainScheduler.instance)
                    .asDriver(onErrorDriveWith: Driver.empty()).drive(weakSelf.data).disposed(by: weakSelf.dispose)
            }
            weakSelf.tableView.mj_footer?.endRefreshing()
        }
    }
    

    
    /// 绑定数据（RX）
    /// - Parameters:
    ///   - cellId: cell的id
    ///   - cellType: cell种类
    private func bindData(cellId:String, cellType:UITableViewCell.Type) {
        
        self.data.bind(to: self.tableView.rx.items(cellIdentifier: cellId, cellType: cellType)) {index,item,cell in
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
        }.disposed(by: dispose)
        
        self.tableView.rx.modelSelected(OMSearchListSectionItem.self).subscribe(onNext: { (item) in
            switch item {
                
            case .ArtistSectionItem(let item):
                break
            case .AlbumSectionItem(let item):
                break
            case .SongSectionItem(let item):
                break
            @unknown default:
                break
            }
            }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: dispose)
    }

    
    /// 处理json数据
    private func handleJsonData<T: AMObjectResponseProtocol>(_ items: T) -> [OMSearchListSectionItem] {
        guard let data = items.data else {
            return []
        }
        switch type {
            case .album:
                return data.map({ (obj) -> OMSearchListSectionItem in
                    return .AlbumSectionItem(item: obj as! AMAlbum)
                })
            case .artist:
                return data.map({ (obj) -> OMSearchListSectionItem in
                    return .ArtistSectionItem(item: obj as! AMArtist)
                })
            case .track:
                return data.map({ (obj) -> OMSearchListSectionItem in
                    return .SongSectionItem(item: obj as! AMTrack)
                })
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
