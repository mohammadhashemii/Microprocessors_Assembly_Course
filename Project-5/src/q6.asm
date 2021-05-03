; Write a program to keep the i'th to j'th bits the
; same and toggle other bits

        AREA     RESET, CODE, READONLY                              
        ENTRY                   
start

			MOV		 R0, #0xFFFFFFFF
			MOV 	 R1, R0
			MOV 	 R2, #3		; R2 = i
			MOV 	 R3, #8	 	; R3 = j
			MOV		 R4, #171	; input    = 0000 0000 1010 1011
			MOV 	 R5, #31
			LSL	 	 R0, R2		; R0 = R0 << i
			SUB	 	 R3, R5, R3
			LSR	 	 R1, R3		; R0 = R0 >> j
			AND		 R1, R1, R0	; R1 = 0000 0001 1111 1000
			EOR		 R4, R4, R1	; R4 = result = 0000 0001 0101 0011
stop
        

	B loop
loop
	B loop
        END        
             