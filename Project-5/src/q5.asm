; A program to count 101 pattern in a binary number

        AREA     RESET, CODE, READONLY
                               
        ENTRY                   
start
		LDR		 R10, =97243073		; input	= 0000 0101 1100 1011 1100 1111 1100 0001
		MOV		 R0, #0				; counter
		MOV 	 R1, #7				; 7 = 111 in binary
		MOV 	 R2, #5			 	; 5 = 101 in binary
		MOV 	 R3, #29			; 29 = 32 - 3
LOOP		
		AND 	 R4, R10, R1		; fetch the three least bits in R10
		CMP		 R4, R2
		ADDEQ	 R0, #1
		LSL		 R1, #1		 		; next 3 bits in the input number
		LSL		 R2, #1				; shift the pattern 1 to the left
		SUB		 R3, R3, #1			; loop counter
		CMP		 R3, #0				; end loop
		BGT		 LOOP
		
		
stop
        

	B loop
loop
	B loop
        END        
             