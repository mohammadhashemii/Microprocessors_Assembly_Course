;-------------------------------------------

; A PROGRAM TO STORE THE FIRST n PRIME NUMBERS IN NA ARRAY

; NOTE: To change the value of the n, simplt change the value of CX
; NOTE: The maximum prime numbers which we can save can be change via ARR capacity in data segment

;-------------------------------------------
            .MODEL SMALL
            .STACK 64
            
            .DATA
ARR         DB   20 DUP(?)      ;define an array to store the prime numbers

            .CODE
MAIN        PROC FAR
            MOV  AX, @DATA
            MOV  DS, AX
            
            MOV  DL, 01H        ; DL = 1
            MOV  CX, 02H        ; CX = n : number of prime numbers
            LEA  DI, ARR        ; DI indicates the first element of the array
            
NEXT:       MOV  BL, 02         ; BL = 2 as the first denominator
            INC  DL             ; DL += 1            
            CMP  DL, 02H        ; DL = 2 as the first prime number
            JE   STORE
            CMP  DL, 03H        ; DL = 3 as the second prime number
            JE   STORE
            CMP  DL, 04H
            JGE  DIVISION
            
DIVISION:   MOV  AH, 00         ; clear the AH
            MOV  AL, DL
            DIV  BL             ; AL = AL / BL
            CMP  AH, 00         ; check whether the remainder is zero or not
            JE   NEXT           ; if it is zero, then jump back to L1
            ADD  BL, 01H        ; BL += 1
            CMP  BL, AL         ; check whether the denominator = AL or not
            JLE  DIVISION       ; if yes then jump back to DIVISION
            JMP  STORE
            
STORE:      MOV  [DI], DL       ; insert the prime number into the ARR
            INC  DI             ; DI += 1
            LOOP NEXT  
                              
            MOV  AH, 4CH
            INT  21H
MAIN        ENDP
            END  MAIN