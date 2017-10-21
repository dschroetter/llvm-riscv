; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I

@addr = global i8* null

define void @test_blockaddress() {
; RV32I-LABEL: test_blockaddress:
; RV32I: lui a0, %hi(addr)
; RV32I: addi a0, a0, %lo(addr)
; RV32I: lui a1, %hi(.Ltmp0)
; RV32I: addi a1, a1, %lo(.Ltmp0)
; RV32I: sw a1, 0(a0)
; RV32I: lw a0, 0(a0)
; RV32I: jalr zero, a0, 0
  store volatile i8* blockaddress(@test_blockaddress, %block), i8** @addr
  %val = load volatile i8*, i8** @addr
  indirectbr i8* %val, [label %block]

block:
  ret void
}
