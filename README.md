## 特性

- [x] 支持多种图片格式，包括 PNG、JPEG、WebP、SVG、Gif、APNG 和 Animated WebP。
- [x] 支持加载视频，支持的网站包括 YouTube、Vimeo 和哔哩哔哩。
- [x] 支持加载 Gist code，可对界面进行自定义。



## 环境要求

* iOS 13.0+
* Swift 5.1+



## 安装

### Cocoapods

在 `podfile` 配置：

```ruby
platform :ios, '13.0'
use_frameworks!

target 'MyApp' do
  # your other pod
  # ...
  pod 'AsyncTextAttachment'
end
```



## 使用示例

首先要做如下设置：

```swift
// 当前控制器
AttachmentConfigure.currentController = self
// 与父视图的边缘间距。默认是 UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
AttachmentConfigure.edgesInSuperview = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
// attachment 的宽度
// 默认是 UIScreen.main.bounds.width - AttachmentConfigure.edgesInSuperview.left - AttachmentConfigure.edgesInSuperview.right
AttachmentConfigure.attachmentWidth = ...
```

#### 图片

待完善……



## License

AsyncTextAttachment is released under the MIT license. See LICENSE for details.