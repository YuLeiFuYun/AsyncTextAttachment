//
//  UITextView+Ex.swift
//  ATA test
//
//  Created by 玉垒浮云 on 2020/11/18.
//

import UIKit

extension UITextView {
    public static func `default`() -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        
        return textView
    }
    
    static func bottomInfoView() -> UITextView {
        let textView = UITextView.default()
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        textView.layer.cornerRadius = AttachmentConfigure.Gist.cornerRadius
        textView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        textView.layer.borderWidth = 1
        textView.layer.borderColor = AttachmentConfigure.Gist.borderColor
        return textView
    }
    
    public var actualNumberOfLines: Int {
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var numberOfLines = 0, index = 0, lineRange = NSMakeRange(0, 1)

        while index < numberOfGlyphs {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange)
            numberOfLines += 1
        }
        return numberOfLines
    }
}
