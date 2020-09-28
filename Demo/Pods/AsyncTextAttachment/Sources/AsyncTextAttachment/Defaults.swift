//
//  Defaults.swift
//  AsyncTextAttachment
//
//  Created by 玉垒浮云 on 2020/9/27.
//

import Foundation
import CoreGraphics

extension UserDefaults {
    static var attachment: UserDefaults {
        let combined = UserDefaults.standard
        combined.addSuite(named: "group.asynctextattachment.app")
        return combined
    }
}

struct Defaults {
    private static let userDefault = UserDefaults.attachment
    
    static func set(_ value: CGSize, forKey defaultName: URL) {
        let cachedValue = [value.width, value.height]
        userDefault.setValue(cachedValue, forKey: "size-\(defaultName.absoluteString)")
    }
    
    static func set(_ downsample: Bool, forKey defaultName: URL) {
        userDefault.setValue(downsample, forKey: "bool-\(defaultName.absoluteString)")
    }
    
    static func size(forKey defaultName: URL) -> CGSize? {
        if let cachedValue = userDefault.value(forKey: "size-\(defaultName.absoluteString)") as? [CGFloat] {
            return CGSize(width: cachedValue[0], height: cachedValue[1])
        }
        
        return nil
    }
    
    static func downsample(forKey defaultName: URL) -> Bool {
        return userDefault.bool(forKey: "bool-\(defaultName.absoluteString)")
    }
    
    static func clearUserData() {
        UserDefaults.standard.removeSuite(named: "group.asynctextattachment.app")
    }
}
