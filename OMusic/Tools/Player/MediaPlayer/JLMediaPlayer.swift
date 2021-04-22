//
//  JLMediaPlayer.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/11/27.
//

import AVFoundation
import CoreAudio
import MediaPlayer
import CoreGraphics

/* 对于 AVPlayer 的监听键 */
private let JLMediaPlayerItemStatus = "status"
private let JLMediaPlayerPlaybackBufferEmpty = "playbackBufferEmpty"
private let JLMediaPlayerPlaybackLikelyToKeepUp = "playbackLikelyToKeepUp"

/// Player 状态
public enum JLMediaPlayerStatus: Int {
    case loading = 0
    case loadingFailed
    case readyToPlay
    case playEnd
    case playbackStalled
    case bufferBegin
    case bufferEnd
}

/// Player remote command, 由通知界面中的音乐控件发出的控制状态
public enum JLMediaPlayerRemoteCommand {
    case play
    case pause
    case next
    case previous
}

/// JLMediaPlayerDelegate
public protocol JLMediaPlayerDelegate: AnyObject {

    /// 进度条时间代理
    func avplayer(_ avplayer: JLMediaPlayer, refreshed currentTime: Float64, totalTime: Float64)

    /// Player状态变化代理
    func avplayer(_ avplayer: JLMediaPlayer, didChanged status: JLMediaPlayerStatus)

    /// 外部控制代理
    func avplayer(_ avplayer: JLMediaPlayer, didReceived remoteCommand: JLMediaPlayerRemoteCommand) -> Bool
}


public class JLMediaPlayer: NSObject {
    
    public typealias SeekCompletion = (Bool) -> Void

    /// 代理对象
    public weak var delegate: JLMediaPlayerDelegate?
    
    /// 总时间
    public var totalTime: Float64 {
        guard let player = player, let currentItem = player.currentItem else {
            return 0
        }
        return CMTimeGetSeconds(currentItem.duration)
    }
    
    /// 当前时间
    public var currentTime: Float64 {
        guard let player = player, let currentItem = player.currentItem else {
            return 0
        }
        return CMTimeGetSeconds(currentItem.currentTime())
    }
    
    /// AVPlayer对象
    private(set) public var player: AVPlayer?
    
    /// AVPlayerItem对象
    private(set) public var playerItem: AVPlayerItem?
    
    /// 当前播放资源地址
    private(set) public var currentURLStr: String?
    
    private var config: JLMediaPlayerConfig = JLMediaPlayerConfig.default

    private var urlAsset: AVURLAsset?
    
    private var assetLoader: JLMediaPlayerAssetLoader?
    
    private var isObserverAdded: Bool = false

    private var timeObserver: Any?
    
    private var isSeeking: Bool = false
    
    private var isReadyToPlay: Bool = false
    
    private var isBufferBegin: Bool = false
    
    private var seekItem: JLMediaPlayerSeekItem?
    
    public override init() {
        super.init()
        self.setupRemoteTransportControls()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.removeNotifications()
        self.removePlayerObserver()
        if let player = player {
            if let currentItem = playerItem {
                self.removePlayerItemObserver(playerItem: currentItem)
            }
            player.replaceCurrentItem(with: nil)
        }
        self.delegate = nil
        self.playerItem = nil
    }
    
}


// MARK: - Actions

extension JLMediaPlayer {
    
    /// 配置Player需要播放的地址, 成功加载后，会进入准备播放的状态
    /// - Parameter config: 配置信息
    public func setupPlayer(config: JLMediaPlayerConfig) {
        guard let url = URL(string: config.urlStr) else {
            return
        }
        if let _ = self.player, let oldAssetLoader = self.assetLoader {
            //清除之前的assetLoader
            oldAssetLoader.cleanup()
            self.assetLoader = nil
        }
        self.config = config
        self.isReadyToPlay = false
        self.currentURLStr = config.urlStr
        //创建并加载assetLoader
        let assetLoader = self.createAssetLoader(url: url, uniqueID: config.uniqueID)
        assetLoader.loadAsset { [weak self] (asset) in
            guard let weakSelf = self else {
                return
            }
            if let _ = weakSelf.player {
                weakSelf.replacePalyerItem(asset: asset)
            } else {
                weakSelf.createPlayer(asset: asset)
            }
        }
        self.assetLoader = assetLoader
    }
    
    /// 替换playerItem
    /// - Parameters:
    ///   - urlStr: 播放资源地址
    ///   - uniqueID: 播放唯一标识符
    public func replace(urlStr: String, uniqueID: String?) {
        self.config.urlStr = urlStr
        self.config.uniqueID = uniqueID
        self.setupPlayer(config: self.config)
    }

    /// 播放
    public func play() {
        guard let player = self.player, player.rate == 0 else {
            return
        }
        player.play()
    }

    /// 暂停
    public func pause() {
        guard let player = self.player, player.rate == 1.0 else {
            return
        }
        player.pause()
    }

    /// 当前歌曲重置到开始时间
    public func reset() {
        guard let player = self.player else {
            return
        }
        player.pause()
        self.seekPlayerToTime(time: 0, autoPlay: false) { [weak self] (finished) in
            guard let weakSelf = self, finished else {
                return
            }
            if let playerItem = weakSelf.player?.currentItem {
                let total = CMTimeGetSeconds(playerItem.duration)
                weakSelf.delegate?.avplayer(weakSelf, refreshed: 0, totalTime: total)
            }
        }
    }

    /// 拖动到指定时间播放
    public func seekPlayerToTime(time: Float64, autoPlay: Bool = true, completion: SeekCompletion?) {
        guard let player = self.player, let playerItem = self.playerItem else {
            return
        }
        guard self.isReadyToPlay else {
            //还没加载好，但是预存进度
            self.seekItem = JLMediaPlayerSeekItem(time: time, autoPlay: autoPlay, completion: completion)
            return
        }
        self.seekItem = nil
        let total = CMTimeGetSeconds(playerItem.duration)
        let didReachEnd = total > 0 && (time >= total || abs(time - total) <= 0.5)
        //到底直接结束
        if didReachEnd {
            if let completion = completion {
                completion(true)
            }
            self.handlePlayerStatus(status: .playEnd)
            return
        }
        self.pause()
        self.isSeeking = true
        let toTime = CMTimeMakeWithSeconds(time, preferredTimescale: player.currentTime().timescale)
        //进行操作
        player.seek(to: toTime, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] (finished) in
            guard let weakSelf = self else {
                return
            }
            weakSelf.isSeeking = false
            if finished && autoPlay {
                weakSelf.play()
            }
            if let completion = completion {
                completion(finished)
            }
        }
    }


    // MARK: Private Method

    private func replacePalyerItem(asset: AVURLAsset) {
        guard let player = player else {
            return
        }
        self.pause()
        if let playerItem = self.playerItem {
            if self.isObserverAdded {
                //移除之前的监听
                self.removePlayerItemObserver(playerItem: playerItem)
            }
            self.playerItem = nil
        }
        self.handlePlayerStatus(status: .loading)
        self.playerItem = AVPlayerItem(asset: asset)
        if let playerItem = self.playerItem {
            player.replaceCurrentItem(with: playerItem)
            self.addPlayerItemObserver(playerItem: playerItem)
        }
    }
    
    private func createPlayer(asset: AVURLAsset) {
        self.handlePlayerStatus(status: .loading)
        self.playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: self.playerItem)
        //解决新系统可能播放不了的问题
        self.player?.automaticallyWaitsToMinimizeStalling = false
        self.addPlayerObserver()
        self.addPlayerItemObserver(playerItem: self.playerItem!)
        self.addNotificationsForPlayer()
    }

    private func createAssetLoader(url: URL, uniqueID: String?) -> JLMediaPlayerAssetLoader {
        let loader = JLMediaPlayerAssetLoader(url: url)
        loader.uniqueID = uniqueID ?? url.absoluteString
        loader.delegate = self
        return loader
    }
}


// MARK: - Handles Notification And Player Status

extension JLMediaPlayer {
    
    /// 处理PlayerItem中的状态
    private func handlePlayerItemStatus(playerItem: AVPlayerItem) {
        guard playerItem == self.playerItem else {
            return
        }
        switch playerItem.status {
        case .readyToPlay:
            if !self.isReadyToPlay {
                self.isReadyToPlay = true
                if let seekItem = self.seekItem {
                    self.seekPlayerToTime(time: seekItem.time, autoPlay: seekItem.autoPlay, completion: seekItem.completion)
                    self.seekItem = nil
                } else {
                    self.handlePlayerStatus(status: .readyToPlay)
                }
            }
        case .failed:
            self.handlePlayerStatus(status: .loadingFailed)
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    /// 处理Player状态
    private func handlePlayerStatus(status: JLMediaPlayerStatus) {
        self.delegate?.avplayer(self, didChanged: status)
    }

    @objc func handlePlayToEnd(_ notification: Notification) {
        if let playerItem = self.playerItem,
            let item = notification.object as? AVPlayerItem,
            playerItem == item {
            self.handlePlayerStatus(status: .playEnd)
        }
    }

    @objc func handlePlaybackStalled(_ notification: Notification) {
        if let playerItem = self.playerItem,
            let item = notification.object as? AVPlayerItem,
            playerItem == item {
            self.handlePlayerStatus(status: .playbackStalled)
        }
    }
    
}

// MARK: - Observer

extension JLMediaPlayer {
    
    /// 对player增加监听
    private func addPlayerObserver() {
        guard let player = self.player else {
            return
        }
        //从avPlayer中监听播放进度方法
        self.timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(value: CMTimeValue(1.0), timescale: CMTimeScale(1.0)), queue: DispatchQueue.main, using: { [weak self] (time) in
            guard let weakSelf = self, let playerItem = weakSelf.player?.currentItem else {
                return
            }
            if weakSelf.isSeeking {
                return
            }
            let current = CMTimeGetSeconds(time)
            let total = CMTimeGetSeconds(playerItem.duration)
            weakSelf.delegate?.avplayer(weakSelf, refreshed: current, totalTime: total)
        })
    }

    private func removePlayerObserver() {
        guard let player = self.player, let timeObserver = self.timeObserver else {
            return
        }
        player.removeTimeObserver(timeObserver)
    }
    
    /// 对于playerItem进行监听
    private func addPlayerItemObserver(playerItem: AVPlayerItem) {
        self.isObserverAdded = true
        playerItem.addObserver(self, forKeyPath: JLMediaPlayerItemStatus, options: .new, context: nil)
        playerItem.addObserver(self, forKeyPath: JLMediaPlayerPlaybackBufferEmpty, options: .new, context: nil)
        playerItem.addObserver(self, forKeyPath: JLMediaPlayerPlaybackLikelyToKeepUp, options: .new, context: nil)
    }

    /// 移除playerItem的监听
    private func removePlayerItemObserver(playerItem: AVPlayerItem) {
        self.isObserverAdded = false
        playerItem.removeObserver(self, forKeyPath: JLMediaPlayerItemStatus)
        playerItem.removeObserver(self, forKeyPath: JLMediaPlayerPlaybackBufferEmpty)
        playerItem.removeObserver(self, forKeyPath: JLMediaPlayerPlaybackLikelyToKeepUp)
    }
    
    /// 重写父类方法observeValue 让外部支持监听相关状态
    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?)
    {
        guard let playerItem = object as? AVPlayerItem else {
            return
        }
        switch keyPath {
        case JLMediaPlayerItemStatus:
            self.handlePlayerItemStatus(playerItem: playerItem)
        case JLMediaPlayerPlaybackBufferEmpty:
            if isReadyToPlay {
                self.isBufferBegin = true
                self.handlePlayerStatus(status: .bufferBegin)
            }
        case JLMediaPlayerPlaybackLikelyToKeepUp:
            if isReadyToPlay && isBufferBegin {
                self.isBufferBegin = false
                self.handlePlayerStatus(status: .bufferEnd)
            }
        default:
            break
        }
    }

}

// MARK: - Notification

extension JLMediaPlayer {
    
    /// 对于播放结束以及plackback被挂起进行监听
    func addNotificationsForPlayer() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(handlePlayToEnd(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        center.addObserver(self, selector: #selector(handlePlaybackStalled(_:)), name: Notification.Name.AVPlayerItemPlaybackStalled, object: nil)
    }

    func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

}

// MARK: - AudioSession & Remote Command

extension JLMediaPlayer {
    
    /// 激活音频会话，让他处于活跃状态
    public static func activeAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback)
            try session.setActive(true, options: [])
        } catch {
            print("ActiveAudioSession failed.")
        }
    }
    
    /// 使得音频会话不处于活跃状态
    public static func deactiveAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient)
            try session.setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            print("DeactiveAudioSession failed.")
        }
    }

    /// 设置外部控件信息
    public func setupNowPlaying(title: String, description: String, image: UIImage?) {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = description
        if let image = image {
            let mediaItem = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = mediaItem
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.playerItem?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.playerItem?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.player?.rate
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    /// 部署外部控件，他在锁屏和通知界面展示音乐控件
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [weak self] event in
            guard let weakSelf = self else {
                return .commandFailed
            }
            return weakSelf.handleRemoteCommand(remoteCommand: .play)
        }
        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let weakSelf = self else {
                return .commandFailed
            }
            return weakSelf.handleRemoteCommand(remoteCommand: .pause)
        }
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            guard let weakSelf = self else {
                return .commandFailed
            }
            return weakSelf.handleRemoteCommand(remoteCommand: .next)
        }
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            guard let weakSelf = self else {
                return .commandFailed
            }
            return weakSelf.handleRemoteCommand(remoteCommand: .next)
        }
    }

    private func handleRemoteCommand(remoteCommand: JLMediaPlayerRemoteCommand) -> MPRemoteCommandHandlerStatus {
        if let executeSucceed = delegate?.avplayer(self, didReceived: remoteCommand), executeSucceed {
            return .success
        }
        return .commandFailed
    }

}


// MARK: - JLMediaPlayerAssetLoaderDelegate

extension JLMediaPlayer: JLMediaPlayerAssetLoaderDelegate {

    public func assetLoaderDidFinishDownloading(_ assetLoader: JLMediaPlayerAssetLoader) {
        print("did finish downloading")
    }

    public func assetLoader(_ assetLoader: JLMediaPlayerAssetLoader, didDownload bytes: Int64) {
        
    }

    public func assetLoader(_ assetLoader: JLMediaPlayerAssetLoader, downloadingFailed error: Error) {
        print(String(describing: error))
    }

}
