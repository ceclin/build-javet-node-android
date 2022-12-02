#!/bin/sh

# patch -f < /abc/node.patches

d() {
  (cd /abc && diff -urN node-ref/$1 node/$1 >>node.patches)
}

if [ $# -ne 0 ]; then
  d $(realpath --relative-to=/abc/node $1)
else
  [ -f /abc/node.patches ] && rm /abc/node.patches
  d android_configure.py
  d common.gypi
  d configure.py
  d deps/v8/src/codegen/arm/constants-arm.h
  d deps/v8/src/heap/base/asm/x64/push_registers_asm.cc
  d test/cctest/test_crypto_clienthello.cc
fi
