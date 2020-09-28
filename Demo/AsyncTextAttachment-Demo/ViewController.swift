//
//  ViewController.swift
//  AsyncTextAttachment-Demo
//
//  Created by 玉垒浮云 on 2020/9/28.
//

import AsyncTextAttachment
import UIKit

let testImageURLs = [
    [
        URL(string: "https://misc.aotu.io/ONE-SUNDAY/SteamEngine.png")!,
        URL(string: "https://mathiasbynens.be/demo/animated-webp-supported.webp")!,
        URL(string: "https://images.unsplash.com/photo-1599574933129-6972e5c5736b?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=1275&q=80")!
    ],
    [
        URL(string: "https://misc.aotu.io/ONE-SUNDAY/BladeRunner.gif")!,
        URL(string: "https://upload.wikimedia.org/wikipedia/commons/a/a1/Johnrogershousemay2020.webp")!,
        URL(string: "https://images.unsplash.com/photo-1599008071146-7bff138d31eb?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=900&q=60")
    ],
    [
        URL(string: "https://images.unsplash.com/photo-1599517483292-33b8f64cc697?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=900&q=60")!,
        URL(string: "https://images.unsplash.com/photo-1599470542516-b34994b6f35d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=900&q=60")!,
        URL(string: "https://s1.ax1x.com/2018/05/01/CJBYOf.png")!
    ],
    [
        URL(string: "https://images.unsplash.com/photo-1599466828730-be6f07d434c1?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=962&q=80")!,
        URL(string: "https://media.giphy.com/media/ZeWsD09o2wV6SU3H11/giphy.gif")!,
        URL(string: "https://images.unsplash.com/photo-1596236561031-188b0c76e60a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2100&q=80")!
    ]
]

let imageTypes = [
    [
        "APNG\n",
        "\nAnimated WebP\n",
        "\nJPEG\n"
    ],
    [
        "Gif\n",
        "\nWebP\n",
        "\nJPEG\n"
    ],
    [
        "JPEG\n",
        "\nJPEG\n",
        "\nPNG\n"
    ],
    [
        "JPEG\n",
        "\nGif\n",
        "\nJPEG\n"
    ]
]

class ViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.frame = view.frame
        tableView.estimatedRowHeight = 1000
        tableView.dataSource = self
        tableView.delegate = self
        tableView.prefetchDataSource = self
        tableView.register(CustomCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()
    
    var cachedHeightDict: [IndexPath: CGFloat] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AttachmentConfigure.maximumImageWidth = UIScreen.main.bounds.width - 20
        view.addSubview(tableView)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CustomCell
        
        let mAttributedString = NSMutableAttributedString()
        mAttributedString.appendAttributedString(with: imageTypes[indexPath.row][0], font: .systemFont(ofSize: 25))
        mAttributedString.appendAsyncTextAttachment(with: testImageURLs[indexPath.row][0]!, containerView: cell.textView, delegate: self, info: indexPath)
        mAttributedString.appendAttributedString(with: imageTypes[indexPath.row][1])
        mAttributedString.appendAsyncTextAttachment(with: testImageURLs[indexPath.row][1]!, containerView: cell.textView, delegate: self, info: indexPath)
        mAttributedString.appendAttributedString(with: imageTypes[indexPath.row][2])
        mAttributedString.appendAsyncTextAttachment(with: testImageURLs[indexPath.row][2]!, containerView: cell.textView, delegate: self, info: indexPath)
        cell.textView.attributedText = mAttributedString
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cachedHeightDict[indexPath] ?? 200
    }
}

extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.reduce([]) { (result, indexPath) -> [URL] in
            result + testImageURLs[indexPath.row].map { $0! }
        }
        
        AttachmentPrefetcher(urls: urls).star()
    }
}

extension ViewController: AsyncTextAttachmentDelegate {
    func textAttachmentDidLoadImage(_ textAttachment: AsyncTextAttachment, info: Any?) {
        guard
            let indexPath = info as? IndexPath,
            let cell = tableView.cellForRow(at: indexPath) as? CustomCell
        else { return }
        
        cachedHeightDict[indexPath] = cell.textView.intrinsicContentSize.height + 20
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension NSMutableAttributedString {
    func appendAttributedString(with string: String, font: UIFont = .systemFont(ofSize: 18)) {
        let attributedString = NSAttributedString(string: string)
        append(attributedString)
        addAttribute(.font, value: font, range: NSRange(location: length - attributedString.length, length: attributedString.length))
    }
    
    func appendAsyncTextAttachment(with url: URL, containerView: UITextView, delegate: AsyncTextAttachmentDelegate, info: Any? = nil) {
        let imageAttachment = AsyncTextAttachment(imageURL: url)
        imageAttachment.containerView = containerView
        imageAttachment.delegate = delegate
        imageAttachment.info = info
        append(NSAttributedString(attachment: imageAttachment))
    }
}

