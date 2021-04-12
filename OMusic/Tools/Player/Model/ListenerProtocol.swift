//
//  ListenerProtocol.swift
//
//  Created by CaiSanze on 2020/01/05.
//

import UIKit

protocol ListenerBaseProtocol: AnyObject {
    
}

// MARK: - SystemEvent

enum SystemEventType {
    case willResignActive
    case didEnterBackground
    case willEnterForeground
    case didBecomeActive
    case willTerminate
}

protocol SystemEventListenerProtocol: ListenerBaseProtocol {
    func onSystemEventDetected(application: UIApplication, type: SystemEventType) -> Void
}

// MARK: - PlayerControllerEvent

@objc enum PlayerControllerEventType: Int {
    /**Player Control*/
    case none
    case loading
    case playing
    case paused
    case stalled
    case failed
    case next
    case previous
    case playEnd
    
    /**List Mode*/
    case loop = 20
    case shuffle = 21
    case `repeat` = 22
    case noneMode = 23
}

protocol PlayerControllerEventListenerProtocol: ListenerBaseProtocol {
    func onPlayerControllerEventDetected(event: PlayerControllerEventType) -> Void
}
