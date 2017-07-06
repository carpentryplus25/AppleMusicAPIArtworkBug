//
//  ImageManager.swift
//  DJ Central
//
//  Created by William Thompson on 6/17/17.
//  Copyright © 2017 J.W. Enterprises LLC. All rights reserved.
//

import UIKit

class ImageManager {
    
    static let imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.name = "ImageManager"
        cache.countLimit = 100
        cache.totalCostLimit = 10 * 1024 * 1024
        return cache
    }()
    
    func cachedImage(url: URL) -> UIImage? {
        return ImageManager.imageCache.object(forKey: url.absoluteString as NSString)
    }
    
    func fetchImage(url: URL, completion: @escaping ((UIImage?) -> Void)) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil, let urlResponse = response as? HTTPURLResponse, urlResponse.statusCode == 200, let data = data else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            if let image = UIImage(data: data) {
                ImageManager.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(UIImage())
                }
            }
        }
        task.resume()
    }
    
}
