////
////  JLPlayer.swift
////  JLSptfy
////
////  Created by Jonathan Lu on 2020/3/30.
////  Copyright © 2020 Jonathan Lu. All rights reserved.
////
//
//import UIKit
//import SZAVPlayer
//import RxSwift
//import RxCocoa
//
//class JLPlayer: NSObject {
//    
//    public struct ListMode: Hashable, Equatable, RawRepresentable {
//        public let rawValue: Int
//        
//        internal init(rawValue: Int) {
//            self.rawValue = rawValue
//        }
//        
//    }
//    
//    let viewController:JLPlayerViewController = .shared
//    
//    private(set) var menuView: UIView!
//    
//    let mediaPlayer = SZAVPlayer()
//    
//    public var playListName = ""
//    
//    public var tracks:[JLPlayItem] = []
//    
//    public var currentTrack: JLPlayItem? = nil
//    
//    
//    
//    override private init() {
//        super.init()
//    }
//    
//    /// Returns the default singleton instance.
//    @objc public static let shared = JLPlayer.init()
//    
//    
//
//}
//
//
////MARK: JLPlayer.ListMode
//
//extension JLPlayer.ListMode {
//    static let none: JLPlayer.ListMode = .init(rawValue: 0)
//    static let loop: JLPlayer.ListMode = .init(rawValue: 1)
//    static let shuffle: JLPlayer.ListMode = .init(rawValue: 2)
//    static let `repeat`: JLPlayer.ListMode = .init(rawValue: 3)
//}
//
