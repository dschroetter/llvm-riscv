# RUN: not llvm-mc -triple riscv32 -mattr=+f < %s 2>&1 | FileCheck %s

# Out of range immediates
## simm12
flw ft1, -2049(a0) # CHECK: :[[@LINE]]:10: error: immediate must be an integer in the range [-2048, 2047]
fsw ft2, 2048(a1) # CHECK: :[[@LINE]]:10: error: immediate must be an integer in the range [-2048, 2047]

# Memory operand not formatted correctly
flw ft1, a0, -200 # CHECK: :[[@LINE]]:10: error: immediate must be an integer in the range [-2048, 2047]
fsw ft2, a1, 100 # CHECK: :[[@LINE]]:10: error: immediate must be an integer in the range [-2048, 2047]

# Invalid register names
flw ft15, 100(a0) # CHECK: :[[@LINE]]:5: error: invalid operand for instruction
flw ft1, 100(a10) # CHECK: :[[@LINE]]:14: error: expected register
fsgnjn.s fa100, fa2, fa3 # CHECK: :[[@LINE]]:10: error: invalid operand for instruction

# Integer registers where FP regs are expected
fmv.x.w fs7, a2 # CHECK: :[[@LINE]]:9: error: invalid operand for instruction

# FP registers where integer regs are expected
fmv.w.x a8, ft2 # CHECK: :[[@LINE]]:9: error: invalid operand for instruction

# Using 'D' instructions for an 'F'-only target
fadd.d ft0, ft1, ft2 # CHECK: :[[@LINE]]:1: error: instruction use requires an option to be enabled

# Using RV64F instructions for RV32 is tested in rv64f-valid.s
