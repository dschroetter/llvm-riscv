; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I

define i32 @bare_select(i1 %a, i32 %b, i32 %c) {
; RV32I-LABEL: bare_select:
; RV32I: andi a0, a0, 1
; RV32I: bne a0, zero, .LBB0_2
; RV32I: addi a1, a2, 0
; RV32I: .LBB0_2:
; RV32I: addi a0, a1, 0
  %1 = select i1 %a, i32 %b, i32 %c
  ret i32 %1
}
