//
//  GSImagesRepository.swift
//  GSImages
//
//  Created by Guillermo Sáenz on 3/21/21.
//

import UIKit
import PromiseKit

public final class GSImagesRepository: ImagesRepository {
    
    // MARK: - Properties
    public static let shared: ImagesRepository = GSImagesRepository()
    private let cacheStore: DataStore
    private let diskStore: DataStore
    private let remoteAPI: RemoteImages
    
    // MARK: - Methods
    public init(
        remoteAPI: RemoteImages = GSRemoteImages(session: .shared)
    ) {
        self.cacheStore = CacheDataStore()
        self.diskStore = DiskDataStore()
        self.remoteAPI = remoteAPI
    }
}

extension GSImagesRepository {
    public func loadImage(
        from url: URL
    ) -> Promise<UIImage?> {
        
        cacheStore
            .image(
                for: url
            )
            .then { image in
                self.fetchFromDiskIfNeeded(
                    with: url,
                    imageFromDataStore: image
                )
            }
            .then { image in
                self.fetchFromNetworkIfNeeded(
                    with: url,
                    imageFromDataStore: image
                )
            }
    }
}

// MARK: - Helpers

extension GSImagesRepository {
    fileprivate func fetchFromDiskIfNeeded(
        with url: URL,
        imageFromDataStore: UIImage?
    ) -> Promise <UIImage?> {
        
        if imageFromDataStore != nil {
            return .value(imageFromDataStore)
        }
        return diskStore
            .image(
                for: url
            )
            .then { image in
                self.storeInCacheIfNeeded(
                    with: url,
                    image: image
                )
            }
    }
    
    fileprivate func fetchFromNetworkIfNeeded(
        with url: URL,
        imageFromDataStore: UIImage?
    ) -> Promise<UIImage?> {
        
        if imageFromDataStore != nil {
            return .value(imageFromDataStore)
        }
        return remoteAPI
            .downloadImage(
                from: url
            )
            .then { image in
                self.storeInDiskIfNeeded(
                    with: url,
                    image: image
                )
            }
            .then { image in
                self.storeInCacheIfNeeded(
                    with: url,
                    image: image
                )
            }
    }
}

extension GSImagesRepository {
    fileprivate func storeInDiskIfNeeded(
        with url: URL,
        image: UIImage?
    ) -> Promise <UIImage?> {
        
        guard
            let image = image
        else {
            return .value(nil)
        }
        
        return diskStore
            .insertImage(
                image,
                for: url
            )
    }
    
    fileprivate func storeInCacheIfNeeded(
        with url: URL,
        image: UIImage?
    ) -> Promise<UIImage?> {
        
        guard
            let image = image
        else {
            return .value(nil)
        }
        
        return cacheStore
            .insertImage(
                image,
                for: url
            )
    }
}
