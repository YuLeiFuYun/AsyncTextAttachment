# AsyncTextAttachment

## Requirements

* iOS 13.0+
* Swift 5.1+



## Installation

### Cocoapods

To integrate AsyncTextAttachment into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'
use_frameworks!

target 'MyApp' do
  # your other pod
  # ...
  pod 'AsyncTextAttachment'
end
```

Run `pod install` to build your dependencies.



## Usage

Create a cell that contains a UITextView:

```swift
class CustomCell: UITableViewCell {
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        ...
        contentView.addSubview(textView)
    }
    ...
}
```

You can set the maximum image width or display size:

```swift
// default is nill
AttachmentConfigure.maximumImageWidth = UIScreen.main.bounds.width - 20
// default is nill
// AttachmentConfigure.displaySize = CGSize(width: 300, height: 300)
```

Create a property to record the height of the cells:

```swift
var cachedHightDict: [IndexPath: CGFloat] = [:]
```

In `tableView(_:cellForRowAt:)` :

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: <Identifier>) as! CustomCell
        
    let mAttributedString = NSMutableAttributedString()
    ...
    let imageAttachment = AsyncTextAttachment(imageURL: url)
    // let imageAttachment = AsyncTextAttachment(imageURL: url, placeholder: placeholder, failueImage: failueImage)
    imageAttachment.containerView = cell.textView
    imageAttachment.delegate = self
    imageAttachment.info = indexPath
    mAttributedString.append(NSAttributedString(attachment: imageAttachment))
    ...
    cell.textView.attributedText = mAttributedString
    return cell
}
```

In `tableView(_:heightForRowAt:)` :

```swift
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return cachedHeightDict[indexPath] ?? 200
}
```

Implement the proxy method:

```swift
extension ViewController: AsyncTextAttachmentDelegate {
    // optional
    func textAttachmentWillLoadImage(_ textAttachment: AsyncTextAttachment, task: AttachmentTask) {
        ...
    }
    
    func textAttachmentDidLoadImage(_ textAttachment: AsyncTextAttachment, info: Any?) {
        guard
            let indexPath = info as? IndexPath,
            let cell = tableView.cellForRow(at: indexPath) as? CustomCell
        else { return }
        
        cachedHeightDict[indexPath] = cell.textView.intrinsicContentSize.height + <Top and bottom margins>
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
```

If you want to prefetch the data:

```swift
extension ViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urls = ...
        AttachmentPrefetcher(urls: urls).star()
    }
}
```



## License

AsyncTextAttachment is released under the MIT license. See LICENSE for details.