//
//  CustomProcessor.swift
//  ATA test
//
//  Created by 玉垒浮云 on 2020/11/18.
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
                if let width = AttachmentConfigure.Image.maxWidth { maxWidth = width }
                return data.compressAndDecoder(maxWidth: maxWidth)
            }
        }
    }
}
