//
//  VideoAttachment.swift
//  ATA test
//
//  Created by 玉垒浮云 on 2020/11/19.
//

import WebKit

public class VideooAttachment: NSTextAttachment {
    public weak var containerView: UITextView?
    public weak var delegate: AttachmentDelegate?
    
    private let webView = WKWebView()
    
    init(url: String) {
        super.init(data: nil, ofType: nil)
        
        guard let destination = url.destionation.flatMap(URL.init) else { return }
        self.webView.load(URLRequest(url: destination))
        self.webView.navigationDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func image(
        forBounds imageBounds: CGRect,
        textContainer: NSTextContainer?,
        characterIndex charIndex: Int
    ) -> UIImage? {
        nil
    }
    
    public override func attachmentBounds(
        for textContainer: NSTextContainer?,
        proposedLineFragment lineFrag: CGRect,
        glyphPosition position: CGPoint,
        characterIndex charIndex: Int
    ) -> CGRect {
        let width = lineFrag.width
        webView.frame = CGRect(origin: position, size: CGSize(width: width, height: 0.75 * width))
        
        return webView.bounds
    }
    
    deinit {
        webView.removeFromSuperview()
    }
}

extension VideooAttachment: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        containerView?.setNeedsDisplay()
        webView.removeFromSuperview()
        containerView?.addSubview(webView)
    }
}
