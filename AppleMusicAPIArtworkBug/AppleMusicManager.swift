//
//  AppleMusicManager.swift
//  DJ Central
//
//  Created by William Thompson on 6/17/17.
//  Copyright © 2017 J.W. Enterprises LLC. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class AppleMusicManager {
    typealias CatalogSearchCompletionHandler = (_ mediaItems: [[MediaItem]], _ error: Error?) -> Void
    typealias GetUserStoreFrontCompletionHandler = (_ storeFront: String?, _ error: Error?) -> Void
    lazy var urlSession: URLSession = {
        let urlSessionConfiguration = URLSessionConfiguration.default
        return URLSession(configuration: urlSessionConfiguration)
    }()
    var storeFrontID: String?
    
    func fetchDeveloperToken() -> String? {
        let developerAuthenticationToken: String? = nil
        // Be sure to add your developer token
        return developerAuthenticationToken
    }
    
    func performAppleMusicCatalogSearch(with term: String, countryCode: String, completion: @escaping CatalogSearchCompletionHandler) {
        guard let developerToken = fetchDeveloperToken() else {
            print("oops")
            return
        }
        let urlRequest = AppleMusicRequest.createSearchRequest(term, countryCode: countryCode, developerToken: developerToken)
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                completion([], error)
                return
            }
            do {
                let mediaItem = try self.processMediaItemSections(data!)
                completion(mediaItem, nil)
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func performAppleMusicStoreFrontLookup(_ regionCode: String, completion: @escaping GetUserStoreFrontCompletionHandler) {
        guard let developerToken = fetchDeveloperToken() else {
            print("oops")
            return
        }
        let urlRequest = AppleMusicRequest.createStoreFrontRequest(regionCode, developerToken: developerToken)
        let task = urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200 else {
                completion(nil, error)
                return
            }
            do {
                let identifier = try self?.processStoreFront(data!)
                completion(identifier, nil)
            } catch {
                fatalError("An error occurred: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func processMediaItemSections(_ json: Data) throws -> [[MediaItem]] {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let results = jsonDictionary[ResponseRootJSONKeys.results] as? [String: [String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.results)
        }
        var mediaItems = [[MediaItem]]()
        if let songsDictionary = results[ResourceTypeJSONKeys.songs] {
            if let dataArray = songsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let songMediaItems = try processMediaItems(from: dataArray)
                mediaItems.append(songMediaItems)
            }
        }
        if let albumsDictionary = results[ResourceTypeJSONKeys.albums] {
            if let dataArray = albumsDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] {
                let albumMediaItems = try processMediaItems(from: dataArray)
                mediaItems.append(albumMediaItems)
            }
        }
        return mediaItems
    }
    
    func processMediaItems(from json: [[String: Any]]) throws -> [MediaItem] {
        let songMediaItems = try json.map { try MediaItem(json: $0) }
        return songMediaItems
    }
    
    func processStoreFront(_ json: Data) throws -> String {
        guard let jsonDictionary = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any],
            let data = jsonDictionary[ResponseRootJSONKeys.data] as? [[String: Any]] else {
                throw SerializationError.missing(ResponseRootJSONKeys.data)
        }
        guard let identifier = data.first?[ResourceJSONKeys.identifier] as? String else {
            throw SerializationError.missing(ResourceJSONKeys.identifier)
        }
        return identifier
    }
}
