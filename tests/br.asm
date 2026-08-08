; Conditional branch.  Expects R1=5 (the ADD #9 must be skipped)
        ADD R0, R0, #5          ; sets the P flag
        BRp SKIP
        ADD R1, R1, #9          ; skipped
SKIP:   ADD R1, R1, #5
        HALT
