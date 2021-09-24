//
//  OMPlayerMenuBarView.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/2/17.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import MarqueeLabel

class OMPlayerMenuBarView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var trackNameLabelView: UIView!
    
    private var trackNameLabel: MarqueeLabel = {
        let label = MarqueeLabel.init()
        label.configLabel(font: MIFont.lanProFont(size: 18, weight: .bold), textColors: [THEME_TEXTBLACK_COLOR, .white], textAlignment: .center, type: .leftRight)
        label.speed = .rate(50)
        return label
    }()
    
    @IBOutlet weak var artistNameLabel: UILabel!
    
    
    @IBOutlet weak var playButton: UIButton!
    
    deinit {
        OMPlayerListenerCenter.shared.removeListener(listener: self, type: .playerStatusEvent)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        OMPlayerListenerCenter.shared.addListener(listener: self, type: .playerStatusEvent)
        self.trackNameLabelView.addSubview(self.trackNameLabel)
        self.trackNameLabel.mas_makeConstraints { (make) in
            make?.edges.equalTo()(self.trackNameLabelView)
        }
        self.backgroundColor = OMTheme.getColor(lightColor: THEME_LIGHTGRAY_COLOR, darkColor: THEME_BLACK_COLOR)
        
        self.playButton.tintColor = OMTheme.getColor(lightColor: THEME_TEXTBLACK_COLOR, darkColor: .white)
        
        self.isHidden = true
    }
    
    //MARK: Private Method
    
    private func updateView() {
        guard let _ = self.imageView else {
            return
        }
        guard let trackItem = OMPlayer.shared.currentTrack?.value else {
            self.isHidden = true
            return
        }
        self.isHidden = false
        self.imageView.fetchImage(URL.amCoverUrl(string: trackItem.amTrack?.attributes?.artwork?.url ?? "", size: 885), placeholderImage: #imageLiteral(resourceName: "default_track_cover"), nil)
        self.trackNameLabel.text = OMStringIsEmpty(trackItem.name) ? "歌曲":trackItem.name
        self.artistNameLabel.text = OMStringIsEmpty(trackItem.amTrack?.attributes?.artistName) ? "歌手":trackItem.amTrack?.attributes?.artistName
        OMPlayer.shared.isPause ? self.setPlay():self.setPause()
    }
    
    
    private func setPlay() {
        self.playButton.setImage(OMTheme.getSFImage(title: "play.fill", pointSize: 56, weight: .regular), for: .normal)
    }
    
    private func setPause() {
        self.playButton.setImage(OMTheme.getSFImage(title: "pause.fill", pointSize: 56, weight: .regular), for: .normal)
    }
    
    
    @IBAction func playAction(_ sender: Any) {
        if OMPlayer.shared.isPause {
            OMPlayer.shared.play()
            self.setPause()
        } else {
            OMPlayer.shared.pause()
            self.setPlay()
        }
    }
    
    
    @IBAction func tapAction(_ sender: Any) {
        OMPlayer.shared.openPlayerViewControllerIfNeed()
    }
    
    
}

//MARK: - OMPlayerListenerBaseProtocol
extension OMPlayerMenuBarView: OMPlayerControllerEventListenerProtocol {
    func onPlayerControllerEventDetected(event: OMPlayerControllerEventType) {
        self.updateView()
    }
}
