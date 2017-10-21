; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I

define i8 @sext_i1_to_i8(i1 %a) {
; RV32I-LABEL: sext_i1_to_i8
; RV32I: andi a0, a0, 1
; RV32I: sub a0, zero, a0
  %1 = sext i1 %a to i8
  ret i8 %1
}

define i16 @sext_i1_to_i16(i1 %a) {
; RV32I-LABEL: sext_i1_to_i16
; RV32I: andi a0, a0, 1
; RV32I: sub a0, zero, a0
  %1 = sext i1 %a to i16
  ret i16 %1
}

define i32 @sext_i1_to_i32(i1 %a) {
; RV32I-LABEL: sext_i1_to_i32
; RV32I: andi a0, a0, 1
; RV32I: sub a0, zero, a0
  %1 = sext i1 %a to i32
  ret i32 %1
}

define i64 @sext_i1_to_i64(i1 %a) {
; RV32I-LABEL: sext_i1_to_i64
; RV32I: andi a0, a0, 1
; RV32I: sub a0, zero, a0
  %1 = sext i1 %a to i64
  ret i64 %1
}

define i16 @sext_i8_to_i16(i8 %a) {
; RV32I-LABEL: sext_i8_to_i16
; RV32I: slli a0, a0, 24
; RV32I: srai a0, a0, 24
  %1 = sext i8 %a to i16
  ret i16 %1
}

define i32 @sext_i8_to_i32(i8 %a) {
; RV32I-LABEL: sext_i8_to_i32
; RV32I: slli a0, a0, 24
; RV32I: srai a0, a0, 24
  %1 = sext i8 %a to i32
  ret i32 %1
}

define i64 @sext_i8_to_i64(i8 %a) {
; RV32I-LABEL: sext_i8_to_i64
; RV32I: slli a1, a0, 24
; RV32I: srai a0, a1, 24
; RV32I: srai a1, a1, 31
  %1 = sext i8 %a to i64
  ret i64 %1
}

define i32 @sext_i16_to_i32(i16 %a) {
; RV32I-LABEL: sext_i16_to_i32
; RV32I: slli a0, a0, 16
; RV32I: srai a0, a0, 16
  %1 = sext i16 %a to i32
  ret i32 %1
}

define i64 @sext_i16_to_i64(i16 %a) {
; RV32I-LABEL: sext_i16_to_i64
; RV32I: slli a1, a0, 16
; RV32I: srai a0, a1, 16
; RV32I: srai a1, a1, 31
  %1 = sext i16 %a to i64
  ret i64 %1
}

define i64 @sext_i32_to_i64(i32 %a) {
; RV32I-LABEL: sext_i32_to_i64
; RV32I: srai a1, a0, 31
  %1 = sext i32 %a to i64
  ret i64 %1
}

define i8 @zext_i1_to_i8(i1 %a) {
; RV32I-LABEL: zext_i1_to_i8
; RV32I: andi a0, a0, 1
  %1 = zext i1 %a to i8
  ret i8 %1
}

define i16 @zext_i1_to_i16(i1 %a) {
; RV32I-LABEL: zext_i1_to_i16
; RV32I: andi a0, a0, 1
  %1 = zext i1 %a to i16
  ret i16 %1
}

define i32 @zext_i1_to_i32(i1 %a) {
; RV32I-LABEL: zext_i1_to_i32
; RV32I: andi a0, a0, 1
  %1 = zext i1 %a to i32
  ret i32 %1
}

define i64 @zext_i1_to_i64(i1 %a) {
; RV32I-LABEL: zext_i1_to_i64
; RV32I: andi a0, a0, 1
; RV32I: addi a1, zero, 0
  %1 = zext i1 %a to i64
  ret i64 %1
}

define i16 @zext_i8_to_i16(i8 %a) {
; RV32I-LABEL: zext_i8_to_i16
; RV32I: andi a0, a0, 255
  %1 = zext i8 %a to i16
  ret i16 %1
}

define i32 @zext_i8_to_i32(i8 %a) {
; RV32I-LABEL: zext_i8_to_i32
; RV32I: andi a0, a0, 255
  %1 = zext i8 %a to i32
  ret i32 %1
}

define i64 @zext_i8_to_i64(i8 %a) {
; RV32I-LABEL: zext_i8_to_i64
; RV32I: andi a0, a0, 255
; RV32I: addi a1, zero, 0
  %1 = zext i8 %a to i64
  ret i64 %1
}

define i32 @zext_i16_to_i32(i16 %a) {
; RV32I-LABEL: zext_i16_to_i32
; RV32I: lui a1, 16
; RV32I: addi a1, a1, -1
; RV32I: and a0, a0, a1
  %1 = zext i16 %a to i32
  ret i32 %1
}

define i64 @zext_i16_to_i64(i16 %a) {
; RV32I-LABEL: zext_i16_to_i64
; RV32I: lui a1, 16
; RV32I: addi a1, a1, -1
; RV32I: and a0, a0, a1
; RV32I: addi a1, zero, 0
  %1 = zext i16 %a to i64
  ret i64 %1
}

define i64 @zext_i32_to_i64(i32 %a) {
; RV32I-LABEL: zext_i32_to_i64
; RV32I: addi a1, zero, 0
  %1 = zext i32 %a to i64
  ret i64 %1
}

; TODO: should the trunc tests explicitly ensure no code is generated before
; jalr?

define i1 @trunc_i8_to_i1(i8 %a) {
; RV32I-LABEL: trunc_i8_to_i1
  %1 = trunc i8 %a to i1
  ret i1 %1
}

define i1 @trunc_i16_to_i1(i16 %a) {
; RV32I-LABEL: trunc_i16_to_i1
  %1 = trunc i16 %a to i1
  ret i1 %1
}

define i1 @trunc_i32_to_i1(i32 %a) {
; RV32I-LABEL: trunc_i32_to_i1
  %1 = trunc i32 %a to i1
  ret i1 %1
}

define i1 @trunc_i64_to_i1(i64 %a) {
; RV32I-LABEL: trunc_i64_to_i1
  %1 = trunc i64 %a to i1
  ret i1 %1
}

define i8 @trunc_i16_to_i8(i16 %a) {
; RV32I-LABEL: trunc_i16_to_i8
  %1 = trunc i16 %a to i8
  ret i8 %1
}

define i8 @trunc_i32_to_i8(i32 %a) {
; RV32I-LABEL: trunc_i32_to_i8
  %1 = trunc i32 %a to i8
  ret i8 %1
}

define i8 @trunc_i64_to_i8(i64 %a) {
; RV32I-LABEL: trunc_i64_to_i8
  %1 = trunc i64 %a to i8
  ret i8 %1
}

define i16 @trunc_i32_to_i16(i32 %a) {
; RV32I-LABEL: trunc_i32_to_i16
  %1 = trunc i32 %a to i16
  ret i16 %1
}

define i16 @trunc_i64_to_i16(i64 %a) {
; RV32I-LABEL: trunc_i64_to_i16
  %1 = trunc i64 %a to i16
  ret i16 %1
}

define i32 @trunc_i64_to_i32(i64 %a) {
; RV32I-LABEL: trunc_i64_to_i32
  %1 = trunc i64 %a to i32
  ret i32 %1
}
