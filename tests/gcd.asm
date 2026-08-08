; Greatest common divisor by repeated subtraction: gcd(9, 6) = 3
; Expects R0=3, R1=3, MEM[23]=3
        LD    R0, A             ; 9
        LD    R1, B             ; 6
LOOP:   NOT   R2, R1
        ADD   R2, R2, #1        ; R2 = -R1
        ADD   R3, R0, R2        ; R3 = R0 - R1
        BRz   DONE              ; equal -> done
        BRp   AGT               ; R0 > R1
        NOT   R2, R0
        ADD   R2, R2, #1        ; R2 = -R0
        ADD   R1, R1, R2        ; R1 = R1 - R0
        BRnzp LOOP
AGT:    ADD   R0, R3, #0        ; R0 = R0 - R1
        BRnzp LOOP
DONE:   ST    R0, RES
        HALT
A:      .FILL 9
B:      .FILL 6
        .ORIG 23
RES:    .FILL 0
