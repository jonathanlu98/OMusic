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
    
    public struct ListMode: Hashable, Equatable, RawRepresentable {
        public let rawValue: Int
        
        internal init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    let viewController:OMPlayerViewController = OMPlayerViewController()
    
    let menuView: OMPlayerMenuBarView = OMPlayerMenuBarView.loadFromXib()!
    
    private let mediaPlayer = JLMediaPlayer()
    
    private(set) var playListName:String?
    
    private(set) var tracks:OMPlaylistList = OMPlaylistList()
    
    private(set) var isPause: Bool = true {
        didSet {
            if isPause {
                ListenerCenter.shared.notifyPlayerControllerEventDetected(event: .paused)
            } else {
                ListenerCenter.shared.notifyPlayerControllerEventDetected(event: .playing)
            }
        }
    }
    
    private var playList: JLPlaylist?
    
    private(set) var currentTrack: OMPlaylistListNode?
    
    private var origialTracks:[JLTrack] = []
    
    private(set) var currentIndex = -1
    
    private(set) var currentTime: Float64 = 0
    
    private(set) var totalTime: Float64 = 0

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
            ListenerCenter.shared.notifyPlayerControllerEventDetected(event:  PlayerControllerEventType.init(rawValue: 20+self.listMode.rawValue)!)
        }
    }
    
    private(set) var trackStatus: JLMediaPlayerStatus?
    
    override private init() {
        super.init()
        self.mediaPlayer.delegate = self
    }
    
    /// Returns the default singleton instance.
    @objc public static let shared = OMPlayer.init()
    
    
//    public func play(from amTrack: AMTrack) {
//        var track = JLTrack.init(amTrack: amTrack)
//        guard let track = track else {
//            return
//        }
//
//        self.pause()
//        self.mediaPlayer.setupPlayer(config: JLMediaPlayerConfig.init(urlStr: amTrack.attributes?.previews?.first?.url ?? "", uniqueID: nil))
//
//        self.tracks = OMPlaylistList.init(track)
//        self.origialTracks = [track]
//        self.currentTrack = self.tracks.head
//        self.currentIndex = 0
//
//        self.currentTime = 0
//        self.totalTime = 0
//
//        self.isPause = false
//
//    }
    
    public func play(from track: JLTrack) {
        self.pause()
        self.mediaPlayer.setupPlayer(config: JLMediaPlayerConfig.init(urlStr: track.url?.absoluteString ?? "", uniqueID: nil))
        
        self.tracks = OMPlaylistList.init(track)
        self.origialTracks = [track]
        self.currentTrack = self.tracks.head
        self.currentIndex = 0

        self.currentTime = 0
        self.totalTime = 0
        
        self.isPause = false

    }
    
//    public func play(from amAlbum: AMAlbum) {
//        self.pause()
//        guard let amTrack = amAlbum.relationships?.tracks?.data?.first else {
//            return
//        }
//        self.mediaPlayer.setupPlayer(config: JLMediaPlayerConfig.init(urlStr: amTrack.attributes?.previews?.first?.url ?? "", uniqueID: nil))
//
//        let array:[JLTrack] = (amAlbum.relationships?.tracks?.data!.map({ (amTrack) -> JLTrack in
//            return JLTrack.init(amTrack: amTrack)
//        }))!
//        let list:OMPlaylistList = OMPlaylistList()
//        for item in array {
//            list.append(item)
//        }
//        self.tracks = list
//        self.origialTracks = array
//
//        self.playListName = amAlbum.attributes?.name
//
//        self.currentTrack = list.head
//        self.currentIndex = 0
//
//        self.currentTime = 0
//        self.totalTime = 0
//
//        self.isPause = false
//    }
    
    public func play(from album: JLAlbum) {
        self.pause()
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
        
        self.playListName = album.name
        
        self.currentTrack = list.head
        self.currentIndex = 0
        
        self.currentTime = 0
        self.totalTime = 0
        
        self.isPause = false

    }
    
    public func play(from playlist: JLPlaylist) {
        self.pause()
        guard let track = playlist.tracks?.first else {
            return
        }
        self.mediaPlayer.setupPlayer(config: JLMediaPlayerConfig.init(urlStr: track.url?.absoluteString ?? "", uniqueID: nil))
        
        let list:OMPlaylistList = OMPlaylistList()
        for item in playlist.tracks! {
            list.append(item)
        }
        self.tracks = list
        self.origialTracks = playlist.tracks!
        self.playList = playlist
        
        self.playListName = playlist.name
        
        self.currentTrack = list.head
        self.currentIndex = 0
        
        self.currentTime = 0
        self.totalTime = 0
        
        self.isPause = false
                
    }
    
    public func openPlayerViewControllerIfNeed() {
        if (UIViewController.currentViewController() is OMPlayerViewController) {
            (UIViewController.currentViewController() as! OMPlayerViewController).updateView()
        } else {
            UIViewController.currentViewController()?.presentPanModal(self.viewController)

        }
    }
    
    
    public func play() {
        if self.isPause && self.currentTime == self.totalTime && (self.currentTrack != nil) {
            self.currentTime = 0
            self.mediaPlayer.reset()
            self.mediaPlayer.play()
            ListenerCenter.shared.notifyPlayerControllerEventDetected(event: .playing)
            return
        }
        self.mediaPlayer.play()
        self.isPause = false
    }
    
    public func pause() {
        self.mediaPlayer.pause()
        self.isPause = true
        
    }
    
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
    
    
    public func seekPlayerToTime(time: Float64, autoPlay: Bool = false, completion: SeekCompletion?) {
        self.mediaPlayer.seekPlayerToTime(time: time, autoPlay: autoPlay, completion: completion)
    }

}


extension OMPlayer: JLMediaPlayerDelegate {
    func avplayer(_ avplayer: JLMediaPlayer, refreshed currentTime: Float64, loadedTime: Float64, totalTime: Float64) {
        self.currentTime = currentTime
        self.totalTime = totalTime
        self.viewController.updateProgressView(currentTime: currentTime, totalTime: totalTime)
    }
    
    func avplayer(_ avplayer: JLMediaPlayer, didChanged status: JLMediaPlayerStatus) {
        self.trackStatus = status
        switch status {
        case .loading:
            self.isPause = false
            ListenerCenter.shared.notifyPlayerControllerEventDetected(event: .loading)
            break
        case .loadingFailed:
            self.isPause = true
            ListenerCenter.shared.notifyPlayerControllerEventDetected(event: .failed)
            break
        case .readyToPlay:
            self.currentTrack?.value.recentPlayTime = Date()
            break
        case .playEnd:
            self.isPause = true
            self.next(isAuto: true)
            ListenerCenter.shared.notifyPlayerControllerEventDetected(event: .playEnd)
            break
        case .playbackStalled:
            self.isPause = true
            ListenerCenter.shared.notifyPlayerControllerEventDetected(event: .stalled)
            break
        case .bufferBegin:
            self.play()
            ListenerCenter.shared.notifyPlayerControllerEventDetected(event: .playing)
            self.updatePlayingCenter()
            break
        case .bufferEnd:
            break
        }
    }
    
    func avplayer(_ avplayer: JLMediaPlayer, didReceived remoteCommand: JLMediaPlayerRemoteCommand) -> Bool {
        switch remoteCommand {
        case .play:
            self.play()
            ListenerCenter.shared.notifyPlayerControllerEventDetected(event: .playing)
            break
        case .pause:
            self.pause()
            ListenerCenter.shared.notifyPlayerControllerEventDetected(event: .paused)
            break
        case .next:
            self.next(isAuto: false)
            ListenerCenter.shared.notifyPlayerControllerEventDetected(event: .next)
            break
        case .previous:
            self.previous()
            ListenerCenter.shared.notifyPlayerControllerEventDetected(event: .previous)
            break
        }
        return true
    }
    
    
    private func openShuffle() {
        if !origialTracks.isEmpty && currentIndex >= 0 && currentIndex < origialTracks.count-1 {
            guard let track = self.currentTrack ?? self.tracks.head else {
                return
            }
            let arr = Array(self.origialTracks.suffix(from: currentIndex+1))
            self.tracks.shuffle(from: track, source: arr)
        }
    }
    
    private func recoverList() {
        if !origialTracks.isEmpty && currentIndex >= 0 && currentIndex < origialTracks.count-1 {
            guard let track = self.currentTrack ?? self.tracks.head else {
                return
            }
            let arr = Array(self.origialTracks.suffix(from: currentIndex+1))
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
            self.mediaPlayer.setupNowPlaying(title: track.name ?? "歌曲", description: description, image: image ?? UIImage.init(named: "default_track_cover"))
        }
    }
}


//MARK: OMPlayer.ListMode

extension OMPlayer.ListMode {
    static let none: OMPlayer.ListMode = .init(rawValue: 0)
    static let loop: OMPlayer.ListMode = .init(rawValue: 1)
    static let shuffle: OMPlayer.ListMode = .init(rawValue: 2)
    static let `repeat`: OMPlayer.ListMode = .init(rawValue: 3)
}



