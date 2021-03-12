 ;-------------------------------------------

; A PROGRAM TO CONVERT BCD TO HEX AND THEN CALCULATE A REMAINDER OF A TWO 16-BIT DIVISION

; NOTE: The length of the first number should be set into N.

;-------------------------------------------
            .MODEL SMALL
            .STACK 64
            
            .DATA
N           DW   4  	            ; define the length of the nominator
NUM1        DB   1, 2, 3, 4         ; define nominator as a BCD number into an array
NUM2        DW   0003H              ; define denominator
REM         DW   ?

            .CODE
MAIN        PROC FAR
            MOV  AX, @DATA
            MOV  DS, AX
            
            ; make SI to point to the least significant digit in NUM1
            MOV  SI, OFFSET NUM1            
            ADD  SI, N
            DEC  SI
                                    
            MOV  BX, 0              ; BX = 0
            MOV  BP, 1              ; multiple of 10 to multiply every digit
            
REPEAT:     MOV  AL, [SI]           ; the current digit of the NUM1 to process
            MOV  AH, 0              ; clear AH -> AX = AL
            MUL  BP                 ; AX *= BP 
            ADD  BX, AX             ; add result to BX
            
            MOV  AX, BP             ; AX = BP
            MOV  BP, 10             
            MUL  BP                 ; AX *= 10
            MOV  BP, AX             ; new multiple of 10
            
            DEC  SI
            CMP  SI, OFFSET NUM1    ; check whether the string is finished or not   
            JGE REPEAT            
            
            
            MOV  AX, BX
            SUB  DX, DX
            DIV  NUM2               ; AX / NUM2   -> AH = remainder
            MOV  REM, DX            ; store the remainder of the division into REM
                              
            MOV  AH, 4CH
            INT  21H
MAIN        ENDP
           

            END  MAIN