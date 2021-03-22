//
//  CacheDataStore.swift
//  GSImages
//
//  Created by Guillermo Sáenz on 3/21/21.
//

import PromiseKit

final class CacheDataStore: DataStore {
    
    struct Configuration {
        let countLimit: Int
        let memoryLimit: Int
        
        static let defaultConfig = Configuration(
            countLimit: 100,
            memoryLimit: 1024 * 1024 * 100
        ) // 100 MB
    }
    
    // MARK: - Properties
    private let queue = DispatchQueue(label: "com.942v.GSImages.cachedatastore", attributes: .concurrent)
    private let configuration: Configuration
    
    /// 1st level cache, contains encoded images
    private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
        createImageCache(
            with: configuration.countLimit
        )
    }()
    
    /// 2nd level cache, contains decoded images
    private lazy var decodedImageCache: NSCache<AnyObject, AnyObject> = {
        createImageCache(
            with: configuration.memoryLimit
        )
    }()
    
    // MARK: - Methods
    init(
        configuration: Configuration = Configuration.defaultConfig
    ) {
        self.configuration = configuration
    }
}

// MARK: - CRUD

extension CacheDataStore {
    func image(
        for url: URL
    ) -> Promise<UIImage?> {
        
        queue.sync {
            // The best case scenario -> there is a decoded image
            if let decodedImage = decodedImageCache.object(
                forKey: url as AnyObject
            ) as? UIImage {
                return .value(decodedImage)
            }
            
            // Search for image data
            if let image = imageCache.object(
                forKey: url as AnyObject
            ) as? UIImage {
                
                let decodedImage = image.decodedImage()
                
                // Store it decoded
                decodedImageCache.setObject(
                    image as AnyObject,
                    forKey: url as AnyObject,
                    cost: decodedImage.diskSize
                )
                
                return .value(decodedImage)
            }
            
            return .value(nil)
        }
    }
    
    func insertImage(
        _ image: UIImage,
        for url: URL
    ) -> Promise<UIImage?> {
        
        Promise<UIImage?> { seal in
            
            let decodedImage = image.decodedImage()
            
            queue.async(flags: .barrier) {
                
                // Store is encoded
                self.imageCache.setObject(
                    decodedImage,
                    forKey: url as AnyObject
                )
                // Store is decoded
                self.decodedImageCache.setObject(
                    image as AnyObject,
                    forKey: url as AnyObject,
                    cost: decodedImage.diskSize
                )
                
                seal.fulfill(image)
            }
        }
    }
    
    func removeImage(
        for url: URL
    ) -> Promise<Void> {
        
        Promise<Void> { seal in
            
            queue.async(flags: .barrier) {
                
                // Remove it from encoded storage
                self.imageCache.removeObject(
                    forKey: url as AnyObject
                )
                // Remove it from decoded storage
                self.decodedImageCache.removeObject(
                    forKey: url as AnyObject
                )
                
                seal.fulfill_()
            }
        }
    }
    
    public func removeAllImages() {
        
        queue.async(flags: .barrier) {
            // Remove it from encoded storage
            self.imageCache.removeAllObjects()
            // Remove it from decoded storage
            self.decodedImageCache.removeAllObjects()
        }
    }
}

// MARK: - Helpers

private
extension CacheDataStore {
    
    /// Creates cache with defined count limit
    /// - Parameter countLimit: Size limit to evict data
    /// - Returns: NSCache box
    func createImageCache(
        with countLimit: Int
    ) -> NSCache<AnyObject, AnyObject> {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = countLimit
        return cache
    }
}
