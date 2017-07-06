//
//  JSONKeys.swift
//  DJ Central
//
//  Created by William Thompson on 6/17/17.
//  Copyright © 2017 J.W. Enterprpises LLC. All rights reserved.
//

import Foundation


struct ResponseRootJSONKeys {
    static let data = "data"
    
    static let results = "results"
}

struct ResourceJSONKeys {
    static let identifier = "id"
    
    static let attributes = "attributes"
    
    static let type = "type"
}

struct ResourceTypeJSONKeys {
    static let songs = "songs"
    
    static let albums = "albums"
}
