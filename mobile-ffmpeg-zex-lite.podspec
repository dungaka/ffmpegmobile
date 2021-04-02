Pod::Spec.new do |s|
    s.name              = "mobile-ffmpeg-zex-lite"
    s.version           = "1.0.0"
    s.summary           = "Mobile FFmpeg Lite GPL ass Static Framework"
    s.description       = <<-DESC
    Includes FFmpeg v4.4-dev-416 with fontconfig v2.13.92, freetype v2.10.2, fribidi v1.0.9, libass v0.14.0, and x264 v20200630-stable libraries enabled.
    DESC

    s.homepage          = "https://github.com/wnpllrzodiac/mobile-ffmpeg"

    s.author            = { "Michael Ma" => "wnpllr@gmail.com" }
    s.license           = { :type => "GPL-3.0", :file => "mobileffmpeg.framework/LICENSE" }

    s.platform          = :ios
    s.requires_arc      = true
    s.libraries         = 'z', 'bz2', 'c++', 'iconv'

    s.source            = { :http => "https://github.com/wnpllrzodiac/mobile-ffmpeg/releases/download/v4.4.LTS_dev_michael/ios_lts_lite_x264_videotoolbox_ass.zip" }

    s.ios.deployment_target = '9.3'
    s.ios.frameworks    = 'AudioToolbox','CoreMedia','VideoToolbox'
    s.ios.vendored_frameworks = 'mobileffmpeg.framework', 'libavcodec.framework', 'libavdevice.framework', 'libavfilter.framework', 'libavformat.framework', 'libavutil.framework', 'libswresample.framework', 'libswscale.framework', 'expat.framework', 'fontconfig.framework', 'freetype.framework', 'fribidi.framework', 'libass.framework', 'x264.framework'

end
