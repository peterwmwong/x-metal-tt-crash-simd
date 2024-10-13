#include <metal_stdlib>

using namespace metal;

struct Output {
    ushort primitives[32];
    ushort indices[32];
};

[[kernel]]
void test(device Output & out [[buffer(0)]]) {
    ushort primitive = simd_prefix_exclusive_sum(1u);
    out.primitives[primitive] = 1;

    /* BAD: metal-tt crashes with the following error...

    LLVM ERROR: cannot select: %2:gpr(s32) = 116 intrinsic(@llvm.agx2.simd.reduce.i.Add), %3:gpr16(s16), %53:gpr16(s16)
    Context:
    %2:gpr(s32) = 116 intrinsic(@llvm.agx2.simd.reduce.i.Add), %3:gpr16(s16), %53:gpr16(s16)
    %3:gpr16(s16) = 120 i16 1
    %53:gpr16(s16) = 5626 0, 1
    (in function: agc.main)
    metal-tt: applegpu-nt command failed
    */
    ushort index = primitive * 3u;
    out.indices[index] = 1;

    // GOOD: metal-tt successful
    // out.indices[primitive * 3u] = 1;
}