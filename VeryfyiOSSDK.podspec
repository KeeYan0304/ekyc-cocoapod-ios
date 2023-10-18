Pod::Spec.new do |s|
  s.name             = 'VeryfyiOSSDK'
  s.version          = '0.1.2'
  s.summary          = 'This is a meaningful summary pod of VeryfyiOSSDK.'
  s.description      = <<-DESC
'The veryfy iOS SDK is a software development tool which connect users to EKYC services and perform verification including identity card and facial recognition to validate a person identity'
                       DESC

  s.homepage         = 'https://github.com/KeeYan0304/ekyc-cocoapod-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Kee Chun Yan' => 'chunyan.kee@veryfyglobal.tech' }
  s.source           = { :git => 'https://github.com/KeeYan0304/ekyc-cocoapod-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files = 'Classes/**/*'
#  s.vendored_frameworks =
  s.swift_version = '5.0'
end
