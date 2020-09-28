//
//  CustomCacheSerializer.swift
//  AsyncTextAttachment
//
//  Created by 玉垒浮云 on 2020/9/27.
//

import Kingfisher
import KingfisherWebP

struct CustomCacheSerializer: CacheSerializer {
    static let `default` = CustomCacheSerializer()
    private init() {}
    
    func data(with image: KFCrossPlatformImage, original: Data?) -> Data? {
        if let original = original, !original.isWebPFormat {
            if original.isAnimated {
                return original
            } else {
                return DefaultCacheSerializer.default.data(with: image, original: original)
            }
        } else {
            return image.kf.normalized.kf.webpRepresentation()
        }
    }
    
    func image(with data: Data, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        if !data.isWebPFormat {
            var maxWidth = CGFloat.infinity
            if let width = AttachmentConfigure.maximumImageWidth { maxWidth = width }
            return data.compressAndDecoder(maxWidth: maxWidth)
        } else {
            return WebPProcessor.default.process(item: .data(data), options: options)
        }
    }
}
