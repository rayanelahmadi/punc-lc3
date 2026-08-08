; Base+offset store.  Expects MEM[4]=15
        ADD R0, R0, #15         ; value to store
        ADD R1, R1, #3          ; base address
        STR R0, R1, #1          ; mem[3 + 1] = 15
        HALT
