Pod::Spec.new do |s|
  s.name         = "AsyncTextAttachment"
  s.version      = "2.0.1"
  s.summary      = "Load web images, videos and gist code on UITextView."
  s.homepage     = "https://github.com/YuLeiFuYun/AsyncTextAttachment"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "YuLeiFuYun" => "yuleifuyunn@gmail.com" }
  s.swift_version = "5.1"
  s.platform     = :ios, "13.0"	
  s.source       = { :git => "https://github.com/YuLeiFuYun/AsyncTextAttachment.git", :tag => s.version }
  s.source_files = "Sources/AsyncTextAttachment/*.swift"
  s.dependency 'Kingfisher', '~> 5.0'
  s.dependency 'KingfisherWebP'
  s.dependency 'Highlightr'
  s.dependency 'YLRegex'
end
