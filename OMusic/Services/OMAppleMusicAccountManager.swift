//
//  OMAppleMusicAccountManager.swift
//  OMusic
//
//  Created by Jonathan Lu on 2020/10/12.
//  Copyright © 2020 Jonathan Lu. All rights reserved.
//

import Foundation
import Alamofire
import StoreKit

class OMAppleMusicAccountManager: NSObject {
    
    /// Developer Token，用于请求Apple Music API的主要令牌
    private(set) var developerToken: String? {
        didSet {
            guard let amToken = developerToken else {
                return
            }
            let defaults = UserDefaults.standard
            defaults.set(amToken, forKey: "AM_TOKEN")
            defaults.set(Date.init(timeIntervalSinceNow: TimeInterval(26*7*24*60*60)).timeIntervalSince1970, forKey: "AM_TOKEN_EXPIREDTIME")
            defaults.synchronize()
        }
    }
    
    /// User Token，用于针对用户个人资料库的请求令牌，需要Developer Token
    private(set) var userToken: String? {
        didSet {
            guard let token = userToken else {
                return
            }
            let defaults = UserDefaults.standard
            defaults.set(token, forKey: "AM_USER_TOKEN")
            defaults.synchronize()
        }
    }
    
    /// 令牌过期时间
    private(set) var expiredAt: Date?
    
    /// 地区
    private(set) var storefront: String?  {
        didSet {
            guard let storefront = storefront else {
                return
            }
            let defaults = UserDefaults.standard
            defaults.set(storefront, forKey: "AM_STOREFRONT")
            defaults.synchronize()
        }
    }
    
    /// 单例对象
    static let shared = OMAppleMusicAccountManager()
    
    override private init() {
        super.init()
        guard let token = UserDefaults.standard.string(forKey: "AM_TOKEN") else {
            return
        }
        developerToken = token
        if let date = UserDefaults.standard.value(forKey: "AM_TOKEN_EXPIREDTIME") {
            expiredAt = Date.init(timeIntervalSince1970: date as! TimeInterval)
        }
        storefront = UserDefaults.standard.string(forKey: "AM_STOREFRONT")
        userToken = UserDefaults.standard.string(forKey: "AM_USER_TOKEN")
    }
    
    
    //MARK: Public Method
    
    
    /// 获取Developer Token
    /// - Parameter completion: completion，提供错误信息
    public func setupDeveloperToken(_ completion: @escaping (Bool, Error?) -> Void) {
        if let _ = developerToken, let expired = expiredAt, let _ = storefront {
            if expired.timeIntervalSinceNow < 24*60*60 {
                helper_setupToken(completion)
            } else {
                completion(true, nil)
            }
        } else {
            helper_setupToken(completion)
        }
    }
    
    /// 获取当前地区，通过用户Apple账户所在地区判断
    /// - Parameter completion: completion，提供错误信息
    public func getStorefront(_ completion: @escaping (Bool, Error?) -> Void = {_,_ in }) {
        SKCloudServiceController.requestAuthorization { (status) in
            switch status {
            case .notDetermined:
                completion(false, NSError.init(domain: SKErrorDomain, code: SKError.Code.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey:"未能完成授权。"]))
                return
            case .denied:
                completion(false, NSError.init(domain: SKErrorDomain, code: SKError.Code.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey:"授权被拒绝。"]))
                return
            case .restricted:
                completion(false, NSError.init(domain: SKErrorDomain, code: SKError.Code.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey:"授权被限制。"]))
                return
            case .authorized:
                let cloud = SKCloudServiceController.init()
                cloud.requestStorefrontCountryCode { [unowned self] (storefront, error) in
                    guard let storefront = storefront else {
                        completion(false, error ?? NSError.init(domain: SKErrorDomain, code: SKError.Code.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey:"未能从Apple Store中读取你所在的地区。"]))
                        return
                    }
                    self.storefront = storefront
                    completion(true, nil)
                }
                return
            @unknown default:
                completion(false, NSError.init(domain: SKErrorDomain, code: SKError.Code.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey:"未能完成授权。"]))
                return
            }
        }
    }
    
    /// 获取User Token
    /// - Parameter completion: completion，提供错误信息
    public func getUserToken(_ completion: @escaping (Bool, Error?) -> Void = {_,_ in }) {
        SKCloudServiceController.requestAuthorization { (status) in
            switch status {
            case .notDetermined:
                completion(false, NSError.init(domain: SKErrorDomain, code: SKError.Code.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey:"未能完成授权。"]))
                return
            case .denied:
                completion(false, NSError.init(domain: SKErrorDomain, code: SKError.Code.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey:"授权被拒绝。"]))
                return
            case .restricted:
                completion(false, NSError.init(domain: SKErrorDomain, code: SKError.Code.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey:"授权被限制。"]))
                return
            case .authorized:
                let cloud = SKCloudServiceController.init()
                guard let d_token = self.developerToken else {
                    completion(false, NSError.init(domain: SKErrorDomain, code: SKError.Code.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey:"请先获取Developer Token。"]))
                    return
                }
                cloud.requestUserToken(forDeveloperToken: d_token) { [unowned self] (token, error) in
                    guard let token = token else {
                        completion(false, error ?? NSError.init(domain: SKErrorDomain, code: SKError.Code.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey:"未能从Apple Store中读取你的Token。"]))
                        return
                    }
                    self.userToken = token
                    completion(true, nil)
                }
                return
            @unknown default:
                completion(false, NSError.init(domain: SKErrorDomain, code: SKError.Code.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey:"未能完成授权。"]))
                return
            }
        }
    }
    
    
    //MARK: Private Method
    
    
    private func helper_setupToken(_ completion: @escaping (Bool, Error?) -> Void) {
        //获取Token前先获取地区
        self.getStorefront { [unowned self] (s_succeed, s_error) in
            if s_succeed {
                self.getToken { (t_succeed, t_error) in
                    if t_succeed {
                        completion(true, nil)
                    } else {
                        completion(false, t_error!)
                    }
                }
            } else {
                completion(false, s_error!)
            }
        }
    }
    
    private func getToken(_ completion: @escaping (Bool, Error?) -> Void = {_,_  in }) {
        //从云服务器中获取账户信息
        Alamofire.request("https://omusic-developer-token.herokuapp.com/getToken", method: .post, parameters: nil, encoding: URLEncoding.default, headers: nil).responseString { [unowned self] (response) in
            switch response.result {
            case .success(let value):
                guard !value.isEmpty else {
                    completion(false, NSError.init(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [NSLocalizedDescriptionKey:"未能获得授权，可能服务器出现了问题。"]))
                    return
                }
                self.developerToken = value
                completion(true, nil)
            case .failure(let error):
                completion(false, error)
            }
        }
    }
    
}

