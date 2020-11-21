//
//  UIImage+addBorder.swift
//  ATA test
//
//  Created by 玉垒浮云 on 2020/11/20.
//

import UIKit

extension UIImage {
    public func addBorder(edges: UIEdgeInsets) -> UIImage? {
        let finalSize = CGSize(
            width: size.width + edges.left + edges.right,
            height: size.height + edges.top + edges.bottom
        )
        UIGraphicsBeginImageContextWithOptions(finalSize, false, UIScreen.main.scale)
        draw(in: CGRect(x: edges.left, y: edges.top, width: size.width, height: size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
