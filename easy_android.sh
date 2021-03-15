#!/bin/bash

# fix .git repo not exists
# BUILD_VERSION=$(git describe --tags)

# fix fontconfig gperf missing
# http://ftp.gnu.org/pub/gnu/gperf/gperf-3.1.tar.gz

# fix libpng 192.168.31.115 build error (link libz)
# https://github.com/LuaDist/libpng

./android.sh --disable-arm-v7a --disable-x86 --disable-x86-64 --enable-gpl --enable-x264 --enable-android-media-codec --enable-fontconfig --enable-freetype --enable-fribidi --enable-libass --reconf-fribidi --reconf-expat --reconf-fontconfig 
# --skip-ffmpeg

