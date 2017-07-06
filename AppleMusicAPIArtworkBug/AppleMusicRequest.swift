//
//  AppleMusicRequest.swift
//  DJ Central
//
//  Created by William Thompson on 6/17/17.
//  Copyright © 2017 J.W. Enterprises LLC. All rights reserved.
//

import Foundation

struct AppleMusicRequest {
    static let appleMusicAPIURLString = "api.music.apple.com"
    static func createSearchRequest(_ term: String, countryCode: String, developerToken: String) -> URLRequest {
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppleMusicRequest.appleMusicAPIURLString
        urlComponents.path = "/v1/catalog/\(countryCode)/search"
        let expectedTerms = term.replacingOccurrences(of: " ", with: "+")
        let urlParameters = ["term": expectedTerms, "limit": "10", "types": "songs,albums"]
        var queryItem = [URLQueryItem]()
        for (key, value) in urlParameters {
            queryItem.append(URLQueryItem(name: key, value: value))
        }
        urlComponents.queryItems = queryItem
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
    
    static func createStoreFrontRequest(_ regionCode: String, developerToken: String) -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = AppleMusicRequest.appleMusicAPIURLString
        urlComponents.path = "/v1/storefronts/\(regionCode)"
        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("Bearer \(developerToken)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
}
