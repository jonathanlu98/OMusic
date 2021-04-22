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
    /// 开始位移
    private(set) public var startOffset: Int64 = 0
    /// 线程队列
    private let performQueue: DispatchQueue
    /// 请求回调
    private var requestCompletion: CompletionHandler?
    /// URLSession对象
    private lazy var session: URLSession = createSession()
    /// URLSessionDataTask对象
    private var task: URLSessionDataTask?
    private var _finished: Bool = false
    private var _executing: Bool = false
    
    public init(url: URL, range: JLMediaPlayerRange?) {
        self.performQueue = DispatchQueue(label: "com.JLMediaPlayer.RequestOperation", qos: .background)
        super.init()
        self.task = self.dataRequest(url: url, range: range)
    }
    
    deinit {
        print("\(Unmanaged<AnyObject>.passUnretained(self as AnyObject).toOpaque())--------------释放了")
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
        weak var weakSelf = self
        self.performQueue.async {
            weakSelf?.work {
                //调用该方法使得对象完成后结束，不调用会无法释放该对象
                weakSelf?.session.finishTasksAndInvalidate()
                DispatchQueue.main.async {
                    guard !(weakSelf?.isCancelled ?? false) else {
                        return
                    }
                    weakSelf?.markAsFinished()
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
