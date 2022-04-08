require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-wechat-api"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://github.com/huiqiangdev/react-native-wechat-api.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm}"

  s.dependency "React-Core"
  s.vendored_libraries = "ios/libWeChatSDK.a"
  s.requires_arc = true
  s.frameworks = 'SystemConfiguration','CoreTelephony','WebKit'
  s.library = 'sqlite3','c++','z'
  s.pod_target_xcconfig    = {
          'OTHER_LDFLAGS' => '-all_load',
          'VALID_ARCHS' => 'x86_64 armv7 arm64'
      }

end
