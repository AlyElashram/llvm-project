; RUN: not llc -O0 -mtriple=spirv32-unknown-unknown %s -o %t.spvt 2>&1 | FileCheck %s --check-prefix=CHECK-ERROR1
; RUN: not llc -O0 -mtriple=spirv32-unknown-unknown --spirv-ext=+SPV_EXT_shader_atomic_float_add %s -o %t.spvt 2>&1 | FileCheck %s --check-prefix=CHECK-ERROR2

; RUN: llc -verify-machineinstrs -O0 -mtriple=spirv32-unknown-unknown --spirv-ext=+SPV_EXT_shader_atomic_float_add,+SPV_EXT_shader_atomic_float16_add %s -o - | FileCheck %s

; CHECK-ERROR1: LLVM ERROR: The atomic float instruction requires the following SPIR-V extension: SPV_EXT_shader_atomic_float_add
; CHECK-ERROR2: LLVM ERROR: The atomic float instruction requires the following SPIR-V extension: SPV_EXT_shader_atomic_float16_add

; CHECK: Capability AtomicFloat16AddEXT
; CHECK: Extension "SPV_EXT_shader_atomic_float_add"
; CHECK: Extension "SPV_EXT_shader_atomic_float16_add"
; CHECK-DAG: %[[TyFP16:[0-9]+]] = OpTypeFloat 16
; CHECK-DAG: %[[TyInt32:[0-9]+]] = OpTypeInt 32 0
; CHECK-DAG: %[[Const0:[0-9]+]] = OpConstantNull %[[TyFP16]]
; CHECK-DAG: %[[Const42:[0-9]+]] = OpConstant %[[TyFP16]] 20800{{$}}
; CHECK-DAG: %[[ScopeAllSvmDevices:[0-9]+]] = OpConstantNull %[[TyInt32]]
; CHECK-DAG: %[[MemSeqCst:[0-9]+]] = OpConstant %[[TyInt32]] 16{{$}}
; CHECK-DAG: %[[ScopeDevice:[0-9]+]] = OpConstant %[[TyInt32]] 1{{$}}
; CHECK-DAG: %[[TyFP16Ptr:[0-9]+]] = OpTypePointer {{[a-zA-Z]+}} %[[TyFP16]]
; CHECK-DAG: %[[DblPtr:[0-9]+]] = OpVariable %[[TyFP16Ptr]] {{[a-zA-Z]+}} %[[Const0]]
; CHECK: OpAtomicFAddEXT %[[TyFP16]] %[[DblPtr]] %[[ScopeAllSvmDevices]] %[[MemSeqCst]] %[[Const42]]
; CHECK: %[[Const42Neg:[0-9]+]] = OpFNegate %[[TyFP16]] %[[Const42]]
; CHECK: OpAtomicFAddEXT %[[TyFP16]] %[[DblPtr]] %[[ScopeAllSvmDevices]] %[[MemSeqCst]] %[[Const42Neg]]
; CHECK: OpAtomicFAddEXT %[[TyFP16]] %[[DblPtr]] %[[ScopeDevice]] %[[MemSeqCst]] %[[Const42]]

@f = common dso_local local_unnamed_addr addrspace(1) global half 0.000000e+00, align 8

define dso_local spir_func void @test1() local_unnamed_addr {
entry:
  %addval = atomicrmw fadd ptr addrspace(1) @f, half 42.000000e+00 seq_cst
  %subval = atomicrmw fsub ptr addrspace(1) @f, half 42.000000e+00 seq_cst
  ret void
}

define dso_local spir_func void @test2() local_unnamed_addr {
entry:
  %addval = tail call spir_func half @_Z21__spirv_AtomicFAddEXT(ptr addrspace(1) @f, i32 1, i32 16, half 42.000000e+00)
  ret void
}

declare dso_local spir_func half @_Z21__spirv_AtomicFAddEXT(ptr addrspace(1), i32, i32, half)

!llvm.module.flags = !{!0}
!0 = !{i32 1, !"wchar_size", i32 4}
