; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 3
; RUN: llc -mtriple=aarch64 -verify-machineinstrs %s -o - 2>&1 | FileCheck %s --check-prefixes=CHECK,CHECK-SD
; RUN: llc -mtriple=aarch64 -global-isel -global-isel-abort=2 -verify-machineinstrs %s -o - 2>&1 | FileCheck %s --check-prefixes=CHECK,CHECK-GI

define i8 @xtn_i16_to_i8(i16 %a) {
; CHECK-LABEL: xtn_i16_to_i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc i16 %a to i8
  ret i8 %arg1
}

define i8 @xtn_i32_to_i8(i32 %a) {
; CHECK-LABEL: xtn_i32_to_i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc i32 %a to i8
  ret i8 %arg1
}

define i8 @xtn_i64_to_i8(i64 %a) {
; CHECK-LABEL: xtn_i64_to_i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    // kill: def $w0 killed $w0 killed $x0
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc i64 %a to i8
  ret i8 %arg1
}

define i8 @xtn_i128_to_i8(i128 %a) {
; CHECK-LABEL: xtn_i128_to_i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    // kill: def $w0 killed $w0 killed $x0
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc i128 %a to i8
  ret i8 %arg1
}

define i16 @xtn_i32_to_i16(i32 %a) {
; CHECK-LABEL: xtn_i32_to_i16:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc i32 %a to i16
  ret i16 %arg1
}

define i16 @xtn_i64_to_i16(i64 %a) {
; CHECK-LABEL: xtn_i64_to_i16:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    // kill: def $w0 killed $w0 killed $x0
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc i64 %a to i16
  ret i16 %arg1
}

define i16 @xtn_i128_to_i16(i128 %a) {
; CHECK-LABEL: xtn_i128_to_i16:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    // kill: def $w0 killed $w0 killed $x0
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc i128 %a to i16
  ret i16 %arg1
}

define i32 @xtn_i64_to_i32(i64 %a) {
; CHECK-LABEL: xtn_i64_to_i32:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    // kill: def $w0 killed $w0 killed $x0
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc i64 %a to i32
  ret i32 %arg1
}

define i32 @xtn_i128_to_i32(i128 %a) {
; CHECK-LABEL: xtn_i128_to_i32:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    // kill: def $w0 killed $w0 killed $x0
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc i128 %a to i32
  ret i32 %arg1
}

define i64 @xtn_i128_to_i64(i128 %a) {
; CHECK-LABEL: xtn_i128_to_i64:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc i128 %a to i64
  ret i64 %arg1
}

define <2 x i8> @xtn_v2i16_v2i8(<2 x i16> %a) {
; CHECK-LABEL: xtn_v2i16_v2i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <2 x i16> %a to <2 x i8>
  ret <2 x i8> %arg1
}

define <2 x i8> @xtn_v2i32_v2i8(<2 x i32> %a) {
; CHECK-LABEL: xtn_v2i32_v2i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <2 x i32> %a to <2 x i8>
  ret <2 x i8> %arg1
}

define <2 x i8> @xtn_v2i64_v2i8(<2 x i64> %a) {
; CHECK-LABEL: xtn_v2i64_v2i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    xtn v0.2s, v0.2d
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <2 x i64> %a to <2 x i8>
  ret <2 x i8> %arg1
}

define <2 x i8> @xtn_v2i128_v2i8(<2 x i128> %a) {
; CHECK-LABEL: xtn_v2i128_v2i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    fmov s0, w0
; CHECK-NEXT:    mov v0.s[1], w2
; CHECK-NEXT:    // kill: def $d0 killed $d0 killed $q0
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <2 x i128> %a to <2 x i8>
  ret <2 x i8> %arg1
}

define <2 x i16> @xtn_v2i32_v2i16(<2 x i32> %a) {
; CHECK-LABEL: xtn_v2i32_v2i16:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <2 x i32> %a to <2 x i16>
  ret <2 x i16> %arg1
}

define <2 x i16> @xtn_v2i64_v2i16(<2 x i64> %a) {
; CHECK-LABEL: xtn_v2i64_v2i16:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    xtn v0.2s, v0.2d
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <2 x i64> %a to <2 x i16>
  ret <2 x i16> %arg1
}

define <2 x i16> @xtn_v2i128_v2i16(<2 x i128> %a) {
; CHECK-LABEL: xtn_v2i128_v2i16:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    fmov s0, w0
; CHECK-NEXT:    mov v0.s[1], w2
; CHECK-NEXT:    // kill: def $d0 killed $d0 killed $q0
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <2 x i128> %a to <2 x i16>
  ret <2 x i16> %arg1
}

define <2 x i32> @xtn_v2i64_v2i32(<2 x i64> %a) {
; CHECK-LABEL: xtn_v2i64_v2i32:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    xtn v0.2s, v0.2d
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <2 x i64> %a to <2 x i32>
  ret <2 x i32> %arg1
}

define <2 x i32> @xtn_v2i128_v2i32(<2 x i128> %a) {
; CHECK-LABEL: xtn_v2i128_v2i32:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    fmov s0, w0
; CHECK-NEXT:    mov v0.s[1], w2
; CHECK-NEXT:    // kill: def $d0 killed $d0 killed $q0
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <2 x i128> %a to <2 x i32>
  ret <2 x i32> %arg1
}

define <2 x i64> @xtn_v2i128_v2i64(<2 x i128> %a) {
; CHECK-LABEL: xtn_v2i128_v2i64:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    fmov d0, x0
; CHECK-NEXT:    mov v0.d[1], x2
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <2 x i128> %a to <2 x i64>
  ret <2 x i64> %arg1
}

define <3 x i8> @xtn_v3i16_v3i8(<3 x i16> %a) {
; CHECK-LABEL: xtn_v3i16_v3i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    // kill: def $d0 killed $d0 def $q0
; CHECK-NEXT:    umov w0, v0.h[0]
; CHECK-NEXT:    umov w1, v0.h[1]
; CHECK-NEXT:    umov w2, v0.h[2]
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <3 x i16> %a to <3 x i8>
  ret <3 x i8> %arg1
}

define <3 x i8> @xtn_v3i32_v3i8(<3 x i32> %a) {
; CHECK-SD-LABEL: xtn_v3i32_v3i8:
; CHECK-SD:       // %bb.0: // %entry
; CHECK-SD-NEXT:    xtn v0.4h, v0.4s
; CHECK-SD-NEXT:    umov w0, v0.h[0]
; CHECK-SD-NEXT:    umov w1, v0.h[1]
; CHECK-SD-NEXT:    umov w2, v0.h[2]
; CHECK-SD-NEXT:    ret
;
; CHECK-GI-LABEL: xtn_v3i32_v3i8:
; CHECK-GI:       // %bb.0: // %entry
; CHECK-GI-NEXT:    mov s1, v0.s[1]
; CHECK-GI-NEXT:    mov s2, v0.s[2]
; CHECK-GI-NEXT:    fmov w0, s0
; CHECK-GI-NEXT:    fmov w1, s1
; CHECK-GI-NEXT:    fmov w2, s2
; CHECK-GI-NEXT:    ret
entry:
  %arg1 = trunc <3 x i32> %a to <3 x i8>
  ret <3 x i8> %arg1
}

define <3 x i8> @xtn_v3i64_v3i8(<3 x i64> %a) {
; CHECK-SD-LABEL: xtn_v3i64_v3i8:
; CHECK-SD:       // %bb.0: // %entry
; CHECK-SD-NEXT:    // kill: def $d0 killed $d0 def $q0
; CHECK-SD-NEXT:    // kill: def $d1 killed $d1 def $q1
; CHECK-SD-NEXT:    // kill: def $d2 killed $d2 def $q2
; CHECK-SD-NEXT:    mov v0.d[1], v1.d[0]
; CHECK-SD-NEXT:    xtn v1.2s, v2.2d
; CHECK-SD-NEXT:    xtn v0.2s, v0.2d
; CHECK-SD-NEXT:    fmov w2, s1
; CHECK-SD-NEXT:    mov w1, v0.s[1]
; CHECK-SD-NEXT:    fmov w0, s0
; CHECK-SD-NEXT:    ret
;
; CHECK-GI-LABEL: xtn_v3i64_v3i8:
; CHECK-GI:       // %bb.0: // %entry
; CHECK-GI-NEXT:    fmov x0, d0
; CHECK-GI-NEXT:    fmov x1, d1
; CHECK-GI-NEXT:    fmov x2, d2
; CHECK-GI-NEXT:    // kill: def $w0 killed $w0 killed $x0
; CHECK-GI-NEXT:    // kill: def $w1 killed $w1 killed $x1
; CHECK-GI-NEXT:    // kill: def $w2 killed $w2 killed $x2
; CHECK-GI-NEXT:    ret
entry:
  %arg1 = trunc <3 x i64> %a to <3 x i8>
  ret <3 x i8> %arg1
}

define <3 x i16> @xtn_v3i32_v3i16(<3 x i32> %a) {
; CHECK-LABEL: xtn_v3i32_v3i16:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    xtn v0.4h, v0.4s
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <3 x i32> %a to <3 x i16>
  ret <3 x i16> %arg1
}

define <3 x i16> @xtn_v3i64_v3i16(<3 x i64> %a) {
; CHECK-SD-LABEL: xtn_v3i64_v3i16:
; CHECK-SD:       // %bb.0: // %entry
; CHECK-SD-NEXT:    // kill: def $d0 killed $d0 def $q0
; CHECK-SD-NEXT:    // kill: def $d1 killed $d1 def $q1
; CHECK-SD-NEXT:    // kill: def $d2 killed $d2 def $q2
; CHECK-SD-NEXT:    mov v0.d[1], v1.d[0]
; CHECK-SD-NEXT:    uzp1 v0.4s, v0.4s, v2.4s
; CHECK-SD-NEXT:    xtn v0.4h, v0.4s
; CHECK-SD-NEXT:    ret
;
; CHECK-GI-LABEL: xtn_v3i64_v3i16:
; CHECK-GI:       // %bb.0: // %entry
; CHECK-GI-NEXT:    fmov x8, d0
; CHECK-GI-NEXT:    fmov x9, d1
; CHECK-GI-NEXT:    fmov s0, w8
; CHECK-GI-NEXT:    fmov x8, d2
; CHECK-GI-NEXT:    mov v0.h[1], w9
; CHECK-GI-NEXT:    mov v0.h[2], w8
; CHECK-GI-NEXT:    // kill: def $d0 killed $d0 killed $q0
; CHECK-GI-NEXT:    ret
entry:
  %arg1 = trunc <3 x i64> %a to <3 x i16>
  ret <3 x i16> %arg1
}

define <3 x i32> @xtn_v3i64_v3i32(<3 x i64> %a) {
; CHECK-SD-LABEL: xtn_v3i64_v3i32:
; CHECK-SD:       // %bb.0: // %entry
; CHECK-SD-NEXT:    // kill: def $d0 killed $d0 def $q0
; CHECK-SD-NEXT:    // kill: def $d1 killed $d1 def $q1
; CHECK-SD-NEXT:    // kill: def $d2 killed $d2 def $q2
; CHECK-SD-NEXT:    mov v0.d[1], v1.d[0]
; CHECK-SD-NEXT:    uzp1 v0.4s, v0.4s, v2.4s
; CHECK-SD-NEXT:    ret
;
; CHECK-GI-LABEL: xtn_v3i64_v3i32:
; CHECK-GI:       // %bb.0: // %entry
; CHECK-GI-NEXT:    fmov x8, d0
; CHECK-GI-NEXT:    fmov x9, d1
; CHECK-GI-NEXT:    fmov s0, w8
; CHECK-GI-NEXT:    fmov x8, d2
; CHECK-GI-NEXT:    mov v0.s[1], w9
; CHECK-GI-NEXT:    mov v0.s[2], w8
; CHECK-GI-NEXT:    ret
entry:
  %arg1 = trunc <3 x i64> %a to <3 x i32>
  ret <3 x i32> %arg1
}

define <4 x i8> @xtn_v4i16_v4i8(<4 x i16> %a) {
; CHECK-LABEL: xtn_v4i16_v4i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <4 x i16> %a to <4 x i8>
  ret <4 x i8> %arg1
}

define <4 x i8> @xtn_v4i32_v4i8(<4 x i32> %a) {
; CHECK-LABEL: xtn_v4i32_v4i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    xtn v0.4h, v0.4s
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <4 x i32> %a to <4 x i8>
  ret <4 x i8> %arg1
}

define <4 x i8> @xtn_v4i64_v4i8(<4 x i64> %a) {
; CHECK-LABEL: xtn_v4i64_v4i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    uzp1 v0.4s, v0.4s, v1.4s
; CHECK-NEXT:    xtn v0.4h, v0.4s
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <4 x i64> %a to <4 x i8>
  ret <4 x i8> %arg1
}

define <4 x i16> @xtn_v4i32_v4i16(<4 x i32> %a) {
; CHECK-LABEL: xtn_v4i32_v4i16:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    xtn v0.4h, v0.4s
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <4 x i32> %a to <4 x i16>
  ret <4 x i16> %arg1
}

define <4 x i16> @xtn_v4i64_v4i16(<4 x i64> %a) {
; CHECK-LABEL: xtn_v4i64_v4i16:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    uzp1 v0.4s, v0.4s, v1.4s
; CHECK-NEXT:    xtn v0.4h, v0.4s
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <4 x i64> %a to <4 x i16>
  ret <4 x i16> %arg1
}

define <4 x i32> @xtn_v4i64_v4i32(<4 x i64> %a) {
; CHECK-LABEL: xtn_v4i64_v4i32:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    uzp1 v0.4s, v0.4s, v1.4s
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <4 x i64> %a to <4 x i32>
  ret <4 x i32> %arg1
}

define <8 x i8> @xtn_v8i16_v8i8(<8 x i16> %a) {
; CHECK-LABEL: xtn_v8i16_v8i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    xtn v0.8b, v0.8h
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <8 x i16> %a to <8 x i8>
  ret <8 x i8> %arg1
}

define <8 x i8> @xtn_v8i32_v8i8(<8 x i32> %a) {
; CHECK-LABEL: xtn_v8i32_v8i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    uzp1 v0.8h, v0.8h, v1.8h
; CHECK-NEXT:    xtn v0.8b, v0.8h
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <8 x i32> %a to <8 x i8>
  ret <8 x i8> %arg1
}

define <8 x i16> @xtn_v8i32_v8i16(<8 x i32> %a) {
; CHECK-LABEL: xtn_v8i32_v8i16:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    uzp1 v0.8h, v0.8h, v1.8h
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <8 x i32> %a to <8 x i16>
  ret <8 x i16> %arg1
}

define <16 x i8> @xtn_v16i16_v16i8(<16 x i16> %a) {
; CHECK-LABEL: xtn_v16i16_v16i8:
; CHECK:       // %bb.0: // %entry
; CHECK-NEXT:    uzp1 v0.16b, v0.16b, v1.16b
; CHECK-NEXT:    ret
entry:
  %arg1 = trunc <16 x i16> %a to <16 x i8>
  ret <16 x i8> %arg1
}
