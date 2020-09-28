//
//  AttachmentPrefetcher.swift
//  AsyncTextAttachment
//
//  Created by 玉垒浮云 on 2020/9/27.
//

import Kingfisher

public struct AttachmentPrefetcher {
    private let urls: [URL]
    
    public init(urls: [URL]) {
        self.urls = urls
    }
    
    public func star() {
        let prefetcher = ImagePrefetcher(
            resources: urls,
            options: [.processor(CustomProcessor.default), .cacheSerializer(CustomCacheSerializer.default)]
        )
        prefetcher.start()
    }
}
