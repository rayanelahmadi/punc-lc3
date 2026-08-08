; Indirect load.  Expects R0=0x00FF, R1=0xFFFF
        LDI R0, PA              ; R0 = mem[mem[PA]]
        LDI R1, PB
        HALT
PA:     .FILL A
PB:     .FILL B
A:      .FILL x00FF
B:      .FILL xFFFF
