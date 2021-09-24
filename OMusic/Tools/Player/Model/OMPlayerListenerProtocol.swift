//
//  ListenerProtocol.swift
//
//

import UIKit

protocol OMPlayerListenerBaseProtocol: AnyObject {
    
}

// MARK: - SystemEvent

enum SystemEventType {
    case willResignActive
    case didEnterBackground
    case willEnterForeground
    case didBecomeActive
    case willTerminate
}

protocol SystemEventListenerProtocol: OMPlayerListenerBaseProtocol {
    func onSystemEventDetected(application: UIApplication, type: SystemEventType) -> Void
}

// MARK: - PlayerControllerEvent

@objc enum OMPlayerControllerEventType: Int {
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

protocol OMPlayerControllerEventListenerProtocol: OMPlayerListenerBaseProtocol {
    func onPlayerControllerEventDetected(event: OMPlayerControllerEventType) -> Void
}
