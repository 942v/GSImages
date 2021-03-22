Pod::Spec.new do |s|
  s.name             = 'GSImages'
  s.version          = '0.1.0'
  s.summary          = 'Image downloader'
  s.description      = <<-DESC
  GS Image downloader uses NSCache and disk storage to provide a fast and persisted images repository
                       DESC
  s.homepage         = 'https://github.com/942v/GSImages'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Guillermo Sáenz' => 'gsaenz@proatomicdev.com' }
  s.source           = { :git => 'https://github.com/942v/GSImages.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/942v'
  s.ios.deployment_target = '10.0'
  
  s.source_files = 'GSImages/Classes/**/*'
  s.swift_version = '5.1'
  s.frameworks = 'UIKit'
  s.dependency 'PromiseKit'
end
