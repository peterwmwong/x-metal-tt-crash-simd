#!/bin/sh

set -e
PS4="\n>>> "; set -x

system_profiler SPHardwareDataType
sw_vers
xcrun --show-sdk-path
xcrun xcodebuild -version

rm -rf build/
mkdir build

xcrun                       \
    -sdk macosx metal       \
    -std=metal3.2           \
    -fmodules               \
    -ffast-math             \
    -arch air64             \
    -o ./build/air.metallib \
    ./main.metal

xcrun                          \
    -sdk macosx metal-tt       \
    -arch applegpu_g15s        \
    -o ./build/binary.metallib \
    ./build/air.metallib       \
    ./pipelines.mtlp-json 

echo "BUILD SUCCESS!"