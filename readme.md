This [Metal Compute shader](./main.metal) and [Pipelines Script](./pipelines.mtlp-json) reproduces a `metal-tt` crash.

Using the result of a simd reduction (ex. `simd_prefix_exclusive_sum`) in the following way causes `metal-tt` to peace out...

```c++
struct Output {
    ushort primitives[32];
    ushort indices[32];
};

[[kernel]]
void test(device Output & out [[buffer(0)]]) {
    ushort primitive = simd_prefix_exclusive_sum(1u);
    out.primitives[primitive] = 1;

    ushort index = primitive * 3u;
    out.indices[index] = 1;
}

/* metal-tt Error:

LLVM ERROR: cannot select: %2:gpr(s32) = 116 intrinsic(@llvm.agx2.simd.reduce.i.Add), %3:gpr16(s16), %53:gpr16(s16)
Context:
%2:gpr(s32) = 116 intrinsic(@llvm.agx2.simd.reduce.i.Add), %3:gpr16(s16), %53:gpr16(s16)
%3:gpr16(s16) = 120 i16 1
%53:gpr16(s16) = 5626 0, 1
 (in function: agc.main)
metal-tt: applegpu-nt command failed

*/
```

This is associated to FB15482904 (Apple Feedback Assistant).

# Reproduction Steps

1. Clone and enter project
```sh
git clone https://github.com/peterwmwong/x-metal-tt-crash-simd.git
cd x-metal-tt-crash-simd
```
2. Run reproduction script
```sh
./build.sh
```

## Output with hardware/software environment information

```
>>> system_profiler SPHardwareDataType
Hardware:

    Hardware Overview:

      Model Name: MacBook Pro
      Model Identifier: Mac15,8
      Model Number: Z1AW001BXLL/A
      Chip: Apple M3 Max
      Total Number of Cores: 16 (12 performance and 4 efficiency)
      Memory: 64 GB
      System Firmware Version: 11881.41.3
      OS Loader Version: 11881.41.3
      Serial Number (system): ...
      Hardware UUID: ...
      Provisioning UDID: ...
      Activation Lock Status: Disabled


>>> sw_vers
ProductName:            macOS
ProductVersion:         15.1
BuildVersion:           24B5070a

>>> xcrun --show-sdk-path
/Applications/Xcode-beta.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk

>>> xcrun xcodebuild -version
Xcode 16.1
Build version 16B5029d

>>> rm -rf build/

>>> mkdir build

>>> xcrun -sdk macosx metal -std=metal3.2 -fmodules -ffast-math -arch air64 -o ./build/air.metallib ./main.metal

>>> xcrun -sdk macosx metal-tt -arch applegpu_g15s -o ./build/binary.metallib ./build/air.metallib ./pipelines.mtlp-json
LLVM ERROR: cannot select: %2:gpr(s32) = 116 intrinsic(@llvm.agx2.simd.reduce.i.Add), %3:gpr16(s16), %53:gpr16(s16)
Context:
%2:gpr(s32) = 116 intrinsic(@llvm.agx2.simd.reduce.i.Add), %3:gpr16(s16), %53:gpr16(s16)
%3:gpr16(s16) = 120 i16 1
%53:gpr16(s16) = 5626 0, 1
 (in function: agc.main)
metal-tt: applegpu-nt command failed
```
