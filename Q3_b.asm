;-------------------------------------------

; A PROGRAM TO CONVERT STRING TO NUMBER AND THEN CALCULATE A REMAINDER OF A DIVISION

; NOTE: The length of the string should be set into N.

;-------------------------------------------
            .MODEL SMALL
            .STACK 64
            
            .DATA
N           DW   4  	            ; define the length of the nominator
NUM1        DW   "1255"             ; define nominator as a string
NUM2        DW   0004H              ; define denominator
REM         DW   ?

            .CODE
MAIN        PROC FAR
            MOV  AX, @DATA
            MOV  DS, AX
            
            ; make SI to point to the least significant digit in NUM1
            MOV  SI, OFFSET NUM1            
            ADD  SI, N
            DEC  SI
                                    ; BX = 0
            MOV  BX, 0              ; multiple of 10 to multiply every digit
            MOV  BP, 1
            
REPEAT:     MOV  AL, [SI]           ; the current character of the NUM1 to process
            SUB  AL, 48             ; convert ascii character to digit
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