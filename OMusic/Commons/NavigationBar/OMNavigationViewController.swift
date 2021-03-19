//
//  OMNavigationViewController.swift
//  JLSptfy
//
//  Created by Jonathan Lu on 2020/2/7.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit

class OMNavigationViewController: UINavigationController {
    
    /// 返回按钮，这里放这为了统一调取，实则是在rootViewcontroller中生效
    let backitem: UIBarButtonItem = {
        let item = UIBarButtonItem.init()
        item.image = UIImage.init(systemName: "chevron.left")
        item.tintColor = THEME_GREEN_COLOR
        return item
    }()
    

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = OMTheme.getColor(lightColor:THEME_LIGHTGRAY_COLOR, darkColor:THEME_BLACK_COLOR)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:MIFont.lanProFont(size: 16, weight: .demibold)];
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.titleTextAttributes = [.font:MIFont.lanProFont(size: 24, weight: .bold), .foregroundColor:OMTheme.getTextColor()];
    }
    
}
