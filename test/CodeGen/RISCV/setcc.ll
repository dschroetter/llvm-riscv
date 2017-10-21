; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I

; TODO: check the generated instructions for the equivalent of seqz, snez,
; sltz, sgtz map to something simple

define i32 @eq(i32 %a, i32 %b) nounwind {
; RV32I-LABEL: eq:
; RV32I: xor a0, a0, a1
; RV32I: sltiu a0, a0, 1
  %1 = icmp eq i32 %a, %b
  %2 = zext i1 %1 to i32
  ret i32 %2
}

define i32 @ne(i32 %a, i32 %b) nounwind {
; RV32I-LABEL: ne:
; RV32I: xor a0, a0, a1
; RV32I: sltu a0, zero, a0
  %1 = icmp ne i32 %a, %b
  %2 = zext i1 %1 to i32
  ret i32 %2
}

define i32 @ugt(i32 %a, i32 %b) nounwind {
; RV32I-LABEL: ugt:
; RV32I: sltu a0, a1, a0
  %1 = icmp ugt i32 %a, %b
  %2 = zext i1 %1 to i32
  ret i32 %2
}

define i32 @uge(i32 %a, i32 %b) nounwind {
; RV32I-LABEL: uge:
; RV32I: sltu a0, a0, a1
; RV32I: xori a0, a0, 1
  %1 = icmp uge i32 %a, %b
  %2 = zext i1 %1 to i32
  ret i32 %2
}

define i32 @ult(i32 %a, i32 %b) nounwind {
; RV32I-LABEL: ult:
; RV32I: sltu a0, a0, a1
  %1 = icmp ult i32 %a, %b
  %2 = zext i1 %1 to i32
  ret i32 %2
}

define i32 @ule(i32 %a, i32 %b) nounwind {
; RV32I-LABEL: ule:
; RV32I: sltu a0, a1, a0
; RV32I: xori a0, a0, 1
  %1 = icmp ule i32 %a, %b
  %2 = zext i1 %1 to i32
  ret i32 %2
}

define i32 @sgt(i32 %a, i32 %b) nounwind {
; RV32I-LABEL: sgt:
; RV32I: slt a0, a1, a0
  %1 = icmp sgt i32 %a, %b
  %2 = zext i1 %1 to i32
  ret i32 %2
}

define i32 @sge(i32 %a, i32 %b) nounwind {
; RV32I-LABEL: sge:
; RV32I: slt a0, a0, a1
; RV32I: xori a0, a0, 1
  %1 = icmp sge i32 %a, %b
  %2 = zext i1 %1 to i32
  ret i32 %2
}

define i32 @slt(i32 %a, i32 %b) nounwind {
; RV32I-LABEL: slt:
; RV32I: slt a0, a0, a1
  %1 = icmp slt i32 %a, %b
  %2 = zext i1 %1 to i32
  ret i32 %2
}

define i32 @sle(i32 %a, i32 %b) nounwind {
; RV32I-LABEL: sle:
; RV32I: slt a0, a1, a0
; RV32I: xori a0, a0, 1
  %1 = icmp sle i32 %a, %b
  %2 = zext i1 %1 to i32
  ret i32 %2
}

; TODO: check variants with an immediate?
