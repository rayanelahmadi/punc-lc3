; Bitwise NOT.  Expects R2=0, R3=0xFFF0
        ADD R0, R0, #-1         ; 0xFFFF
        NOT R2, R0              ; 0x0000
        ADD R1, R1, #15         ; 0x000F
        NOT R3, R1              ; 0xFFF0
        HALT
