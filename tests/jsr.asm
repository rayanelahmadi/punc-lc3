; Jump to subroutine, PC-relative.  Expects R0=1, R7=1
        JSR SUB                 ; R7 = 1 (return address)
        HALT
SUB:    ADD R0, R0, #1
        HALT
