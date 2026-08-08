; PC-relative load.  Expects R0=1, R1=2, R2=4, R3=0x2402
        LD  R0, ONE
        LD  R1, TWO
        LD  R2, FOUR
        LD  R3, WORD
        HALT
ONE:    .FILL 1
TWO:    .FILL 2
FOUR:   .FILL 4
WORD:   .FILL x2402
