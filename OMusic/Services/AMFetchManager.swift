//
//  AMFetchManager.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/6/13.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import Foundation
import Alamofire

class AMFetchManager: NSObject {
    
    /// 适用于Apple Music API的请求头
    fileprivate var headers: HTTPHeaders? {
        get {
            guard let developerToken = OMAppleMusicAccountManager.shared.developerToken else {
                return nil
            }
            if let userToken = OMAppleMusicAccountManager.shared.userToken {
                return ["Authorization": "Bearer  \(developerToken)", "Music-User-Token": userToken]
            }
            return ["Authorization": "Bearer  \(developerToken)"]
        }
    }
    
    /// 单例对象
    static let shared = AMFetchManager()
    
    
    //MARK: Public Method

    
    /// 获取Apple Music中的各类型的具体信息，包括单曲、专辑、歌手
    /// - Parameters:
    ///   - ids: 传入对应类型对象的id数组
    ///   - amObject: 类型封装类，须符合AMObjectProtocol协议
    ///   - completion: completion，提供资源对象数组，id数组，错误信息
    public func getAMObjects<T: AMObjectProtocol>(by ids: [String],
                                            from amObject: T.Type,
                                            completion: @escaping ([T]?, [String]?, Error?) -> Void) {
        guard let headers = headers else {
            completion(nil, nil, JLErrorCode.AMAccountMangerHeaderNotFoundError)
            return
        }
        guard let storefront = OMAppleMusicAccountManager.shared.storefront else {
            completion(nil, nil, JLErrorCode.AMAccountMangerStorefrontNotFoundError)
            return
        }
        let requestUrl = "https://api.music.apple.com/v1/catalog/\(storefront)"
        Alamofire.request("\(requestUrl)/\(amObject.urlPathDescription.rawValue)", method: .get, parameters: ["ids":ids.joined(separator: ",")], encoding: URLEncoding.default, headers: headers).responseData { (response) in
            switch response.result {
            case .success(let data):
                //JSON解析
                guard let items = try? JSONDecoder().decode(T.self.responseCodableClass, from: data) else {
                    completion(nil, nil, NSError.init(domain: JLErrorDomain, code: JLErrorCode.JSONDecodeFailed, userInfo: [NSLocalizedDescriptionKey:"解析数据错误。"]))
                    return
                }
                guard let objects = items.data else {
                    completion(nil, nil, NSError.init(domain: JLErrorDomain, code: JLErrorCode.AMObjectsNotFound, userInfo: [NSLocalizedDescriptionKey:"数据中没有相关值，请确保id正确。"]))
                    return
                }
                completion((objects as! [T]),
                           objects.map { (item) -> String in return (item.id) },
                           nil)
            case .failure(let error):
                completion(nil, nil, error)
            }
        }
    }
    
    
    /// 获取Apple Music中的各类型的具体信息，包括单曲、专辑、歌手
    /// - Parameters:
    ///   - id: 传入对应类型对象的id
    ///   - amObject: 类型封装类，须符合AMObjectProtocol协议
    ///   - completion: completion，提供资源对象，错误信息
    public func getObject<T: AMObjectProtocol>(by id: String,
                                         from amObject: T.Type,
                                         completion: @escaping (T?, Error?) -> Void) {
        guard let headers = headers else {
            completion(nil, JLErrorCode.AMAccountMangerHeaderNotFoundError)
            return
        }
        guard let storefront = OMAppleMusicAccountManager.shared.storefront else {
            completion(nil, JLErrorCode.AMAccountMangerStorefrontNotFoundError)
            return
        }
        let requestUrl = "https://api.music.apple.com/v1/catalog/\(storefront)"
        Alamofire.request("\(requestUrl)/\(amObject.urlPathDescription.rawValue)", method: .get, parameters: ["ids":id], encoding: URLEncoding.default, headers: headers).responseData { (response) in
            switch response.result {
            case .success(let data):
                //JSON解析
                guard let items = try? JSONDecoder().decode(T.self.responseCodableClass, from: data) else {
                    completion(nil, NSError.init(domain: JLErrorDomain, code: JLErrorCode.JSONDecodeFailed, userInfo: [NSLocalizedDescriptionKey:"解析数据错误。"]))
                    return
                }
                guard let object = items.data?.first else {
                    completion(nil, NSError.init(domain: JLErrorDomain, code: JLErrorCode.AMObjectsNotFound, userInfo: [NSLocalizedDescriptionKey:"数据中没有相关值，请确保id正确。"]))
                    return
                }
                completion((object as! T), nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    
    /// 综合搜索 默认每个类型5个搜索结果
    /// - Parameters:
    ///   - text: 搜索关键字
    ///   - completion: completion，返回AMSearchItems对象，错误信息
    public func requestMutiSearch(text: String,
                            completion: @escaping (AMSearchItems?, Error?) -> Void) {
        guard let headers = headers else {
            completion(nil, JLErrorCode.AMAccountMangerHeaderNotFoundError)
            return
        }
        guard let storefront = OMAppleMusicAccountManager.shared.storefront else {
            completion(nil, JLErrorCode.AMAccountMangerStorefrontNotFoundError)
            return
        }
        let requestUrl = "https://api.music.apple.com/v1/catalog/\(storefront)/search"
        Alamofire.request("\(requestUrl)", method: .get, parameters: ["term":text,"limit":5,"offset":0], encoding: URLEncoding.default, headers: headers).responseData { (response) in
            switch response.result {
            case .success(let data):
                //JSON解析
                guard let items = try? JSONDecoder().decode(AMSearchResponse.self, from: data) else {
                    completion(nil, NSError.init(domain: JLErrorDomain, code: JLErrorCode.JSONDecodeFailed, userInfo: [NSLocalizedDescriptionKey:"解析数据错误。"]))
                    return
                }
                completion((items.results), nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    /// 详细搜索 适应每个类型，类型需符合AMObjectResponseProtocol协议
    /// - Parameters:
    ///   - text: 搜索关键字
    ///   - limit: 每次获取数据条数 默认20
    ///   - offset: offset
    ///   - completion: completion，返回对象，错误信息
    public func requestSearch<T: AMObjectResponseProtocol>(text: String,
                                                          limit: NSInteger = 20,
                                                         offset: NSInteger,
                                                         responseObject: T.Type,
                                                     completion: @escaping (T?, Error?) -> Void) {
        guard let headers = headers else {
            completion(nil, JLErrorCode.AMAccountMangerHeaderNotFoundError)
            return
        }
        guard let storefront = OMAppleMusicAccountManager.shared.storefront else {
            completion(nil, JLErrorCode.AMAccountMangerStorefrontNotFoundError)
            return
        }
        let requestUrl = "https://api.music.apple.com/v1/catalog/\(storefront)/search"
        Alamofire.request("\(requestUrl)", method: .get, parameters: ["term":text,"limit":limit,"offset":offset, "types":T.MediaClass.urlPathDescription.rawValue], encoding: URLEncoding.default, headers: headers).responseData { (response) in
            switch response.result {
            case .success(let data):
                //JSON解析
                guard let item = try? JSONDecoder().decode(AMSearchResponse.self, from: data) else {
                    completion(nil, NSError.init(domain: JLErrorDomain, code: JLErrorCode.JSONDecodeFailed, userInfo: [NSLocalizedDescriptionKey:"解析数据错误。"]))
                    return
                }
                completion(item.results?.getSearchItems(), nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    
    /// 获取下一页搜索结果，类型需符合AMObjectResponseProtocol协议
    /// - Parameters:
    ///   - next: 包含在AMObjectResponseProtocol中的next字段信息，如果与泛型不匹配则返回错误
    ///   - completion: completion，返回对象，错误信息
    public func requestSearchNextPage<T: AMObjectResponseProtocol>(next: String,
                                                                   limit: NSInteger = 20,
                                                                   responseObject: T.Type,
                                                                   completion: @escaping (T?, Error?) -> Void) {
        guard next.contains(T.MediaClass.urlPathDescription.rawValue) else {
            completion(nil, JLErrorCode.UrlStringNotMatchError)
            return
        }
        let next = next+"&limit=\(limit)"
        guard let headers = headers else {
            completion(nil, JLErrorCode.AMAccountMangerHeaderNotFoundError)
            return
        }
        Alamofire.request("https://api.music.apple.com"+next, method: .get, parameters: ["types":T.MediaClass.urlPathDescription.rawValue], encoding: URLEncoding.default, headers: headers).responseData { (response) in
            switch response.result {
            case .success(let data):
                //JSON解析
                guard let item = try? JSONDecoder().decode(AMSearchResponse.self, from: data) else {
                    completion(nil, NSError.init(domain: JLErrorDomain, code: JLErrorCode.JSONDecodeFailed, userInfo: [NSLocalizedDescriptionKey:"解析数据错误。"]))
                    return
                }
                completion(item.results?.getSearchItems(), nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
}


