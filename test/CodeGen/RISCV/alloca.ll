; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I

declare void @notdead(i8*)

; These tests must ensure the stack pointer is restored using the frame
; pointer

define void @simple_alloca(i32 %n) {
; RV32I-LABEL: simple_alloca:
; RV32I: addi sp, sp, -16
; RV32I: sw ra, 12(sp)
; RV32I: sw s0, 8(sp)
; RV32I: addi s0, sp, 16
; RV32I: addi a0, a0, 15
; RV32I: andi a0, a0, -16
; RV32I: sub a0, sp, a0
; RV32I: addi sp, a0, 0
; RV32I: lui a1, %hi(notdead)
; RV32I: addi a1, a1, %lo(notdead)
; RV32I: jalr ra, a1, 0
; RV32I: addi sp, s0, -16
; RV32I: lw s0, 8(sp)
; RV32I: lw ra, 12(sp)
; RV32I: addi sp, sp, 16
; RV32I: jalr zero, ra, 0
  %1 = alloca i8, i32 %n
  call void @notdead(i8* %1)
  ret void
}

declare i8* @llvm.stacksave()
declare void @llvm.stackrestore(i8*)

define void @scoped_alloca(i32 %n) {
; RV32I-LABEL: scoped_alloca:
; RV32I: addi sp, sp, -16
; RV32I: sw ra, 12(sp)
; RV32I: sw s0, 8(sp)
; RV32I: sw s1, 4(sp)
; RV32I: addi s0, sp, 16
; RV32I: addi s1, sp, 0
; RV32I: addi a0, a0, 15
; RV32I: andi a0, a0, -16
; RV32I: sub a0, sp, a0
; RV32I: addi sp, a0, 0
; RV32I: lui a1, %hi(notdead)
; RV32I: addi a1, a1, %lo(notdead)
; RV32I: jalr ra, a1, 0
; RV32I: addi sp, s1, 0
; RV32I: addi sp, s0, -16
; RV32I: lw s1, 4(sp)
; RV32I: lw s0, 8(sp)
; RV32I: lw ra, 12(sp)
; RV32I: addi sp, sp, 16
; RV32I: jalr zero, ra, 0
  %sp = call i8* @llvm.stacksave()
  %addr = alloca i8, i32 %n
  call void @notdead(i8* %addr)
  call void @llvm.stackrestore(i8* %sp)
  ret void
}
