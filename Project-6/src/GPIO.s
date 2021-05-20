;Addresses
;-------------------------------------
; Clock
RCC_AHB1ENR 	EQU 0x40023830

; GPIOA - Base Addr: 0x4002 0000
GPIOA_MODER		EQU 0x40020000
GPIOA_IDR		EQU 0x40030010
GPIOA_ODR		EQU 0x40020014
	
; GPIOB - Base Addr: 0x4002 0400
GPIOB_MODER		EQU 0x40020400
GPIOB_IDR		EQU 0x40020410
GPIOB_ODR		EQU 0x40020414
	
; GPIOC - Base Addr: 0x4002 0800
GPIOC_MODER		EQU 0x40020800
GPIOC_IDR		EQU 0x40020810
GPIOC_ODR		EQU 0x40020814	

;-------------------------------------

	
	EXPORT SystemInit
	EXPORT __main
		
	AREA Mycode, CODE, READONLY

SystemInit FUNCTION
	
	; Enable clk FOR portA, portB AND portC
	LDR	R1, =RCC_AHB1ENR
	MOV	R0, #0x7 ; =000...0111
	STR	R0, [R1]
	
	; GPIOA MODER -> All the pins are used as output
	LDR	R1, =GPIOA_MODER
	LDR	R0, [R1]
	MOV	R0, #0x55555555 ; =010101...0101
	STR	R0, [R1]
	
	; GPIOB MODER -> Some for output and some for input
	LDR	R1, =GPIOB_MODER
	LDR	R0, [R1]
	MOV	R0, #0x55005500
	STR	R0, [R1]
	
	; GPIOC MODER
	LDR	R1, =GPIOC_MODER -> the least four pins are used for output
	LDR	R0, [R1]
	MOV	R0, #0x00000055
	STR	R0, [R1]
		
	ENDFUNC
__main FUNCTION
	
	MOV R6, #0 		; A flag
	
MAIN_LOOP
	
	;-------------------------------------
	; Check if the reset button is pressed	
	LDR R1, =GPIOB_IDR
	LDR R0, [R1]
	MOV R1, R0
	
	MOV R2, #0xFFF7 ; 1111 1111 1111 0111
	ORR R0, R0, R2
	CMP R0, R2
	BEQ RESET
	;-------------------------------------
	
	
	;-------------------------------------
	;First row in keypad enable
	LDR	R2, =GPIOB_ODR
	MOV R3, #0xEFFF ; =1110 1111 1111 1111
	STR R3, [R2]
	
	LDR R2, =GPIOB_IDR
	LDR R0, [R2]
	MOV R1, R0
	; Check if 1 is pressed
	MOV R4, #0xFEFF	; =1111 1110 1111 1111
	ORR R0, R0, R4
	CMP R0, R4
	MOV R0, #1
	BEQ DISPLAY_7SEG
	;Check if 2 is pressed
	MOV R4, #0xFDFF	; =1111 1101 1111 1111
	MOV R3, R1
	ORR R3, R3, R4
	CMP R3, R4
	MOV R0, #2
	BEQ DISPLAY_7SEG
	;Check if 3 is pressed
	MOV R4, #0xFBFF	; =1111 1011 1111 1111
	MOV R5, R1
	ORR R5, R5, R4
	CMP R5, R4
	MOV R0, #3
	BEQ DISPLAY_7SEG
	;-------------------------------------
	
	
	;-------------------------------------
	;Second row in keypad enable
	LDR	R2, =GPIOB_ODR
	MOV R3, #0xDFFF ; =1101 1111 1111 1111
	STR R3, [R2]
	
	LDR R2, =GPIOB_IDR
	LDR R0, [R2]
	MOV R1, R0
	; Chech if 4 is pressed
	MOV R4, #0xFEFF	; =1111 1110 1111 1111
	ORR R0, R0, R4
	CMP R0, R4
	MOV R0, #4
	BEQ DISPLAY_7SEG
	;Check if 5 is pressed
	MOV R4, #0xFDFF	; =1111 1101 1111 1111
	MOV R3, R1
	ORR R3, R3, R4
	CMP R3, R4
	MOV R0, #5
	BEQ DISPLAY_7SEG
	;Check if 6 is pressed
	MOV R4, #0xFBFF	; =1111 1011 1111 1111
	MOV R5, R1
	ORR R5, R5, R4
	CMP R5, R4
	MOV R0, #6
	BEQ DISPLAY_7SEG
	;-------------------------------------
	
	;-------------------------------------
	;Third row in keypad enable
	LDR	R2, =GPIOB_ODR
	MOV R3, #0xBFFF ; =1011 1111 1111 1111
	STR R3, [R2]
	
	LDR R2, =GPIOB_IDR
	LDR R0, [R2]
	MOV R1, R0
	; Chech if 7 is pressed
	MOV R4, #0xFEFF	; =1111 1110 1111 1111
	ORR R0, R0, R4
	CMP R0, R4
	MOV R0, #7
	BEQ DISPLAY_7SEG
	;Check if 8 is pressed
	MOV R4, #0xFDFF	; =1111 1101 1111 1111
	MOV R3, R1
	ORR R3, R3, R4
	CMP R3, R4
	MOV R0, #8
	BEQ DISPLAY_7SEG
	;Check if 9 is pressed
	MOV R4, #0xFBFF	; =1111 1011 1111 1111
	MOV R5, R1
	ORR R5, R5, R4
	CMP R5, R4
	MOV R0, #9
	BEQ DISPLAY_7SEG
	;-------------------------------------
	
	;-------------------------------------
	;Fourth row in keypad enable
	LDR	R2, =GPIOB_ODR
	MOV R3, #0x7FFF ; =0111 1111 1111 1111
	STR R3, [R2]
	
	LDR R2, =GPIOB_IDR
	LDR R0, [R2]
	MOV R1, R0
	
	;Check if 0 is pressed
	MOV R4, #0xFDFF	; =1111 1101 1111 1111
	MOV R3, R1
	ORR R3, R3, R4
	CMP R3, R4
	MOV R0, #0
	BEQ DISPLAY_7SEG
		
	B MAIN_LOOP
	
;-------------------------------------
RESET
	LDR R1, =GPIOA_ODR
	MOV R0, #0
	STR R0, [R1]
	MOV R6, #0
	MOV R7, #0
;-------------------------------------	

	B MAIN_LOOP
	
DISPLAY_7SEG
	; R0 should contain the expected value to be displayed
	LSL R0, R0, #12			; R0 = R0 * 1000 (in decimal)
	LDR R1, =GPIOA_ODR
	STR R0, [R1]
	CMP R7, R0
	BEQ MAIN_LOOP
	CMP R6, #1
	BEQ COUNTER
	MOV R6, #1
	MOV R7, R0		; R7 = source
	B MAIN_LOOP
	

COUNTER
	; R0 should contain destination level
	; R7 should contain source level
	LSR R6, R0, #12
	LSR R5, R7, #12
	
	MOV R8, #12
	MOV R10 , #0 	; A flag
	MOV R11, #1 	; for LED index
	MOV R12, #0
	CMP R6, R5
	BGT COUNTER_LOOP
	MOV R12, #1
	
COUNTER_LOOP
	;-------------------------------------
	; Check if the reset button is pressed	
	LDR	R1, =GPIOB_IDR
	LDR R3, [R1]
	MOV	R1, R3
	
	MOV R2, #0xFFF7 ; 1111 1111 1111 0111
	ORR R3, R3, R2
	CMP R3, R2
	BEQ RESET
	;-------------------------------------
	
	;-------------------------------------
	; Wait loop
	LDR R4, =0x3FFFFF   ; delay time
WAIT
	CMP R4, #0
	BEQ START
	SUB R4, R4, #1
	B WAIT
	;-------------------------------------

START
	CMP R12, #1	
	BEQ L2				; if destination < source

;-------------------------------------
; For when destination > source
L1	
	CMP R5, R6
	BGT END_LOOP
	LSL R9, R5, R8
	ORR R7, R7, R9
	ADD R5, R5, #1
	SUB R8, R8, #4
	B DISPLAY
;-------------------------------------
; For when destination < source
L2
	CMP R5, R6
	BLT END_LOOP
	LSL R9, R5, R8
	ORR R7, R7, R9
	SUB R5, R5, #1
	SUB R8, R8, #4
;-------------------------------------	
DISPLAY
	; DISPLAY ON 7-SEGMENT
	LDR R1, =GPIOA_ODR
	STR R7, [R1]
	
	;-------------------------------------
	; TURN THE CORRESPONDING LED ON
	LDR R1, =GPIOC_ODR
	STR R11, [R1]
	LSL R11, R11, #1
	;-------------------------------------
	
	CMP R8, #0
	BGT COUNTER_LOOP
	CMP R10, #1
	BEQ MOVE_LEFT
	MOV R10, #1
	B COUNTER_LOOP
MOVE_LEFT
	MOV R8, #12
	MOV R7, #0
	MOV R10, #0
	MOV R11, #1
	B COUNTER_LOOP
END_LOOP

	ENDFUNC
		