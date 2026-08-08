; Unconditional jump.  Expects R1=1 (the ADD #7 must be skipped)
        LEA R0, TGT
        JMP R0
        ADD R1, R1, #7          ; skipped
        HALT
TGT:    ADD R1, R1, #1
        HALT
