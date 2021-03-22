//
//  DiskDataStore.swift
//  GSImages
//
//  Created by Guillermo Sáenz on 3/21/21.
//

import PromiseKit

final class DiskDataStore: DataStore {
    
    // MARK: - Properties
    private let queue = DispatchQueue(label: "com.942v.GSImages.diskdatastore", attributes: .concurrent)
    private let fileManager = FileManager.default
    
    // MARK: - Methods
    init(
    ) {
        createTemporaryDirectoryIfNeeded()
    }
}

// MARK: - CRUD

extension DiskDataStore {
    func image(
        for url: URL
    ) -> Promise<UIImage?> {
        
        queue.sync {
            let fileCachePath = self.fileCachePath(
                for: url
            )
            
            let fileURL = URL(
                fileURLWithPath: fileCachePath.path
            )
            
            // Search for image data
            guard
                let data = try? Data(
                    contentsOf: fileURL
                )
            else {
                return .value(nil)
            }
            let image = UIImage(data: data)
            
            return .value(image)
        }
    }
    
    func insertImage(
        _ image: UIImage,
        for url: URL
    ) -> Promise<UIImage?> {
        
        removeImage(
            for: url
        )
        .then {
            
            Promise<UIImage?> { seal in
                
                let dataImage = image.cgImage!.dataProvider!.data! as Data
                
                self.queue.async(flags: .barrier) {
                    
                    let fileCachePath = self.fileCachePath(
                        for: url
                    )
                    
                    _ = self.fileManager.createFile(
                        atPath: fileCachePath.path,
                        contents: dataImage,
                        attributes: .none)
                    
                    seal.fulfill(image)
                }
            }
        }
    }
    
    func removeImage(
        for url: URL
    ) -> Promise<Void> {
        
        Promise<Void> { seal in
            
            queue.async(flags: .barrier) {
                
                let fileCachePath = self.fileCachePath(
                    for: url
                )
                
                // Remove it from  storage
                if self.fileManager.fileExists(atPath: fileCachePath.path) {
                    do {
                        try self.fileManager.removeItem(at: fileCachePath)
                    } catch {
                        seal.reject(error)
                    }
                }
                
                seal.fulfill_()
            }
        }
    }
    
    public func removeAllImages() {
        
        queue.async(flags: .barrier) {
            let temporaryDirectory = self.temporaryDirectory()
            
            do {
                try self.fileManager.removeItem(at: temporaryDirectory)
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - Helpers

extension DiskDataStore {
    func fileCachePath(for url: URL) -> URL {
        temporaryDirectory()
            .appendingPathComponent(
                url.lastPathComponent,
                isDirectory: false
            )
    }
    
    func temporaryDirectory() -> URL {
        fileManager
            .temporaryDirectory
            .appendingPathComponent(
                "ImagesDiskDataStore",
                isDirectory: true
            )
    }
    
    func createTemporaryDirectoryIfNeeded() {
        let url = temporaryDirectory()
        
        if !self.fileManager.fileExists(atPath: url.path) {
            try? self.fileManager.createDirectory(
                atPath: url.path,
                withIntermediateDirectories: false,
                attributes: .none
            )
        }
    }
}
