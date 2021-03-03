//
//  OMBaseNavigationController.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/10/12.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import UIKit
import RxSwift


class OMBaseNavigationBar: UIView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = OMTheme.getTextColor()
        label.font = MIFont.lanProFont(size: 32, weight: .bold)
        return label
    }()
    
    private lazy var moreButton: UIButton = {
        let button = UIButton.init(type: .system)
        button.setImage(OMTheme.getSFImage(title: "ellipsis", pointSize: 24, weight: .bold), for: .normal)
        button.backgroundColor = UIColor.init(white: 0, alpha: 0.0001)
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton.init(type: .system)
        button.setImage(OMTheme.getSFImage(title: "chevron.backward", pointSize: 24, weight: .bold), for: .normal)
        button.backgroundColor = UIColor.init(white: 0, alpha: 0.0001)
        return button
    }()
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var shouldBackButtonHidden: Bool = true {
        didSet {
            backButton.isHidden = shouldBackButtonHidden
        }
    }
    
    var shouldMoreButtonHidden: Bool = true {
        didSet {
            moreButton.isHidden = shouldMoreButtonHidden
        }
    }
    
    var isFixed: Bool = false
    
    private var dispose = DisposeBag()
    
    enum OMBaseNavigationBarActionType {
        case backAction
        case moreAction
    }
    
    enum OMBaseNavigationBarAnimateDirection {
        case up
        case down
    }
    
    typealias OMBaseNavigationBarActionBlock = (OMBaseNavigationBarActionType) -> Void
    
    typealias OMBaseNavigationBarAnimateCompletion = (OMBaseNavigationBarAnimateDirection) -> Void
    
    var actionBlock: OMBaseNavigationBarActionBlock? {
        didSet {
            if (actionBlock != nil) {
                registerActions()
            }
        }
    }
    
    var animateCompletion: OMBaseNavigationBarAnimateCompletion?
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showBackButton() {
        shouldBackButtonHidden = false;
        backButton.alpha = 0;
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) {
            self.backButton.alpha = 1;
        }
    }
    
    func startUpwardAnimation() {
        if isFixed {
            return
        }
        titleLabel.alpha = 0
        titleLabel.transform = .init(translationX: 0, y: -20)
        if !shouldMoreButtonHidden {
            backButton.alpha = 0
            backButton.transform = .init(translationX: 0, y: -20)
        }
        if !shouldBackButtonHidden {
            moreButton.alpha = 0
            moreButton.transform = .init(translationX: 0, y: -20)
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
            if !self.shouldMoreButtonHidden {
                self.backButton.alpha = 1
                self.backButton.transform = .identity
            }
            if !self.shouldBackButtonHidden {
                self.moreButton.alpha = 1
                self.moreButton.transform = .identity
            }
        }
        animateCompletion?(.up)
    }
    
    func startDownwardAnimation() {
        if isFixed {
            return
        }
        titleLabel.alpha = 1
        if !shouldMoreButtonHidden {
            backButton.alpha = 1
        }
        if !shouldBackButtonHidden {
            moreButton.alpha = 1
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.titleLabel.alpha = 0
            self.titleLabel.transform = .init(translationX: 0, y: -20)
            if !self.shouldMoreButtonHidden {
                self.backButton.alpha = 0
                self.backButton.transform = .init(translationX: 0, y: -20)
            }
            if !self.shouldBackButtonHidden {
                self.moreButton.alpha = 0
                self.moreButton.transform = .init(translationX: 0, y: -20)
            }
        }
        animateCompletion?(.down)
    }
    
    func setNeedsNavigationBackgroundAlpha(_ alpha:CGFloat) {
        if isFixed && self.alpha == alpha  {
            return
        }
        if alpha == 0.7 {
            if self.alpha < alpha {
                startUpwardAnimation()
            } else {
                startDownwardAnimation()
            }
        }
        self.backgroundColor = OMTheme.setColorAlpha(color: self.backgroundColor!, alpha: alpha)
    }
    
    
    
    
    
    //MARK: Private Method
    
     private func setupViews() {
        moreButton.isHidden = true
        backButton.isHidden = true
        backgroundColor = OMTheme.getColor(lightColor: .white, darkColor: .black)
        alpha = 0.7
        addSubview(titleLabel)
        addSubview(moreButton)
        addSubview(backButton)
    }
    
    private func setupConstraints() {
        backButton.mas_makeConstraints { (make) in
            make?.left.equalTo()(self)?.offset()(22)
            make?.centerY.equalTo()(self)
        }
        titleLabel.mas_makeConstraints { (make) in
            make?.left.equalTo()(self.backButton.isHidden ? self:self.backButton.mas_right)?.offset()(self.backButton.isHidden ? 22:24)
            make?.centerY.equalTo()(self)
            make?.right.equalTo()(self.moreButton.isHidden ? self:self.moreButton.mas_left)?.offset()(self.moreButton.isHidden ? 22:24)
        }
        moreButton.mas_makeConstraints { (make) in
            make?.right.equalTo()(self)?.offset()(22)
            make?.centerY.equalTo()(self)
        }
    }
    
    private func registerActions() {
        backButton.rx.controlEvent(.touchUpInside).subscribe { [unowned self] (_) in
            self.actionBlock?(.backAction)
        }.disposed(by: dispose)
        moreButton.rx.controlEvent(.touchUpInside).subscribe { [unowned self] (_) in
            self.actionBlock?(.moreAction)
        }.disposed(by: dispose)
    }
    
    
    
}









class OMBaseNavigationController: UINavigationController {
    
    private(set) var om_navigationBar: OMBaseNavigationBar
    
    public init(rootViewController: OMBaseCollectionViewController) {
        om_navigationBar = .init(title: rootViewController.title ?? "")
        super.init(rootViewController: rootViewController)
        setNavigationBarHidden(true, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupViews()
        setupContraints()
    }

    
    
    //MARK: Action
    private func backAction() {
        popViewController(animated: true)
        om_navigationBar.title = topViewController?.title ?? ""
    }
    
    private func moreAction() {
        
    }
    
    
    
    //MARK: Private Method
    private func setupViews() {
        topViewController?.view.addSubview(om_navigationBar)
    }
    
    private func setupContraints() {
        if topViewController != nil {
            om_navigationBar.mas_makeConstraints { (make) in
                make?.top.equalTo()(topViewController?.view)
                make?.left.equalTo()(topViewController?.view)
                make?.right.equalTo()(topViewController?.view)
                make?.height.mas_equalTo()(116)
            }
            if topViewController!.isKind(of: OMBaseCollectionViewController.self) {
                
            }
        }
    }
    
    private func registerActions() {
        om_navigationBar.actionBlock = { [unowned self] (type) in
            switch type {
            case .backAction:
                self.backAction()
                break
            case .moreAction:
                self.moreAction()
                break
            }
        }
    }
    
    

}
