#
# Be sure to run `pod lib lint FlintKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FlintKit'
  s.version          = '7.0'
  s.summary          = 'Basic categories and utilities.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Basic categories and utilities for analytics, Coe Data, Core Foundation,
Core Graphics, Core Location, Foundation, MapKit, Mobile Core Services,
Swift Standard Library, UIKit and more.
                       DESC

  s.homepage         = 'https://github.com/mckaskle/FlintKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Devin McKaskle' => 'devin.mckaskle@gmail.com' }
  s.source           = { :git => 'https://github.com/mckaskle/FlintKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.2'

  s.source_files = 'FlintKit/**/*'
  s.exclude_files = 'FlintKit/Supporting Files/**/*'
  s.tvos.exclude_files = [
    'FlintKit/UIKit/Views/**/*', 
    'FlintKit/UIKit/NetworkActivityIndicatorManager.swift',
    'FlintKit/UIKit/KeyboardManager.swift',
    'FlintKit/Foundation/Notification+FlintKit.swift'
  ]
  
  # s.resource_bundles = {
  #   'FlintKit' => ['FlintKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
