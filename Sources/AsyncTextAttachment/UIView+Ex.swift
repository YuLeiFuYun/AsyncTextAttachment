//
//  UIView+Ex.swift
//  ATA test
//
//  Created by 玉垒浮云 on 2020/11/20.
//

import UIKit
 
extension UIView {
    /// 将当前视图转为 UIImage
    public func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
