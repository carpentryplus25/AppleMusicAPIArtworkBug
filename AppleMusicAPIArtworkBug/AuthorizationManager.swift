//
//  AuthorizationManager.swift
//  DJ Central
//
//  Created by William Thompson on 6/17/17.
//  Copyright © 2017 J.W. Enterprises LLC. All rights reserved.
//

import Foundation
import StoreKit
import MediaPlayer

class AuthorizationManager: NSObject {
    
    static let cloudServiceDidUpdateNotification = Notification.Name("cloudServiceDidiUpdateNotification")
    static let authorizationDidUpdateNotification = Notification.Name("authorizationDidUpdateNotification")
    let cloudServiceController = SKCloudServiceController()
    let appleMusicManager: AppleMusicManager
    var cloudServiceCapabilities = SKCloudServiceCapability()
    var cloudServiceStoreFrontCountryCode = "us"
    
    init(appleMusicManager: AppleMusicManager) {
        self.appleMusicManager = appleMusicManager
        super.init()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(requestCloudServiceCapabilities), name: .SKCloudServiceCapabilitiesDidChange, object: nil)
        if SKCloudServiceController.authorizationStatus() == .authorized {
            requestCloudServiceCapabilities()
            requestStoreFrontCountryCode()
        }
    }
    
    deinit {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: .SKCloudServiceCapabilitiesDidChange, object: nil)
    }
    
    func requestCloudServiceAuthorization() {
        guard SKCloudServiceController.authorizationStatus() == .notDetermined else {
            return
        }
        SKCloudServiceController.requestAuthorization { [weak self] (authorizationStatus) in
            switch authorizationStatus {
            case .authorized:
                self?.requestCloudServiceCapabilities()
                self?.requestStoreFrontCountryCode()
            default:
                break
            }
            NotificationCenter.default.post(name: AuthorizationManager.authorizationDidUpdateNotification, object: nil)
        }
    }
    
    func requestMediaLibrayAuthorization() {
        guard MPMediaLibrary.authorizationStatus() == .notDetermined else {
            return
        }
        MPMediaLibrary.requestAuthorization { (_) in
            NotificationCenter.default.post(name: AuthorizationManager.cloudServiceDidUpdateNotification, object: nil)
        }
    }
    
    func requestCloudServiceCapabilities() {
        cloudServiceController.requestCapabilities(completionHandler: { [weak self] (cloudServiceCapability, error) in
            guard error == nil else {
                print("oops")
                return
                //fatalError("An error occurred when requesting capabilities: \(error!.localizedDescription)")
            }
            self?.cloudServiceCapabilities = cloudServiceCapability
            NotificationCenter.default.post(name: AuthorizationManager.cloudServiceDidUpdateNotification, object: nil)
        })
    }
    
    func requestStoreFrontCountryCode() {
        let completionHandler: (String?, Error?) -> Void = { [weak self] (countryCode, error) in
            guard error == nil else {
                print("An error occurred when requesting storefront country code: \(error!.localizedDescription)")
                return
            }
            guard let countryCode = countryCode else {
                print("Unexpected value from SKCloudServiceController for storefront country code.")
                return
            }
            self?.cloudServiceStoreFrontCountryCode = countryCode
            NotificationCenter.default.post(name: AuthorizationManager.cloudServiceDidUpdateNotification, object: nil)
        }
        if SKCloudServiceController.authorizationStatus() == .authorized {
            determineRegionWithDeviceLocale(completion: completionHandler)
            
        } else {
            determineRegionWithDeviceLocale(completion: completionHandler)
        }
    }
    
    func determineRegionWithDeviceLocale(completion: @escaping (String?, Error?) -> Void) {
        let currentRegionCode = Locale.current.regionCode?.lowercased() ?? "us"
        appleMusicManager.performAppleMusicStoreFrontLookup(currentRegionCode, completion: completion)
    }
    
}
