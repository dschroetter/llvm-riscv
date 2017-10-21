; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32I %s

@gi = external global i32

define i32 @constraint_r(i32 %a) {
; RV32I-LABEL: constraint_r:
; RV32I: add a0, a0, a1
  %1 = load i32, i32* @gi
  %2 = tail call i32 asm "add $0, $1, $2", "=r,r,r"(i32 %a, i32 %1)
  ret i32 %2
}

define i32 @constraint_i(i32 %a) {
; RV32I-LABEL: constraint_i:
; RV32I: addi a0, a0, 113
  %1 = load i32, i32* @gi
  %2 = tail call i32 asm "addi $0, $1, $2", "=r,r,i"(i32 %a, i32 113)
  ret i32 %2
}

define void @constraint_m(i32* %a) {
; RV32I-LABEL: constraint_m:
  call void asm sideeffect "", "=*m"(i32* %a)
  ret void
}

define i32 @constraint_m2(i32* %a) {
; RV32I-LABEL: constraint_m2:
; RV32I: lw a0, 0(a0)
  %1 = tail call i32 asm "lw $0, $1", "=r,*m"(i32* %a) nounwind
  ret i32 %1
}

; TODO: expend tests for more complex constraints, out of range immediates etc
