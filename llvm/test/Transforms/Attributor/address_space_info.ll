; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --check-attributes --check-globals --prefix-filecheck-ir-name true
; RUN: opt -mtriple=amdgcn-amd-amdhsa -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefix=CHECK

; REQUIRES: amdgpu-registered-target

@dst = dso_local addrspace(1) externally_initialized global i32 0, align 4
@g1 = dso_local addrspace(1) externally_initialized global ptr null, align 4
@g2 = dso_local addrspace(1) externally_initialized global i32 0, align 4
@s1 = dso_local addrspace(3) global i32 undef, align 4
@s2 = dso_local addrspace(3) global i32 undef, align 4

;.
; CHECK: @dst = dso_local addrspace(1) externally_initialized global i32 0, align 4
; CHECK: @g1 = dso_local addrspace(1) externally_initialized global ptr null, align 4
; CHECK: @g2 = dso_local addrspace(1) externally_initialized global i32 0, align 4
; CHECK: @s1 = dso_local addrspace(3) global i32 undef, align 4
; CHECK: @s2 = dso_local addrspace(3) global i32 undef, align 4
;.
define internal void @_Z12global_writePi(ptr noundef %p) #0 {
; CHECK: Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(write)
; CHECK-LABEL: define {{[^@]+}}@_Z12global_writePi
; CHECK-SAME: (ptr nofree noundef nonnull writeonly align 4 dereferenceable(8) [[P:%.*]]) #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = addrspacecast ptr [[P]] to ptr addrspace(1)
; CHECK-NEXT:    store ptr [[P]], ptr addrspace(1) [[TMP0]], align 4
; CHECK-NEXT:    ret void
;
entry:
  store ptr %p, ptr %p, align 4
  ret void
}

; Function Attrs: convergent mustprogress noinline nounwind
define internal void @_Z13unknown_writePi(ptr noundef %p) #0 {
; CHECK: Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(write)
; CHECK-LABEL: define {{[^@]+}}@_Z13unknown_writePi
; CHECK-SAME: (ptr nofree noundef nonnull writeonly align 4 captures(none) dereferenceable(4) [[P:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    store i32 2, ptr [[P]], align 4
; CHECK-NEXT:    ret void
;
entry:
  store i32 2, ptr %p, align 4
  ret void
}

; Function Attrs: convergent mustprogress noinline nounwind
define internal void @_Z12shared_writePi(ptr noundef %p) #0 {
; CHECK: Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(write)
; CHECK-LABEL: define {{[^@]+}}@_Z12shared_writePi
; CHECK-SAME: (ptr nofree noundef nonnull writeonly align 4 captures(none) dereferenceable(4) [[P:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = addrspacecast ptr [[P]] to ptr addrspace(3)
; CHECK-NEXT:    store i32 3, ptr addrspace(3) [[TMP0]], align 4
; CHECK-NEXT:    ret void
;
entry:
  store i32 3, ptr %p, align 4
  ret void
}

; Function Attrs: convergent mustprogress noinline nounwind
define internal void @_Z11global_readPi(ptr noundef %p) #0 {
; CHECK: Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn
; CHECK-LABEL: define {{[^@]+}}@_Z11global_readPi
; CHECK-SAME: (ptr nofree noundef nonnull readonly align 4 captures(none) dereferenceable(4) [[P:%.*]]) #[[ATTR1:[0-9]+]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = addrspacecast ptr [[P]] to ptr addrspace(1)
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, ptr addrspace(1) [[TMP0]], align 4
; CHECK-NEXT:    store i32 [[TMP1]], ptr addrspace(1) @dst, align 4
; CHECK-NEXT:    ret void
;
entry:
  %0 = load i32, ptr %p, align 4
  store i32 %0, ptr addrspacecast (ptr addrspace(1) @dst to ptr), align 4
  ret void
}

; Function Attrs: convergent mustprogress noinline nounwind
define internal void @_Z12unknown_readPi(ptr noundef %p) #0 {
; CHECK: Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn
; CHECK-LABEL: define {{[^@]+}}@_Z12unknown_readPi
; CHECK-SAME: (ptr nofree noundef nonnull readonly align 4 captures(none) dereferenceable(4) [[P:%.*]]) #[[ATTR1]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, ptr [[P]], align 4
; CHECK-NEXT:    store i32 [[TMP0]], ptr addrspace(1) @dst, align 4
; CHECK-NEXT:    ret void
;
entry:
  %0 = load i32, ptr %p, align 4
  store i32 %0, ptr addrspacecast (ptr addrspace(1) @dst to ptr), align 4
  ret void
}

; Function Attrs: convergent mustprogress noinline nounwind
define internal void @_Z11shared_readPi(ptr noundef %p) #0 {
; CHECK: Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn
; CHECK-LABEL: define {{[^@]+}}@_Z11shared_readPi
; CHECK-SAME: (ptr nofree noundef nonnull readonly align 4 captures(none) dereferenceable(4) [[P:%.*]]) #[[ATTR1]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = addrspacecast ptr [[P]] to ptr addrspace(3)
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, ptr addrspace(3) [[TMP0]], align 4
; CHECK-NEXT:    store i32 [[TMP1]], ptr addrspace(1) @dst, align 4
; CHECK-NEXT:    ret void
;
entry:
  %0 = load i32, ptr %p, align 4
  store i32 %0, ptr addrspacecast (ptr addrspace(1) @dst to ptr), align 4
  ret void
}

; Function Attrs: convergent mustprogress noinline nounwind
define dso_local void @_Z3bazv() #0 {
; CHECK: Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn
; CHECK-LABEL: define {{[^@]+}}@_Z3bazv
; CHECK-SAME: () #[[ATTR1]] {
; CHECK-NEXT:  entry:
; CHECK-NEXT:    call void @_Z12global_writePi(ptr nofree noundef nonnull writeonly align 4 dereferenceable(8) addrspacecast (ptr addrspace(1) @g1 to ptr)) #[[ATTR2:[0-9]+]]
; CHECK-NEXT:    call void @_Z12global_writePi(ptr nofree noundef nonnull writeonly align 4 dereferenceable(4) addrspacecast (ptr addrspace(1) @g2 to ptr)) #[[ATTR2]]
; CHECK-NEXT:    call void @_Z13unknown_writePi(ptr nofree noundef nonnull writeonly align 4 captures(none) dereferenceable(8) addrspacecast (ptr addrspace(1) @g1 to ptr)) #[[ATTR2]]
; CHECK-NEXT:    call void @_Z13unknown_writePi(ptr nofree noundef nonnull writeonly align 4 captures(none) dereferenceable(4) addrspacecast (ptr addrspace(3) @s1 to ptr)) #[[ATTR2]]
; CHECK-NEXT:    call void @_Z12shared_writePi(ptr nofree noundef nonnull writeonly align 4 captures(none) dereferenceable(4) addrspacecast (ptr addrspace(3) @s1 to ptr)) #[[ATTR2]]
; CHECK-NEXT:    call void @_Z12shared_writePi(ptr nofree noundef nonnull writeonly align 4 captures(none) dereferenceable(4) addrspacecast (ptr addrspace(3) @s2 to ptr)) #[[ATTR2]]
; CHECK-NEXT:    call void @_Z11global_readPi(ptr nofree noundef nonnull readonly align 4 captures(none) dereferenceable(8) addrspacecast (ptr addrspace(1) @g1 to ptr)) #[[ATTR3:[0-9]+]]
; CHECK-NEXT:    call void @_Z11global_readPi(ptr nofree noundef nonnull readonly align 4 captures(none) dereferenceable(4) addrspacecast (ptr addrspace(1) @g2 to ptr)) #[[ATTR3]]
; CHECK-NEXT:    call void @_Z12unknown_readPi(ptr nofree noundef nonnull readonly align 4 captures(none) dereferenceable(8) addrspacecast (ptr addrspace(1) @g1 to ptr)) #[[ATTR3]]
; CHECK-NEXT:    call void @_Z12unknown_readPi(ptr nofree noundef nonnull readonly align 4 captures(none) dereferenceable(4) addrspacecast (ptr addrspace(3) @s1 to ptr)) #[[ATTR3]]
; CHECK-NEXT:    call void @_Z11shared_readPi(ptr nofree noundef nonnull readonly align 4 captures(none) dereferenceable(4) addrspacecast (ptr addrspace(3) @s1 to ptr)) #[[ATTR3]]
; CHECK-NEXT:    call void @_Z11shared_readPi(ptr nofree noundef nonnull readonly align 4 captures(none) dereferenceable(4) addrspacecast (ptr addrspace(3) @s2 to ptr)) #[[ATTR3]]
; CHECK-NEXT:    ret void
;
entry:
  call void @_Z12global_writePi(ptr noundef addrspacecast (ptr addrspace(1) @g1 to ptr)) #1
  call void @_Z12global_writePi(ptr noundef addrspacecast (ptr addrspace(1) @g2 to ptr)) #1
  call void @_Z13unknown_writePi(ptr noundef addrspacecast (ptr addrspace(1) @g1 to ptr)) #1
  call void @_Z13unknown_writePi(ptr noundef addrspacecast (ptr addrspace(3) @s1 to ptr)) #1
  call void @_Z12shared_writePi(ptr noundef addrspacecast (ptr addrspace(3) @s1 to ptr)) #1
  call void @_Z12shared_writePi(ptr noundef addrspacecast (ptr addrspace(3) @s2 to ptr)) #1
  call void @_Z11global_readPi(ptr noundef addrspacecast (ptr addrspace(1) @g1 to ptr)) #1
  call void @_Z11global_readPi(ptr noundef addrspacecast (ptr addrspace(1) @g2 to ptr)) #1
  call void @_Z12unknown_readPi(ptr noundef addrspacecast (ptr addrspace(1) @g1 to ptr)) #1
  call void @_Z12unknown_readPi(ptr noundef addrspacecast (ptr addrspace(3) @s1 to ptr)) #1
  call void @_Z11shared_readPi(ptr noundef addrspacecast (ptr addrspace(3) @s1 to ptr)) #1
  call void @_Z11shared_readPi(ptr noundef addrspacecast (ptr addrspace(3) @s2 to ptr)) #1
  ret void
}

attributes #0 = { convergent mustprogress noinline nounwind }
attributes #1 = { convergent nounwind }
;.
; CHECK: attributes #[[ATTR0]] = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(write) }
; CHECK: attributes #[[ATTR1]] = { mustprogress nofree noinline norecurse nosync nounwind willreturn }
; CHECK: attributes #[[ATTR2]] = { convergent nofree nosync nounwind willreturn memory(write) }
; CHECK: attributes #[[ATTR3]] = { convergent nofree nosync nounwind willreturn }
;.
