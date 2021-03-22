//
//  DataStore.swift
//  GSImages
//
//  Created by Guillermo Sáenz on 3/21/21.
//

import PromiseKit

protocol DataStore {
    
    /// Returns the image associated with a given url
    /// - Parameter url: Image URL
    /// - Returns: Optional UIImage
    func image(
        for url: URL
    ) -> Promise<UIImage?>
    
    /// Inserts the image of the specified url in the cache
    /// - Parameters:
    ///   - image: Image to store
    ///   - url: Image URL
    /// - Returns: Optional UIImage
    func insertImage(
        _ image: UIImage,
        for url: URL
    ) -> Promise<UIImage?>
    
    /// Removes the image of the specified url in the cache
    /// - Parameter url: Image URL
    /// - Returns: Optional UIImage 
    func removeImage(
        for url: URL
    ) -> Promise<Void>
    
    /// Removes all images from the cache
    func removeAllImages()
}
