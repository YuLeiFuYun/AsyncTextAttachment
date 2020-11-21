//
//  AttachmentDelegate.swift
//  ATA test
//
//  Created by 玉垒浮云 on 2020/11/18.
//

import Kingfisher

public protocol AttachmentTask {
    func cancel()
}

extension DownloadTask: AttachmentTask { }

extension URLSessionTask: AttachmentTask { }

public protocol AttachmentDelegate: NSObject {
    func textAttachmentWillLoad(_ textAttachment: NSTextAttachment, task: AttachmentTask?)
    func textAttachmentDidLoad(_ textAttachment: NSTextAttachment, indexPath: IndexPath?)
}

extension AttachmentDelegate {
    public func textAttachmentWillLoad(_ textAttachment: NSTextAttachment, task: AttachmentTask?) { }
}


