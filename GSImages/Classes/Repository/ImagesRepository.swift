//
//  ImagesRepository.swift
//  GSImages
//
//  Created by Guillermo Sáenz on 3/21/21.
//

import PromiseKit

public protocol ImagesRepository {
    
    static var shared: ImagesRepository { get }
    
    func loadImage(
        from url: URL
    ) -> Promise<UIImage?>
}
