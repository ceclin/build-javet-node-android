#!/bin/sh

# patch -f < /abc/javet.patches

d() {
  (cd /abc && diff -urN javet-ref/$1 javet/$1 >>javet.patches)
}

if [ $# -ne 0 ]; then
  d $(realpath --relative-to=/abc/javet $1)
else
  [ -f /abc/javet.patches ] && rm /abc/javet.patches
  d cpp/CMakeLists.txt
  d cpp/jni/javet_native.h
fi
