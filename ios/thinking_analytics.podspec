#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint thinking_analytics.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'thinking_analytics'
  s.version          = '1.2.0'
  s.summary          = 'Thinking Analytics Flutter plugin'
  s.description      = <<-DESC
Official Thinking Analytics Flutter plugin. Used to tracking events and user data to Thinking Analytics.
                       DESC

  s.homepage         = 'https://www.thinkingdata.cn'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Thinking Analytics' => 'sdk@thinkingdata.cn' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'ThinkingSDK', "2.5.5"
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
