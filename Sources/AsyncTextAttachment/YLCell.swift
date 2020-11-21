//
//  YLCell.swift
//  ATA test
//
//  Created by 玉垒浮云 on 2020/11/20.
//

import UIKit

open class YLCell: UITableViewCell {
    public let textView = UITextView.default()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textView)
        
        let inset = AttachmentConfigure.edgesInSuperview
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: inset.top),
            textView.leftAnchor.constraint(equalTo: leftAnchor, constant: inset.left),
            textView.rightAnchor.constraint(equalTo: rightAnchor, constant: -inset.right),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset.bottom)
        ])
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension YLCell {
    public var height: CGFloat {
        let edges = AttachmentConfigure.edgesInSuperview
        return textView.sizeThatFits(
            CGSize(
                width: AttachmentConfigure.attachmentWidth,
                height: CGFloat.infinity
            )
        ).height + edges.top + edges.bottom
    }
}
