//
//  JLMediaPlayerAssetLoader.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/12/23.
//


import AVFoundation
import CoreServices
import Alamofire

/// AVPlayerItem 自定义 schema
private let JLMediaPlayerItemScheme = "JLMediaPlayerItemScheme"


public protocol JLMediaPlayerAssetLoaderDelegate: AnyObject {
    func assetLoaderDidFinishDownloading(_ assetLoader: JLMediaPlayerAssetLoader)
    func assetLoader(_ assetLoader: JLMediaPlayerAssetLoader, didDownload bytes: Int64)
    func assetLoader(_ assetLoader: JLMediaPlayerAssetLoader, downloadingFailed error: Error)
}


public class JLMediaPlayerAssetLoader: NSObject {
    
    /// 代理对象
    public weak var delegate: JLMediaPlayerAssetLoaderDelegate?
    /// 歌曲唯一标识符
    public var uniqueID: String = "defaultUniqueID"
    /// 资源路径
    public let url: URL
    /// AVURLAsset对象
    public var urlAsset: AVURLAsset?
    /// 加载器线程队列
    private let loaderQueue = DispatchQueue(label: "com.OMusic.JLMediaPlayer.loaderQueue")
    /// 当期请求
    private var currentRequest: JLMediaPlayerRequest? {
        didSet {
            oldValue?.cancel()
        }
    }
    /// 是否取消
    private var isCancelled: Bool = false
    /// 加载长度
    private var loadedLength: Int64 = 0

    init(url: URL) {
        self.url = url
        super.init()
    }

    deinit {
        print("deinit")
    }
    
    /// 加载Asset资源
    /// - Parameter completion: completion
    public func loadAsset(completion: @escaping (AVURLAsset) -> Void) {
        var asset: AVURLAsset
        if let urlWithScheme = self.url.withScheme(JLMediaPlayerItemScheme) {
            asset = AVURLAsset(url: urlWithScheme)
        } else {
            assertionFailure("URL scheme is empty, please make sure to use the correct initilization func.")
            asset = AVURLAsset(url: self.url)
        }
        asset.resourceLoader.setDelegate(self, queue: self.loaderQueue)
        // 异步捕捉playable属性
        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
            DispatchQueue.main.async {
                completion(asset)
            }
        }
        self.urlAsset = asset
    }
    
    /// 清理状态
    public func cleanup() {
        self.loadedLength = 0
        self.isCancelled = true
        self.currentRequest?.cancel()
    }

}

// MARK: - Load Actions

extension JLMediaPlayerAssetLoader {

    private func handleContentInfoRequest(loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let infoRequest = loadingRequest.contentInformationRequest else {
            return false
        }
        let request = self.contentInfoRequest(loadingRequest: loadingRequest)
        Alamofire.download(request).response { [weak self] (responseObject) in
            self?.handleContentInfoResponse(loadingRequest: loadingRequest,
                                           infoRequest: infoRequest,
                                           response: responseObject.response,
                                           error: responseObject.error)
        }
        self.currentRequest = JLMediaPlayerContentInfoRequest(
            resourceUrl: url,
            loadingRequest: loadingRequest,
            infoRequest: infoRequest
        )
        return true
    }

    private func handleContentInfoResponse(loadingRequest: AVAssetResourceLoadingRequest,
                                           infoRequest: AVAssetResourceLoadingContentInformationRequest,
                                           response: URLResponse?,
                                           error: Error?) {
        //异步加载
        self.loaderQueue.async { [unowned self] in
            if self.isCancelled || loadingRequest.isCancelled {
                return
            }
            guard let request = self.currentRequest as? JLMediaPlayerContentInfoRequest,
                loadingRequest === request.loadingRequest else {
                return
            }
            if let error = error {
                print("Failed with error: \(String(describing: error))")
                loadingRequest.finishLoading(with: error)
                return
            }
            if let response = response {
                self.fillInWithRemoteResponse(infoRequest, response: response)
                loadingRequest.finishLoading()
            }
            if self.currentRequest === request {
                self.currentRequest = nil
            }
        }
    }

    private func handleDataRequest(loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if self.isCancelled || loadingRequest.isCancelled {
            return false
        }
        guard let avDataRequest = loadingRequest.dataRequest else {
            return false
        }
        let lowerBound = avDataRequest.requestedOffset
        let length = Int64(avDataRequest.requestedLength)
        let upperBound = lowerBound + length
        let requestedRange = lowerBound..<upperBound
        if let lastRequest = self.currentRequest as? JLMediaPlayerDataRequest {
            if lastRequest.range == requestedRange {
                return true
            } else {
                lastRequest.cancel()
            }
        }
        let loader = JLMediaPlayerDataLoader(uniqueID: self.uniqueID,
                                          url: self.url,
                                          range: requestedRange,
                                          callbackQueue: self.loaderQueue)
        loader.delegate = self
        let dataRequest: JLMediaPlayerDataRequest = {
            return JLMediaPlayerDataRequest(
                resourceUrl: self.url,
                loadingRequest: loadingRequest,
                dataRequest: avDataRequest,
                loader: loader,
                range: requestedRange
            )
        }()
        self.currentRequest = dataRequest
        loader.start()
        return true
    }

    private func fillInWithRemoteResponse(_ request: AVAssetResourceLoadingContentInformationRequest, response: URLResponse) {
        if let mimeType = response.mimeType,
            let contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil) {
            request.contentType = contentType.takeRetainedValue() as String
        }
        request.contentLength = response.jl_expectedContentLength
        //资源是否能在任何时间段访问，会影响拖动
        request.isByteRangeAccessSupported = response.jl_isByteRangeAccessSupported
    }

}


// MARK: - AVAssetResourceLoaderDelegate

extension JLMediaPlayerAssetLoader: AVAssetResourceLoaderDelegate {

    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                               shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        if let _ = loadingRequest.contentInformationRequest {
            //请求信息,获取currentRequest
            return self.handleContentInfoRequest(loadingRequest: loadingRequest)
        } else if let _ = loadingRequest.dataRequest {
            //请求数据
            return self.handleDataRequest(loadingRequest: loadingRequest)
        } else {
            return false
        }
    }

    public func resourceLoader(_ resourceLoader: AVAssetResourceLoader,
                               didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        self.currentRequest?.cancel()
    }

}

// MARK: - JLMediaPlayerDataLoaderDelegate

extension JLMediaPlayerAssetLoader: JLMediaPlayerDataLoaderDelegate {

    func dataLoader(_ loader: JLMediaPlayerDataLoader, didReceive data: Data) {
        if let dataRequest = self.currentRequest?.loadingRequest.dataRequest {
            dataRequest.respond(with: data)
        }
        self.loadedLength = self.loadedLength + Int64(data.count)
        self.delegate?.assetLoader(self, didDownload: self.loadedLength)
    }

    func dataLoaderDidFinish(_ loader: JLMediaPlayerDataLoader) {
        self.currentRequest?.loadingRequest.finishLoading()
        self.currentRequest = nil
        self.delegate?.assetLoaderDidFinishDownloading(self)
    }

    func dataLoader(_ loader: JLMediaPlayerDataLoader, didFailWithError error: Error) {
        self.currentRequest?.loadingRequest.finishLoading(with: error)
        self.currentRequest = nil
        self.delegate?.assetLoader(self, downloadingFailed: error)
    }

}

// MARK: - Getter

extension JLMediaPlayerAssetLoader {

    private static func isNetworkError(code: Int) -> Bool {
        let errorCodes = [
            NSURLErrorNotConnectedToInternet,
            NSURLErrorNetworkConnectionLost,
            NSURLErrorTimedOut,
        ]
        return errorCodes.contains(code)
    }

    private func contentInfoRequest(loadingRequest: AVAssetResourceLoadingRequest) -> URLRequest {
        var request = URLRequest(url: self.url)
        if let dataRequest = loadingRequest.dataRequest {
            let lowerBound = Int(dataRequest.requestedOffset)
            let upperBound = lowerBound + Int(dataRequest.requestedLength) - 1
            let rangeHeader = "bytes=\(lowerBound)-\(upperBound)"
            request.setValue(rangeHeader, forHTTPHeaderField: "Range")
        }
        return request
    }

}


// MARK: - Extensions

fileprivate extension URL {

    func withScheme(_ scheme: String) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.scheme = scheme
        return components.url
    }

}

fileprivate extension URLResponse {

    var jl_expectedContentLength: Int64 {
        guard let response = self as? HTTPURLResponse else {
            return expectedContentLength
        }
        let contentRangeKeys: [String] = [
            "Content-Range",
            "content-range",
            "Content-range",
            "content-Range",
        ]
        var rangeString: String?
        for key in contentRangeKeys {
            if let value = response.allHeaderFields[key] as? String {
                rangeString = value
                break
            }
        }
        if let rangeString = rangeString,
            let bytesString = rangeString.split(separator: "/").map({String($0)}).last,
            let bytes = Int64(bytesString) {
            return bytes
        } else {
            return expectedContentLength
        }
    }

    var jl_isByteRangeAccessSupported: Bool {
        guard let response = self as? HTTPURLResponse else {
            return false
        }
        let rangeAccessKeys: [String] = [
            "Accept-Ranges",
            "accept-ranges",
            "Accept-ranges",
            "accept-Ranges",
        ]
        for key in rangeAccessKeys {
            if let value = response.allHeaderFields[key] as? String,
                value == "bytes" {
                return true
            }
        }
        return false
    }

}

