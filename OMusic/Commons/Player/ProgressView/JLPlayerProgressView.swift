//
//  JLPlayerProgressView.swift
//  JLSptfy
//
//  Created by Jonathan Lu on 2020/2/24.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import Masonry



protocol JLPlayerProgressViewDelegate: AnyObject {
    func progressView(_ progressView: JLPlayerProgressView, didChanged currentTime: Float64)
}

class JLPlayerProgressView: UIView {
    
    //MARK: Properties
    
    public weak var delegate: JLPlayerProgressViewDelegate?
    private(set) public var isDraggingSlider: Bool = false
    private var progressSliderOriginalBounds: CGRect?
    private var shouldIgnoreProgress: Bool = false
    private(set) var style: Style = .normal
    public struct Style : Hashable, Equatable, RawRepresentable {
        
        public let rawValue: Int
        
        internal init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
    }
    private(set) public var progressSlider: UISlider = {
        let slider = UISlider()
        let thumbImage = UIImage.init(systemName: "circle.fill")
        slider.setThumbImage(thumbImage?.byResize(to: .init(width: 12, height: 12))?.withTintColor(THEME_GREEN_COLOR), for: .normal)
        slider.minimumTrackTintColor = THEME_GREEN_COLOR
        slider.maximumTrackTintColor = THEME_GRAY_COLOR
        slider.setThumbImage(thumbImage, for: .highlighted)
        slider.setThumbImage(thumbImage, for: .selected)
//        slider.addTarget(self, action: #selector(handleSliderValueChanged(_:event:)), for: .touchDragInside)
        slider.addTarget(self, action: #selector(handleSliderValueChanged(_:event:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(handleSliderTouchUp(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(handleSliderTouchUp(_:)), for: .touchUpOutside)
        return slider
    }()
    
    private var minTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.font = MIFont.lanProFont(size: 11, weight: .regular)
        label.textColor = THEME_GRAY_COLOR.setAlpha(0.7)
        label.textAlignment = .left
        label.text = "--:--"
        return label
    }()
    
    private var maxTimeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = MIFont.lanProFont(size: 11, weight: .regular)
        label.textColor = THEME_GRAY_COLOR.setAlpha(0.7)
        label.textAlignment = .right
        label.text = "--:--"
        return label
    }()


//MARK: Functions
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        addSubviews()
//        ListenerCenter.shared.addListener(listener: self, type: .playerStatusEvent)
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        addSubviews()
        ListenerCenter.shared.addListener(listener: self, type: .playerStatusEvent)
    }
    
    deinit {
        ListenerCenter.shared.removeAllListener(listener: self)
    }
    
    private func addSubviews() {
        addSubview(progressSlider)
        progressSlider.mas_makeConstraints { (make) in
            make?.leading.equalTo()(self.mas_leading)
            make?.trailing.equalTo()(self.mas_trailing)
            make?.top.equalTo()(self.mas_top)
            make?.height.offset()(29)
        }
        addSubview(minTimeLabel)
        minTimeLabel.mas_makeConstraints { (make) in
            make?.leading.equalTo()(self.mas_leading)
            make?.top.equalTo()(self.progressSlider.mas_bottom)?.offset()(1)
            make?.height.offset()(14)
            make?.width.offset()(42)
        }
        addSubview(maxTimeLabel)
        maxTimeLabel.mas_makeConstraints { (make) in
            make?.trailing.equalTo()(self.mas_trailing)
            make?.top.equalTo()(self.progressSlider.mas_bottom)?.offset()(1)
            make?.height.offset()(14)
            make?.width.offset()(42)
        }
    }
    
    /// 重置计数与slider
    public func reset() {
        minTimeLabel.text = "00:00"
        maxTimeLabel.text = "--:--"
        progressSlider.value = 0
    }

}


// MARK: - Actions

extension JLPlayerProgressView {

    @objc private func handleSliderValueChanged(_ slider: UISlider, event: UIEvent) {
        isDraggingSlider = true
        minTimeLabel.text = minuteAndSecondStr(second: Float64(slider.value))
    }

    @objc private func handleSliderTouchUp(_ slider: UISlider) {
        delegate?.progressView(self, didChanged: Float64(slider.value))
        isDraggingSlider = false
    }

}


// MARK: - Utils

extension JLPlayerProgressView {

    private func minuteAndSecondStr(second: Float64) -> String {
        let str = String(format: "%02ld:%02ld", Int64(second / 60), Int64(second.truncatingRemainder(dividingBy: 60)))
        // 02:30
        return str
    }
    
    /// 更新视图
    /// - Parameters:
    ///   - currentTime: 当前时间
    ///   - totalTime: 总共时间
    public func update(currentTime: Float64, totalTime: Float64) {
        guard currentTime >= 0 && totalTime >= 0 && totalTime >= currentTime else { return }
        if isDraggingSlider || shouldIgnoreProgress {
            return
        }
        minTimeLabel.text = minuteAndSecondStr(second: currentTime)
        maxTimeLabel.text = minuteAndSecondStr(second: totalTime)
        progressSlider.value = Float(currentTime)
        progressSlider.maximumValue = Float(totalTime)
    }
    
    /// 更改样式
    /// - Parameter style: JLPlayerProgressVIew.Style
    public func setStyle(_ style: Style) {
        self.style = style
        switch style {
        case .normal:
            UIView.animate(withDuration: 0.2) {
                self.progressSlider.maximumTrackTintColor = THEME_GRAY_COLOR
                self.minTimeLabel.textColor = THEME_GRAY_COLOR.setAlpha(0.7)
                self.maxTimeLabel.textColor = THEME_GRAY_COLOR.setAlpha(0.7)
            }
        case .colorful:
            UIView.animate(withDuration: 0.2) {
                self.progressSlider.maximumTrackTintColor = UIColor.white.setAlpha(0.3)
                self.minTimeLabel.textColor = UIColor.white.setAlpha(0.7)
                self.maxTimeLabel.textColor = UIColor.white.setAlpha(0.7)
            }
        default:
            UIView.animate(withDuration: 0.2) {
                self.progressSlider.maximumTrackTintColor = THEME_GRAY_COLOR
                self.minTimeLabel.textColor = THEME_GRAY_COLOR.setAlpha(0.7)
                self.maxTimeLabel.textColor = THEME_GRAY_COLOR.setAlpha(0.7)
            }
        }
    }

}


// MARK: - PlayerStatusListenerProtocol

extension JLPlayerProgressView: PlayerControllerEventListenerProtocol {

    func onPlayerControllerEventDetected(event: PlayerControllerEventType) {
        shouldIgnoreProgress = event != .playing
    }

}


//MARK: JLPLayerProgressView.Style

extension JLPlayerProgressView.Style {
    static let normal: JLPlayerProgressView.Style = .init(rawValue: 0)
    static let colorful: JLPlayerProgressView.Style = .init(rawValue: 1)
}
