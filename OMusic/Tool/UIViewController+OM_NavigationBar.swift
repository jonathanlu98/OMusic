//
//  UIViewController+OM_NavigationBar.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/10/21.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit


extension UIViewController {
    
      fileprivate struct AssociatedKeys {
        static var navBarBgAlpha: CGFloat = 0.7
      }
    
      var navBarBgAlpha: CGFloat {
          get {
              let alpha = objc_getAssociatedObject(self, &AssociatedKeys.navBarBgAlpha) as? CGFloat
              if alpha == nil {
                //默认透明度为0.7
                return 0.7
              }else{
                  return alpha!
              }
          }
          set {
              var alpha = newValue
            if alpha > 0.7 {
                alpha = 0.7
              }
              if alpha < 0 {
                  alpha = 0
              }
              objc_setAssociatedObject(self, &AssociatedKeys.navBarBgAlpha, alpha, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
              //设置导航栏透明度
            if navigationController?.isKind(of: OMBaseNavigationController.self) ?? false {
                (navigationController as! OMBaseNavigationController).om_navigationBar.setNeedsNavigationBackgroundAlpha(alpha)
            }
          }
      }
}
