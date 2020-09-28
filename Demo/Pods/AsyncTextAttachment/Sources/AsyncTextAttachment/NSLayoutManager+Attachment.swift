//
//  NSLayoutManager+Attachment.swift
//  AsyncTextAttachment
//
//  Created by 玉垒浮云 on 2020/9/27.
//

import UIKit

extension NSLayoutManager {
    func rangesForAttachment(attachment: NSTextAttachment) -> [NSRange]? {
        guard let attributedString = self.textStorage else { return nil }
        
        let range = NSRange(location: 0, length: attributedString.length)
        
        var refreshRanges: [NSRange] = []
        
        attributedString.enumerateAttribute(.attachment, in: range, options: []) {
            (value, effectiveRange, nil) in
            guard
                let foundAttachment = value as? NSTextAttachment,
                foundAttachment == attachment
            else { return }
            
            refreshRanges.append(effectiveRange)
        }
        
        if refreshRanges.isEmpty { return nil }
        return refreshRanges
    }
    
    /// Trigger a re-layout for an attachment
    public func setNeedsLayout(forAttachment attachment: NSTextAttachment) {
        guard let ranges = rangesForAttachment(attachment: attachment) else { return }
        for range in ranges.reversed() {
            self.invalidateLayout(forCharacterRange: range, actualCharacterRange: nil)
            self.invalidateDisplay(forCharacterRange: range)
        }
    }
    
    /// Trigger a re-display for an attachment
    public func setNeedsDisplay(forAttachment attachment: NSTextAttachment) {
        guard let ranges = rangesForAttachment(attachment: attachment) else { return }
        for range in ranges.reversed() {
            self.invalidateDisplay(forCharacterRange: range)
        }
    }
}
