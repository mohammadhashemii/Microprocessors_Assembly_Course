.MODEL SMALL
.STACK 100
.DATA  
      ; config PPI chip
      PORTA EQU 00H; 0000 0000	
      PORTB EQU 02H; 0000 0010
      PORTC EQU 04H; 0000 0100
      CW_PORT EQU 06H ; 0000 0110
      
      ; config timer chip(8253A)
      COUNTER EQU 10H
      COUNTER_CONTROL EQU 16H
      ; config interrupt chip(8259A)
      ICW1 EQU 20H
      ICW2 EQU 22H
      
      MODE DB 0H
      EDGES DW 0H
   
CODE    SEGMENT PUBLIC 'CODE'
        ASSUME CS:CODE  
	

INIT_INTERRUPT MACRO INT_NO, PROCEDURE, IP_OFFSET, CS_OFFSET
	MOV AL , 13H  ;  0001 0011			
	OUT  ICW1, AL	 
	MOV AL, INT_NO	
	OUT ICW2 , AL
	MOV AL , 03H ; 0000 0011
	OUT ICW2 , AL   
	MOV AX , 0H		
	MOV ES , AX 
	MOV AX , OFFSET PROCEDURE  
	MOV ES:[IP_OFFSET] , AX	;IP_OFFSET = INT_NO*4
	MOV ES:[CS_OFFSET] , CS  	;CS_OFFSET = INT_NO*4+2
ENDM


START_TIMER PROC FAR
	 MOV  AL, 9H		; is set based on the 8253 clock freq (9)
	 OUT COUNTER, AL
	 MOV  AL, 10H; 0001 0000	;is set based on PC4 ~ GATE0
	 OUT PORTC, AL	
	 RET 
START_TIMER ENDP

STOP_TIMER PROC FAR
      MOV  AL, 00H
      OUT COUNTER, AL
      OUT PORTC, AL	
      RET
STOP_TIMER ENDP

POS_EDGE PROC FAR
      IPUSH AX
      PUSH DS
      CLI
      MOV AX,@DATA
      MOV DS,AX     
      INC EDGES
      CMP MODE, 0H			; if mode = counter  => show on the 7-seg
      JNE L2
L1:
      POP DS
      POP AX
      STI
      IRET       
L2:
      CALL DISPLAY_7SEG
      JMP L1
POS_EDGE ENDP

TIMER_ENDED PROC FAR
      PUSH AX
      PUSH DS
      CLI
      MOV AX,@DATA
      MOV DS,AX      
      CALL DISPLAY_7SEG
      MOV EDGES, 0H     
      POP DS
      POP AX
      STI
      IRET
TIMER_ENDED ENDP

DISPLAY_7SEG PROC FAR
      MOV AX, EDGES
      MOV BX, 0AH
      MOV DX, 0H
      DIV BX; 		; DX = AX mod BX
      MOV CX, DX
      MOV DX, 0H
      DIV BX
      PUSH AX
      MOV AX, DX
      MOV BX, 10H
      MUL BX
      ADD AX, CX 
      OUT PORTA, AL
      POP AX
      MOV BX, 0AH
      MOV DX, 0H
      DIV BX
      MOV CX, DX
      MOV BX, 10H
      MUL BX
      ADD AX, CX 
      OUT PORTB, AL
      RET
DISPLAY_7SEG ENDP


START:
	MOV AL, 81H ; 1000 0001			; D0=1 -> port_c low is input       D7 =1 -> IO mode
	OUT CW_PORT, AL	
	
	MOV AL, 16H		; 0001 0110		;  aks
	OUT COUNTER_CONTROL,  AL
	CALL START_TIMER
	 
	CLI
	INIT_INTERRUPT 60H, POS_EDGE, 180H, 182H	 
	INIT_INTERRUPT 61H, TIMER_ENDED, 184H, 186H
	STI

LOOP_:
	 MOV AX,@DATA
	 MOV DS,AX
	 IN AL, PORTC
	 AND AL, 01H
	 CMP AL, 00H
	 JE BUTTON_PRESSED
       JMP LOOP_
BUTTON_PRESSED:
	 IN AL, PORTC
	 AND AL, 01H
	 CMP AL, 00H
	 JE BUTTON_PRESSED
	 CLI
	 MOV AX,@DATA
	 MOV DS,AX
	 MOV EDGES, 00H
	 XOR MODE,  01H	; change the mode
	 CMP MODE, 01H	; 
	 JE STOP_TIMER_LABEL
         CALL START_TIMER
	 STI
	 JMP LOOP_
STOP_TIMER_LABEL:
      CALL STOP_TIMER
	 STI			; enable interupts
	 JMP LOOP_
CODE    ENDS
        END START