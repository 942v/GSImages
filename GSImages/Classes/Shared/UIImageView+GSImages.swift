//
//  UIImageView+GSImages.swift
//  GSImages
//
//  Created by Guillermo Sáenz on 3/21/21.
//

import UIKit

extension UIImageView {
    public func setImage(
        from url: URL,
        finished: ((UIImage?) ->  Void)? = nil
    ) {
        setImage(
            from: url,
            imagesRepository: GSImagesRepository.shared,
            finished: finished
        )
    }
    
    public func setImage(
        from url: URL,
        imagesRepository: ImagesRepository,
        finished: ((UIImage?) ->  Void)? = nil
    ) {
        
        imagesRepository
            .loadImage(
                from: url
            )
            .done { image in
                self.image = image
                finished?(image)
            }
            .catch { error in
                print(error)
            }
    }
}
