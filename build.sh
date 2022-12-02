#!/bin/sh

build_node() {
    ./android-configure $NDK_HOME 24 $1
    make -j$(nproc --all)
}

build_javet() {
    rm -rf build/lib*.so
    ./build-android.sh \
        -DNODE_DIR=/abc/node \
        -DCMAKE_ANDROID_NDK=$NDK_HOME \
        -DCMAKE_ANDROID_ARCH=$1
}

rm -rf out/log
mkdir -p out/log

for arch in ${@:-arm64 x86_64 arm x86}; do
    echo "arch $arch started at $(date)" >>out/log/time.log
    case $arch in
    arm64) abi=arm64-v8a ;;
    arm) abi=armeabi-v7a ;;
    x86_64) abi=x86_64 ;;
    x86) abi=x86 ;;
    *)
        echo "Unsupported arch: $arch"
        exit 1
        ;;
    esac
    prefix="out/lib/$abi"
    mkdir -p $prefix
    if [ $(ls -A $prefix) ]; then
        echo "arch $arch skipped at $(date)" >>out/log/time.log
        continue
    fi
    (cd node && build_node $arch) 2>&1 | tee "out/log/node_$arch.log"
    [ $? -ne 0 ] && continue
    (cd javet/cpp && build_javet $arch) 2>&1 | tee "out/log/javet_$arch.log"
    [ $? -ne 0 ] && continue
    cp javet/cpp/build/lib*.so $prefix
    echo "arch $arch ended at $(date)" >>out/log/time.log
done
