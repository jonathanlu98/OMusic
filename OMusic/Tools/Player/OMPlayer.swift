//
//  OMPlayer.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/3/30.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import SDWebImage
import PanModal

class OMPlayer: NSObject {
    
    public typealias SeekCompletion = (Bool) -> Void
    /// 播放列表枚举结构类
    public struct ListMode: Hashable, Equatable, RawRepresentable {
        public let rawValue: Int
        internal init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    /// 播放主界面
    public let viewController: OMPlayerViewController = OMPlayerViewController()
    /// 播放控制栏
    public let menuView: OMPlayerMenuBarView = OMPlayerMenuBarView.loadFromXib()!
    /// mediaPlayer
    private let mediaPlayer = JLMediaPlayer()
    /// 当前播放队列的名称
    private(set) var playListName:String?
    /// 播放队列
    private(set) var tracks:OMPlaylistList = OMPlaylistList()
    /// 是否暂停
    private(set) var isPause: Bool = true {
        didSet {
            if isPause {
                OMPlayerListenerCenter.shared.notifyPlayerControllerEventDetected(event: .paused)
            } else {
                OMPlayerListenerCenter.shared.notifyPlayerControllerEventDetected(event: .playing)
            }
        }
    }
    /// 当前播放歌曲
    private(set) var currentTrack: OMPlaylistListNode?
    /// 原始播放歌曲数组
    private var origialTracks:[JLTrack] = []
    /// 当前歌曲在列表中的下标
    private(set) var currentIndex = -1
    /// 当前播放进度
    private(set) var currentTime: Float64 = 0
    /// 当前歌曲播放总时长
    private(set) var totalTime: Float64 = 0
    /// 播放模式
    public var listMode: ListMode = .none {
        didSet {
            if listMode == .shuffle {
                if oldValue == .loop {
                    self.tracks.isLoop = false
                }
                self.openShuffle()
            } else if listMode == .loop {
                if oldValue == .shuffle {
                    self.recoverList()
                }
                self.tracks.isLoop = true
            } else {
                if oldValue == .loop {
                    self.tracks.isLoop = false
                }
                if oldValue == .shuffle {
                    self.recoverList()
                }
            }
            OMPlayerListenerCenter.shared.notifyPlayerControllerEventDetected(event:  OMPlayerControllerEventType.init(rawValue: 20+self.listMode.rawValue)!)
        }
    }
    /// 当前歌曲状态
    private(set) var trackStatus: JLMediaPlayerStatus?
    /// 单例对象
    @objc public static let shared = OMPlayer.init()
    
    override private init() {
        super.init()
        self.mediaPlayer.delegate = self
    }
    
    
    //MARK: Public Method
    
    
    /// 单曲播放
    /// - Parameter track: JLTrack对象
    public func play(from track: JLTrack) {
        self.mediaPlayer.setupPlayer(config: JLMediaPlayerConfig.init(urlStr: track.url?.absoluteString ?? "", uniqueID: nil))
        self.tracks = OMPlaylistList.init(track)
        self.origialTracks = [track]
        self.currentTrack = self.tracks.head
        self.reset()
    }
    
    /// 专辑播放
    /// - Parameter album: JLAlbum对象
    public func play(from album: JLAlbum) {
        guard let track = album.tracks?.first else {
            return
        }
        self.mediaPlayer.setupPlayer(config: JLMediaPlayerConfig.init(urlStr: track.url?.absoluteString ?? "", uniqueID: nil))
        let list:OMPlaylistList = OMPlaylistList()
        for item in album.tracks! {
            list.append(item)
        }
        self.tracks = list
        self.origialTracks = Array.init(album.tracks!)
        self.currentTrack = list.head
        self.reset()
        self.playListName = album.name
    }
    
    /// 弹出播放主界面
    public func openPlayerViewControllerIfNeed() {
        if (UIViewController.currentViewController() is OMPlayerViewController) {
            (UIViewController.currentViewController() as! OMPlayerViewController).updateView()
        } else {
            UIViewController.currentViewController()?.presentPanModal(self.viewController)
        }
    }
    
    /// 播放
    public func play() {
        if self.isPause && self.currentTime == self.totalTime && (self.currentTrack != nil) {
            self.currentTime = 0
            self.mediaPlayer.reset()
            self.mediaPlayer.play()
            OMPlayerListenerCenter.shared.notifyPlayerControllerEventDetected(event: .playing)
            return
        }
        self.mediaPlayer.play()
        self.isPause = false
    }
    
    /// 暂停
    public func pause() {
        self.mediaPlayer.pause()
        self.isPause = true
    }
    
    /// 下一首
    /// - Parameter isAuto: 是否是自动下一首，比如音乐结束了
    public func next(isAuto: Bool) {
        self.totalTime = 0
        self.currentTime = 0
        self.pause()
        guard let currentTrack = self.currentTrack else {
            return
        }
        if isAuto && self.listMode == .repeat {
            self.mediaPlayer.setupPlayer(config: .init(urlStr: currentTrack.value.url?.absoluteString ?? "", uniqueID: nil))
            self.isPause = false
            return
        }
        guard let next = self.currentTrack?.next else {
            return
        }
        self.currentTrack = next
        self.currentIndex = self.currentIndex + 1
        self.mediaPlayer.setupPlayer(config: .init(urlStr: self.currentTrack?.value.url?.absoluteString ?? "", uniqueID: nil))
        self.isPause = false
    }
    
    /// 上一首
    public func previous() {
        self.totalTime = 0
        self.currentTime = 0
        self.pause()
        guard let previousTrack = self.currentTrack?.previous else {
            return
        }
        self.currentTrack = previousTrack
        self.currentIndex = self.currentIndex - 1
        self.mediaPlayer.setupPlayer(config: JLMediaPlayerConfig.init(urlStr: previousTrack.value.url?.absoluteString ?? "", uniqueID: nil))
        self.isPause = false
    }
    
    /// 指定从某处播放
    /// - Parameters:
    ///   - time: 开始时间
    ///   - autoPlay: 是否自动播放
    ///   - completion: SeekCompletion
    public func seekPlayerToTime(time: Float64, autoPlay: Bool = false, completion: SeekCompletion?) {
        self.mediaPlayer.seekPlayerToTime(time: time, autoPlay: autoPlay, completion: completion)
    }
    
    
    // MARK: Private Method
    
    
    private func reset() {
        self.currentIndex = 0
        self.currentTime = 0
        self.totalTime = 0
        self.playListName = ""
        self.pause()
    }
    
    private func openShuffle() {
        if !origialTracks.isEmpty && currentIndex >= 0 && currentIndex < origialTracks.count-1 {
            guard let track = self.currentTrack ?? self.tracks.head else {
                return
            }
            let arr = Array(self.origialTracks.suffix(from: currentIndex+1))
            //随机排序
            self.tracks.shuffle(from: track, source: arr)
        }
    }
    
    private func recoverList() {
        if !origialTracks.isEmpty && currentIndex >= 0 && currentIndex < origialTracks.count-1 {
            guard let track = self.currentTrack ?? self.tracks.head else {
                return
            }
            let arr = Array(self.origialTracks.suffix(from: currentIndex+1))
            //恢复排序
            self.tracks.recoverList(from: track, source: arr)
        }
    }
    
    private func updatePlayingCenter() {
        guard let trackNode = self.currentTrack else {
            self.mediaPlayer.setupNowPlaying(title: "" , description: "", image: UIImage())
            return
        }
        let track = trackNode.value
        let imgUrl = URL.amCoverUrl(string: track.amTrack?.attributes?.artwork?.url ?? "", size: 864)
        let albumName = OMStringIsEmpty(track.album?.name) ? track.amTrack?.attributes?.albumName:track.album?.name
        let artistName = OMStringIsEmpty(track.artists?.first?.name) ? track.amTrack?.attributes?.artistName:track.artists?.first?.name
        let description = (albumName ?? "专辑") + "   " + (artistName ?? "歌手")
        self.mediaPlayer.setupNowPlaying(title: track.name ?? "歌曲", description: description, image: UIImage.init(named: "default_track_cover"))
        SDWebImageDownloader.shared.downloadImage(with: imgUrl) { [unowned self] (image, data, error, succeed) in
            if trackNode != self.currentTrack {
                return
            }
            //对于系统Remote Control栏进行更新信息
            self.mediaPlayer.setupNowPlaying(title: track.name ?? "歌曲", description: description, image: image ?? UIImage.init(named: "default_track_cover"))
        }
    }
}


//MARK: JLMediaPlayerDelegate

extension OMPlayer: JLMediaPlayerDelegate {
    
    func avplayer(_ avplayer: JLMediaPlayer, refreshed currentTime: Float64, totalTime: Float64) {
        //进度更新
        self.currentTime = currentTime
        self.totalTime = totalTime
        self.viewController.updateProgressView(currentTime: currentTime, totalTime: totalTime)
    }
    
    func avplayer(_ avplayer: JLMediaPlayer, didChanged status: JLMediaPlayerStatus) {
        //播放状态改变
        self.trackStatus = status
        switch status {
        case .loading:
            self.isPause = false
            OMPlayerListenerCenter.shared.notifyPlayerControllerEventDetected(event: .loading)
            break
        case .loadingFailed:
            self.isPause = true
            OMPlayerListenerCenter.shared.notifyPlayerControllerEventDetected(event: .failed)
            break
        case .readyToPlay:
            self.currentTrack?.value.recentPlayTime = Date()
            break
        case .playEnd:
            self.isPause = true
            self.next(isAuto: true)
            OMPlayerListenerCenter.shared.notifyPlayerControllerEventDetected(event: .playEnd)
            break
        case .playbackStalled:
            self.isPause = true
            OMPlayerListenerCenter.shared.notifyPlayerControllerEventDetected(event: .stalled)
            break
        case .bufferBegin:
            self.play()
            OMPlayerListenerCenter.shared.notifyPlayerControllerEventDetected(event: .playing)
            self.updatePlayingCenter()
            break
        case .bufferEnd:
            break
        }
    }
    
    func avplayer(_ avplayer: JLMediaPlayer, didReceived remoteCommand: JLMediaPlayerRemoteCommand) -> Bool {
        //应用外部做出的操作
        switch remoteCommand {
        case .play:
            self.play()
            OMPlayerListenerCenter.shared.notifyPlayerControllerEventDetected(event: .playing)
            break
        case .pause:
            self.pause()
            OMPlayerListenerCenter.shared.notifyPlayerControllerEventDetected(event: .paused)
            break
        case .next:
            self.next(isAuto: false)
            OMPlayerListenerCenter.shared.notifyPlayerControllerEventDetected(event: .next)
            break
        case .previous:
            self.previous()
            OMPlayerListenerCenter.shared.notifyPlayerControllerEventDetected(event: .previous)
            break
        }
        return true
    }
}


//MARK: OMPlayer.ListMode

extension OMPlayer.ListMode {
    static let none: OMPlayer.ListMode = .init(rawValue: 0)
    static let loop: OMPlayer.ListMode = .init(rawValue: 1)
    static let shuffle: OMPlayer.ListMode = .init(rawValue: 2)
    static let `repeat`: OMPlayer.ListMode = .init(rawValue: 3)
}



