//
//  GSImagesRepository.swift
//  GSImages
//
//  Created by Guillermo Sáenz on 3/21/21.
//

import UIKit
import PromiseKit

public final class GSImagesRepository: ImagesRepository {
    
    public static let shared: ImagesRepository = GSImagesRepository()
    
    // MARK: - Properties
    private let cacheStore: DataStore
    private let remoteAPI: RemoteImages
    
    // MARK: - Methods
    public init(
        remoteAPI: RemoteImages = GSRemoteImages(session: .shared)
    ) {
        self.cacheStore = CacheDataStore()
        self.remoteAPI = remoteAPI
    }
}

extension GSImagesRepository {
    public func loadImage(
        from url: URL
    ) -> Promise<UIImage?> {
        
        cacheStore
            .image(for: url)
            .then { image in
                self.fetchFromNetworkIfNeeded(
                    with: url,
                    imageFromDataStore: image
                )
            }
    }
}

extension GSImagesRepository {
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
                self.cacheStore.insertImage(
                    image,
                    for: url
                )
            }
    }
}
