; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32I %s

declare void @notdead(i8*)
declare i8* @llvm.frameaddress(i32)
declare i8* @llvm.returnaddress(i32)

define i8* @test_frameaddress_0() {
; RV32I-LABEL: test_frameaddress_0:
; RV32I: addi sp, sp, -16
; RV32I: addi s0, sp, 16
; RV32I: addi a0, s0, 0
; RV32I: jalr zero, ra, 0
  %1 = call i8* @llvm.frameaddress(i32 0)
  ret i8* %1
}

define i8* @test_frameaddress_2() {
; RV32I-LABEL: test_frameaddress_2:
; RV32I: addi sp, sp, -16
; RV32I: addi s0, sp, 16
; RV32I: lw a0, -8(s0)
; RV32I: lw a0, -8(a0)
; RV32I: jalr zero, ra, 0
  %1 = call i8* @llvm.frameaddress(i32 2)
  ret i8* %1
}

define i8* @test_frameaddress_3_alloca() {
; RV32I-LABEL: test_frameaddress_3_alloca:
; RV32I: addi sp, sp, -112
; RV32I: sw ra, 108(sp)
; RV32I: sw s0, 104(sp)
; RV32I: addi s0, sp, 112
; RV32I: lw a0, -8(s0)
; RV32I: lw a0, -8(a0)
; RV32I: lw a0, -8(a0)
; RV32I: jalr zero, ra, 0
  %1 = alloca [100 x i8]
  %2 = bitcast [100 x i8]* %1 to i8*
  call void @notdead(i8* %2)
  %3 = call i8* @llvm.frameaddress(i32 3)
  ret i8* %3
}

define i8* @test_returnaddress_0() {
; RV32I-LABEL: test_returnaddress_0:
; RV32I: addi a0, ra, 0
; RV32I: jalr zero, ra, 0
  %1 = call i8* @llvm.returnaddress(i32 0)
  ret i8* %1
}

define i8* @test_returnaddress_2() {
; RV32I-LABEL: test_returnaddress_2:
; RV32I: addi sp, sp, -16
; RV32I: addi s0, sp, 16
; RV32I: lw a0, -8(s0)
; RV32I: lw a0, -8(a0)
; RV32I: lw a0, -4(a0)
; RV32I: jalr zero, ra, 0
  %1 = call i8* @llvm.returnaddress(i32 2)
  ret i8* %1
}
