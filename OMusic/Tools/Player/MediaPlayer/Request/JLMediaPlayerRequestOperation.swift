//
//  JLMediaPlayerRequestOperation.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/12/6.
//
//

import Foundation
import Alamofire

public protocol JLMediaPlayerRequestOperationDelegate: AnyObject {
    
    func requestOperationWillStart(_ operation: JLMediaPlayerRequestOperation)
    
    func requestOperation(_ operation: JLMediaPlayerRequestOperation, didReceive data: Data)
    
    func requestOperation(_ operation: JLMediaPlayerRequestOperation, didCompleteWithError error: Error?)
    
}

public class JLMediaPlayerRequestOperation: Operation {
    
    public typealias CompletionHandler = () -> Void
    public weak var delegate: JLMediaPlayerRequestOperationDelegate?
    private(set) public var startOffset: Int64 = 0
    
    private let performQueue: DispatchQueue
    private var requestCompletion: CompletionHandler?
    private lazy var session: URLSession = createSession()
    private var task: URLSessionDataTask?

    private var _finished: Bool = false
    private var _executing: Bool = false
    
    public init(url: URL, range: JLMediaPlayerRange?) {
        self.performQueue = DispatchQueue(label: "com.JLMediaPlayer.RequestOperation", qos: .background)
        super.init()

        self.task = self.dataRequest(url: url, range: range)
    }

    private func work(completion: @escaping CompletionHandler) {
        self.requestCompletion = completion
        self.delegate?.requestOperationWillStart(self)
        self.task?.resume()
    }
    
    // MARK: Operation Requirements

    override public func start() {
        guard !self.isCancelled else {
            return
        }
        self.markAsRunning()
        self.performQueue.async {
            self.work {
                DispatchQueue.main.async { [weak self] in
                    guard  let weakSelf = self, !(weakSelf.isCancelled) else {
                        return
                    }
                    weakSelf.markAsFinished()
                }
            }
        }
    }

    override public func cancel() {
        self.task?.cancel()
    }

    override open var isFinished: Bool {
        get {
            return _finished
        }
        set {
            _finished = newValue
        }
    }

    override open var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            _executing = newValue
        }
    }
    
    override open var isAsynchronous: Bool {
        return true
    }
    
}

// MARK: - Private

extension JLMediaPlayerRequestOperation {

    private func markAsRunning() {
        self.willChangeValue(for: .isExecuting)
        _executing = true
        self.didChangeValue(for: .isExecuting)
    }

    private func markAsFinished() {
        self.willChangeValue(for: .isExecuting)
        self.willChangeValue(for: .isFinished)
        _executing = false
        _finished = true
        self.didChangeValue(for: .isExecuting)
        self.didChangeValue(for: .isFinished)
    }

    private func willChangeValue(for key: OperationChangeKey) {
        self.willChangeValue(forKey: key.rawValue)
    }

    private func didChangeValue(for key: OperationChangeKey) {
        self.didChangeValue(forKey: key.rawValue)
    }

    private enum OperationChangeKey: String {
        case isFinished
        case isExecuting
    }

}

// MARK: - URLSessionDelegate

extension JLMediaPlayerRequestOperation: URLSessionDataDelegate {

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.delegate?.requestOperation(self, didReceive: data)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.delegate?.requestOperation(self, didCompleteWithError: error)

        if let completion = requestCompletion {
            completion()
        }
    }

}

// MARK: - Getter

extension JLMediaPlayerRequestOperation {

    private func dataRequest(url: URL, range: JLMediaPlayerRange? = nil) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        if let range = range {
            let rangeHeader = "bytes=\(range.lowerBound)-\(range.upperBound)"
            request.setValue(rangeHeader, forHTTPHeaderField: "Range")
            self.startOffset = range.lowerBound
        }
        
        return self.session.dataTask(with: request)
    }
    

    private func createSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

        return session
    }

}