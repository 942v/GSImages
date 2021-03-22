//
//  RemoteImages.swift
//  GSImages
//
//  Created by Guillermo Sáenz on 3/21/21.
//

import PromiseKit

public protocol RemoteImages {
    func downloadImage(
        from url: URL
    ) -> Promise<UIImage>
}
