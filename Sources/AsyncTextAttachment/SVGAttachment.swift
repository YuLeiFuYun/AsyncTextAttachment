//
//  SVGAttachment.swift
//  ATA test
//
//  Created by 玉垒浮云 on 2020/11/20.
//

import SafariServices
import WebKit

public class SVGAttachment: NSTextAttachment {
    public weak var containerView: UITextView?
    public weak var delegate: AttachmentDelegate?
    public var indexPath: IndexPath?
    
    private let webView = WKWebView()
    private var webViewSize = CGSize(width: 20, height: 20)
    
    public init(svgURL: String, link: String? = nil) {
        super.init(data: nil, ofType: nil)
        
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false
        
        let svgString = createSVGString(svgURL: svgURL, link: link)
        webView.loadHTMLString(svgString, baseURL: nil)
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
        webView.frame = CGRect(origin: position, size: webViewSize)
        return CGRect(origin: CGPoint(x: 0, y: -3), size: webView.bounds.size)
    }
    
    deinit {
        webView.removeFromSuperview()
    }
}

extension SVGAttachment: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.removeFromSuperview()
        containerView?.addSubview(webView)
        
        webView.evaluateJavaScript("document.readyState") { (complete, error) in
            guard complete != nil else { return }
            
            webView.evaluateJavaScript("[document.getElementById('svg').clientWidth,document.getElementById('svg').clientHeight]") {
                [weak self] (size, error) in
                guard let self = self, let size = size as? [CGFloat] else { return }
                
                let width = min(AttachmentConfigure.attachmentWidth, size[0])
                let factor = width / size[0]
                let height = size[1] * factor
                self.webViewSize = CGSize(width: width, height: height)
                
                let scale: CGFloat = 4
                webView.evaluateJavaScript("document.getElementById('svg').width = '\(width * scale)';document.getElementById('svg').height = '\(height * scale)';", completionHandler: nil)
                self.delegate?.textAttachmentDidLoad(self, indexPath: self.indexPath)
            }
        }
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url, url.scheme == "https" else {
            return decisionHandler(.allow)
        }
        
        let sfVC = SFSafariViewController(url: url)
        AttachmentConfigure.currentController?.present(sfVC, animated: true, completion: nil)
        decisionHandler(.cancel)
    }
}

extension SVGAttachment {
    private func createSVGString(svgURL: String, link: String?) -> String {
        if let link = link {
            return """
            <a href="\(link)" rel="nofollow"><img alt="" src="\(svgURL)" id="svg" /></a>"
            """
        } else {
            return """
            <img alt="" src="\(svgURL)" id="svg" />"
            """
        }
    }
}
