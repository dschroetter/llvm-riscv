; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I

; Basic shift support is tested as part of ALU.ll. This file ensures that
; shifts which may not be supported natively are lowered properly.

define i64 @lshr64(i64 %a, i64 %b) nounwind {
; RV32I-LABEL: lshr64:
; RV32I: lui a3, %hi(__lshrdi3)
; RV32I: addi a3, a3, %lo(__lshrdi3)
  %1 = lshr i64 %a, %b
  ret i64 %1
}

define i64 @ashr64(i64 %a, i64 %b) nounwind {
; RV32I-LABEL: ashr64:
; RV32I: lui a3, %hi(__ashrdi3)
; RV32I: addi a3, a3, %lo(__ashrdi3)
  %1 = ashr i64 %a, %b
  ret i64 %1
}

define i64 @shl64(i64 %a, i64 %b) nounwind {
; RV32I-LABEL: shl64:
; RV32I: lui a3, %hi(__ashldi3)
; RV32I: addi a3, a3, %lo(__ashldi3)
  %1 = shl i64 %a, %b
  ret i64 %1
}
