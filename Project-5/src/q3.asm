; A program to calculate the GCD of two numbers

        AREA     RESET, CODE, READONLY
                               
        ENTRY                   
start
        MOV      R1, #12    	; R1 = 12   
        MOV      R2, #8		; R2 = 8
GCD
	CMP	 R1, R2				
	SUBGT	 R1, R1, R2	; R1 = R1 - R2
	SUBLT    R2, R2, R1	; R2 = R2 - R1
	BNE    	 GCD				
		
	MOV R0, R1		; R0 = GCD(R1, R2)
		    
stop
        MOV      r0, #0x18      
        LDR      r1, =0x010101 

	B loop
loop
	B loop
        END        
             