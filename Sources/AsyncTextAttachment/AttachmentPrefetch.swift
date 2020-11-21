//
//  AttachmentPrefetch.swift
//  ATA test
//
//  Created by 玉垒浮云 on 2020/11/21.
//

import Kingfisher

public class AttachmentPrefetcher {
    private let imageURLs: [URL]
    private let gistURLs: [URL]
    private weak var target: AttachmentDelegate?
    
    public init(indexPaths: [IndexPath], target: AttachmentDelegate) {
        self.target = target
        
        var imageURLs: [URL] = []
        var gistURLs:[URL] = []
        for indexPath in indexPaths {
            if let urls = target.imagePrefetchDict[indexPath] {
                imageURLs.append(contentsOf: urls)
            } else if let urls = target.gistPrefetchDict[indexPath] {
                gistURLs.append(contentsOf: urls)
            }
        }
        
        self.imageURLs = imageURLs
        self.gistURLs = gistURLs
    }
    
    public func star() {
        for url in imageURLs {
            let prefetch = ImagePrefetcher(
                resources: [url],
                options: [
                    .processor(CustomProcessor.default),
                    .cacheSerializer(CustomCacheSerializer.default)
                ],
                progressBlock: nil
            ) { [weak self] (_, _, completedResources) in
                if completedResources.count == 1 {
                    self?.target?.imagePrefetchRecords[url] = nil
                }
            }
            prefetch.start()
            target?.imagePrefetchRecords[url] = prefetch
        }
        
        for url in gistURLs {
            let task = URLSession.shared.dataTask(with: url) { [weak self] (_, _, error) in
                guard error == nil else { return }
                self?.target?.gistPrefetchRecords[url] = nil
            }
            task.resume()
            target?.gistPrefetchRecords[url] = task
        }
    }
    
    public func stop() {
        for url in imageURLs {
            if let imagePrefetch = target?.imagePrefetchRecords[url] {
                imagePrefetch.stop()
                target?.imagePrefetchRecords[url] = nil
            }
        }
        
        for url in gistURLs {
            if let task = target?.gistPrefetchRecords[url] {
                task.cancel()
                target?.gistPrefetchRecords[url] = nil
            }
        }
    }
}
