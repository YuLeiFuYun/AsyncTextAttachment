//
//  GistAttachment.swift
//  ATA test
//
//  Created by 玉垒浮云 on 2020/11/18.
//

import Kingfisher
import SafariServices

public class GistAttachment: NSTextAttachment {
    public weak var containerView: UITextView?
    public weak var delegate: AttachmentDelegate? {
        didSet {
            guard
                let delegate = delegate,
                let indexPath = indexPath
            else { return }
            
            var urls = [URL(string: url)!]
            if let gistURLs = delegate.gistPrefetchDict[indexPath] {
                urls = gistURLs + urls
            }
            
            delegate.gistPrefetchDict[indexPath] = urls
        }
    }
    public var indexPath: IndexPath? {
        didSet {
            guard
                let delegate = delegate,
                let indexPath = indexPath
            else { return }
            
            var urls = [URL(string: url)!]
            if let gistURLs = delegate.gistPrefetchDict[indexPath] {
                urls = gistURLs + urls
            }
            
            delegate.gistPrefetchDict[indexPath] = urls
        }
    }
    
    private let codeTextView = UITextView.default()
    private let codeContainerView = UIScrollView.codeContainer()
    private let bottomInfoView = UITextView.bottomInfoView()
    private var contentView = UIView()
    private let url: String
    
    init(url: String) {
        self.url = url
        super.init(data: nil, ofType: nil)
        
        let urlRequest = URLRequest(
            url: URL(string: url.toGistAPI())!,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 3 * 24 * 3600
        )
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, _, error) in
            guard error == nil, let self = self else { return }
            
            if let data = data, !data.isEmpty {
                guard
                    let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                    let dict = json as? [String: Any],
                    let files = dict["files"] as? [String: Any],
                    let info = files.values.first as? [String: Any],
                    let fileName = info["filename"] as? String,
                    let raw = info["raw_url"] as? String,
                    let language = info["language"] as? String,
                    var code = info["content"] as? String
                else { return }
                
                DispatchQueue.main.async {
                    let inset = AttachmentConfigure.Gist.inset
                    let attachmentWidth = AttachmentConfigure.attachmentWidth
                    self.codeTextView.attributedText = code.toAttributedString(language: language)
                    
                    let lineLabel = UILabel.line(numberOfLines: self.codeTextView.actualNumberOfLines)
                    let lineSize = lineLabel.intrinsicContentSize
                    lineLabel.frame = CGRect(
                        x: inset.left, y: inset.top,
                        width: lineSize.width, height: lineSize.height
                    )
                    self.codeContainerView.addSubview(lineLabel)
                    
                    var x = inset.left + lineSize.width + AttachmentConfigure.Gist.lcSpace
                    let codeSize = self.codeTextView.intrinsicContentSize
                    self.codeTextView.frame = CGRect(origin: CGPoint(x: x, y: inset.top), size: codeSize)
                    self.codeContainerView.addSubview(self.codeTextView)
                    
                    var codeContentSize: CGSize = .zero
                    codeContentSize.width = self.codeTextView.frame.maxX + inset.right
                    codeContentSize.height = self.codeTextView.frame.maxY + inset.bottom
                    self.codeContainerView.contentSize = codeContentSize
                    
                    let height = min(AttachmentConfigure.Gist.maxHeight, codeContentSize.height)
                    self.codeContainerView.frame = CGRect(
                        x: 0,
                        y: AttachmentConfigure.Gist.topSpace,
                        width: attachmentWidth,
                        height: height
                    )
                    
                    self.bottomInfoView.delegate = self
                    self.bottomInfoView.attributedText = self.createBottomAttributedText(
                        fileName: fileName, source: url
                    )
                    
                    let y = self.codeContainerView.frame.maxY - 1
                    let bottomInfoViewSize = self.bottomInfoView.intrinsicContentSize
                    self.bottomInfoView.frame = CGRect(
                        x: 0, y: y,
                        width: attachmentWidth, height: bottomInfoViewSize.height
                    )
                    
                    let bottomRawView = UITextView.default()
                    bottomRawView.attributedText = self.createRawAttributedText(raw: raw)
                    bottomRawView.backgroundColor = .clear
                    bottomRawView.delegate = self
                    
                    let bottomRawViewSize = bottomRawView.intrinsicContentSize
                    let bottomViewInset = AttachmentConfigure.Gist.bottomViewInset
                    x = attachmentWidth - bottomRawViewSize.width - bottomViewInset.right
                    if x > bottomInfoViewSize.width {
                        bottomRawView.frame = CGRect(
                            origin: CGPoint(x: x, y: bottomViewInset.top),
                            size: bottomRawViewSize
                        )
                        self.bottomInfoView.addSubview(bottomRawView)
                    }
                    
                    self.contentView.frame = CGRect(
                        x: inset.left,
                        y: 0,
                        width: attachmentWidth,
                        height: self.bottomInfoView.frame.maxY + AttachmentConfigure.Gist.bottomSpace
                    )
                    self.contentView.addSubview(self.codeContainerView)
                    self.contentView.addSubview(self.bottomInfoView)
                    // 为防止卡顿，gist 在 tableView 滑动停止时才会被添加到 cell，这导致 gist 在初次加载滑动时出现空白，
                    // 故用截图进行填充。截图位置有偏移，所以给截图加上边框以抵消偏移。
                    DispatchQueue.main.async {
                        let viewshot = self.contentView.asImage()
                            .addBorder(
                                edges: UIEdgeInsets(
                                    top: 0,
                                    left: 0,
                                    bottom: AttachmentConfigure.Gist.topSpace,
                                    right: 0
                                )
                            )
                        if let viewshot = viewshot {
                            ImageCache.default.store(viewshot, forKey: url)
                        }
                    }
                    
                    self.updateLayoutAndDisplay()
                }
            }
        }
        task.resume()
        
        self.delegate?.textAttachmentWillLoad(self, task: task)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func image(
        forBounds imageBounds: CGRect,
        textContainer: NSTextContainer?,
        characterIndex charIndex: Int
    ) -> UIImage? {
        ImageCache.default.retrieveImageInMemoryCache(forKey: url) ?? nil
    }
    
    public override func attachmentBounds(
        for textContainer: NSTextContainer?,
        proposedLineFragment lineFrag: CGRect,
        glyphPosition position: CGPoint,
        characterIndex charIndex: Int
    ) -> CGRect {
        var frame = contentView.frame
        frame.origin.y = lineFrag.origin.y
        contentView.frame = frame
        
        return contentView.bounds
    }
    
    deinit {
        contentView.removeFromSuperview()
        
        let viewshot = contentView.asImage()
            .addBorder(
                edges: UIEdgeInsets(
                    top: 0,
                    left: 0,
                    bottom: AttachmentConfigure.Gist.topSpace,
                    right: 0
                )
            )
        if let viewshot = viewshot {
            ImageCache.default.store(viewshot, forKey: url)
        }
    }
}

private extension GistAttachment {
    func updateLayoutAndDisplay() {
        guard let textView = containerView else { return }
        
        DispatchQueue.main.async {
            textView.layoutManager.setNeedsLayout(forAttachment: self)
            self.delegate?.textAttachmentDidLoad(self, indexPath: self.indexPath)
            self.perform(#selector(self.display), with: nil, afterDelay: 0, inModes: [.default])
        }
    }
    
    @objc func display() {
        containerView?.superview?.addSubview(contentView)
    }
    
    func createBottomAttributedText(fileName: String, source: String) -> NSAttributedString {
        let mutableAttributedString = NSMutableAttributedString()
        
        let fontSize = AttachmentConfigure.Gist.bottomTextFontSize
        var attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: fontSize),
            .link: URL(string: source)!
        ]
        var attributedString = NSAttributedString(string: fileName, attributes: attributes)
        mutableAttributedString.append(attributedString)
        
        attributes = [.font: UIFont.systemFont(ofSize: fontSize)]
        attributedString = NSAttributedString(string: " hosted with ❤ by ", attributes: attributes)
        mutableAttributedString.append(attributedString)
        
        attributes = [
            .font: UIFont.boldSystemFont(ofSize: fontSize),
            .link: URL(string: "https://github.com/")!
        ]
        attributedString = NSAttributedString(string: "GitHub", attributes: attributes)
        mutableAttributedString.append(attributedString)
        
        return mutableAttributedString
    }
    
    func createRawAttributedText(raw: String) -> NSAttributedString {
        let font = UIFont.boldSystemFont(ofSize: AttachmentConfigure.Gist.bottomTextFontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .link: URL(string: raw)!]
        return NSAttributedString(string: "view raw", attributes: attributes)
    }
}

extension GistAttachment: UITextViewDelegate {
    public func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        let safairVC = SFSafariViewController(url: URL)
        AttachmentConfigure.currentController?.present(safairVC, animated: true, completion: nil)
        
        return false
    }
}

private extension UILabel {
    static func line(numberOfLines: Int) -> UILabel {
        let lineLabel = UILabel()
        lineLabel.numberOfLines = 0
        let text = (0..<numberOfLines).reduce("", ({ $0 + "\($1 + 1)\n" }))
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AttachmentConfigure.Gist.font,
            .foregroundColor: AttachmentConfigure.Gist.lineTextColor,
            .paragraphStyle: AttachmentConfigure.Gist.paragraph
        ]
        lineLabel.attributedText = NSAttributedString(string: text, attributes: attributes)
        lineLabel.textAlignment = .right
        
        return lineLabel
    }
}

private extension UIScrollView {
    static func codeContainer() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = AttachmentConfigure.Gist.bgColor
        scrollView.layer.cornerRadius = AttachmentConfigure.Gist.cornerRadius
        scrollView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        scrollView.layer.borderWidth = 1
        scrollView.layer.borderColor = AttachmentConfigure.Gist.borderColor
        return scrollView
    }
}
