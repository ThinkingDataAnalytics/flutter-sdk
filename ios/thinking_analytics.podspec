#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint thinking_analytics.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'thinking_analytics'
  s.version          = '3.3.3'
  s.summary          = 'Thinking Analytics Flutter plugin'
  s.description      = <<-DESC
Official Thinking Analytics Flutter plugin. Used to tracking events and user data to Thinking Analytics.
                       DESC

  s.homepage         = 'https://www.thinkingdata.cn'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Thinking Analytics' => 'sdk@thinkingdata.cn' }
  s.source           = { :path => '.' }
  s.source_files = 'thinking_analytics/Sources/thinking_analytics/**/*.{h,m}'
  s.public_header_files = 'thinking_analytics/Sources/thinking_analytics/include/**/*.h'
  s.dependency 'Flutter'
  # iOS native SDK 3.4.8 (ThinkingDataCore pulled transitively)
  s.dependency 'ThinkingSDK', '3.4.8'
  s.dependency 'TAThirdParty', '0.3.5'
  s.platform = :ios, '12.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
