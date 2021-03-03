//
//  AMFetchManager.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/6/13.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import Foundation
import Alamofire
import StoreKit

class AMFetchManager: NSObject {
    
    fileprivate var headers: HTTPHeaders? {
        get {
            guard let developerToken = OMAccountManager.shared.developerToken else {
                return nil
            }
            if let userToken = OMAccountManager.shared.userToken {
                return ["Authorization": "Bearer  \(developerToken)", "Music-User-Token": userToken]
            }
            return ["Authorization": "Bearer  \(developerToken)"]
        }
    }
    
    static let shared = AMFetchManager()
    

    
    public func getAMObjects<T: AMProtocol>(by ids: [String],
                                            from amObject: T.Type,
                                            completion: @escaping ([T]?, [String]?, Error?) -> Void) {
        guard let headers = headers else {
            completion(nil, nil, NSError.init(domain: JLErrorDomain, code: JLErrorCode.ValueNotFound, userInfo: [NSLocalizedDescriptionKey:"未能获得授权。"]))
            return
        }
        guard let storefront = OMAccountManager.shared.storefront else {
            completion(nil, nil, NSError.init(domain: JLErrorDomain, code: JLErrorCode.ValueNotFound, userInfo: [NSLocalizedDescriptionKey:"未能从Apple Store中读取你所在的地区。"]))
            return
        }
        let requestUrl = "https://api.music.apple.com/v1/catalog/\(storefront)"
        Alamofire.request("\(requestUrl)/\(amObject.description)", method: .get, parameters: ["ids":ids.joined(separator: ",")], encoding: URLEncoding.default, headers: headers).responseData { (response) in
            switch response.result {
            case .success(let data):
                guard let items = try? JSONDecoder().decode(T.self.codableClass, from: data) else {
                    completion(nil, nil, NSError.init(domain: JLErrorDomain, code: JLErrorCode.JSONDecodeFailed, userInfo: [NSLocalizedDescriptionKey:"解析数据错误，请重试。"]))
                    return
                }
                guard let objects = items.data else {
                    completion(nil, nil, NSError.init(domain: JLErrorDomain, code: JLErrorCode.AMObjectsNotFound, userInfo: [NSLocalizedDescriptionKey:"数据中没有相关值，请确保id正确。"]))
                    return
                }
                completion((objects as! [T]),
                           objects.map { (item) -> String in return (item.id ?? "") },
                           nil)
            case .failure(let error):
                completion(nil, nil, error)
            }
        }
    }
    
    
    public func getObject<T: AMProtocol>(by id: String,
                                         from amObject: T.Type,
                                         completion: @escaping (T?, Error?) -> Void) {
        guard let headers = headers else {
            completion(nil, NSError.init(domain: JLErrorDomain, code: JLErrorCode.ValueNotFound, userInfo: [NSLocalizedDescriptionKey:"未能获得授权。"]))
            return
        }
        guard let storefront = OMAccountManager.shared.storefront else {
            completion(nil, NSError.init(domain: JLErrorDomain, code: JLErrorCode.ValueNotFound, userInfo: [NSLocalizedDescriptionKey:"未能从Apple Store中读取你所在的地区。"]))
            return
        }
        let requestUrl = "https://api.music.apple.com/v1/catalog/\(storefront)"
        Alamofire.request("\(requestUrl)/\(amObject.description)", method: .get, parameters: ["ids":id], encoding: URLEncoding.default, headers: headers).responseData { (response) in
            switch response.result {
            case .success(let data):
                guard let items = try? JSONDecoder().decode(T.self.codableClass, from: data) else {
                    completion(nil, NSError.init(domain: JLErrorDomain, code: JLErrorCode.JSONDecodeFailed, userInfo: [NSLocalizedDescriptionKey:"解析数据错误，请重试。"]))
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
    
}


