#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint thrio.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'thrio'
  s.version          = '0.0.1'
  s.summary          = 'A flutter plugin which enables hybrid integration of flutter for existing ios or android apps.'
  s.description      = <<-DESC
A flutter plugin which enables hybrid integration of flutter for existing ios or android apps.
                       DESC
  s.homepage         = 'http://hellobike.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'hellobike' => 'foxsofter@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = ['Classes/*.h',
                           'Classes/Category/*.h',
                           'Classes/Channel/*.h',
                           'Classes/Logger/*.h',
                           'Classes/Module/*.h',
                           'Classes/Registry/*.h',
                           'Classes/Navigator/NavigatorNotifyProtocol.h',
                           'Classes/Navigator/ThrioFlutterViewController.h',
                           'Classes/Navigator/ThrioNavigator.h',
                           'Classes/Navigator/UIViewController+WillPopCallback.h',
                           'Classes/Navigator/UIViewController+HidesNavigationBar.h',]
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
