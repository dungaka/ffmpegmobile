#!/bin/sh

# curl -T ios_lts_lite_x264_videotoolbox_ass.zip ftp://BBBBBBB:AAAAAAAAAAAA@ilovejoke.tk:9121//AiDisk_a1/opt/wwwroot/default/ -v

./ios.sh --force --lts --disable-i386 --enable-gpl --enable-x264 --enable-ios-videotoolbox --enable-fontconfig --enable-freetype --enable-fribidi --enable-libass

