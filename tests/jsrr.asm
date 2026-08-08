; Jump to subroutine via base register.  Expects R1=3
        LEA R0, SUB
        JSRR R0
SUB:    ADD R1, R1, #3
        HALT
