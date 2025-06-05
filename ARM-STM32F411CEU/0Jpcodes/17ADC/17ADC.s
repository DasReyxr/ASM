; --------------  Das -----------
; ------------ ADC ------------
; ------------- 20/05/2025 ------------
; ------------- Variables -------------
; ---------------- Main ---------------


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

PWMFULL         EQU 1600
	AREA myData, DATA, READWRITE

    AREA bobostudio,CODE,READONLY
	ENTRY
	EXPORT __main

__main
    BL      Config_RCC
    BL      Config_GPIO
	BL 		Config_TIM
	
loop
	;leyendo el ADC
    LDR     R0, =ADC_DR
    LDR     R1, [R0]

    LDR     R2, =PWMFULL
    MUL     R2,R2,R1
    LSR     R2, #12

    ;Loading the value to the TIM2_CCR1 chanel 0
    LDR     R0, =TIM2_CCR1
    STR     R2, [R0]

	B 		loop
    
Config_RCC
    LDR     R0,=RCC_AHB1     ; 0    00           0     0     0     0     0
    LDR     R1,[R0]          ;GPIOH RESERVE   GPIOE  GPIOD GPIOC GPIOB GPIOA
    ORR     R1,#(0x1)       ; 0    00           0    0      0    0     1
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
    ORR     R1,#(1<<8)      
    STR     R1,[R0]

    BX      LR 

Config_GPIO

    ;--- PORTA ---
    ; PA0 as alternate function
    ; PA7 as analog input
    LDR     R0, =GPIOA_MODER
    LDR     R1, [R0]
    ORR     R1, #(0x03 << 14)  ; Analog mode for PA7 (bits 15:14 = 11)
    STR     R1, [R0]

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
	align
	end