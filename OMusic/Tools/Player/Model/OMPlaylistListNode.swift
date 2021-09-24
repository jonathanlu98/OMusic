//
//  OMPlaylistListNode.swift
//  OMusic
//
//  Created by 陆佳鑫 - 个人 on 2021/3/24.
//  Copyright © 2021 Jonathan Lu. All rights reserved.
//

import UIKit

class OMPlaylistListNode: Equatable {
    
    static func == (lhs: OMPlaylistListNode, rhs: OMPlaylistListNode) -> Bool {
        if Unmanaged<AnyObject>.passUnretained(lhs).toOpaque() == Unmanaged<AnyObject>.passUnretained(rhs).toOpaque() {
            return true
        } else {
            return false
        }
    }
    
    fileprivate(set) var value: JLTrack
    fileprivate(set) var next: OMPlaylistListNode?
    fileprivate(set) weak var previous: OMPlaylistListNode?
    
    weak fileprivate var list: OMPlaylistList?
        
    init(_ value: JLTrack) {
        self.value = value
        self.next = nil
        self.previous = nil
    }
}



class OMPlaylistList: Equatable {
    private(set) var head: OMPlaylistListNode?
    private(set) var last: OMPlaylistListNode?
        
    var array: [OMPlaylistListNode] {
        get {
            guard let head = self.head else {
                return []
            }
            var array = [OMPlaylistListNode]()
            array.append(head)
            var node = head
            while let next = node.next {
                if next == head {
                    break
                }
                array.append(next)
                node = next
            }
            return array
        }
    }
    
    var isLoop:Bool = false {
        didSet {
            if (isLoop != oldValue) {
                self.setLoop(isLoop)
            }
        }
    }
    
    var isShuffle:Bool = false
    
    static func == (lhs: OMPlaylistList, rhs: OMPlaylistList) -> Bool {
        if Unmanaged<AnyObject>.passUnretained(lhs).toOpaque() == Unmanaged<AnyObject>.passUnretained(rhs).toOpaque() {
            return true
        } else {
            return false
        }
    }
    
    init() {
        
    }
    
    init(_ value: JLTrack) {
        let node = OMPlaylistListNode.init(value)
        self.head = node
        self.last = node
        node.list = self
    }
    
    init(_ array: [JLTrack], isRepeat: Bool) {
        self.isLoop = isRepeat
        for item in array {
            self.append(item)
        }
    }
    
    func append(_ value: JLTrack) {
        let node = OMPlaylistListNode.init(value)
        if let last = last {
            last.next = node
            node.previous = last
        } else {
            head = node
        }
        last = node
        if (self.isLoop) {
            last?.next = head
            head?.previous = last
        }
        node.list = self
    }
    
 
    private func setLoop(_ value:Bool) {
        if value {
            last?.next = head
            head?.previous = last
        } else {
            last?.next = nil
            head?.previous = nil
        }
    }
    
    /// 生成随机序列
    /// - Parameters:
    ///   - node: 开始的节点，节点必须是当前列表的，不然返回空
    ///   - array: 待随机的数组
    func shuffle(from node: OMPlaylistListNode, source array: [JLTrack]) {
        guard node.list == self else {
            return
        }
        guard !array.isEmpty else {
            return
        }
        let res = array.shuffled().map { (track) -> OMPlaylistListNode in
            let node = OMPlaylistListNode.init(track)
            node.list = self
            return node
        }
        node.next?.previous = nil
        node.next = nil
        var node = node
        
        for (idx, item) in res.enumerated() {
            node.next = item
            item.previous = node
            node = item
            if (idx == res.count-1) {
                self.last = item
                if (self.isLoop) {
                    last?.next = head
                    head?.previous = last
                }
            }
        }
        
        self.isShuffle = true
    }
    
    
    /// 恢复随机序列
    func recoverList(from node: OMPlaylistListNode, source array: [JLTrack]) {
        guard node.list == self else {
            return
        }
        guard !array.isEmpty else {
            return
        }
        let res = array.map { (track) -> OMPlaylistListNode in
            let node = OMPlaylistListNode.init(track)
            node.list = self
            return node
        }
        node.next?.previous = nil
        node.next = nil
        var node = node
        
        for (idx, item) in res.enumerated() {
            node.next = item
            item.previous = node
            node = item
            if (idx == res.count-1) {
                self.last = item
                if (self.isLoop) {
                    last?.next = head
                    head?.previous = last
                }
            }
        }
        
        self.isShuffle = false
    }
}
