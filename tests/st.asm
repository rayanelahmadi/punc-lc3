; PC-relative store.  Expects MEM[0]=15, MEM[1]=10
; The stores overwrite addresses 0 and 1, but only after those two
; instructions have already been fetched and executed.
A0:     ADD R0, R0, #15
A1:     ADD R1, R1, #10
        ST  R0, A0
        ST  R1, A1
        HALT
