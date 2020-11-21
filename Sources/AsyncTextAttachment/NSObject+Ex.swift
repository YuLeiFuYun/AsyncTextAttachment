//
//  NSObject+Ex.swift
//  ATA test
//
//  Created by 玉垒浮云 on 2020/11/21.
//

import Kingfisher

private struct AssociatedKeys {
    static var imagePrefetchDict = "imagePrefetchDict"
    static var imagePrefetchRecords = "imagePrefetchRecords"
    static var gistPrefetchDict = "gistPrefetchDict"
    static var gistPrefetchRecords = "gistPrefetchRecords"
}

extension NSObject {
    var imagePrefetchDict: [IndexPath: [URL]] {
        get {
            guard
                self is AttachmentDelegate,
                let prefetchDict = objc_getAssociatedObject(self, &AssociatedKeys.imagePrefetchDict) as? [IndexPath: [URL]]
            else { return [:] }
            
            return prefetchDict
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.imagePrefetchDict, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var gistPrefetchDict: [IndexPath: [URL]] {
        get {
            guard
                self is AttachmentDelegate,
                let prefetchDict = objc_getAssociatedObject(self, &AssociatedKeys.gistPrefetchDict) as? [IndexPath: [URL]]
            else { return [:] }
            
            return prefetchDict
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gistPrefetchDict, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var imagePrefetchRecords: [URL: ImagePrefetcher] {
        get {
            guard
                self is AttachmentDelegate,
                let prefetchDict = objc_getAssociatedObject(self, &AssociatedKeys.imagePrefetchRecords) as? [URL: ImagePrefetcher]
            else { return [:] }
            
            return prefetchDict
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.imagePrefetchRecords, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var gistPrefetchRecords: [URL: URLSessionDataTask] {
        get {
            guard
                self is AttachmentDelegate,
                let prefetchDict = objc_getAssociatedObject(self, &AssociatedKeys.gistPrefetchRecords) as? [URL: URLSessionDataTask]
            else { return [:] }
            
            return prefetchDict
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gistPrefetchRecords, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
