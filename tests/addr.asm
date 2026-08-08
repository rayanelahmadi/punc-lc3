; ADD with register operands.  Expects R2=8, R3=13
        ADD R0, R0, #3
        ADD R1, R1, #5
        ADD R2, R0, R1          ; 3 + 5
        ADD R3, R2, R1          ; 8 + 5
        HALT
