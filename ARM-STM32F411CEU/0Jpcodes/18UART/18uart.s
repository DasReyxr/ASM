; --------------  Das -----------
; ------------ UART ------------
; ------------- 26/05/2025 ------------
; ------------- Variables -------------
; ---------------- Main ---------------


;-- USART --
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
; -- Alternate F --
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

ledDelay EQU 6000000

	AREA myData, DATA, READWRITE

    AREA juve3dstudio,CODE,READONLY
	ENTRY
	EXPORT __main

__main
    BL      Config_RCC
    BL      Config_GPIO
	BL 		Config_TIM
	BL      Config_UART
loop
	;leyendo el ADC
        BL      Read_UART
    BL      Write_UART
; MOV     R1, #'H'
;     BL      Write_UART
;     BL      delay
; 	MOV     R1, #'O'
;     BL      Write_UART
;     BL      delay
; 	MOV     R1, #'L'
;     BL      Write_UART
;     BL      delay
; 	MOV     R1, #'A'
;     BL      Write_UART
;     BL      delay
; 	MOV     R1, #' '
;     BL      Write_UART
;     BL      delay
; 	MOV     R1, #'J'
;     BL      Write_UART
;     BL      delay
; 	MOV     R1, #'U'
;     BL      Write_UART
;     BL      delay
;     MOV     R1, #'A'
;     BL      Write_UART
;     BL      delay
; 	MOV     R1, #'N'
;     BL      Write_UART
;     BL      delay
   ;  BL      Write_UART

    B 		loop
    
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

delay
    LDR R0,=ledDelay
juan
    ADDS    R0,R0,#-1
    BNE     juan

    BX      LR
	
	align
	end