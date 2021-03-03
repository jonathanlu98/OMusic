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
        loadAIView.startAnimating()
        setupToken()
        _ = retryButton.rx.controlEvent( .touchUpInside).subscribe(onNext: { [unowned self] (arg0) in
            let () = arg0
            self.retryButton.isHidden = true
            self.loadAIView.startAnimating()
            self.descriptionLabel.text = "Loading"
            self.setupToken()
            }, onError: nil, onCompleted: nil, onDisposed: nil)
    }
    
    func setupToken() {
        OMAccountManager.shared.setupDeveloperToken { [weak self] (t_succeed, t_error) in
            if t_succeed {
                OMAccountManager.shared.getUserToken { [weak self] (u_succeed, u_error) in
                    if u_succeed {
                        print(OMAccountManager.shared.developerToken)
                        print(OMAccountManager.shared.userToken)
                        self?.loadAIView.stopAnimating()
                        self?.descriptionLabel.text = "OK"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            let layout = UICollectionViewFlowLayout()
                            layout.itemSize = .init(width: UIScreen.main.bounds.width, height: 100)
                            layout.minimumInteritemSpacing = 20
                            layout.scrollDirection = .vertical
                            let vc = OMHomeViewController.init(title: "Home", backgroundColor: OMTheme.getColor(lightColor: UIColor.white, darkColor: UIColor.black), collectionViewLayout: layout)
                            let navivc = OMBaseNavigationController.init(rootViewController: vc)
                            let transtition = CATransition()
                            transtition.duration = 0.3
                            transtition.timingFunction = CAMediaTimingFunction.init(name: .easeOut)
                            UIApplication.shared.windows.first?.layer.add(transtition, forKey: "animation")
                            UIApplication.shared.windows.first?.rootViewController = navivc
                        }
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


}

