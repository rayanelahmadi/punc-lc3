/*  INITIAL BLOCK:*/
/*0: */ LD R0, #30 // loading mem[31] (N)
/*1: */ BRn #24 // if negative, go to halt.
/*2: */ AND R1, R1, #0 // i = 0
/*3: */ ADD R1, R1, #1  // i=1
// Outer_Loop
/*4: */ JSR #22 // jump to the subroutine 'negation' and compute two's complement of R1
/*5  */ LD R0, #25 // (N)
/*6: */ ADD R3, R0, R2 // N-i
/*7: */ BRnz #17 // goto end of Outer_Loop if negative and return (N-i > 0)
/*8: */ AND R4, R4, #0 // sum = 0
/*9: */ AND R5, R5, #0 // j = 0
/*10: */ AND R6, R6, #0 // resettig our return register for jmp
// Inner_Loop
/*11: */ ADD R3, R5, R2 // j-i
/*12: */ BRzp #6 // condition to leave -> End of Inner_Loop
/*13: */ LD R0, #18 // loading ans
/*14: */ ADD R4, R4, R0 // sum = sum + ans
/*15: */ ADD R5, R5, #1 // increment j
/*16: */ AND R6, R6, #0 // resetting return reg
/*17: */ ADD R6, R6, #11 // return address, jmp to add r3, r5, r2
/*18: */ JMP R6// jmp? back to top of inner_loop
// End of Inner_Loop
/*19: */ ADD R0, R4, #0 // ans = sum + 0
/*20:  */ ST R0, #11 // storing ans back into memory 
/*21: */ ADD R1, R1, #1 // increment i
/*22: */ AND R6, R6, #0 // resetting return register
/*23: */ ADD R6, R6, #4 // JMP TO JSR
/*24: */ JMP R6           // goes to top of outter loop
// End of Outer_Loop
// Epilog (MAY NEED A LD/STR?)
/*25: */ ST R4, #4 // store into Mem
/*26: */ HALT // end program
// Two's Complement Subroutine
/*27: */ NOT R2, R1 // two's comp
/*28: */ ADD R2, R2, #1 // two's comp
/*29: */ RET // go back
// DATA:
/*30: */ 0000 // returnVal of fibonacci in mem
/*31: */ 0006 // factorial starting number (N)
/*32: */ 0006 // N/ans
