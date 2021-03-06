; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I

; Check load/store operations on values wider than what is natively supported

define i64 @load_i64(i64 *%a) nounwind {
; RV32I-LABEL: load_i64:
; RV32I: lw a2, 0(a0)
; RV32I: lw a1, 4(a0)
  %1 = load i64, i64* %a
  ret i64 %1
}

@val64 = local_unnamed_addr global i64 2863311530, align 8

; TODO: codegen on this should be improved. It shouldn't be necessary to
; generate two addi
define i64 @load_i64_global() nounwind {
; RV32I-LABEL: load_i64_global:
; RV32I: addi a0, a0, %lo(val64)
; RV32I: lw a0, 0(a0)
; RV32I: addi a1, a1, %lo(val64+4)
; RV32I: lw a1, 0(a1)
  %1 = load i64, i64* @val64
  ret i64 %1
}
