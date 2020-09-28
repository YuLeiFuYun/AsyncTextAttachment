//
//  AttachmentTask.swift
//  AsyncTextAttachment
//
//  Created by 玉垒浮云 on 2020/9/27.
//

import Kingfisher

public struct AttachmentTask {
    var task: DownloadTask?
    
    init(task: DownloadTask?) {
        self.task = task
    }
    
    public func cancel() {
        task?.cancel()
    }
}
