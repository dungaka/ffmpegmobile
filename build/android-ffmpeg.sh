#!/bin/bash

if [[ -z ${ANDROID_NDK_ROOT} ]]; then
    echo -e "(*) ANDROID_NDK_ROOT not defined\n"
    exit 1
fi

if [[ -z ${ARCH} ]]; then
    echo -e "(*) ARCH not defined\n"
    exit 1
fi

if [[ -z ${API} ]]; then
    echo -e "(*) API not defined\n"
    exit 1
fi

if [[ -z ${BASEDIR} ]]; then
    echo -e "(*) BASEDIR not defined\n"
    exit 1
fi

HOST_PKG_CONFIG_PATH=`command -v pkg-config`
if [ -z ${HOST_PKG_CONFIG_PATH} ]; then
    echo -e "(*) pkg-config command not found\n"
    exit 1
fi

# ENABLE COMMON FUNCTIONS
. ${BASEDIR}/build/android-common.sh

# PREPARE PATHS & DEFINE ${INSTALL_PKG_CONFIG_DIR}
LIB_NAME="ffmpeg"
set_toolchain_clang_paths ${LIB_NAME}

# PREPARING FLAGS
BUILD_HOST=$(get_build_host)
CFLAGS=$(get_cflags ${LIB_NAME})
CXXFLAGS=$(get_cxxflags ${LIB_NAME})
LDFLAGS=$(get_ldflags ${LIB_NAME})
export PKG_CONFIG_LIBDIR="${INSTALL_PKG_CONFIG_DIR}"

TARGET_CPU=""
TARGET_ARCH=""
ARCH_OPTIONS=""
case ${ARCH} in
    arm-v7a)
        TARGET_CPU="armv7-a"
        TARGET_ARCH="armv7-a"
        ARCH_OPTIONS="	--disable-neon --enable-asm --enable-inline-asm"
    ;;
    arm-v7a-neon)
        TARGET_CPU="armv7-a"
        TARGET_ARCH="armv7-a"
        ARCH_OPTIONS="	--enable-neon --enable-asm --enable-inline-asm --build-suffix=_neon"
    ;;
    arm64-v8a)
        TARGET_CPU="armv8-a"
        TARGET_ARCH="aarch64"
        ARCH_OPTIONS="	--enable-neon --enable-asm --enable-inline-asm"
    ;;
    x86)
        TARGET_CPU="i686"
        TARGET_ARCH="i686"

        # asm disabled due to this ticker https://trac.ffmpeg.org/ticket/4928
        ARCH_OPTIONS="	--disable-neon --disable-asm --disable-inline-asm"
    ;;
    x86-64)
        TARGET_CPU="x86_64"
        TARGET_ARCH="x86_64"
        ARCH_OPTIONS="	--disable-neon --enable-asm --enable-inline-asm"
    ;;
esac

CONFIGURE_POSTFIX=""
HIGH_PRIORITY_INCLUDES=""

for library in {1..49}
do
    if [[ ${!library} -eq 1 ]]; then
        ENABLED_LIBRARY=$(get_library_name $((library - 1)))

        echo -e "INFO: Enabling library ${ENABLED_LIBRARY}" 1>>${BASEDIR}/build.log 2>&1

        case $ENABLED_LIBRARY in
            chromaprint)
                CFLAGS+=" $(pkg-config --cflags libchromaprint)"
                LDFLAGS+=" $(pkg-config --libs --static libchromaprint)"
                CONFIGURE_POSTFIX+=" --enable-chromaprint"
            ;;
            fontconfig)
                CFLAGS+=" $(pkg-config --cflags fontconfig)"
                LDFLAGS+=" $(pkg-config --libs --static fontconfig)"
                CONFIGURE_POSTFIX+=" --enable-libfontconfig"
            ;;
            freetype)
                CFLAGS+=" $(pkg-config --cflags freetype2)"
                LDFLAGS+=" $(pkg-config --libs --static freetype2)"
                CONFIGURE_POSTFIX+=" --enable-libfreetype"
            ;;
            fribidi)
                CFLAGS+=" $(pkg-config --cflags fribidi)"
                LDFLAGS+=" $(pkg-config --libs --static fribidi)"
                CONFIGURE_POSTFIX+=" --enable-libfribidi"
            ;;
            gmp)
                CFLAGS+=" $(pkg-config --cflags gmp)"
                LDFLAGS+=" $(pkg-config --libs --static gmp)"
                CONFIGURE_POSTFIX+=" --enable-gmp"
            ;;
            gnutls)
                CFLAGS+=" $(pkg-config --cflags gnutls)"
                LDFLAGS+=" $(pkg-config --libs --static gnutls)"
                CONFIGURE_POSTFIX+=" --enable-gnutls"
            ;;
            kvazaar)
                CFLAGS+=" $(pkg-config --cflags kvazaar)"
                LDFLAGS+=" $(pkg-config --libs --static kvazaar)"
                CONFIGURE_POSTFIX+=" --enable-libkvazaar"
            ;;
            lame)
                CFLAGS+=" $(pkg-config --cflags libmp3lame)"
                LDFLAGS+=" $(pkg-config --libs --static libmp3lame)"
                CONFIGURE_POSTFIX+=" --enable-libmp3lame"
            ;;
            libaom)
                CFLAGS+=" $(pkg-config --cflags aom)"
                LDFLAGS+=" $(pkg-config --libs --static aom)"
                CONFIGURE_POSTFIX+=" --enable-libaom"
            ;;
            libass)
                CFLAGS+=" $(pkg-config --cflags libass)"
                LDFLAGS+=" $(pkg-config --libs --static libass)"
                CONFIGURE_POSTFIX+=" --enable-libass"
            ;;
            libiconv)
                CFLAGS+=" $(pkg-config --cflags libiconv)"
                LDFLAGS+=" $(pkg-config --libs --static libiconv)"
                CONFIGURE_POSTFIX+=" --enable-iconv"
                HIGH_PRIORITY_INCLUDES+=" $(pkg-config --cflags libiconv)"
            ;;
            libilbc)
                CFLAGS+=" $(pkg-config --cflags libilbc)"
                LDFLAGS+=" $(pkg-config --libs --static libilbc)"
                CONFIGURE_POSTFIX+=" --enable-libilbc"
            ;;
            libtheora)
                CFLAGS+=" $(pkg-config --cflags theora)"
                LDFLAGS+=" $(pkg-config --libs --static theora)"
                CONFIGURE_POSTFIX+=" --enable-libtheora"
            ;;
            libvidstab)
                CFLAGS+=" $(pkg-config --cflags vidstab)"
                LDFLAGS+=" $(pkg-config --libs --static vidstab)"
                CONFIGURE_POSTFIX+=" --enable-libvidstab --enable-gpl"
            ;;
            libvorbis)
                CFLAGS+=" $(pkg-config --cflags vorbis)"
                LDFLAGS+=" $(pkg-config --libs --static vorbis)"
                CONFIGURE_POSTFIX+=" --enable-libvorbis"
            ;;
            libvpx)
                CFLAGS+=" $(pkg-config --cflags vpx)"
                LDFLAGS+=" $(pkg-config --libs vpx)"
                LDFLAGS+=" $(pkg-config --libs cpu-features)"
                CONFIGURE_POSTFIX+=" --enable-libvpx"
            ;;
            libwebp)
                CFLAGS+=" $(pkg-config --cflags libwebp)"
                LDFLAGS+=" $(pkg-config --libs --static libwebp)"
                CONFIGURE_POSTFIX+=" --enable-libwebp"
            ;;
            libxml2)
                CFLAGS+=" $(pkg-config --cflags libxml-2.0)"
                LDFLAGS+=" $(pkg-config --libs --static libxml-2.0)"
                CONFIGURE_POSTFIX+=" --enable-libxml2"
            ;;
            opencore-amr)
                CFLAGS+=" $(pkg-config --cflags opencore-amrnb)"
                LDFLAGS+=" $(pkg-config --libs --static opencore-amrnb)"
                CONFIGURE_POSTFIX+=" --enable-libopencore-amrnb"
            ;;
            openh264)
                FFMPEG_CFLAGS+=" $(pkg-config --cflags openh264)"
                FFMPEG_LDFLAGS+=" $(pkg-config --libs --static openh264)"
                CONFIGURE_POSTFIX+=" --enable-libopenh264"
            ;;
            opus)
                CFLAGS+=" $(pkg-config --cflags opus)"
                LDFLAGS+=" $(pkg-config --libs --static opus)"
                CONFIGURE_POSTFIX+=" --enable-libopus"
            ;;
            rubberband)
                CFLAGS+=" $(pkg-config --cflags rubberband)"
                LDFLAGS+=" $(pkg-config --libs --static rubberband)"
                CONFIGURE_POSTFIX+=" --enable-librubberband --enable-gpl"
            ;;
            shine)
                CFLAGS+=" $(pkg-config --cflags shine)"
                LDFLAGS+=" $(pkg-config --libs --static shine)"
                CONFIGURE_POSTFIX+=" --enable-libshine"
            ;;
            sdl)
                CFLAGS+=" $(pkg-config --cflags sdl2)"
                LDFLAGS+=" $(pkg-config --libs --static sdl2)"
                CONFIGURE_POSTFIX+=" --enable-sdl2"
            ;;
            snappy)
                CFLAGS+=" $(pkg-config --cflags snappy)"
                LDFLAGS+=" $(pkg-config --libs --static snappy)"
                CONFIGURE_POSTFIX+=" --enable-libsnappy"
            ;;
            soxr)
                CFLAGS+=" $(pkg-config --cflags soxr)"
                LDFLAGS+=" $(pkg-config --libs --static soxr)"
                CONFIGURE_POSTFIX+=" --enable-libsoxr"
            ;;
            speex)
                CFLAGS+=" $(pkg-config --cflags speex)"
                LDFLAGS+=" $(pkg-config --libs --static speex)"
                CONFIGURE_POSTFIX+=" --enable-libspeex"
            ;;
            tesseract)
                CFLAGS+=" $(pkg-config --cflags tesseract)"
                LDFLAGS+=" $(pkg-config --libs --static tesseract)"
                CFLAGS+=" $(pkg-config --cflags giflib)"
                LDFLAGS+=" $(pkg-config --libs --static giflib)"
                CONFIGURE_POSTFIX+=" --enable-libtesseract"
            ;;
            twolame)
                CFLAGS+=" $(pkg-config --cflags twolame)"
                LDFLAGS+=" $(pkg-config --libs --static twolame)"
                CONFIGURE_POSTFIX+=" --enable-libtwolame"
            ;;
            vo-amrwbenc)
                CFLAGS+=" $(pkg-config --cflags vo-amrwbenc)"
                LDFLAGS+=" $(pkg-config --libs --static vo-amrwbenc)"
                CONFIGURE_POSTFIX+=" --enable-libvo-amrwbenc"
            ;;
            wavpack)
                CFLAGS+=" $(pkg-config --cflags wavpack)"
                LDFLAGS+=" $(pkg-config --libs --static wavpack)"
                CONFIGURE_POSTFIX+=" --enable-libwavpack"
            ;;
            x264)
                CFLAGS+=" $(pkg-config --cflags x264)"
                LDFLAGS+=" $(pkg-config --libs --static x264)"
                CONFIGURE_POSTFIX+=" --enable-libx264 --enable-gpl"
            ;;
            x265)
                CFLAGS+=" $(pkg-config --cflags x265)"
                LDFLAGS+=" $(pkg-config --libs --static x265)"
                CONFIGURE_POSTFIX+=" --enable-libx265 --enable-gpl"
            ;;
            xvidcore)
                CFLAGS+=" $(pkg-config --cflags xvidcore)"
                LDFLAGS+=" $(pkg-config --libs --static xvidcore)"
                CONFIGURE_POSTFIX+=" --enable-libxvid --enable-gpl"
            ;;
            expat)
                CFLAGS+=" $(pkg-config --cflags expat)"
                LDFLAGS+=" $(pkg-config --libs --static expat)"
            ;;
            libogg)
                CFLAGS+=" $(pkg-config --cflags ogg)"
                LDFLAGS+=" $(pkg-config --libs --static ogg)"
            ;;
            libpng)
                CFLAGS+=" $(pkg-config --cflags libpng)"
                LDFLAGS+=" $(pkg-config --libs --static libpng)"
            ;;
            libuuid)
                CFLAGS+=" $(pkg-config --cflags uuid)"
                LDFLAGS+=" $(pkg-config --libs --static uuid)"
            ;;
            nettle)
                CFLAGS+=" $(pkg-config --cflags nettle)"
                LDFLAGS+=" $(pkg-config --libs --static nettle)"
                CFLAGS+=" $(pkg-config --cflags hogweed)"
                LDFLAGS+=" $(pkg-config --libs --static hogweed)"
            ;;
            android-zlib)
                CFLAGS+=" $(pkg-config --cflags zlib)"
                LDFLAGS+=" $(pkg-config --libs --static zlib)"
                CONFIGURE_POSTFIX+=" --enable-zlib"
            ;;
            android-media-codec)
                CONFIGURE_POSTFIX+=" --enable-mediacodec"
        esac
    else

        # THE FOLLOWING LIBRARIES SHOULD BE EXPLICITLY DISABLED TO PREVENT AUTODETECT
        # NOTE THAT IDS MUST BE +1 OF THE INDEX VALUE
        if [[ ${library} -eq 31 ]]; then
            CONFIGURE_POSTFIX+=" --disable-sdl2"
        elif [[ ${library} -eq 46 ]]; then
            CONFIGURE_POSTFIX+=" --disable-zlib"
        fi
    fi
done

LDFLAGS+=" -L${ANDROID_NDK_ROOT}/platforms/android-${API}/arch-${TOOLCHAIN_ARCH}/usr/lib"

# LINKING WITH ANDROID LTS SUPPORT LIBRARY IS NECESSARY FOR API < 18
if [[ ! -z ${MOBILE_FFMPEG_LTS_BUILD} ]] && [[ ${API} < 18 ]]; then
    LDFLAGS+=" -Wl,--whole-archive ${BASEDIR}/android/app/src/main/cpp/libandroidltssupport.a -Wl,--no-whole-archive"
fi

# OPTIMIZE FOR SPEED INSTEAD OF SIZE
if [[ -z ${MOBILE_FFMPEG_OPTIMIZED_FOR_SPEED} ]]; then
    SIZE_OPTIONS="--enable-small";
else
    SIZE_OPTIONS="";
fi

# SET DEBUG OPTIONS
if [[ -z ${MOBILE_FFMPEG_DEBUG} ]]; then

    # SET LTO FLAGS
    if [[ -z ${NO_LINK_TIME_OPTIMIZATION} ]]; then
        DEBUG_OPTIONS="--disable-debug --enable-lto";
    else
        DEBUG_OPTIONS="--disable-debug --disable-lto";
    fi
else
    DEBUG_OPTIONS="--enable-debug --disable-stripping";
fi

echo -n -e "\n${LIB_NAME}: "

# DOWNLOAD LIBRARY
DOWNLOAD_RESULT=$(download_library_source ${LIB_NAME})
if [[ ${DOWNLOAD_RESULT} -ne 0 ]]; then
    exit 1
fi

cd ${BASEDIR}/src/${LIB_NAME} || exit 1

if [[ -z ${NO_WORKSPACE_CLEANUP_ffmpeg} ]]; then
    echo -e "INFO: Cleaning workspace for ${LIB_NAME}" 1>>${BASEDIR}/build.log 2>&1
    make distclean 2>/dev/null 1>/dev/null
fi

export CFLAGS="${HIGH_PRIORITY_INCLUDES} ${CFLAGS}"
export CXXFLAGS="${CXXFLAGS}"
export LDFLAGS="${LDFLAGS}"

# USE HIGHER LIMITS FOR FFMPEG LINKING
ulimit -n 2048 1>>${BASEDIR}/build.log 2>&1

########################### CUSTOMIZATIONS #######################

# 1. Use thread local log level
${SED_INLINE} 's/static int av_log_level/__thread int av_log_level/g' ${BASEDIR}/src/${LIB_NAME}/libavutil/log.c 1>>${BASEDIR}/build.log 2>&1

###################################################################

EXTRA_OPTIONS="--disable-decoders --enable-decoder=rawvideo,webp,h263,h264,hevc,vp3,vp5,vp6,vp6a,vp6f,vp7,vp8,vp9,flv,h264_mediacodec,hevc_mediacodec,mpeg4_mediacodec,vp8_mediacodec,vp9_mediacodec,mpeg1video,mpeg2video,mpegvideo,mpeg4,dca,ac3,eac3,aac,mp1,mp2,mp3,rv30,rv40,cook,wmv1,wmv2,wmv3,wmv3image,vorbis,ape,flac,opus,wmav1,wmav2,wmapro,mjpeg,msmpeg4v1,msmpeg4v2,msmpeg4v3,tscc,gsm,gsm_ms,amrnb,amrwb,alac,sipr,pcm_s8*,pcm_u8*,pcm_s16*,pcm_u16*,pcm_f*,ass,dvbsub,dvdsub,mov_text,movtext,sami,srt,ssa,subrip,text,gif,jpeg*,mjpeg*,png,apng,bmp --disable-demuxers --enable-demuxer=rm,mpegvideo,mjpeg*,image2,avi,h263,h264,hevc,matroska,dts,dtshd,aac,flv,mpegts,mpegps,mp4,m4v,mov,ape,hls,flac,amr,rawvideo,realtext,rtsp,vc1,mp3,wav,asf,ogg,concat,sdp,gif,ass,apng,image_bmp_pipe,image_png_pipe,image_jpeg_pipe,image_webp_pipe,pcm_s16*,webp --disable-parsers --enable-parser=h263,h264,hevc,mpegaudio,mpegvideo,aac_latm,mpeg4video,dca,aac,ac3,eac3,flac,gif,png,bmp,vorbis,mjpeg,webp --disable-encoders --enable-encoder=libx264,mpeg1video,mpeg2video,mpeg4,mjpeg,aac,apng,pcm_f*,pcm_s16*,pcm_s8* --disable-muxers --enable-muxer=mpegts,flv,mov,mp4,hls,image2,wav,null,apng,pcm_s16* "

./configure \
    --cross-prefix="${BUILD_HOST}-" \
    --sysroot="${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/${TOOLCHAIN}/sysroot" \
    --prefix="${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME}" \
    --pkg-config="${HOST_PKG_CONFIG_PATH}" \
    --enable-version3 \
    --arch="${TARGET_ARCH}" \
    --cpu="${TARGET_CPU}" \
    --cc="${CC}" \
    --cxx="${CXX}" \
    --extra-libs="$(pkg-config --libs --static cpu-features)" \
    --target-os=android \
    ${ARCH_OPTIONS} \
    --enable-cross-compile \
    --enable-pic \
    --enable-jni \
    --enable-optimizations \
    --enable-swscale \
    --enable-shared \
    --enable-v4l2-m2m \
    --disable-outdev=fbdev \
    --disable-indev=fbdev \
    ${SIZE_OPTIONS} \
    --disable-openssl \
    --disable-xmm-clobber-test \
    ${DEBUG_OPTIONS} \
    --disable-neon-clobber-test \
    --disable-programs \
    --disable-postproc \
    --disable-doc \
    --disable-htmlpages \
    --disable-manpages \
    --disable-podpages \
    --disable-txtpages \
    --disable-static \
    --disable-sndio \
    --disable-schannel \
    --disable-securetransport \
    --disable-xlib \
    --disable-cuda \
    --disable-cuvid \
    --disable-nvenc \
    --disable-vaapi \
    --disable-vdpau \
    --disable-videotoolbox \
    --disable-audiotoolbox \
    --disable-appkit \
    --disable-alsa \
    --disable-cuda \
    --disable-cuvid \
    --disable-nvenc \
    --disable-vaapi \
    --disable-vdpau \
    $EXTRA_OPTIONS \
    ${CONFIGURE_POSTFIX} 1>>${BASEDIR}/build.log 2>&1

if [ $? -ne 0 ]; then
    echo "failed"
    exit 1
fi

if [[ -z ${NO_OUTPUT_REDIRECTION} ]]; then
    make -j$(get_cpu_count) 1>>${BASEDIR}/build.log 2>&1

    if [ $? -ne 0 ]; then
        echo "failed"
        exit 1
    fi
else
    echo -e "started\n"
    make -j$(get_cpu_count) 1>>${BASEDIR}/build.log 2>&1

    if [ $? -ne 0 ]; then
        echo -n -e "\n${LIB_NAME}: failed\n"
        exit 1
    else
        echo -n -e "\n${LIB_NAME}: "
    fi
fi

rm -rf ${BASEDIR}/prebuilt/android-$(get_target_build)/${LIB_NAME}
make install 1>>${BASEDIR}/build.log 2>&1

if [ $? -ne 0 ]; then
    echo "failed"
    exit 1
fi

# MANUALLY ADD REQUIRED HEADERS
mkdir -p ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavutil/x86
mkdir -p ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavutil/arm
mkdir -p ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavutil/aarch64
mkdir -p ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavcodec/x86
mkdir -p ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavcodec/arm
cp -f ${BASEDIR}/src/ffmpeg/config.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include
cp -f ${BASEDIR}/src/ffmpeg/libavcodec/mathops.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavcodec
cp -f ${BASEDIR}/src/ffmpeg/libavcodec/x86/mathops.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavcodec/x86
cp -f ${BASEDIR}/src/ffmpeg/libavcodec/arm/mathops.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavcodec/arm
cp -f ${BASEDIR}/src/ffmpeg/libavformat/network.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavformat
cp -f ${BASEDIR}/src/ffmpeg/libavformat/os_support.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavformat
cp -f ${BASEDIR}/src/ffmpeg/libavformat/url.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavformat
cp -f ${BASEDIR}/src/ffmpeg/libavutil/internal.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavutil
cp -f ${BASEDIR}/src/ffmpeg/libavutil/libm.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavutil
cp -f ${BASEDIR}/src/ffmpeg/libavutil/reverse.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavutil
cp -f ${BASEDIR}/src/ffmpeg/libavutil/thread.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavutil
cp -f ${BASEDIR}/src/ffmpeg/libavutil/timer.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavutil
cp -f ${BASEDIR}/src/ffmpeg/libavutil/x86/asm.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavutil/x86
cp -f ${BASEDIR}/src/ffmpeg/libavutil/x86/timer.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavutil/x86
cp -f ${BASEDIR}/src/ffmpeg/libavutil/arm/timer.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavutil/arm
cp -f ${BASEDIR}/src/ffmpeg/libavutil/aarch64/timer.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavutil/aarch64
cp -f ${BASEDIR}/src/ffmpeg/libavutil/x86/emms.h ${BASEDIR}/prebuilt/android-$(get_target_build)/ffmpeg/include/libavutil/x86

if [ $? -eq 0 ]; then
    echo "ok"
else
    echo "failed"
    exit 1
fi
