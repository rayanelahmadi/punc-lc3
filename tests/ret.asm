; Return from subroutine.  Expects R1=1
        JSR SUB                 ; R7 = 1
        HALT
SUB:    ADD R1, R1, #1
        RET                     ; PC = R7
