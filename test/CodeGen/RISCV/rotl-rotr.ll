; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I

; These IR sequences will generate ISD::ROTL and ISD::ROTR nodes, that the 
; RISC-V backend must be able to select

define i32 @rotl(i32 %x, i32 %y) {
; RV32I-LABEL: rotl:
  %z = sub i32 32, %y
  %b = shl i32 %x, %y
  %c = lshr i32 %x, %z
  %d = or i32 %b, %c
  ret i32 %d
}

define i32 @rotr(i32 %x, i32 %y) {
; RV32I-LABEL: rotr:
  %z = sub i32 32, %y
  %b = lshr i32 %x, %y
  %c = shl i32 %x, %z
  %d = or i32 %b, %c
  ret i32 %d
}
