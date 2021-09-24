//
//  JLMediaPlayerDataLoader.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/12/6.
//

import UIKit


public typealias JLMediaPlayerRange = Range<Int64>


protocol JLMediaPlayerDataLoaderDelegate: AnyObject {
    func dataLoader(_ loader: JLMediaPlayerDataLoader, didReceive data: Data)
    
    func dataLoaderDidFinish(_ loader: JLMediaPlayerDataLoader)
    
    func dataLoader(_ loader: JLMediaPlayerDataLoader, didFailWithError error: Error)
}


class JLMediaPlayerDataLoader: NSObject {
    
    /// 代理对象
    public weak var delegate: JLMediaPlayerDataLoaderDelegate?
    /// 回调线程队列
    private let callbackQueue: DispatchQueue
    /// 操作线程队列
    private let operationQueue: OperationQueue
    /// 歌曲唯一标识符
    private let uniqueID: String
    /// URL
    private let url: URL
    /// 请求数据范围
    private let requestedRange: JLMediaPlayerRange
    /// 媒体数据
    private var mediaData: Data?
    /// 是否取消
    private var cancelled: Bool = false
    /// 是否失败
    private var failed: Bool = false

    public init(uniqueID: String, url: URL, range: JLMediaPlayerRange, callbackQueue: DispatchQueue) {
        self.uniqueID = uniqueID
        self.url = url
        self.requestedRange = range
        self.callbackQueue = callbackQueue
        self.operationQueue = {
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 2
            return queue
        }()
        super.init()
    }

    deinit {
        print("deinit")
    }
    
    /// 开始加载
    public func start() {
        guard !self.cancelled && !self.failed else {
            return
        }
        let startOffset = self.requestedRange.lowerBound
        let endOffset = self.requestedRange.upperBound
        let notEnded = startOffset < endOffset
        if notEnded {
            self.addRemoteRequest(startOffset: startOffset, endOffset: endOffset)
        }
    }
    
    /// 取消加载
    public func cancel() {
        self.cancelled = true
        self.operationQueue.cancelAllOperations()
    }
}


// MARK: - Request

extension JLMediaPlayerDataLoader {

    private func remoteRequestOperation(range: JLMediaPlayerRange) -> Operation {
        let operation = JLMediaPlayerRequestOperation(url: self.url, range: range)
        operation.delegate = self
        return operation
    }

}

// MARK: - Private

private extension JLMediaPlayerDataLoader {

    func addRemoteRequest(startOffset: Int64, endOffset: Int64) {
        guard startOffset < endOffset else {
            return
        }
        let range = startOffset..<endOffset
        self.operationQueue.addOperation(self.remoteRequestOperation(range: range))
    }

}


// MARK: - JLMediaPlayerRequestOperationDelegate

extension JLMediaPlayerDataLoader: JLMediaPlayerRequestOperationDelegate {

    func requestOperationWillStart(_ operation: JLMediaPlayerRequestOperation) {
        mediaData = Data()
    }

    func requestOperation(_ operation: JLMediaPlayerRequestOperation, didReceive data: Data) {
        mediaData?.append(data)
        callbackQueue.sync { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.delegate?.dataLoader(weakSelf, didReceive: data)
        }
    }

    func requestOperation(_ operation: JLMediaPlayerRequestOperation, didCompleteWithError error: Error?) {
        var shouldSaveData = false
        callbackQueue.sync {[weak self] in
            guard let weakSelf = self else {
                return
            }
            if let error = error {
                delegate?.dataLoader(weakSelf, didFailWithError: error)
            } else {
                delegate?.dataLoaderDidFinish(weakSelf)
                shouldSaveData = true
            }
        }
        if shouldSaveData, let mediaData = self.mediaData, mediaData.count > 0 {
            self.mediaData = nil
        }
    }

}

