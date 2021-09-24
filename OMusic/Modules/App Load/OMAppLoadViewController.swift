//
//  ViewController.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/4/20.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit

class OMAppLoadViewController: UIViewController {
    
    @IBOutlet weak var loadAIView: UIActivityIndicatorView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //凭证已经拥有
        if OMAppleMusicAccountManager.shared.developerToken != nil {
            self.enterTabBarViewController()
            return
        }
        self.descriptionLabel.isHidden = false;
        self.loadAIView.startAnimating()
        self.setupToken()
        retryButton.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
    }
    
    private func setupToken() {
        OMAppleMusicAccountManager.shared.setupDeveloperToken { [weak self] (t_succeed, t_error) in
            if t_succeed {
                print(OMAppleMusicAccountManager.shared.developerToken ?? "request developerToken failed!")
                
                self?.loadAIView.stopAnimating()
                self?.descriptionLabel.text = "OK"
                self?.enterTabBarViewController()
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
    
    
    @objc private func retryAction() {
        self.retryButton.isHidden = true
        self.loadAIView.startAnimating()
        self.descriptionLabel.text = "加载中"
        self.setupToken()
    }


}

