; RUN: llc -mtriple=riscv32 -disable-fp-elim -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32I %s

declare void @llvm.va_start(i8*)
declare void @llvm.va_end(i8*)

declare void @notdead(i8*)

; Although frontends are recommended to not generate va_arg due to the lack of
; support for aggregate types, we test simple cases here to ensure they are
; lowered correctly

 define i32 @va1(i8* %fmt, ...) {
; RV32I-LABEL: va1
; RV32I: addi sp, sp, -48
; RV32I: sw ra, 12(sp)
; RV32I: sw s0, 8(sp)
; RV32I: addi s0, sp, 16
; RV32I: sw a1, 4(s0)
; RV32I: sw a7, 28(s0)
; RV32I: sw a6, 24(s0)
; RV32I: sw a5, 20(s0)
; RV32I: sw a4, 16(s0)
; RV32I: sw a3, 12(s0)
; RV32I: sw a2, 8(s0)
; RV32I: addi a0, s0, 8
; RV32I: sw a0, -12(s0)
; RV32I: lw a0, 4(s0)
; RV32I: lw s0, 8(sp)
; RV32I: lw ra, 12(sp)
; RV32I: addi sp, sp, 48
; RV32I: jalr zero, ra, 0
  %va = alloca i8*, align 4
  %1 = bitcast i8** %va to i8*
  call void @llvm.va_start(i8* %1)
  %argp.cur = load i8*, i8** %va, align 4
  %argp.next = getelementptr inbounds i8, i8* %argp.cur, i32 4
  store i8* %argp.next, i8** %va, align 4
  %2 = bitcast i8* %argp.cur to i32*
  %3 = load i32, i32* %2, align 4
  call void @llvm.va_end(i8* %1)
  ret i32 %3
}

define i32 @va1_va_arg(i8* %fmt, ...) {
; RV32I-LABEL: va1_va_arg
; RV32I: addi sp, sp, -48
; RV32I: sw ra, 12(sp)
; RV32I: sw s0, 8(sp)
; RV32I: addi s0, sp, 16
; RV32I: sw a1, 4(s0)
; RV32I: sw a7, 28(s0)
; RV32I: sw a6, 24(s0)
; RV32I: sw a5, 20(s0)
; RV32I: sw a4, 16(s0)
; RV32I: sw a3, 12(s0)
; RV32I: sw a2, 8(s0)
; RV32I: addi a0, s0, 8
; RV32I: sw a0, -12(s0)
; RV32I: lw s0, 8(sp)
; RV32I: lw ra, 12(sp)
; RV32I: addi sp, sp, 48
; RV32I: jalr zero, ra, 0
  %va = alloca i8*, align 4
  %1 = bitcast i8** %va to i8*
  call void @llvm.va_start(i8* %1)
  %2 = va_arg i8** %va, i32
  call void @llvm.va_end(i8* %1)
  ret i32 %2
}

; Ensure the adjustment when restoring the stack pointer using the frame
; pointer is correct
define i32 @va1_va_arg_alloca(i8* %fmt, ...) {
; RV32I-LABEL: va1_va_arg_alloca:
; RV32I: addi sp, sp, -48
; RV32I: sw ra, 12(sp)
; RV32I: sw s0, 8(sp)
; RV32I: sw s1, 4(sp)
; RV32I: addi s0, sp, 16
; RV32I: addi sp, s0, -16
; RV32I: lw s0, 8(sp)
; RV32I: lw ra, 12(sp)
; RV32I: addi sp, sp, 48
  %va = alloca i8*, align 4
  %1 = bitcast i8** %va to i8*
  call void @llvm.va_start(i8* %1)
  %2 = va_arg i8** %va, i32
  %3 = alloca i8, i32 %2
  call void @notdead(i8* %3)
  call void @llvm.va_end(i8* %1)
  ret i32 %2
}

define void @va1_caller() {
; RV32I-LABEL: va1_caller:
; RV32I: lui a0, 261888
; RV32I: addi a3, a0, 0
; RV32I: lui a0, %hi(va1)
; RV32I: addi a0, a0, %lo(va1)
; RV32I: addi a4, zero, 2
; RV32I: addi a2, zero, 0
; RV32I: jalr ra, a0, 0
; Pass a double, as a float would be promoted by a C/C++ frontend
  %1 = call i32 (i8*, ...) @va1(i8* undef, double 1.0, i32 2)
  ret void
}

; Ensure that 2x xlen size+alignment varargs are accessed via an "aligned"
; register pair (wher the first register is even-numbered.

define double @va2(i8 *%fmt, ...) {
; RV32I-LABEL: va2:
; RV32I: addi sp, sp, -48
; RV32I: sw ra, 12(sp)
; RV32I: sw s0, 8(sp)
; RV32I: addi s0, sp, 16
; RV32I: sw a7, 28(s0)
; RV32I: sw a6, 24(s0)
; RV32I: sw a5, 20(s0)
; RV32I: sw a4, 16(s0)
; RV32I: sw a3, 12(s0)
; RV32I: sw a2, 8(s0)
; RV32I: sw a1, 4(s0)
; RV32I: addi a0, s0, 19
; RV32I: sw a0, -12(s0)
; RV32I: addi a0, s0, 11
; RV32I: andi a1, a0, -8
; RV32I: lw a0, 0(a1)
; RV32I: ori a1, a1, 4
; RV32I: lw a1, 0(a1)
; RV32I: lw s0, 8(sp)
; RV32I: lw ra, 12(sp)
; RV32I: addi sp, sp, 48
; RV32I: jalr zero, ra, 0
  %va = alloca i8*, align 4
  %1 = bitcast i8** %va to i8*
  call void @llvm.va_start(i8* %1)
  %2 = bitcast i8** %va to i32*
  %argp.cur = load i32, i32* %2, align 4
  %3 = add i32 %argp.cur, 7
  %4 = and i32 %3, -8
  %argp.cur.aligned = inttoptr i32 %3 to i8*
  %argp.next = getelementptr inbounds i8, i8* %argp.cur.aligned, i32 8
  store i8* %argp.next, i8** %va, align 4
  %5 = inttoptr i32 %4 to double*
  %6 = load double, double* %5, align 8
  call void @llvm.va_end(i8* %1)
  ret double %6
}

define double @va2_va_arg(i8 *%fmt, ...) {
; RV32I-LABEL: va2_va_arg:
; RV32I: addi sp, sp, -48
; RV32I: sw ra, 12(sp)
; RV32I: sw s0, 8(sp)
; RV32I: addi s0, sp, 16
; RV32I: sw a7, 28(s0)
; RV32I: sw a6, 24(s0)
; RV32I: sw a5, 20(s0)
; RV32I: sw a4, 16(s0)
; RV32I: sw a3, 12(s0)
; RV32I: sw a2, 8(s0)
; RV32I: sw a1, 4(s0)
; RV32I: addi a0, s0, 11
; RV32I: andi a0, a0, -8
; RV32I: ori a1, a0, 4
; RV32I: sw a1, -12(s0)
; RV32I: lw a0, 0(a0)
; RV32I: addi a2, a1, 4
; RV32I: sw a2, -12(s0)
; RV32I: lw a1, 0(a1)
; RV32I: lw  s0, 8(sp)
; RV32I: lw  ra, 12(sp)
; RV32I: addi  sp, sp, 48
; RV32I: jalr zero, ra, 0
  %va = alloca i8*, align 4
  %1 = bitcast i8** %va to i8*
  call void @llvm.va_start(i8* %1)
  %2 = va_arg i8** %va, double
  call void @llvm.va_end(i8* %1)
  ret double %2
}

define void @va2_caller() {
; RV32I-LABEL: va2_caller:
; RV32I: lui a0, 261888
; RV32I: addi a3, a0, 0
; RV32I: lui a0, %hi(va2)
; RV32I: addi a0, a0, %lo(va2)
; RV32I: addi a2, zero, 0
; RV32I: jalr ra, a0, 0
 %1 = call double (i8*, ...) @va2(i8* undef, double 1.000000e+00)
 ret void
}

; Ensure a named double argument is passed in a1 and a2, while the vararg
; double is passed in a4 and a5 (rather than a3 and a4)

define double @va3(i32 %a, double %b, ...) {
; RV32I-LABEL: va3:
; RV32I: addi sp, sp, -48
; RV32I: sw ra, 20(sp)
; RV32I: sw s0, 16(sp)
; RV32I: addi s0, sp, 24
; RV32I: sw a7, 20(s0)
; RV32I: sw a6, 16(s0)
; RV32I: sw a5, 12(s0)
; RV32I: sw a4, 8(s0)
; RV32I: sw a3, 4(s0)
; RV32I: addi a0, s0, 19
; RV32I: sw a0, -12(s0)
; RV32I: lui a0, %hi(__adddf3)
; RV32I: addi a5, a0, %lo(__adddf3)
; RV32I: addi a0, s0, 11
; RV32I: andi a0, a0, -8
; RV32I: lw a4, 0(a0)
; RV32I: ori a0, a0, 4
; RV32I: lw a3, 0(a0)
; RV32I: addi a0, a1, 0
; RV32I: addi a1, a2, 0
; RV32I: addi a2, a4, 0
; RV32I: jalr ra, a5, 0
; RV32I: lw s0, 16(sp)
; RV32I: lw ra, 20(sp)
; RV32I: addi sp, sp, 48
; RV32I: jalr zero, ra, 0
  %va = alloca i8*, align 4
  %1 = bitcast i8** %va to i8*
  call void @llvm.va_start(i8* %1)
  %2 = bitcast i8** %va to i32*
  %argp.cur = load i32, i32* %2, align 4
  %3 = add i32 %argp.cur, 7
  %4 = and i32 %3, -8
  %argp.cur.aligned = inttoptr i32 %3 to i8*
  %argp.next = getelementptr inbounds i8, i8* %argp.cur.aligned, i32 8
  store i8* %argp.next, i8** %va, align 4
  %5 = inttoptr i32 %4 to double*
  %6 = load double, double* %5, align 8
  call void @llvm.va_end(i8* %1)
  %7 = fadd double %b, %6
  ret double %7
}

define double @va3_va_arg(i32 %a, double %b, ...) {
; RV32I-LABEL: va3_va_arg:
; RV32I: addi sp, sp, -48
; RV32I: sw ra, 20(sp)
; RV32I: sw s0, 16(sp)
; RV32I: addi s0, sp, 24
; RV32I: sw a7, 20(s0)
; RV32I: sw a6, 16(s0)
; RV32I: sw a5, 12(s0)
; RV32I: sw a4, 8(s0)
; RV32I: sw a3, 4(s0)
; RV32I: addi a0, s0, 11
; RV32I: andi a0, a0, -8
; RV32I: ori a3, a0, 4
; RV32I: sw a3, -12(s0)
; RV32I: lw a4, 0(a0)
; RV32I: addi a0, a3, 4
; RV32I: sw a0, -12(s0)
; RV32I: lui a0, %hi(__adddf3)
; RV32I: addi a5, a0, %lo(__adddf3)
; RV32I: lw a3, 0(a3)
; RV32I: addi a0, a1, 0
; RV32I: addi a1, a2, 0
; RV32I: addi a2, a4, 0
; RV32I: jalr ra, a5, 0
; RV32I: lw s0, 16(sp)
; RV32I: lw ra, 20(sp)
; RV32I: addi sp, sp, 48
; RV32I: jalr zero, ra, 0
  %va = alloca i8*, align 4
  %1 = bitcast i8** %va to i8*
  call void @llvm.va_start(i8* %1)
  %2 = va_arg i8** %va, double
  call void @llvm.va_end(i8* %1)
  %3 = fadd double %b, %2
  ret double %3
}

define void @va3_caller() {
; RV32I-LABEL: va3_caller:
; RV32I: addi sp, sp, -16
; RV32I: sw ra, 12(sp)
; RV32I: sw s0, 8(sp)
; RV32I: addi s0, sp, 16
; RV32I: lui a0, 261888
; RV32I: addi a2, a0, 0
; RV32I: lui a0, 262144
; RV32I: addi a5, a0, 0
; RV32I: lui a0, %hi(va3)
; RV32I: addi a3, a0, %lo(va3)
; RV32I: addi a0, zero, 2
; RV32I: addi a1, zero, 0
; RV32I: addi a4, zero, 0
; RV32I: jalr ra, a3, 0
; RV32I: lw s0, 8(sp)
; RV32I: lw ra, 12(sp)
; RV32I: addi sp, sp, 16
; RV32I: jalr zero, ra, 0
 %1 = call double (i32, double, ...) @va3(i32 2, double 1.000000e+00, double 2.000000e+00)
 ret void
}

declare void @llvm.va_copy(i8*, i8*)

define i32 @va4_va_copy(i32 %argno, ...) {
; RV32I-LABEL: va4_va_copy:
; RV32I: addi sp, sp, -64
; RV32I: sw ra, 28(sp)
; RV32I: sw s0, 24(sp)
; RV32I: sw s1, 20(sp)
; RV32I: addi s0, sp, 32
; RV32I: sw a1, 4(s0)
; RV32I: sw a7, 28(s0)
; RV32I: sw a6, 24(s0)
; RV32I: sw a5, 20(s0)
; RV32I: sw a4, 16(s0)
; RV32I: sw a3, 12(s0)
; RV32I: sw a2, 8(s0)
; RV32I: addi a0, s0, 8
; RV32I: sw a0, -16(s0)
; RV32I: sw a0, -20(s0)
; RV32I: lw s1, 4(s0)
; RV32I: lui a1, %hi(notdead)
; RV32I: addi a1, a1, %lo(notdead)
; RV32I: jalr ra, a1, 0
; RV32I: lw a0, -16(s0)
; RV32I: addi a0, a0, 3
; RV32I: andi a0, a0, -4
; RV32I: addi a1, a0, 4
; RV32I: sw a1, -16(s0)
; RV32I: lw a1, 0(a0)
; RV32I: addi a0, a0, 7
; RV32I: andi a0, a0, -4
; RV32I: addi a2, a0, 4
; RV32I: sw a2, -16(s0)
; RV32I: lw a2, 0(a0)
; RV32I: addi a0, a0, 7
; RV32I: andi a0, a0, -4
; RV32I: addi a3, a0, 4
; RV32I: sw a3, -16(s0)
; RV32I: add a1, a1, s1
; RV32I: add a1, a1, a2
; RV32I: lw a0, 0(a0)
; RV32I: add a0, a1, a0
; RV32I: lw s1, 20(sp)
; RV32I: lw s0, 24(sp)
; RV32I: lw ra, 28(sp)
; RV32I: addi sp, sp, 64
; RV32I: jalr zero, ra, 0
  %vargs = alloca i8*, align 4
  %wargs = alloca i8*, align 4
  %1 = bitcast i8** %vargs to i8*
  %2 = bitcast i8** %wargs to i8*
  call void @llvm.va_start(i8* %1)
  %3 = va_arg i8** %vargs, i32
  call void @llvm.va_copy(i8* %2, i8* %1)
  %4 = load i8*, i8** %wargs, align 4
  call void @notdead(i8* %4)
  %5 = va_arg i8** %vargs, i32
  %6 = va_arg i8** %vargs, i32
  %7 = va_arg i8** %vargs, i32
  call void @llvm.va_end(i8* %1)
  call void @llvm.va_end(i8* %2)
  %add1 = add i32 %5, %3
  %add2 = add i32 %add1, %6
  %add3 = add i32 %add2, %7
  ret i32 %add3
}

; Check 2x*xlen values are aligned appropriately when passed on the stack in a vararg call

define i32 @va5_aligned_stack_callee(i32 %a, ...) {
; RV32I-LABEL: va5_aligned_stack_callee:
  ret i32 1
}

define void @va5_aligned_stack_caller() {
; The double should be 8-byte aligned on the stack, but the two-element array
; should only be 4-byte aligned
; RV32I-LABEL: va5_aligned_stack_caller:
; RV32I: addi a0, zero, 17
; RV32I: sw a0, 24(sp)
; RV32I: addi a0, zero, 16
; RV32I: sw a0, 20(sp)
; RV32I: addi a0, zero, 15
; RV32I: sw a0, 16(sp)
; RV32I: lui a0, 262236
; RV32I: addi a0, a0, 655
; RV32I: sw a0, 12(sp)
; RV32I: lui a0, 377487
; RV32I: addi a0, a0, 1475
; RV32I: sw a0, 8(sp)
; RV32I: addi a0, zero, 14
; RV32I: sw a0, 0(sp)
  %1 = call i32 (i32, ...) @va5_aligned_stack_callee(i32 1, i32 11,
    fp128 0xLEB851EB851EB851F400091EB851EB851, i32 12, i32 13, i64 20000000000,
    i32 14, double 2.720000e+00, i32 15, [2 x i32] [i32 16, i32 17])
  ret void
}

; A function with no fixed arguments is not valid C, but can be
; specified in LLVM IR. We must ensure the vararg save area is
; still set up correctly.

define i32 @va6_no_fixed_args(...) {
; RV32I-LABEL: va6_no_fixed_args:
; RV32I: addi sp, sp, -48
; RV32I: sw ra, 12(sp)
; RV32I: sw s0, 8(sp)
; RV32I: addi s0, sp, 16
; RV32I: sw a0, 0(s0)
; RV32I: sw a7, 28(s0)
; RV32I: sw a6, 24(s0)
; RV32I: sw a5, 20(s0)
; RV32I: sw a4, 16(s0)
; RV32I: sw a3, 12(s0)
; RV32I: sw a2, 8(s0)
; RV32I: sw a1, 4(s0)
; RV32I: addi a0, s0, 0
; RV32I: ori a0, a0, 4
; RV32I: sw a0, -12(s0)
; RV32I: lw a0, 0(s0)
; RV32I: lw s0, 8(sp)
; RV32I: lw ra, 12(sp)
; RV32I: addi sp, sp, 48
; RV32I: jalr zero, ra, 0
  %va = alloca i8*, align 4
  %1 = bitcast i8** %va to i8*
  call void @llvm.va_start(i8* %1)
  %2 = va_arg i8** %va, i32
  call void @llvm.va_end(i8* %1)
  ret i32 %2
}
