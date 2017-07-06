//
//  Artwork.swift
//  DJ Central
//
//  Created by William Thompson on 6/17/17.
//  Copyright © 2017 J. W. Enterprises, LLC. All rights reserved.
//

import UIKit

class Artwork {
    
    struct JSONKeys {
        static let height = "height"
        static let width = "width"
        static let url = "url"
    }
    
    let height: Int
    let width: Int
    let urlTemplateString: String
    
    init(json: [String: Any]) throws {
        guard let height = json[JSONKeys.height] as? Int else {
            throw SerializationError.missing(JSONKeys.height)
        }
        guard let width = json[JSONKeys.width] as? Int else {
            throw SerializationError.missing(JSONKeys.width)
        }
        guard let urlTemplateString = json[JSONKeys.url] as? String else {
            throw SerializationError.missing(JSONKeys.url)
        }
        self.height = height
        self.width = width
        self.urlTemplateString = urlTemplateString
    }
    
    func imageUrl(_ size: CGSize) -> URL {
        var imageURLString = urlTemplateString.replacingOccurrences(of: "{w}", with: "\(Int(size.width))")
        imageURLString = imageURLString.replacingOccurrences(of: "{h}", with: "\(Int(size.width))")
        imageURLString = imageURLString.replacingOccurrences(of: "{f}", with: "png")
        return URL(string: imageURLString)!
    }
}
