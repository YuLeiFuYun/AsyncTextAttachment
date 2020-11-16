//
//  CustomProcessor.swift
//  AsyncTextAttachment
//
//  Created by 玉垒浮云 on 2020/9/27.
//

import Kingfisher
import KingfisherWebP

public struct CustomProcessor: ImageProcessor {
    public var identifier = "come.kingfisher.ylcustomprocessor"
    public static let `default` = CustomProcessor()
    private init() {}
    
    public func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            return image
        case .data(let data):
            if data.isWebPFormat {
                return KingfisherWrapper<KFCrossPlatformImage>.image(
                    webpData: data,
                    scale: options.scaleFactor,
                    onlyFirstFrame: options.onlyLoadFirstFrame
                )
            } else {
                var maxWidth = CGFloat.infinity
                if let width = AttachmentConfigure.maximumImageWidth { maxWidth = width }
                return data.compressAndDecoder(maxWidth: maxWidth)
            }
        }
    }
}
