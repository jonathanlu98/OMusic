//
//  ViewController.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/4/20.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import Alamofire
import Lottie
import RxSwift
import RxCocoa

//precedencegroup asyncGroup {
//    associativity: left
//    higherThan: AdditionPrecedence
//    lowerThan: MultiplicationPrecedence
//}
//
//infix operator +>: asyncGroup
//
//typealias Action = ()->Void
//typealias AsyncTask = (Action) -> Void

//func +>(left: @escaping AsyncTask, right: @escaping AsyncTask) -> AsyncTask {
//        return { complete in
//            left {
//                right {
//                    complete()
//                }
//            }
//        }
//}


class OMAppLoadViewController: UIViewController {
    

    
    @IBOutlet weak var loadAIView: UIActivityIndicatorView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //凭证已经拥有
        if OMAppleMusicAccountManager.shared.developerToken != nil && OMAppleMusicAccountManager.shared.userToken != nil {
            self.enterTabBarViewController()
            return
        }
        descriptionLabel.isHidden = false;
        loadAIView.startAnimating()
        setupToken()
        _ = retryButton.rx.controlEvent( .touchUpInside).subscribe(onNext: { [unowned self] (arg0) in
            let () = arg0
            self.retryButton.isHidden = true
            self.loadAIView.startAnimating()
            self.descriptionLabel.text = "加载中"
            self.setupToken()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
    }
    
    private func setupToken() {
        OMAppleMusicAccountManager.shared.setupDeveloperToken { [weak self] (t_succeed, t_error) in
            if t_succeed {
                OMAppleMusicAccountManager.shared.getUserToken { [weak self] (u_succeed, u_error) in
                    if u_succeed {
                        
                        print(OMAppleMusicAccountManager.shared.developerToken)
                        print(OMAppleMusicAccountManager.shared.userToken)
                        
                        self?.loadAIView.stopAnimating()
                        self?.descriptionLabel.text = "OK"
                        self?.enterTabBarViewController()
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            self?.loadAIView.stopAnimating()
                            self?.descriptionLabel.text = u_error!.localizedDescription
                            self?.retryButton.isHidden = false
                        }
                    }
                    return
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.loadAIView.stopAnimating()
                    self?.descriptionLabel.text = t_error!.localizedDescription
                    self?.retryButton.isHidden = false
                }
            }
        }
    }
    
    
    private func enterTabBarViewController() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let tabBarViewController = OMTabBarController.init()
            let transtition = CATransition()
            transtition.duration = 0.3
            transtition.timingFunction = CAMediaTimingFunction.init(name: .easeOut)
            UIApplication.shared.windows.first?.layer.add(transtition, forKey: "animation")
            UIApplication.shared.windows.first?.rootViewController = tabBarViewController
        }
    }


}

