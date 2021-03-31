;-------------------------------------------

; A PROGRAM TO COMPUTE THE FACTORIAL OF INTEGER n USING RECURSIVE PROCEDURE

; NOTE: The result must fit into a word, so for bigger results just change the type of FACT variable.

;-------------------------------------------
            .MODEL SMALL
            .STACK 64
            
            .DATA
N           DB   06H            ; define N
FACT        DW   ?              ; put the final result in FACT

            .CODE
MAIN        PROC FAR
            MOV  AX, @DATA
            MOV  DS, AX
            
            MOV  AX, 1          ; The final result will be caculated in AX
            MOV  BX, N          ; BX = N
            CALL FACTORIAL      ; Call the factorial proc and store the next instruction into the stack
            MOV  FACT, AX
                              
            MOV  AH, 4CH
            INT  21H
MAIN        ENDP


FACTORIAL   PROC NEAR            
            CMP  BX, 1          ; if BX == 1
            JE   FINISH         ; return 
            PUSH BX             ; else push the BX into the stack
            DEC  BX             ; BX -= 1
            CALL FACTORIAL      ; FACTORIAL(N-1)
            POP  BX             ; pop the top of the stack into BX
            MUL  BX             ; AX *= BX
            
FINISH:     RET
FACTORIAL   ENDP


            END  MAIN