//
//  MediaItem.swift
//  DJ Central
//
//  Created by William Thompson on 6/17/17.
//  Copyright © 2017 J. W. Enterprises, LLC. All rights reserved.
//

import Foundation

class MediaItem {
    
    enum  MediaType: String {
        case songs, albums
    }
    
    struct JSONKeys {
        static let identifier = "id"
        static let type = "type"
        static let attributes = "attributes"
        static let name = "name"
        static let artistName = "artistName"
        static let artwork = "artwork"
    }
    
    let identifier: String
    let name: String
    let artistName: String
    let artwork: Artwork
    let type: MediaType
    
    init(json: [String: Any]) throws {
        
        guard let identifier = json[JSONKeys.identifier] as? String else {
            throw SerializationError.missing(JSONKeys.identifier)
        }
        
        guard let typeString = json[JSONKeys.type] as? String, let type = MediaType(rawValue: typeString) else {
            throw SerializationError.missing(JSONKeys.type)
        }
        
        guard let attributes = json[JSONKeys.attributes] as? [String: Any] else {
            throw SerializationError.missing(JSONKeys.attributes)
        }
        
        guard let name = attributes[JSONKeys.name] as? String else {
            throw SerializationError.missing(JSONKeys.name)
        }
        
        guard let artistName = attributes[JSONKeys.artistName] as? String else {
            throw SerializationError.missing(JSONKeys.artistName)
        }
        
        guard let artworkJSON = attributes[JSONKeys.artwork] as? [String: Any], let artwork = try? Artwork(json: artworkJSON) else {
            throw SerializationError.missing(JSONKeys.artwork)
        }
        
        self.identifier = identifier
        self.type = type
        self.name = name
        self.artistName = artistName
        self.artwork = artwork
    }
}
