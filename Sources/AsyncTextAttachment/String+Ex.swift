//
//  String+Ex.swift
//  ATA test
//
//  Created by 玉垒浮云 on 2020/11/18.
//

import Highlightr
import YLRegex

extension String {
    func toGistAPI() -> String {
        let regex = try! NSRegularExpression(pattern: #"\w/[^/]+/(\w+)"#, options: [])
        let match = regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count))!
        let range = Range(match.range(at: 1), in: self)
        return "https://api.github.com/gists/" + String(self[range!])
    }
    
    mutating func toAttributedString(language: String) -> NSAttributedString {
        if last == "\n" {
            self = String(dropLast())
        }
        
        let highlightr = Highlightr()!
        highlightr.setTheme(to: AttachmentConfigure.Gist.theme.rawValue)
        
        let highlightedCode = highlightr.highlight(self, as: language, fastRender: true)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: AttachmentConfigure.Gist.font,
            .paragraphStyle: AttachmentConfigure.Gist.paragraph
        ]
        let mutableAttributedString = NSMutableAttributedString(attributedString: highlightedCode!)
        mutableAttributedString.addAttributes(
            attributes,
            range: NSRange(location: 0, length: mutableAttributedString.length)
        )
        
        return mutableAttributedString
    }
    
    var destionation: String? {
        guard
            let match = firstMatch(pattern: #"https://([^/]+)/(.*)"#),
            let website = match.captures[0],
            let path = match.captures[1]
        else { return nil }
        
        switch website {
        case "www.youtube.com":
            if path.hasPrefix("embed/") {
                return self
            } else if let id = path.firstMatch(pattern: #"=([^&]+)"#)?.captures[0] {
                return "https://www.youtube.com/embed/" + id
            } else {
                return nil
            }
        case "www.bilibili.com":
            guard
                let match = path.firstMatch(pattern: #"/(\w\w)(\w+)"#),
                let format = match.captures[0],
                let id = match.captures[1]
            else { return nil }
            
            let part = (format == "av") ? "?aid=" : "?bvid="
            return "https://player.bilibili.com/player.html" + part + id
        case "vimeo.com":
            guard
                let match = path.firstMatch(pattern: #"(\d+)"#),
                let id = match.captures[0]
            else { return nil }
            
            return "https://player.vimeo.com/video/" + id
        default:
            return nil
        }
    }
}
