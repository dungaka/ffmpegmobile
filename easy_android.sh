#!/bin/bash

# fix .git repo not exists
# BUILD_VERSION=$(git describe --tags)

# fix fontconfig gperf missing
# http://ftp.gnu.org/pub/gnu/gperf/gperf-3.1.tar.gz

# fix libpng 192.168.31.115 build error (link libz)
# https://github.com/LuaDist/libpng

#rm -rf android/build
#tools\release\android\build.lts.gradle

#sed -i 's/compileSdkVersion 29/compileSdkVersion 30/g' tools/release/android/build.lts.gradle
#sed -i 's/compileSdkVersion 29/targetSdkVersion 26/g' tools/release/android/build.lts.gradle
#sed -i 's/21.3.6528147/21.4.7075529/g' tools/release/android/build.lts.gradle
#sed -i 's/gradle-6.0.1-all.zip/gradle-6.5-bin.zip/g' android/gradle/wrapper/gradle-wrapper.properties

unset PKG_CONFIG_PATH
unset C_INCLUDE_PATH

export ANDROID_NDK_ROOT=$NDK_HOME

sed -i 's/compileSdkVersion 29/compileSdkVersion 30/g' tools/release/android/build.lts.gradle
sed -i 's/compileSdkVersion 29/targetSdkVersion 26/g' tools/release/android/build.lts.gradle

./android.sh --lts --disable-x86 --disable-x86-64 --enable-gpl --enable-x264 --enable-android-media-codec --enable-fontconfig --enable-freetype --enable-fribidi --enable-libass
#--enable-gnutls
#--reconf-fribidi --reconf-expat --reconf-fontconfig 
#--skip-ffmpeg

