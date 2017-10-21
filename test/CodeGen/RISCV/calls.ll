; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32I %s

declare i32 @external_function(i32) nounwind

define i32 @test_call_external(i32 %a) {
; RV32I-LABEL: test_call_external:
; RV32I: lui a1, %hi(external_function)
; RV32I: addi a1, a1, %lo(external_function)
; RV32I: jalr ra, a1, 0
  %1 = call i32 @external_function(i32 %a) nounwind
  ret i32 %1
}

define i32 @defined_function(i32 %a) nounwind noinline {
  %1 = add i32 %a, 1
  ret i32 %1
}

define i32 @test_call_defined(i32 %a) {
; RV32I-LABEL: test_call_defined:
; RV32I: lui a1, %hi(defined_function)
; RV32I: addi a1, a1, %lo(defined_function)
; RV32I: jalr ra, a1, 0
  %1 = call i32 @defined_function(i32 %a) nounwind
  ret i32 %1
}

define i32 @test_call_indirect(i32 (i32)* %a, i32 %b) {
; RV32I-LABEL: test_call_indirect:
; RV32I: addi a2, a0, 0
; RV32I: addi a0, a1, 0
; RV32I: jalr ra, a2, 0
  %1 = call i32 %a(i32 %b)
  ret i32 %1
}

; Ensure that calls to fastcc functions aren't rejected. Such calls may be
; introduced when compiling with optimisation.

define fastcc i32 @fastcc_function(i32 %a, i32 %b) {
 %1 = add i32 %a, %b
 ret i32 %1
}

define i32 @test_call_fastcc(i32 %a, i32 %b) {
; RV32I-LABEL: test_call_fastcc:
  %1 = call fastcc i32 @fastcc_function(i32 %a, i32 %b)
  ret i32 %a
}

declare i32 @external_many_args(i32, i32, i32, i32, i32, i32, i32, i32, i32, i32) nounwind

define i32 @test_call_external_many_args(i32 %a) {
; RV32I-LABEL: test_call_external_many_args:
; RV32I: lui a0, %hi(external_many_args)
; RV32I: addi t0, a0, %lo(external_many_args)
; RV32I: jalr ra, t0, 0
  %1 = call i32 @external_many_args(i32 %a, i32 %a, i32 %a, i32 %a, i32 %a,
                                    i32 %a, i32 %a, i32 %a, i32 %a, i32 %a)
  ret i32 %a
}

define i32 @defined_many_args(i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 %j) {
  %added = add i32 %j, 1
  ret i32 %added
}

define i32 @test_call_defined_many_args(i32 %a) {
; RV32I-LABEL: test_call_defined_many_args:
; RV32I: lui a1, %hi(defined_many_args)
; RV32I: addi t0, a1, %lo(defined_many_args)
; RV32I: jalr ra, t0, 0
  %1 = call i32 @defined_many_args(i32 %a, i32 %a, i32 %a, i32 %a, i32 %a,
                                   i32 %a, i32 %a, i32 %a, i32 %a, i32 %a)
  ret i32 %1
}
