; ------ Orlando Reyes ------
; --------- Auf Das ---------
; ----- IEEE Calculator -----
; ---- I date 10/06/2025 ----
; ---- C date 13/06/2025 ----
; -------- Variables --------
; ----------- Main -----------
R0	RN R0diezn
R1	RN R1UART

;r5 flag dot
	AREA myData, DATA, READWRITE
		
ENTERO SPACE 10
FRAC   SPACE 6

    AREA juve3dstudio,CODE,READONLY
	ENTRY
	IMPORT calc
	EXPORT UART

UART
    BL      Config_RCC
    BL      Config_GPIO
	BL 		Config_TIM
	BL      Config_UART
	MOV     R4, #0          ; Índice
	MOV 	R5, #0
	MOV 	R6, #0

LOOP
	; -- IN --
	; R1UART  character  from UART
	; R0diezn  Address General Purpose 
	; R4 Counter for integer part
	; R6 Counter for fractional part
	; R5 Flag for decimal point

	; -- OUT --
	; R3 Result of conversion
	; R6

    BL      Read_UART       
	CMP     R1UART, #0x0D       ; Enter key (Carriage Return)
    BEQ     CONVERT       
	CMP 	R1UART, #'.'
	BEQ		PUNTO

	TST 	R5, #1
	BNE		SAVE_FRAC
	; Validation ranges 0-9 Values only
	CMP     R1UART, #0x30
	BLT     LOOP
	CMP     R1UART, #0x39
	BGT     LOOP

	B		SAVE_ENT
LOOP1
    BL      Write_UART      ; Reenviar por UART
    B       LOOP


SAVE_ENT
	LDR     R2, =ENTERO 
    SUB     R1UART, #48   
    STRB    R1UART, [R2, R4]    
    ADD     R4, R4, #1      	
	B       LOOP1

SAVE_FRAC
	LDR     R2, =FRAC
	SUB     R1UART, #48   
    STRB    R1UART, [R2, R6]    
    ADD     R6, R6, #1      	
	B       LOOP1

PUNTO
	ORR 	R5, #1
	B       LOOP1


CONVERT
	PUSH 	{R10}
    LDR     R2, =ENTERO 
	ADDS 	R4, #0
	BEQ		FRACT

	MOV		R1UART, R4  ; Duplicar el valor de R4
	MOV 	R0diezn, #1	; Valor minimo de la escala
	MOV 	R10, #10 ; inmediato 10	
exp10r4 ; 10^R4
	SUBS 	R1UART, #1
	BEQ		CONV_INT
	MUL 	R0diezn, R0diezn, R10
	B exp10r4

	EOR		R3,R3
CONV_INT
	LDRB 	R5,[R2,R1UART]	; Cargar bit de R2 [Entero]
	MUL 	R5, R5, R0diezn
	ADD	  	R3, R5
	
	UDIV	R0diezn, R0diezn, R10 ; reducir escalas
	ADD 	R1UART, #1
	CMP 	R1UART, R4
	BNE		CONV_INT
	
FRACT
	LDR     R2, =FRAC

CleanVector
	EOR		R4,R4
	STRB    R4, [R2, R6] ; Limpiar
    ADD     R6, #1 
	CMP		R6, #6
	BNE		CleanVector
	EOR 	R6,R6

	LDR		R1UART,=1000

Convert
	LDRB 	R5,[R2,R4]
	MUL 	R5, R5, R1UART
	ADD	  	R6, R5
	ADD 	R4, #1
	
	UDIV	R1UART, R1UART, R10 ; Reduce la escala
	CMP 	R4, #5
	BNE		Convert

	POP 	{R10}

	ADD 	r4,#0
	; OUT
	MOV 	R11, R6
	MOV  	R2, R3
	
	EOR 	R1UART,R1
	EOR 	R3,R3
	EOR 	R4,R4
	EOR 	R5,R5
	EOR 	R6,R6
	EOR 	R7,R7
	EOR 	R8,R8
	EOR 	R9,R9
	
	
	LDR 	R0, =calc
	;LDR 	PC,=calc
	;BX 		R0

	

Read_UART
    PUSH{LR}
    LDR    R0, =USART1_SR
readCycle
    LDR   R1, [R0] ; Read status register
    TST   R1, #(1<<5) ; Check if RXNE is set
    BEQ   readCycle ; If not, wait
    LDR   R0, =USART1_DR ; Read data register
    LDR   R1, [R0] ; Read received data

    POP{PC}

Write_UART
    PUSH{LR}
    LDR    R0, =USART1_DR
    STR    R1, [R0] ; Write data to transmit register
    LDR    R0, =USART1_SR
writeCycle
    LDR   R1, [R0] ; Read status register
    TST   R1, #(1<<6) ; Check if TXE is set
    BEQ   writeCycle ; If not, wait
    
    POP{PC}



	align
	end