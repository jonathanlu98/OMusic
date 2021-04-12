//
//  OMPlayerListenerCenter.swift
//
//

import UIKit

class OMPlayerListenerCenter {
    
    public static let shared = OMPlayerListenerCenter()
    
    private(set) lazy var recursiveLock: NSRecursiveLock = NSRecursiveLock()
    private lazy var systemEventListeners: [OMPlayerListenerNode] = []
    private(set) lazy var playerControllerEventListeners: [OMPlayerListenerNode] = []

    //保存监听者，不让其自动释放，监听完毕以后再手动删除
    private lazy var preserveListeners: [OMPlayerListenerBaseProtocol] = []
    
    enum ListenerType: CaseIterable {
        case systemEvent
        case playerStatusEvent
    }
    
}

// MARK: - Public

extension OMPlayerListenerCenter {
    
    func addListener(listener: OMPlayerListenerBaseProtocol, type: ListenerType, preserve: Bool = false) {
        removeListener(listener: listener, type: type)
        
        recursiveLock.lock()
        defer { recursiveLock.unlock() }
        
        switch type {
        case .systemEvent:
            OMPlayerListenerNode.add(listener: listener, to: &systemEventListeners)
        case .playerStatusEvent:
            OMPlayerListenerNode.add(listener: listener, to: &playerControllerEventListeners)
        }
        
        if preserve {
            preserveListeners.append(listener)
        }
    }
    
    func removeListener(listener: AnyObject, type: ListenerType) {
        recursiveLock.lock()
        defer { recursiveLock.unlock() }
        
        switch type {
        case .systemEvent:
            OMPlayerListenerNode.remove(listener: listener, from: &systemEventListeners)
        case .playerStatusEvent:
            OMPlayerListenerNode.remove(listener: listener, from: &playerControllerEventListeners)
        }
        
        for (index, preserveListener) in preserveListeners.enumerated() {
            if listener.isEqual(preserveListener) {
                preserveListeners.remove(at: index)
            }
        }
    }
    
    func removeAllListener(listener: AnyObject) {
        recursiveLock.lock()
        defer { recursiveLock.unlock() }
        
        for type in ListenerType.allCases {
            removeListener(listener: listener, type: type)
        }
    }
    
}

// MARK: - SystemEvent

extension OMPlayerListenerCenter {
    
    public func notifySystemEventDetected(application: UIApplication, type: SystemEventType) {
        recursiveLock.lock()
        defer { recursiveLock.unlock() }
        
        for node in systemEventListeners {
            if let listener = node.listener as? SystemEventListenerProtocol {
                listener.onSystemEventDetected(application: application, type: type)
            }
        }
    }
    
}

// MARK: - PlayerStatus

extension OMPlayerListenerCenter {

    public func notifyPlayerControllerEventDetected(event: OMPlayerControllerEventType) {
        recursiveLock.lock()
        defer { recursiveLock.unlock() }

        for node in playerControllerEventListeners {
            if let listener = node.listener as? OMPlayerControllerEventListenerProtocol {
                listener.onPlayerControllerEventDetected(event: event)
            }
        }
    }

}




