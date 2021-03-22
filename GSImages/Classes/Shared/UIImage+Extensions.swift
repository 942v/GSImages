//
//  UIImage+Extensions.swift
//  GSImages
//
//  Created by Guillermo Sáenz on 3/21/21.
//

import UIKit

extension UIImage {
    
    /// This function consumes a regular UIImage and returns a decompressed and rendered version
    /// - Returns: Decompressed and rendered Image
    func decodedImage(
    ) -> UIImage {
        guard
            let cgImage = cgImage
        else {
            return self
        }
        
        let size = CGSize(
            width: cgImage.width,
            height: cgImage.height
        )
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(
            data: nil, width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: cgImage.bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        context?.draw(
            cgImage,
            in: CGRect(
                origin: .zero,
                size: size
            )
        )
        
        guard
            let decodedImage = context?.makeImage()
        else {
            return self
        }
        
        let image = UIImage(
            cgImage: decodedImage
        )
        return image
    }
    
    /// Rough estimation of how much memory an image uses in bytes
    var diskSize: Int {
        guard
            let cgImage = cgImage
        else {
            return 0
        }
        
        let diskSize = cgImage.bytesPerRow * cgImage.height
        return diskSize
    }
}
