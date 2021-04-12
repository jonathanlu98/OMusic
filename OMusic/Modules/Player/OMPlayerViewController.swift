//
//  OMPlayerViewController.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/2/9.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import MarqueeLabel
import PanModal
import AVKit
import Masonry
import UIAlertController_Blocks_swift

class OMPlayerViewController: UIViewController {
        
    @IBOutlet weak private var dismissButton: UIButton!
    
    @IBOutlet weak private var moreButton: UIButton!
    
    @IBOutlet weak private var playlistNameLabel: UILabel!
    
    @IBOutlet weak private var trackNameLabelView: UIView!
    
    private var trackNameLabel: MarqueeLabel = {
        let label = MarqueeLabel.init()
        label.configLabel(font: MIFont.lanProFont(size: 24, weight: .bold), textColors: [THEME_TEXTBLACK_COLOR, .white], textAlignment: .center, type: .leftRight)
        label.speed = .rate(50)
        return label
    }()

    @IBOutlet weak private var artistNameLabel: UILabel!
    
    @IBOutlet weak private var contentCollectonView: UICollectionView!
    
    @IBOutlet weak private var progressView: OMPlayerProgressView!
    
    @IBOutlet weak private var previousButton: UIButton!
    
    @IBOutlet weak private var playButton: UIButton!
    
    @IBOutlet weak private var nextButton: UIButton!
    
    @IBOutlet weak private var listModeButton: UIButton!
    
    @IBOutlet weak private var airplayView: UIView!
        
    override var shouldAutorotate: Bool {
        return false
    }
    
    override internal var prefersStatusBarHidden: Bool {
        return true
    }
    
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateView()
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        ListenerCenter.shared.addListener(listener: self, type: .playerStatusEvent)
        self.setupUI()
        
    }
    
    
    deinit {
        ListenerCenter.shared.addListener(listener: self, type: .playerStatusEvent)
    }
    
    
    private func setupUI() {
        
        self.view.backgroundColor = OMTheme.getColor(lightColor: THEME_LIGHTGRAY_COLOR, darkColor: THEME_BLACK_COLOR)
        
        self.progressView.delegate = self
        
        self.dismissButton.tintColor = OMTheme.getColor(lightColor: THEME_BLACK_COLOR, darkColor: .white)
        
        self.moreButton.tintColor = OMTheme.getColor(lightColor: THEME_BLACK_COLOR, darkColor: .white)
        
        self.playlistNameLabel.textColor = OMTheme.getColor(lightColor: THEME_TEXTBLACK_COLOR, darkColor: .white)
        
        self.trackNameLabelView.addSubview(self.trackNameLabel)
        self.trackNameLabel.mas_makeConstraints { (make) in
            make?.edges.equalTo()(self.trackNameLabelView)
        }
 
        self.nextButton.tintColor = OMTheme.getColor(lightColor: THEME_BLACK_COLOR, darkColor: .white)
        
        self.previousButton.tintColor = OMTheme.getColor(lightColor: THEME_BLACK_COLOR, darkColor: .white)
        
        self.playButton.tintColor = OMTheme.getColor(lightColor: THEME_BLACK_COLOR, darkColor: .white)
        
        let airplayView = AVRoutePickerView.init(frame: self.airplayView.bounds)
        airplayView.tintColor = OMTheme.getColor(lightColor: THEME_BLACK_COLOR, darkColor: .white)
        airplayView.activeTintColor = THEME_GREEN_COLOR
        self.airplayView.addSubview(airplayView)
        airplayView.mas_makeConstraints { (make) in
            make?.top.left()?.bottom()?.equalTo()(self.airplayView)
        }
        
        self.setupImageCollectionView()
    }
    
    
    private func setupImageCollectionView() {
        
    
        self.contentCollectonView.delegate = self
        self.contentCollectonView.dataSource = self
        self.contentCollectonView.isScrollEnabled = false
        self.contentCollectonView.register(UINib.init(nibName: PlayerImageCollectionViewCellReuseIdentifier, bundle: nil), forCellWithReuseIdentifier: PlayerImageCollectionViewCellReuseIdentifier)
        
    }
    
    
    public func updateView(animated: Bool = false) {
        
        self.playlistNameLabel.text = OMStringIsEmpty(OMPlayer.shared.playListName) ? "": "来自\(OMPlayer.shared.playListName!)"
        self.trackNameLabel.text = OMStringIsEmpty(OMPlayer.shared.currentTrack?.value.name) ? "歌曲":OMPlayer.shared.currentTrack?.value.name
        self.artistNameLabel.text = OMStringIsEmpty(OMPlayer.shared.currentTrack?.value.amTrack?.attributes?.artistName) ? "歌手":OMPlayer.shared.currentTrack?.value.amTrack?.attributes?.artistName
                
        self.contentCollectonView.reloadData()
        self.contentCollectonView.layoutIfNeeded()
        if OMPlayer.shared.currentIndex >= 0 && OMPlayer.shared.currentIndex < OMPlayer.shared.tracks.array.count {
            self.contentCollectonView.scrollToItem(at: .init(row: OMPlayer.shared.currentIndex, section: 0), at: .centeredHorizontally, animated: animated)
        }

        self.progressView.update(currentTime: OMPlayer.shared.currentTime, totalTime: OMPlayer.shared.totalTime)

        self.nextButton.isEnabled = (OMPlayer.shared.currentTrack?.next != nil)
        
        OMPlayer.shared.isPause ? self.setPlay():self.setPause()

        self.previousButton.isEnabled = (OMPlayer.shared.currentTrack?.previous != nil)
        
        self.changeListModeButtonStatus(OMPlayer.shared.listMode)

    }
    
    public func updateProgressView(currentTime: Float64, totalTime: Float64) {
        self.progressView.update(currentTime: currentTime, totalTime: totalTime)
    }
    
    public func resetProgressView() {
        self.progressView.reset()
    }
    
    

    //MARK: Actions

    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated:true, completion: nil)
    }
    
    @IBAction func moreAction(_ sender: Any) {
        guard let track = OMPlayer.shared.currentTrack?.value else {
            return
        }
        if let object:JLTrack = JLDatabase.shared.getObject(amId: track.amId ?? "") {
            track.isLiked = object.isLiked
        }
        UIAlertController.showActionSheet(title: nil, message: nil, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: OMPlayer.shared.currentTrack?.value.isLiked ?? false ? ["取消收藏"]:["收藏"]) { (controller) in
            
        } tapBlock: { (controller, action, index) in
            if controller.firstOtherButtonIndex == index {
                track.isLiked = !(track.isLiked ?? false)
            }
        }

    }
    
    @IBAction func playOrPauseAction(_ sender: Any) {
        if OMPlayer.shared.isPause {
            OMPlayer.shared.play()
            self.setPause()
        } else {
            OMPlayer.shared.pause()
            self.setPlay()
        }
    }
    
    @IBAction func previousAction(_ sender: Any) {
        OMPlayer.shared.previous()
//        self.contentCollectonView.scrollToItem(at: .init(row: OMPlayer.shared.currentIndex-1, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        OMPlayer.shared.next(isAuto: false)
//        self.contentCollectonView.scrollToItem(at: .init(row: OMPlayer.shared.currentIndex+1, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    
    @IBAction func listModeAction(_ sender: Any) {
        switch OMPlayer.shared.listMode {
        case .none:
            OMPlayer.shared.listMode = .loop
            break
        case .loop:
            OMPlayer.shared.listMode = .repeat
            break
        case .repeat:
            OMPlayer.shared.listMode = .shuffle
            break
        case .shuffle:
            OMPlayer.shared.listMode = .none
            break
        default:
             break
        }
    }
    
}

//MARK: PlayerControllerEventListenerProtocol

extension OMPlayerViewController: PlayerControllerEventListenerProtocol {
    func onPlayerControllerEventDetected(event: PlayerControllerEventType) {
        self.updateView()
    }
}



//MARK: UICollectionView Delegate & Datasource

extension OMPlayerViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return OMPlayer.shared.tracks.array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: OMPlayerImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: PlayerImageCollectionViewCellReuseIdentifier, for: indexPath) as! OMPlayerImageCollectionViewCell
        cell.setupCell(item: OMPlayer.shared.tracks.array[indexPath.row].value)
        return cell
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return .init(width: self.contentCollectonView.frame.size.width, height: self.contentCollectonView.frame.size.height)
    }
    
    
    internal func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

    }
    
}


//MARK: OMPlayerProgressViewDelegate

extension OMPlayerViewController: OMPlayerProgressViewDelegate {

    internal func progressView(_ progressView: OMPlayerProgressView, didChanged currentTime: Float64) {
        
        OMPlayer.shared.seekPlayerToTime(time: currentTime, autoPlay: !OMPlayer.shared.isPause) { (succeed) in
            
        }
    }

}


//MARK: Private Status Funcation
extension OMPlayerViewController {
    private func setPlay() {
        self.playButton.setImage(OMTheme.getSFImage(title: "play.fill", pointSize: 56, weight: .regular)?.withTintColor(OMTheme.getColor(lightColor: THEME_TEXTBLACK_COLOR, darkColor: .white)), for: .normal)
    }
    
    private func setPause() {
        self.playButton.setImage(OMTheme.getSFImage(title: "pause.fill", pointSize: 56, weight: .regular)?.withTintColor(OMTheme.getColor(lightColor: THEME_TEXTBLACK_COLOR, darkColor: .white)), for: .normal)
    }
    
    private func setDisabled(from button: UIButton, _ value: Bool) {
        button.isEnabled = value;
    }
    
    private func changeListModeButtonStatus(_ status: OMPlayer.ListMode) {
        switch status {
        case .none:
            self.listModeButton.setImage(OMTheme.getSFImage(title: "repeat", pointSize: 19, weight: .regular)?.sd_tintedImage(with:THEME_GRAY_COLOR), for: .normal)
            break
        case .loop:
            self.listModeButton.setImage(OMTheme.getSFImage(title: "repeat", pointSize: 19, weight: .regular)?.sd_tintedImage(with:THEME_GREEN_COLOR), for: .normal)
            break
        case .`repeat`:
            self.listModeButton.setImage(OMTheme.getSFImage(title: "repeat.1", pointSize: 19, weight: .regular)?.sd_tintedImage(with:THEME_GREEN_COLOR), for: .normal)
            break
        case .shuffle:
            self.listModeButton.setImage(OMTheme.getSFImage(title: "shuffle", pointSize: 19, weight: .regular)?.sd_tintedImage(with:THEME_GREEN_COLOR), for: .normal)
            break
        default:
            break
        }
    }
}

//MARK: Config PanModal
extension OMPlayerViewController: PanModalPresentable {
    var panScrollable: UIScrollView? {
        return nil
    }
    var topOffset: CGFloat {
        return 0.0
    }

    var springDamping: CGFloat {
        return 1.0
    }

    var transitionDuration: Double {
        return 0.4
    }

    var transitionAnimationOptions: UIView.AnimationOptions {
        return [.allowUserInteraction, .beginFromCurrentState]
    }

    var shouldRoundTopCorners: Bool {
        return false
    }

    var showDragIndicator: Bool {
        return false
    }

}


    

