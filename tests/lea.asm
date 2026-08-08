; Load effective address.  Expects R0=4, R1=6, R2=1
        LEA R0, FOUR
L1:     LEA R1, SIX
        LEA R2, L1
        HALT
        .ORIG 4
FOUR:   .FILL 0
        .ORIG 6
SIX:    .FILL 0
