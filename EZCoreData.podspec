#
# Be sure to run `pod lib lint EZCoreData.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EZCoreData'
  s.version          = '0.1.0'
  s.summary          = 'A great helper for core data if you use iOS 10+'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      =  'A library that builds up the basic main and private contexts for CoreData and brings a few utility methods'


  s.homepage         = 'https://github.com/marcelosalloum/EZCoreData'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'marcelosalloum' => 'marcelosalloum@gmal.com' }
  s.source           = { :git => 'https://github.com/marcelosalloum/EZCoreData.git', :tag => s.version.to_s }
  s.social_media_url   = 'https://www.linkedin.com/in/marcelosalloum'

  s.ios.deployment_target = '10.0'

  s.source_files = 'EZCoreData/Classes/**/*'
  s.swift_version = '4.2'
  
  # s.resource_bundles = {
  #   'EZCoreData' => ['EZCoreData/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.frameworks = 'CoreData'
  # s.dependency 'AFNetworking', '~> 2.3'
end
