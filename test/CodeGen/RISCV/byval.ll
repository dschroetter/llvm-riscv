; RUN: llc -mtriple=riscv32 -disable-fp-elim -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32I %s

%struct.Foo = type { i32, i32, i32, i16, i8 }
@foo = global %struct.Foo { i32 1, i32 2, i32 3, i16 4, i8 5 }, align 4

define i32 @callee(%struct.Foo* byval %f) nounwind {
entry:
; RV32I-LABEL: callee:
; RV32I: lw a0, 0(a0)
  %0 = getelementptr inbounds %struct.Foo, %struct.Foo* %f, i32 0, i32 0
  %1 = load i32, i32* %0, align 4
  ret i32 %1
}


define void @caller() nounwind {
entry:
; RV32I-LABEL: caller:
; RV32I: lui a0, %hi(foo)
; RV32I: addi a0, a0, %lo(foo)
; RV32I: lw a0, 0(a0)
; RV32I: sw a0, -24(s0)
; RV32I: addi a0, s0, -24
; RV32I-NEXT: jalr
  %call = call i32 @callee(%struct.Foo* byval @foo)
  ret void
}
