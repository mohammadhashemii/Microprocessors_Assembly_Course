;-------------------------------------------

; A PROGRAM TO CALCULATE THE MULTIPICATION OF TWO 32-BIT NUMBERS

;-------------------------------------------

            .MODEL SMALL
            .STACK 64
            
            .DATA
A           DW   5678H, 1234H           ; A = 12345678
B           DW   1111H, 1111H           ; B = 11111111
C           DW   0, 0, 0, 0

            .CODE
MAIN        PROC FAR
            MOV  AX, @DATA
            MOV  DS, AX
            MOV  SI, OFFSET A
           
            MOV  AX, A[SI]              ; load the lower 16bits of A into AX
            MUL  B                      ; load the lower 16bits of B and multiply by AX
            MOV  C, AX                  
            MOV  C+2, DX
            
            MOV  AX, A+2                ; load the higher 16bits of A into AX
            MUL  B                      ; load the lower 16bits of B and multiply by AX
            ADD  C+2, AX
            ADC  C+4, DX
            ADC  C+6, 0
            
            MOV  AX, A                  ; load the lower 16bits of A into AX
            MUL  B+2                    ; load the higher 16bits of B and multiply by AX
            ADD  C+2, AX
            ADC  C+4, DX
            ADC  C+6, 0
            
            MOV  AX, A+2                ; load the higher 16bits of A into AX
            MUL  B+2                    ; load the higher 16bits of B and multiply by AX
            ADD  C+4, AX
            ADC  C+6, DX
             
            MOV  AH, 4CH
            INT  21H
MAIN        ENDP
            END  MAIN