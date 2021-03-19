//
//  OMTabBarController.swift
//  OMusic
//
//  Created by Jonathan Lu on 2019/3/21.
//  Copyright © 2019 JonathanLu. All rights reserved.
//

import UIKit
import RxSwift
import PanModal

let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height

class OMTabBarController: UITabBarController, UITabBarControllerDelegate {

    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.isTranslucent = false
        self.tabBar.barTintColor = OMTheme.getColor(lightColor: THEME_LIGHTGRAY_COLOR, darkColor: THEME_BLACK_COLOR)
        
        self.tabBar.tintColor = THEME_GREEN_COLOR
        
        self.tabBar.unselectedItemTintColor = OMTheme.getColor(lightColor: THEME_BLACK_COLOR, darkColor: UIColor.white)
        
        self.loadViewControllers()
        
    }

    
    
    /// 加载viewControllers
    private func loadViewControllers() {
                
        let homeViewController = UIViewController()
        homeViewController.title = ""
        let homeNavVC = OMNavigationViewController.init(rootViewController: homeViewController)
        configTabBarItem(from: homeNavVC, icon: #imageLiteral(resourceName: "tabBar_home"))

        let searchViewController = OMSearchViewController()
        searchViewController.title = ""
        let searchNavVC = OMNavigationViewController.init(rootViewController: searchViewController)
        configTabBarItem(from: searchNavVC, icon: #imageLiteral(resourceName: "tabBar_search"))

        let libraryViewController = UIViewController()
        libraryViewController.title = ""
        let libraryNavVC = OMNavigationViewController.init(rootViewController: libraryViewController)
        configTabBarItem(from: libraryNavVC, icon: #imageLiteral(resourceName: "tabBar_library"))
        

        
    }
    
    /// 配置tabBarItem
    /// - Parameters:
    ///   - tabBarItem: tabBarItem
    ///   - title: title 可以为空
    ///   - image: SFSymbol图标名
    private func configTabBarItem(from viewController:UIViewController,icon image: UIImage) {
        
        viewController.tabBarItem.selectedImage = image
        viewController.tabBarItem.image = image
        
        self.addChild(viewController)
        
        viewController.tabBarItem.titlePositionAdjustment = UIOffset.init(horizontal: 0, vertical: 20)

    }

}


extension OMTabBarController {
    /// 解决ipad上的尺寸问题
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let presentableController = viewControllerToPresent as? PanModalPresentable, let controller = presentableController as? UIViewController {
            controller.modalPresentationStyle = .custom
            controller.modalPresentationCapturesStatusBarAppearance = true
            controller.transitioningDelegate = PanModalPresentationDelegate.default
            super.present(controller, animated: flag, completion: completion)
            return
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
}





