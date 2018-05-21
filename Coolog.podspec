#
# Be sure to run `pod lib lint Coolog.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Coolog'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Coolog.'

  s.description      = <<-DESC
  A expandable log framework for iOS.
                       DESC

  s.homepage         = 'https://github.com/yao.li/Coolog'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yao.li' => 'yao.li@cootek.cn' }
  s.source           = { :git => 'https://github.com/RyanLeeLY/Coolog.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Coolog/Classes/**/*'
  
  s.dependency 'PocketSocket'
end
