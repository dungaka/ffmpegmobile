Pod::Spec.new do |s|
    s.name              = "zex-transsdk-lite-local"
    s.version           = "1.0.6"
    s.summary           = "Mobile FFmpeg Lite GPL ass Static Framework"
    s.description       = <<-DESC
    Includes FFmpeg v4.4-dev-416 with fontconfig v2.13.92, freetype v2.10.2, fribidi v1.0.9, libass v0.14.0, and x264 v20200630-stable libraries enabled, support speed.
    DESC

    s.homepage          = "https://github.com/wnpllrzodiac/mobile-ffmpeg-zex-lite"

    s.author            = { "Michael Ma" => "wnpllr@gmail.com" }
    s.license           = { :type => "GPL-3.0", :file => "ios-framework/mobileffmpeg.framework/LICENSE" }

    s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
    s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

    s.platform          = :ios
    s.requires_arc      = true
    s.libraries         = 'z', 'bz2', 'c++', 'iconv'

    s.source            = { :http => "http://192.168.31.115:9180/archive/zex-transsdk-lite/v106/ios_lts_lite_x264_videotoolbox_ass_v1.0.6.zip" }

    s.ios.deployment_target = '9.3'
    s.ios.frameworks    = 'AudioToolbox','CoreMedia','VideoToolbox'
    s.ios.vendored_frameworks = 'ios-framework/mobileffmpeg.framework', 'ios-framework/libavcodec.framework', 'ios-framework/libavdevice.framework', 'ios-framework/libavfilter.framework', 'ios-framework/libavformat.framework', 'ios-framework/libavutil.framework', 'ios-framework/libswresample.framework', 'ios-framework/libswscale.framework', 'ios-framework/expat.framework', 'ios-framework/fontconfig.framework', 'ios-framework/freetype.framework', 'ios-framework/fribidi.framework', 'ios-framework/libass.framework', 'ios-framework/libpng.framework', 'ios-framework/x264.framework'

end
