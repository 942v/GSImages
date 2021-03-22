//
//  GSRemoteImages.swift
//  GSImages
//
//  Created by Guillermo Sáenz on 3/21/21.
//

import PromiseKit

public final class GSRemoteImages: RemoteImages {
    
    private let session: URLSession
    
    public init(
        session: URLSession
    ) {
        self.session = session
    }
}

extension GSRemoteImages {
    
    public func downloadImage(
        from url: URL
    ) -> Promise<UIImage> {
        
        session
            .dataTask(.promise, with: URLRequest(url: url))
            .validate()
            .then(parseImage)
    }
}

extension GSRemoteImages {
    private func parseImage(
        from data: Data,
        response: URLResponse
    ) -> Promise<UIImage> {
        Promise<UIImage> { seal in
            guard
                let image = UIImage(data: data)
            else {
                seal.fulfill(UIImage()) // FIXME: this should fail with custom error
                return
            }
            
            seal.fulfill(image)
        }
    }
}
