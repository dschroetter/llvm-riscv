; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32I %s
; RUN: llc -mtriple=riscv32 -disable-fp-elim -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32I-FPTR %s

%struct.key_t = type { i32, [16 x i8] }

; Function Attrs: nounwind uwtable
define i32 @test() {
; RV32I-LABEL: test:
; RV32I: addi sp, sp, -32
; RV32I: sw ra, 28(sp)
; RV32I: sw zero, 24(sp)
; RV32I: sw zero, 20(sp)
; RV32I: sw zero, 16(sp)
; RV32I: sw zero, 12(sp)
; RV32I: sw zero, 8(sp)
; RV32I: addi a0, sp, 8
; RV32I: ori a0, a0, 4
; RV32I: lui a1, %hi(test1)
; RV32I: addi a1, a1, %lo(test1)
; RV32I: jalr ra, a1, 0
; RV32I: addi a0, zero, 0
; RV32I: lw ra, 28(sp)
; RV32I: addi sp, sp, 32
; RV32I: jalr zero, ra, 0

; RV32I-FPTR-LABEL: test:
; RV32I-FPTR: addi sp, sp, -32
; RV32I-FPTR: sw ra, 28(sp)
; RV32I-FPTR: sw s0, 24(sp)
; RV32I-FPTR: addi s0, sp, 32
; RV32I-FPTR: sw zero, -16(s0)
; RV32I-FPTR: sw zero, -20(s0)
; RV32I-FPTR: sw zero, -24(s0)
; RV32I-FPTR: sw zero, -28(s0)
; RV32I-FPTR: sw zero, -32(s0)
; RV32I-FPTR: addi a0, s0, -32
; RV32I-FPTR: ori a0, a0, 4
; RV32I-FPTR: lui a1, %hi(test1)
; RV32I-FPTR: addi a1, a1, %lo(test1)
; RV32I-FPTR: jalr ra, a1, 0
; RV32I-FPTR: addi a0, zero, 0
; RV32I-FPTR: lw s0, 24(sp)
; RV32I-FPTR: lw ra, 28(sp)
; RV32I-FPTR: addi sp, sp, 32
; RV32I-FPTR: jalr zero, ra, 0
  %key = alloca %struct.key_t, align 4
  %1 = bitcast %struct.key_t* %key to i8*
  call void @llvm.memset.p0i8.i64(i8* %1, i8 0, i64 20, i32 4, i1 false)
  %2 = getelementptr inbounds %struct.key_t, %struct.key_t* %key, i64 0, i32 1, i64 0
  call void @test1(i8* %2) #3
  ret i32 0
}

; Function Attrs: nounwind argmemonly
declare void @llvm.memset.p0i8.i64(i8* nocapture, i8, i64, i32, i1)

declare void @test1(i8*)
