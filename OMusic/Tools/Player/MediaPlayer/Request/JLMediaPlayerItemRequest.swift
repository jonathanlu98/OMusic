//
//  JLMediaPlayerRequest.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/12/28.
//
//

import Foundation
import AVFoundation

protocol JLMediaPlayerRequest: AnyObject {

    var resourceUrl: URL { get }
    var loadingRequest: AVAssetResourceLoadingRequest { get }

    func cancel()

}




class JLMediaPlayerContentInfoRequest: JLMediaPlayerRequest {

    let resourceUrl: URL
    
    /// 一个对象，它封装了资源加载器对象发出的资源请求的信息。
    let loadingRequest: AVAssetResourceLoadingRequest
    
    /// 用于获取资产资源加载请求所引用的资源的基本信息的查询。
    let infoRequest: AVAssetResourceLoadingContentInformationRequest
        
    init(resourceUrl: URL,
         loadingRequest: AVAssetResourceLoadingRequest,
         infoRequest: AVAssetResourceLoadingContentInformationRequest) {
        self.resourceUrl = resourceUrl
        self.loadingRequest = loadingRequest
        self.infoRequest = infoRequest
    }
    
    func cancel() {
        if !self.loadingRequest.isCancelled && !self.loadingRequest.isFinished {
            self.loadingRequest.finishLoading()
        }
    }

}

class JLMediaPlayerDataRequest: JLMediaPlayerRequest  {
    
    let resourceUrl: URL
    let loadingRequest: AVAssetResourceLoadingRequest
    let dataRequest: AVAssetResourceLoadingDataRequest
    let loader: JLMediaPlayerDataLoader
    let range: JLMediaPlayerRange
    
    init(resourceUrl: URL,
         loadingRequest: AVAssetResourceLoadingRequest,
         dataRequest: AVAssetResourceLoadingDataRequest,
         loader: JLMediaPlayerDataLoader,
         range: JLMediaPlayerRange)
    {
        self.resourceUrl = resourceUrl
        self.loadingRequest = loadingRequest
        self.dataRequest = dataRequest
        self.loader = loader
        self.range = range
    }
    
    func cancel() {
        self.loader.cancel()
        if !self.loadingRequest.isCancelled && !self.loadingRequest.isFinished {
            self.loadingRequest.finishLoading()
        }
    }
    
}
