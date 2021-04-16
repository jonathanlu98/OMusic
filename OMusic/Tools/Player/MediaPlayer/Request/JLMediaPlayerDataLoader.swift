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

    public weak var delegate: JLMediaPlayerDataLoaderDelegate?

    private let callbackQueue: DispatchQueue
    
    private let operationQueue: OperationQueue
    
    private let uniqueID: String
    
    private let url: URL
    
    private let requestedRange: JLMediaPlayerRange
    
    private var mediaData: Data?
    
    private var cancelled: Bool = false
    
    private var failed: Bool = false

    init(uniqueID: String, url: URL, range: JLMediaPlayerRange, callbackQueue: DispatchQueue) {
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
