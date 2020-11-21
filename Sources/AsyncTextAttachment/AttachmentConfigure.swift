//
//  AttachmentConfigure.swift
//  ATA test
//
//  Created by 玉垒浮云 on 2020/11/18.
//

import UIKit

public enum GistTheme: String {
    case google = "googlecode"
    case github = "github-gist"
    case xcode = "xcode"
    case schoolbook = "school-book"
    case vs = "vs"
    case atelier = "atelier-sulphurpool-light"
}

public enum AttachmentConfigure {
    // 当前控制器
    public static weak var currentController: UIViewController?
    // 与父视图的边缘间距
    public static var edgesInSuperview = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    // attachment 的宽度
    public static var attachmentWidth = UIScreen.main.bounds.width - AttachmentConfigure.edgesInSuperview.left - AttachmentConfigure.edgesInSuperview.right
    
    public enum Image {
        public static var maxWidth: CGFloat?
        public static var displaySize: CGSize?
        // 图片向下偏移量
        public static var downwardOffset: CGFloat = 0
    }
    
    public enum Gist {
        // 背景色
        public static var bgColor = UIColor.white
        // code theme
        public static var theme: GistTheme = .github
        // gist code 的字体
        public static var font = UIFont(name: "Menlo", size: 15)!
        // lineLabel 字体颜色
        public static var lineTextColor = UIColor(white: 0.4, alpha: 1)
        // 边框颜色
        public static var borderColor = UIColor(white: 0.8, alpha: 1).cgColor
        // 底部 info text 的字体大小
        public static var bottomTextFontSize: CGFloat = 11
        // code 容器 scroll view 的最大高度
        public static var maxHeight: CGFloat = 550
        // 四周圆角
        public static var cornerRadius: CGFloat = 7
        // attachment 的上下空隙
        public static var topSpace: CGFloat = 15
        public static var bottomSpace: CGFloat = 0
        // left 为 lineLabel 与 super view 的边距，top、right、bottom 为 gist code 与 super view 的边距
        public static var inset = UIEdgeInsets(top: 20, left: 10, bottom: 15, right: 15)
        // 底部 view 的 inset
        public static var bottomViewInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        // lineLabel 与 code 的间距
        public static var lcSpace: CGFloat = 15
        // 设置行间距
        public static var paragraph: NSParagraphStyle = {
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 5
            return paragraph
        }()
    }
}
