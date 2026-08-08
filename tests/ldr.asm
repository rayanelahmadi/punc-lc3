; Base+offset load.  Expects R2=2, R3=3
        LD  R0, BASE
        LDR R2, R0, #0
        LDR R3, R0, #1
        HALT
BASE:   .FILL DATA
DATA:   .FILL 2
        .FILL 3
