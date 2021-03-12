;-------------------------------------------

; A PROGRAM TO SUM OVER ALL THE ODD NUMBERS OF A SERIES

; NOTE: The input serie is stored in an array of numbers
; NOTE: The initial value of CX should be the same as the serie's length 
;-------------------------------------------
            .MODEL SMALL
            .STACK 64
            
            .DATA
ARR         DB   12H, 23H, 0ABH, 01H    ; define a series of numbers
SUM         DW   0000H                  ; put the final result in SUM

            .CODE
MAIN        PROC FAR
            MOV  AX, @DATA
            MOV  DS, AX
            
            MOV  SI, 00H
            MOV  CX, 04H                ; CX = n : number of prime numbers
            MOV  DH, 00H;               ; DH = 0  for summing
                     
NEXT:       MOV  BX, OFFSET ARR
            MOV  AL, [BX+SI]            ; AL now is the next number in the serie    
            
            MOV  DL, 02                 ; DL = 2
            SUB  AH, AH                 ; AH = 0   (AH will be the remainder of the divion by 2)            
            DIV  DL                     ; AL / DL  --> AL will be the quotient of the division
            CMP  AH, 00                 ; check whether the remainder is zero or not
            JE   SKIP                   ; ignore adding the number to DH
            ADD  DH, [BX+SI]            ; DH += the odd number
SKIP:       INC  SI                     ; for pointing to the next number in the serie
            LOOP NEXT
            
            
              
            MOV  SUM, DH                ; store the result in the SUM variable                  
            MOV  AH, 4CH
            INT  21H
MAIN        ENDP
            END  MAIN