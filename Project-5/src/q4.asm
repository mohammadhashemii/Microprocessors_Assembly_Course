; A to compute Factoriel(reverese(n))

        AREA     RESET, CODE, READONLY
                               
        ENTRY                   
start
        MOV      R0, #0xE0000000    	   
		MOV 	 R1, #0
		MOV 	 R2, #32			; since we have 32-bit register
		
REVERESE_LOOP
		LSRS 	 R0, #1
		ADDCS 	 R1, R1, #1			; add if carry flag is set
		LSL		 R1, #1						
		SUB 	 R2, R2, #1
		CMP 	 R2, #1	
		BNE 	 REVERESE_LOOP
		ADD 	 R1, R1, #1
		MOV 	 R0, R1			 	; R0 = Reverse(n)

		MOV 	 R10, #1
FACTORIAL
		CMP 	 R0, #1
		BEQ 	 DONE
		MUL	 	 R10, R0, R10
		SUB	  	 R0, R0, #1
		B		 FACTORIAL
DONE	
		
stop
        

	B loop
loop
	B loop
        END        
             