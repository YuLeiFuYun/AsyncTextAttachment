//
//  Data+Ex.swift
//  ATA test
//
//  Created by 玉垒浮云 on 2020/11/18.
//

import UIKit

extension Data {
    func compressAndDecoder(maxWidth: CGFloat) -> UIImage? {
        if !isAnimated && imageSize.width > maxWidth {
            let ratio = maxWidth / imageSize.width
            let size = CGSize(width: maxWidth, height: imageSize.height * ratio)
            return downsampleAndDecoder(pointSize: size)
        } else {
            return decoder(maxWidth: maxWidth)
        }
    }
    
    func downsampleAndDecoder(pointSize: CGSize) -> UIImage? {
        guard
            let imageSource = CGImageSourceCreateWithData(
                self as CFData, [kCGImageSourceShouldCache: false] as CFDictionary
            )
        else { return nil }
        
        let ratio = Swift.min(pointSize.width / imageSize.width, 0.95)
        let maxDimensionInPixels = Swift.max(imageSize.width, imageSize.height) * ratio
        let downsampleOptions = [
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true
        ] as CFDictionary
        guard
            let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)
        else { return nil }
        return UIImage(cgImage: downsampledImage)
    }
    
    func decoder(maxWidth: CGFloat) -> UIImage? {
        let options = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(self as CFData, options) else {
            return nil
        }
        
        let frameDurations = imageSource.frameDurations
        if isAnimated {
            var images: [UIImage] = []
            for i in 0..<frameDurations.count {
                let frameDuration = frameDurations[i]
                var frameProperties = [
                    kCGImagePropertyGIFDictionary : [
                        kCGImagePropertyGIFDelayTime: frameDuration,
                        kCGImagePropertyGIFUnclampedDelayTime: frameDuration
                    ]
                ]
                if imageFormat == .png {
                    frameProperties = [
                        kCGImagePropertyPNGDictionary: [
                            kCGImagePropertyAPNGUnclampedDelayTime: frameDuration,
                            kCGImagePropertyAPNGDelayTime: frameDuration
                        ]
                    ]
                }
                
                guard
                    let cgImage = CGImageSourceCreateImageAtIndex(
                        imageSource, i, frameProperties as CFDictionary
                    )
                else { return nil }
                
                let image = UIImage(cgImage: cgImage)
                images.append(image)
            }
            
            let duration = imageSource.frameDurations.reduce(0, +)
            return UIImage.animatedImage(with: images, duration: duration)
        } else {
            let options = [kCGImageSourceShouldCacheImmediately: true] as CFDictionary
            guard
                let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, options)
            else { return nil }
            
            return UIImage(cgImage: cgImage)
        }
    }
}

extension Data {
    enum ImageFormat {
        case jpg, png, gif, unknown
    }
    
    var imageFormat: ImageFormat {
        var headerData = [UInt8](repeating: 0, count: 3)
        self.copyBytes(to: &headerData, from:(0..<3))
        let hexString = headerData.reduce("") { $0 + String(($1&0xFF), radix:16) }.uppercased()
        var imageFormat = ImageFormat.unknown
        switch hexString {
        case "FFD8FF":
            imageFormat = .jpg
        case "89504E":
            imageFormat = .png
        case "474946":
            imageFormat = .gif
        default:
            imageFormat = .unknown
        }
        
        return imageFormat
    }
    
    var isAnimated: Bool {
        guard
            let imageSource = CGImageSourceCreateWithData(
                self as CFData, [kCGImageSourceShouldCache: false] as CFDictionary
            )
        else { return false }
        
        return CGImageSourceGetCount(imageSource) > 1
    }
    
    var imageSize: CGSize {
        guard
            let imageSource = CGImageSourceCreateWithData(
                self as CFData, [kCGImageSourceShouldCache: false] as CFDictionary
            ),
            let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [AnyHashable: Any],
            let imageHeight = properties[kCGImagePropertyPixelHeight] as? CGFloat,
            let imageWidth = properties[kCGImagePropertyPixelWidth] as? CGFloat
        else { return .zero }
        
        return CGSize(width: imageWidth, height: imageHeight)
    }
}

extension CGImageSource {
    func frameDurationAtIndex(_ index: Int) -> Double {
        var frameDuration = Double(0.1)
        if let frameProperties = CGImageSourceCopyPropertiesAtIndex(self, index, nil) as? [AnyHashable: Any] {
            if let gifProperties = frameProperties[kCGImagePropertyGIFDictionary] as? [AnyHashable: Any] {
                if let unclampedDuration = gifProperties[kCGImagePropertyGIFUnclampedDelayTime] as? Double {
                    frameDuration = unclampedDuration
                } else {
                    if let clampedDuration = gifProperties[kCGImagePropertyGIFDelayTime] as? Double {
                        frameDuration = clampedDuration
                    }
                }
            } else if let apngProperties = frameProperties[kCGImagePropertyPNGDictionary] as? [AnyHashable: Any] {
                if let unclampedDuration = apngProperties[kCGImagePropertyAPNGUnclampedDelayTime] as? Double {
                    frameDuration = unclampedDuration
                } else {
                    if let clampedDuration = apngProperties[kCGImagePropertyAPNGDelayTime] as? Double {
                        frameDuration = clampedDuration
                    }
                }
            }  else {
                return frameDuration
            }
        }
        
        return frameDuration
    }
    
    var frameDurations: [Double] {
        let frameCount = CGImageSourceGetCount(self)
        return (0..<frameCount).map { self.frameDurationAtIndex($0) }
    }
}
