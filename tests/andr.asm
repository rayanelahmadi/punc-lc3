; AND with register operands.  Expects R2=2
        ADD R0, R0, #6          ; 0b0110
        ADD R1, R1, #3          ; 0b0011
        AND R2, R0, R1          ; 2
        HALT
