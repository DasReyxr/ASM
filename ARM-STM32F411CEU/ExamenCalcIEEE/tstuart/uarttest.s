; ------ Orlando Reyes ------
; --------- Auf Das ---------
; ----- IEEE Calculator -----
; ---- I date 10/06/2025 ----
; ---- C date 13/06/2025 ----
; -------- Variables --------
; ----------- Main -----------

USART1_BASE      EQU 0x40011000
USART1_SR        EQU (USART1_BASE + 0x00)
USART1_DR        EQU (USART1_BASE + 0x04)
USART1_BRR       EQU (USART1_BASE + 0x08)
USART1_CR1       EQU (USART1_BASE + 0x0C)


; -- Timer ----
TIM2_BASE 		EQU 0x40000000
TIM2_CR1 		EQU (TIM2_BASE + 0x00)
TIM2_SR			EQU (TIM2_BASE + 0x10)
TIM2_CCMR1 		EQU (TIM2_BASE + 0x18)
TIM2_CCER       EQU (TIM2_BASE + 0x20)
TIM2_CNT 		EQU (TIM2_BASE + 0x24)
TIM2_PSC 		EQU (TIM2_BASE + 0x28)
TIM2_ARR 		EQU (TIM2_BASE + 0x2C)
TIM2_CCR1       EQU (TIM2_BASE + 0x34)

; -- CLocks --
RCC_BASE        EQU 0x40023800
RCC_AHB1        EQU (RCC_BASE  + 0x30)
RCC_APB1        EQU (RCC_BASE  + 0x40)
RCC_APB2        EQU (RCC_BASE  + 0x44)

; -- GPIO A --
GPIOB_BASE       EQU 0x40020400
GPIOB_MODER     EQU (GPIOB_BASE + 0x00)
;-- Configuration Registers --
GPIOB_OTYPER    EQU (GPIOB_BASE + 0x04)
GPIOB_OSPEED    EQU (GPIOB_BASE + 0x08)
GPIOB_PUPDR     EQU (GPIOB_BASE + 0x0C)
;-- Comm Registers --
GPIOB_IDR       EQU (GPIOB_BASE + 0x10)
GPIOB_ODR       EQU (GPIOB_BASE + 0x14)
; -- Alternate FRACT --
GPIOB_AFRL       EQU (GPIOB_BASE + 0x20)
GPIOB_AFRH       EQU (GPIOB_BASE + 0x24)


;-- Special Registers --
GPIOB_BSSR       EQU (GPIOB_BASE + 0x18) ; Bit Set Set Register

; -- GPIO C --
GPIOC_BASE       EQU 0x40020800
GPIOC_MODER      EQU (GPIOC_BASE + 0x00)
;-- Configuration Registers --
GPIOC_OTYPER    EQU (GPIOC_BASE + 0x04)
GPIOC_OSPEED    EQU (GPIOC_BASE + 0x08)
GPIOC_PUPDR     EQU (GPIOC_BASE + 0x0C)
;-- Comm Registers --
GPIOC_IDR       EQU (GPIOC_BASE + 0x10)
GPIOC_ODR       EQU (GPIOC_BASE + 0x14)


;r5 flag dot
	AREA myData, DATA, READWRITE
		
ENTERO SPACE 10
FRAC   SPACE 6

    AREA juve3dstudio,CODE,READONLY
	ENTRY
	IMPORT calc
	EXPORT __main

__main
    BL      Config_RCC
    BL      Config_GPIO
	BL 		Config_TIM
	BL      Config_UART
	MOV     R4, #0          ; Índice
	MOV 	R5, #0
	MOV 	R6, #0

LOOP
	; -- IN --
	; R1  character  from UART
	; R0  Address General Purpose 
	; R4 Counter for integer part
	; R6 Counter for fractional part
	; R5 Flag for decimal point

	; -- OUT --
	; R3 Result of conversion
	; R6

    BL      Read_UART       
	CMP     R1, #0x0D       ; Enter key (Carriage Return)
    BEQ     CONVERT       
	CMP 	R1, #'.'
	BEQ		PUNTO

	TST 	R5, #1
	BNE		SAVE_FRAC
	; Validation ranges 0-9 Values only
	CMP     R1, #0x30
	BLT     LOOP
	CMP     R1, #0x39
	BGT     LOOP

	B		SAVE_ENT
LOOP1
    BL      Write_UART      ; Reenviar por UART
    B       LOOP


SAVE_ENT
	LDR     R2, =ENTERO 
    SUB     R0, R1, #48   
    STRB    R0, [R2, R4]    
    ADD     R4, R4, #1      	
	B       LOOP1

SAVE_FRAC
	LDR     R2, =FRAC
	SUB     R0, R1, #48   
    STRB    R0, [R2, R6]    
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

	MOV		R1, R4  ; Duplicar el valor de R4
	MOV 	R0, #1	; Valor minimo de la escala
	MOV 	R10, #10 ; inmediato 10	
exp10r4 ; 10^R4
	SUBS 	R1, #1
	BEQ		CONV_INT
	MUL 	R0, R0, R10
	B exp10r4

	EOR		R3,R3
CONV_INT
	LDRB 	R5,[R2,R1]	; Cargar bit de R2 [Entero]
	MUL 	R5, R5, R0
	ADD	  	R3, R5
	
	UDIV	R0, R0, R10 ; reducir escalas
	ADD 	R1, #1
	CMP 	R1, R4
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

	LDR		R1,=1000

Convert
	LDRB 	R5,[R2,R4]
	MUL 	R5, R5, R1
	ADD	  	R6, R5
	ADD 	R4, #1
	
	UDIV	R1, R1, R10 ; Reduce la escala
	CMP 	R4, #5
	BNE		Convert

	POP 	{R10}

	ADD 	r4,#0
	; OUT
	MOV 	R11, R6
	MOV  	R2, R3
	
	EOR 	R1,R1
	EOR 	R3,R3
	EOR 	R4,R4
	EOR 	R5,R5
	EOR 	R6,R6
	EOR 	R7,R7
	EOR 	R8,R8
	EOR 	R9,R9
	
	
	LDR 	R0, =calc
	BX 		R0

	

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


Config_RCC
    LDR     R0,=RCC_AHB1     ; 0    00           0     0     0     0     0
    LDR     R1,[R0]          ;GPIOH RESERVE   GPIOE  GPIOD GPIOC GPIOB GPIOB
    ORR     R1,#(0x2)       ; 0    00           0    0      0    1     0
    STR     R1,[R0]


    ; Activamos el CLK del USART 
    LDR     R0,=RCC_APB2     
    LDR     R1,[R0]         
    ORR     R1,#(1<<4)  ; USART   
    STR     R1,[R0]


    BX      LR 

Config_GPIO

    ;--- PORTA ---
    ; PA0 as alternate function
    ; PA7 as analog input
    LDR     R0, =GPIOB_MODER
    LDR     R1, [R0]
    ORR     R1, #(0xA << 12)  ;Alternate function for PB6
    STR     R1, [R0]



    LDR     R0,=GPIOB_AFRL     
    LDR     R1,[R0]         
    ORR     R1,#((7<<24)|(7<<28))  ; USART   
    STR     R1,[R0]


    
    BX      LR

Config_TIM
	; CKD    ARPE  CMS  DIR  OPM  URS   UDIS CEN
	; 00      1    00    0   0    0      0    1

	LDR 	R0, =TIM2_PSC
	MOV 	R1, #0;#999 ; Tim_Prescaler -->(1000-1)
	STR		R1,[R0]
	
	LDR 	R0, =TIM2_ARR
	MOV 	R1, #1599 ; Tim_Period -->(24000-1)
	STR		R1,[R0]
	
    LDR 	R0, =TIM2_CCMR1
    LDR 	R1, [R0]
	ORR 	R1, #0x68
	STR		R1,[R0]
	
    LDR 	R0, =TIM2_CCER
	LDR 	R1, [R0]
	ORR 	R1, #(1 << 0)
	STR		R1,[R0]


	LDR 	R0, =TIM2_CR1
	LDR 	R1, [R0]
	ORR 	R1, #0x81
	STR		R1,[R0]
	
	LDR 	R0, =TIM2_CCR1
	MOV 	R1, #799 ; Tim_PWM -->(800-1)
    STR		R1,[R0]
	
    BX      LR
Config_UART
    PUSH{LR}
    ;966 Baud rate
    LDR     R0, =USART1_BRR
    LDR     R1, =0x683 ; Baud rate 9600
    STR     R1, [R0] ; Set baud rate
    
    ;Configuramos nuestro uart a una trama de 1 bit start
	LDR R0,=USART1_CR1
	LDR R1,[R0]
	MOVW R2,#0x200C ; Otra forma #(1 << 13) | (3<<2)
	ORR R1, R2 		; #(1 << 13) | (3<<2)
	STR R1,[R0]
    POP{PC}


	align
	end