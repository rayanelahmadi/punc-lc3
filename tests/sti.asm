; Indirect store.  Expects MEM[0]=15
A0:     ADD R0, R0, #15
        STI R0, PTR             ; mem[mem[PTR]] = R0
        HALT
PTR:    .FILL A0
