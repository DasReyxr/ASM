; --------------  Das -----------
; ------------ ADC ------------
; ------------- 20/05/2025 ------------
; ------------- Variables -------------
; ---------------- Main ---------------
; -- Pinout --
; PB6 PB7 TX RX
; PA7 ADC PA0 PWM



;-- USART --
USART1_BASE      EQU 0x40011000
USART1_SR        EQU (USART1_BASE + 0x00)
USART1_DR        EQU (USART1_BASE + 0x04)
USART1_BRR       EQU (USART1_BASE + 0x08)
USART1_CR1       EQU (USART1_BASE + 0x0C)

; -- ADC ----
ADC_BASE        EQU 0x40012000
ADC_SR          EQU (ADC_BASE + 0x00)
ADC_CR1         EQU (ADC_BASE + 0x04)
ADC_CR2         EQU (ADC_BASE + 0x08)
ADC_SMPR2       EQU (ADC_BASE + 0x10)
ADC_SQR1        EQU (ADC_BASE + 0x2C)
ADC_SQR3        EQU (ADC_BASE + 0x34) ;usaremos canal 0
ADC_DR          EQU (ADC_BASE + 0x4C)

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
GPIOA_BASE       EQU 0x40020000
GPIOA_MODER     EQU (GPIOA_BASE + 0x00)
;-- Configuration Registers --
GPIOA_OTYPER    EQU (GPIOA_BASE + 0x04)
GPIOA_OSPEED    EQU (GPIOA_BASE + 0x08)
GPIOA_PUPDR     EQU (GPIOA_BASE + 0x0C)
;-- Comm Registers --
GPIOA_IDR       EQU (GPIOA_BASE + 0x10)
GPIOA_ODR       EQU (GPIOA_BASE + 0x14)
; -- Alternate F --
GPIOA_AFRL       EQU (GPIOA_BASE + 0x20)
GPIOA_AFRH       EQU (GPIOA_BASE + 0x24)


; -- GPIO B --
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
GPIOA_BSSR       EQU (GPIOA_BASE + 0x18) ; Bit Set Set Register

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

MaxWatt         EQU 1400
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
    LDR     R0, =ADC_DR
    LDR     R1, [R0]


    LDR     R2, =MaxWatt
    MUL     R2,R2,R1  
    LSR     R2, #12


    MOV     R1,# 'P'
    BL      Write_UART
    MOV     R1,# 'O'
    BL      Write_UART
    MOV     R1,# 'T'
    BL      Write_UART
    MOV     R1,# 'E'
    BL      Write_UART
    MOV     R1,# 'N'
    BL      Write_UART
    MOV     R1,# 'C'
    BL      Write_UART
    MOV     R1,# 'I'
    BL      Write_UART
    MOV     R1,# 'A'
    BL      Write_UART
    MOV     R1,# ' '
    BL      Write_UART

    BL      dividiridigitos
 
    MOV     R1,# 'W'
    BL      Write_UART
    LDR     R1, =0x0D
    BL      Write_UART
    LDR     R1, =0x0A
    BL      Write_UART

    
 	B 		loop

    

dividiridigitos
    ; r2 contains the value to display (up to 9999)
    PUSH {LR}
    
    ; First digit (thousands)
    MOV R10, #1000
    UDIV R1, R2, R10      ; R1 = R2 / 1000
    BL Write_UART         ; Write the thousands digit
    SUB	R1,#0x30
	MUL R3, R1, R10       ; R3 = digit * 1000
    SUB R2, R2, R3        ; Subtract from original number
    
    ; Second digit (hundreds)
    MOV R10, #100
    UDIV R1, R2, R10      ; R1 = remaining / 100
    BL Write_UART         ; Write the hundreds digit
    SUB	R1,#0x30
	MUL R3, R1, R10       ; R3 = digit * 100
    SUB R2, R2, R3        ; Subtract from remaining number
    
    ; Third digit (tens)
    MOV R10, #10
    UDIV R1, R2, R10      ; R1 = remaining / 10
    BL Write_UART         ; Write the tens digit
    SUB	R1,#0x30
	MUL R3, R1, R10       ; R3 = digit * 10
    SUB R1, R2, R3        ; R1 = units digit
    
    ; Fourth digit (units)
    BL Write_UART         ; Write the units digit
    
    POP {PC}

Write_UART
    PUSH{R2,LR}
    LDR    R0, =USART1_DR
    CMP    R1, #10
    BLLT    sumar30
    STR    R1, [R0] ; Write data to transmit register
    LDR    R0, =USART1_SR

writeCycle
    LDR   R2, [R0] ; Read status register
    TST   R2, #(1<<6) ; Check if TXE is set
    BEQ   writeCycle ; If not, wait
    
    POP{R2,PC}
    
sumar30
    PUSH{LR}
    ADD    R1,#0x30
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
; --------------- q raro un chingo de configuracion ---------------
Config_RCC
    LDR     R0,=RCC_AHB1     ; 0    00           0     0     0     0     0
    LDR     R1,[R0]          ;GPIOH RESERVE   GPIOE  GPIOD GPIOC GPIOB GPIOA
    ORR     R1,#(0x3)       ; 0    00           0    0      0    1     1
    STR     R1,[R0]

	; Activamos el CLK del TIM2 0x4000 0000

	; TIM5  TIM4  TIM3  TIM2
	; 0      0     0      1
    LDR     R0,=RCC_APB1     
    LDR     R1,[R0]         
    ORR     R1,#0x01      
    STR     R1,[R0]

    ; Activamos el CLK del ADC 0x4001 2000
    LDR     R0,=RCC_APB2     
    LDR     R1,[R0]         
    ORR     R1,#(1<<8)|(1<<4) ; ADC1 y TIM2      
    STR     R1,[R0]

    BX      LR 

Config_GPIO

    ;--- PORTA ---
    


    LDR     R0, =GPIOA_MODER
    LDR     R1, [R0]
    LDR     R2, =0x0000C002
    ORR     R1,R1,R2
    STR     R1,[R0]

    ; Pull Down mode 10
    LDR     R0, =GPIOA_OSPEED
    LDR     R1, [R0]
    ORR     R2,R1, #0x03 
    STR     R2,[R0]

    ; Pull Down mode 10
    LDR     R0, =GPIOA_AFRL
    LDR     R1, [R0]
    ORR     R1,#(1 << 0)
    STR     R1,[R0]

    ;--- PORTB UART --- 
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
	
	
Config_ADC
    ; 12 bits of resolution CR1 is OFF

    ; We turn on for first time the ADC
    LDR 	R0, =ADC_CR2
	LDR 	R1, [R0]
    ORR     R1, #0x01
	STR		R1,[R0]

    ; Configure 15 cycles of sampling time
    LDR 	R0, =ADC_SMPR2
	LDR 	R1, [R0]
    ORR     R1, #(1<<21)
	STR		R1,[R0]

    ; We set the sequence of channel 7
    LDR 	R0, =ADC_SQR3
	LDR 	R1, [R0]
    ORR     R1, #(7<<0)
	STR		R1,[R0]

    ; We turn on the ADC for second time and we active count and conversion
    LDR 	R0, =ADC_CR2
	LDR 	R1, [R0]
    LDR		R2,=0x40000003
	ORR		R1,R2
	;STR		R1,[R0]
	;ORR 	R1, #(1<<30)
	STR		R1,[R0]


	BX 	LR

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