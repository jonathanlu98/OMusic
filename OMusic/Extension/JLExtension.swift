//
//  JLExtension.swift
//  JLSptfy
//
//  Created by Jonathan Lu on 2020/2/10.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import RxSwift
import MarqueeLabel
import PanModal
import SDWebImage



extension UITableViewCell {
    
    //在使用RXSwift时，为cell添加的dispose以便监听的释放
    var dispose: DisposeBag {
        get {
            return DisposeBag()
        }
    }
    /**
     用于cell中图片的获取，使用SDWebImage
     - Parameter url: 图片的URL
     - Parameter imageView: 所作用的imageView
     */
    func fetchImage(_ url:URL?,imageView:UIImageView) {
        imageView.alpha = 0
        if (url != nil) {
            imageView.sd_setImage(with: url, placeholderImage: nil, options: .retryFailed) { image, error, type, uurl in
                //对于图片的渐出效果，通过判断图片来源（内存还是磁盘还是刚下载的），来选择效果
                if (image != nil) {
                switch type {
                case .none, .disk, .all:
                        UIImageView.animate(withDuration: 0.2) {
                            imageView.alpha = 1
                        }
                case .memory:
                        imageView.alpha = 1

                @unknown default: break
                    }
                }
            }
        } else {
            UIImageView.animate(withDuration: 0.2) {
                imageView.alpha = 1
            }
        }
        
    }
}


extension UICollectionViewCell {
    /**
     用于cell中图片的获取，使用SDWebImage
     - Parameter url: 图片的URL
     - Parameter imageView: 所作用的imageView
     */
    func fetchImage(_ url:URL?,imageView:UIImageView) {
        imageView.alpha = 0
        if (url != nil) {
            imageView.sd_setImage(with: url, placeholderImage: nil, options: .retryFailed) { image, error, type, uurl in
                //对于图片的渐出效果，通过判断图片来源（内存还是磁盘还是刚下载的），来选择效果
                if (image != nil) {
                switch type {
                case .none, .disk, .all:
                        UIImageView.animate(withDuration: 0.2) {
                            imageView.alpha = 1
                        }
                case .memory:
                        imageView.alpha = 1

                @unknown default: break
                    }
                }
            }
        } else {
            UIImageView.animate(withDuration: 0.2) {
                imageView.alpha = 1
            }
        }
        
    }
}

extension UIImageView {
    
    typealias fetchImageCompletionBlock = (UIImage?, Bool) -> Void
    
    /// 图片加载
    /// - Parameter url: 图片url
    func fetchImage(_ url:URL?,_ completionBlock: fetchImageCompletionBlock?) {
        self.alpha = 0
        if (url != nil) {
            self.sd_setImage(with: url, placeholderImage: nil, options: .retryFailed) { image, error, type, uurl in
                //对于图片的渐出效果，通过判断图片来源（内存还是磁盘还是刚下载的），来选择效果
                if (image != nil) {
                    if (completionBlock != nil) {
                        completionBlock!(image,true)
                    }
                    
                    switch type {
                    case .none, .disk, .all:
                            UIImageView.animate(withDuration: 0.2) {
                                self.alpha = 1
                            }
                    case .memory:
                            self.alpha = 1

                    @unknown default: break
                        }
                } else {
                    if (completionBlock != nil) {
                        completionBlock!(nil,false)
                    }
                }
            }
        } else {
            
            if (completionBlock != nil) {
                completionBlock!(nil,false)
            }
            UIImageView.animate(withDuration: 0.2) {
                self.alpha = 1
            }
        }
        
    }

}


extension  MarqueeLabel {

    /// 移除translatesAutoresizingMaskIntoConstraints效果，这在使用Masonry布局时是必要的，否则再来无用的布局添加
    /// - Parameter bool: bool
    func shouldCancelAutoresizing(_ bool: Bool) -> MarqueeLabel {
        if bool == true {
            self.translatesAutoresizingMaskIntoConstraints = false
        }
        return self
    }
    
    /// 设置label样式
    /// - Parameters:
    ///   - font: 字体
    ///   - textColors: 颜色  [light,dark] or [color]
    ///   - textAlignment: 对齐方式
    ///   - type: 类型
    func configLabel(font: UIFont, textColors: [UIColor], textAlignment: NSTextAlignment, type: MarqueeType) {
        self.animationDelay = 2
        self.leadingBuffer = 0
        self.trailingBuffer = 60
        self.fadeLength = 13
        self.font = font
        configLabelTextColors(textColors)
        self.textAlignment = textAlignment
        self.type = type
    }
    
    func configLabelTextColors(_ textColors: [UIColor]) {
        if textColors.count > 1 {
            switch OMTheme.currentStyle {
                case .system:
                    self.textColor = UIColor.init { (traitCollection) -> UIColor in
                        if traitCollection.userInterfaceStyle == .dark {
                            return textColors[1]
                        } else {
                            return textColors.first!
                        }
                    }
                case .dark:
                    self.textColor = textColors[1]
                case .light:
                    self.textColor = textColors.first
                default:
                    self.textColor = textColors.first
            }
        } else {
            self.textColor = textColors.first
        }
    }
    
}


extension UIImageView {
    /**
     移除translatesAutoresizingMaskIntoConstraints效果，这在使用Masonry布局时是必要的，否则再来无用的布局添加
     */
    func shouldCancelAutoresizing(_ bool:Bool) -> UIImageView {
        if bool == true {
            self.translatesAutoresizingMaskIntoConstraints = false
        }
        return self
    }
}

extension UIButton {
    /**
     移除translatesAutoresizingMaskIntoConstraints效果，这在使用Masonry布局时是必要的，否则再来无用的布局添加
     */
    func shouldCancelAutoresizing(_ bool:Bool) -> UIButton {
        if bool == true {
            self.translatesAutoresizingMaskIntoConstraints = false
        }
        return self
    }
}

extension UIViewController {
    /**
     对于错误弹出⚠️窗口，默认确认按钮
     
     - Parameter title: 窗口名
     - Parameter message: 错误信息
     - Parameter buttonTitle: 按钮提示名
     */
    func presentAlertController(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
            controller.addAction(action)
            self.present(controller, animated: true)
        }

    }
}

extension String {
    /// 输出String的长度
    /// - Parameters:
    ///   - font: 当前字体
    ///   - height: label高度（实则无需）
    func widthForComment(font: UIFont, height: CGFloat = 15) -> CGFloat {
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.width)
    }
}


extension UILabel {

    /// 将label的文本转为时间格式
    /// - Parameter value: 秒数
    func timeFormatter(_ value: Double?) {
        //一个小算法，来实现00：00这种格式的播放时间
        if value != nil {
            let all:Int=Int(value!)
            let m:Int=all % 60
            let f:Int=Int(all/60)
            var time:String=""
            if f<10{
                time="0\(f):"
            }else {
                time="\(f)"
            }
            if m<10{
                time+="0\(m)"
            }else {
                time+="\(m)"
            }
            //更新播放时间
            self.text=time
        }
    }
}


extension UIButton {
    
    /// 改变Button,用于加载时的等待以防用户的多次点击
    /// - Parameters:
    ///   - isDisabled: 是否为有效
    ///   - disabledColor: 无效的颜色
    ///   - enabledColor: 有效的颜色
    func changStatus(isDisabled: Bool, disabledColor: UIColor, enabledColor: UIColor) {

        if isDisabled == true {
            self.isEnabled = false
            self.backgroundColor = disabledColor
        } else {
            self.isEnabled = true
            self.backgroundColor = enabledColor
        }
    }
}


extension URL{
    /**
     用于修复URL中特殊字符产生Crash的bug
     */
    static func initPercent(string:String) -> URL
    {
        let urlwithPercentEscapes = string.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let url = URL.init(string: urlwithPercentEscapes!)
        return url!
    }
    
    
    /// 获取文件名
    func getFileName() -> String? {
        //使用截取的方法获取url的文件名
        let path = self.absoluteString
        let range = (path as NSString?)?.range(of: "/", options: .backwards)
        if range?.location != NSNotFound {
            //以下方法会包含起始索引的字符，所以+1
            return (path as NSString).substring(from: (range?.location ?? 0) + 1)
        }
        return nil
    }
    
    static func amCoverUrl(string: String, size: Int) -> URL? {
        guard string == "" else {
            return nil
        }
        guard let range = string.range(of: "/", options: .backwards) else {
            return nil
        }
        let urlString = string.prefix(upTo: range.lowerBound) + "\(size)x\(size).jpg"
        return URL.init(string: String(urlString))
    }
}



extension UIViewController {
    
    /// 当前显示得viewController
    /// - Parameter base: UIApplication.shared.keyWindow?.rootViewController
    class func currentViewController(base: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return currentViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        return base
    }
}


extension CIColor {
    public func setAlpha(_ alpha: CGFloat) -> CIColor {
        return .init(red: self.red, green: self.green, blue: self.blue, alpha: alpha)
    }
}


extension UIColor {
    public func setAlpha(_ alpha: CGFloat) -> UIColor {
        return UIColor.init(red: self.ciColor.red, green: self.ciColor.green, blue: self.ciColor.blue, alpha: alpha)
    }
    
    static func themeColor(light: UIColor, dark: UIColor) -> UIColor {
        switch OMTheme.currentStyle {
        case .light:
            return light
        case .dark:
            return dark
        case .system:
            if #available(iOS 13.0, *) {
               return UIColor(dynamicProvider: {(traitCollection) in
                    switch traitCollection.userInterfaceStyle {
                        case .light:
                            return light
                        case .dark:
                            return dark
                        case .unspecified:
                            return light
                        @unknown default:
                            return light
                    }
                })
            } else {
                return light
            }
        default:
            return dark
        }

    }
    
}

extension UIImage {
    func byResize(to size: CGSize) -> UIImage? {
        if size.width <= 0 || size.height <= 0 {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(size, _: false, _: scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

}




