Pod::Spec.new do |s|
  s.name                  = "PDFReader"
  s.version               = "2.4.1.1"
  s.license               = { :type => "MIT" }
  s.homepage              = "https://github.com/Alua-Kinzhebayeva/iOS-PDF-Reader"
  s.author                = { "Alua Kinzhebayeva" => "alua.kinzhebayeva@gmail.com" }
  s.summary               = "PDF Reader for iOS written in Swift"
  s.source                = { :git => "https://github.com/Codas/iOS-PDF-Reader.git", :tag => s.version.to_s }
  s.ios.deployment_target = "9.0"
  s.source_files          = "Sources/Classes/*.swift"
  s.resources             = "Sources/Assets/*.storyboard"
  s.requires_arc          = true
  s.dependency 'RxSwift', '~> 3.6.0'
  s.dependency 'RxCocoa', '~> 3.5.0'
  s.dependency 'Reusable', '~> 4.0.0'
end
