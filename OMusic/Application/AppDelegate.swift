//
//  AppDelegate.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/4/20.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import ProgressHUD
import LifetimeTracker

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //初始化数据库
        JLDatabase.shared.initializeTable()
                
        JLMediaPlayer.activeAudioSession()
                
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        
        self.window?.backgroundColor = OMTheme.getColor(lightColor: .white, darkColor: .black)
        
        let vc = OMAppLoadViewController()
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
        
        #if DEBUG
            LifetimeTracker.setup(onUpdate: LifetimeTrackerDashboardIntegration(visibility: .alwaysVisible, style: .bar).refreshUI)
        #endif
        
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait;
    }


}

