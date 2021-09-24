//
//  OMPlayerListenerNode.swift
//
//

import UIKit

class OMPlayerListenerNode {
    
    public weak var listener: AnyObject?
    
    public static func create(listener: AnyObject) -> OMPlayerListenerNode {
        let node = OMPlayerListenerNode()
        node.listener = listener
        
        return node
    }
    
    public static func add(listener: AnyObject, to listenners: inout [OMPlayerListenerNode]) {
        let node = OMPlayerListenerNode.create(listener: listener)
        listenners.append(node)
    }
    
    public static func remove(listener: AnyObject, from listeners: inout [OMPlayerListenerNode]) {
        for (index, node) in listeners.enumerated() {
            if let tmpListener = node.listener {
                if tmpListener.isEqual(listener) {
                    listeners.remove(at: index)
                }
            } else {
                listeners.remove(at: index)
            }
        }
    }
    
}
