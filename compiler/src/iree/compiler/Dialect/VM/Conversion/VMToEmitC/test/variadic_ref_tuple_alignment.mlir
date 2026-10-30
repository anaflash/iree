// RUN: iree-opt --split-input-file --pass-pipeline="builtin.module(vm.module(iree-vm-ordinal-allocation),vm.module(iree-convert-vm-to-emitc))" %s | FileCheck %s

vm.module @my_module {
  vm.import private @variadic_fn(
      %arg0 : i64, %arg1 : i64,
      %arg2 : tuple<!vm.ref<?>, i64, i64> ...)

  // CHECK-LABEL: emitc.func private @my_module_call_0IICrIID_v_1_import_shim
  // CHECK: call_opaque "memcpy"({{.*}}, {{.*}}, {{.*}}) : (!emitc.ptr<ui8>, !emitc.ptr<i32>, !emitc.opaque<"iree_host_size_t">) -> ()
  // CHECK: literal "8" : !emitc.opaque<"iree_host_size_t">
  // CHECK: call_opaque "iree_host_align"
  // CHECK: call_opaque "iree_vm_ref_retain"
  vm.func @call_variadic(
      %arg0 : i64, %arg1 : i64,
      %arg2 : !vm.ref<?>, %arg3 : i64, %arg4 : i64) {
    vm.call.variadic @variadic_fn(
        %arg0, %arg1, [(%arg2, %arg3, %arg4)]) :
        (i64, i64, tuple<!vm.ref<?>, i64, i64> ...)
    vm.return
  }
}