; AND with an immediate operand.  Expects R1=2, R3=0
        ADD R0, R0, #6          ; 0b0110
        AND R1, R0, #3          ; 0b0110 & 0b0011 = 2
        AND R3, R0, #0          ; clear
        HALT
