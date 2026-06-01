#
#  Be sure to run `pod spec lint TKRoomSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "TKRoomSDK"
  s.version      = "5.1.7"
  s.summary      = "A Framework for audio and video ."
  # s.module_name  = "TKRoomSDK"
  s.description  = <<-DESC
                 A Framework for audio and video .

  s.homepage     = "https://github.com/Talk-Cloud/TKRoomSDK_iOS"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Talk-Cloud" => "tksdk@talk-cloud.com" }


  s.platform     = :ios, "12.0"

  s.ios.deployment_target = "12.0" 

  s.source       = { :git => "https://github.com/Talk-Cloud/TKRoomSDK_iOS.git", 
                     :tag => "v#{s.version.to_s}" ,
                     :submodules => true
                   }

  s.vendored_frameworks = 'sdk/iphoneos/*.framework'

  s.requires_arc = true

end
