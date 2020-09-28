//
//  AsyncTextAttachment.swift
//  AsyncTextAttachment
//
//  Created by 玉垒浮云 on 2020/9/27.
//

import Kingfisher
import KingfisherWebP

public protocol AsyncTextAttachmentDelegate: NSObject {
    func textAttachmentWillLoadImage(_ textAttachment: AsyncTextAttachment, task: AttachmentTask)
    func textAttachmentDidLoadImage(_ textAttachment: AsyncTextAttachment, info: Any?)
}

extension AsyncTextAttachmentDelegate {
    func textAttachmentWillLoadImage(_ textAttachment: AsyncTextAttachment, task: AttachmentTask) { }
}

public class AsyncTextAttachment: NSTextAttachment {
    public var imageURL: URL
    
    private let imageView = AnimatedImageView()
    
    private var imageViewFrame: CGRect = .zero
    
    private var cachedSize: CGSize?
    
    private var originalImageSize = CGSize(width: 1, height: 1)
    
    public var info: Any?
    
    public weak var delegate: AsyncTextAttachmentDelegate?
    
    public weak var containerView: UITextView?
    
    public override var image: UIImage? {
        didSet {
            guard let image = image else { return }
            originalImageSize = image.size
        }
    }
    
    public init(imageURL: URL, placeholder: UIImage? = nil, failueImage: UIImage? = nil) {
        self.imageURL = imageURL
        super.init(data: nil, ofType: nil)
        
        imageView.contentMode = .scaleAspectFit
        DispatchQueue.global().async {
            let options: KingfisherOptionsInfo = [
                .processor(CustomProcessor.default),
                .cacheSerializer(CustomCacheSerializer.default),
                .transition(.fade(0.3)),
                .onFailureImage(failueImage)
            ]
            if
                AttachmentConfigure.displaySize == nil,
                let size = Defaults.size(forKey: self.imageURL)
            {
                self.cachedSize = size
                
                if Int.random(in: 1...300) == 100 {
                    guard ImageCache.default.isCached(forKey: self.imageURL.absoluteString) else { return }
                    Defaults.clearUserData()
                }
            }
            
            DispatchQueue.main.async {
                let task = self.imageView.kf.setImage(
                    with: imageURL,
                    placeholder: placeholder,
                    options: options,
                    completionHandler:  {
                        [weak self] (result) in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let value):
                            self.image = value.image
                            self.updateLayoutAndDisplay()
                        case .failure(let error):
                            print("error: \(error)")
                        }
                    }
                )
                
                self.delegate?.textAttachmentWillLoadImage(self, task: AttachmentTask(task: task))
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func image(
        forBounds imageBounds: CGRect,
        textContainer: NSTextContainer?,
        characterIndex charIndex: Int
    ) -> UIImage? {
        image ?? imageView.image
    }
    
    public override func attachmentBounds(
        for textContainer: NSTextContainer?,
        proposedLineFragment lineFrag: CGRect,
        glyphPosition position: CGPoint,
        characterIndex charIndex: Int
    ) -> CGRect {
        var size: CGSize
        if let displaySize = AttachmentConfigure.displaySize {
            size = displaySize
        } else if let cachedSize = cachedSize {
            size = cachedSize
        } else {
            let maxWidth = min(lineFrag.width, originalImageSize.width)
            let factor = maxWidth / originalImageSize.width
            let width = originalImageSize.width * factor
            let height = originalImageSize.height * factor
            size = CGSize(width: width, height: height)
            
            DispatchQueue.global().async {
                if self.imageView.image != nil {
                    Defaults.set(size, forKey: self.imageURL)
                }
            }
        }
        
        imageViewFrame = CGRect(origin: position, size: size)
        return CGRect(origin: .zero, size: size)
    }
    
    deinit {
        imageView.removeFromSuperview()
    }
}

private extension AsyncTextAttachment {
    func updateLayoutAndDisplay() {
        guard let textView = containerView else { return }
        
        //  使用 GCD 是为了防止出现滚动时 cell 闪烁
        DispatchQueue.main.async {
            if AttachmentConfigure.displaySize == nil && self.cachedSize == nil {
                textView.layoutManager.setNeedsLayout(forAttachment: self)
            } else {
                textView.layoutManager.setNeedsDisplay(forAttachment: self)
            }
            
            self.delegate?.textAttachmentDidLoadImage(self, info: self.info)
            if let image = self.imageView.image, image.images != nil {
                self.imageView.frame = self.imageViewFrame
                self.perform(#selector(self.display), with: nil, afterDelay: 0, inModes: [.default])
            }
        }
    }
    
    @objc func display() {
        containerView?.addSubview(self.imageView)
    }
}
