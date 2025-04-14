; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ------------- 14 Timers -------------
; ------------- 07/04/2025 -------------
; ------------- Variables -------------
; A0 Timer 2 CH1
; ---------------- Main ----------------

; -- Timer --
TIM2_BASE		EQU 0x40000000
TIM2_CR1		EQU (TIM2_BASE + 0x00)
TIM2_SR			EQU (TIM2_BASE + 0x10)

TIM2_CNT			EQU (TIM2_BASE + 0x24)
TIM2_PSC			EQU (TIM2_BASE + 0x28)
TIM2_ARR			EQU (TIM2_BASE + 0x2C)

; -- CLocks --
RCC_BASE	        EQU 0x40023800
RCC_AHB1    	    EQU (RCC_BASE  + 0x30)
RCC_APB1ENR        EQU (RCC_BASE  + 0x40)
RCC_APB2ENR        EQU (RCC_BASE  + 0x44)

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

;-- Special Registers --
GPIOA_BSSR       EQU (GPIOA_BASE + 0x18) ; Bit Set Set Register

ledilei        EQU 4000000
ledileicuarto  EQU 1000000

	AREA myData, DATA, READWRITE

    AREA juve3dstudio,CODE,READONLY
	ENTRY
	EXPORT __main

__main
    BL      Config_RCC
    BL      Config_GPIO
	BL 		Config_TIMER

LOOP
    ; Metodo Juan
	; LDR		R0, =TIM2_CNT
	; LDR		R1, [R0]
	; MOVW	R2, #23999
	; CMP 	R1,R2
	; BNE		LOOP

	; LDR 	R0,=GPIOC_ODR
	; LDR		R1, [R0]
	; EOR 	R1, #0x2000
	; STR		R1, [R0]

    ; Metodo 
    LDR     R0, =TIM2_SR
    LDR     R1, [R0]
    TST     R1, #(1<<0)
    BEQ     LOOP    
    BIC     R1,#(0<<0)      ; bit clear
    STR     R1,[R0]
    LDR 	R0,=GPIOC_ODR
	LDR		R1, [R0]
	EOR 	R1, #0x2000
	STR		R1, [R0]



	B 		LOOP
    


Config_RCC
    LDR     R0,=RCC_AHB1     ; 0    00           0     0     0     0     0
    LDR     R1,[R0]          ;GPIOH RESERVE   GPIOE  GPIOD GPIOC GPIOB GPIOA
    ORR     R1,#(0x5)       ; 0    00           0    0     1     0     1
    STR     R1,[R0]


	; 
    LDR     R0,=RCC_APB1ENR     
    LDR     R1,[R0]         
    ORR     R1,#0x4000      
    STR     R1,[R0]

	; TIM5  TIM4  TIM3  TIM2
	; 0      0     0      1
    LDR     R0,=RCC_APB2ENR     
    LDR     R1,[R0]         
    ORR     R1,(1 << 0)      
    STR     R1,[R0]


    BX      LR

Config_GPIO

    ;--- PORTA ---
    ; Se omitio esta parte porque por default esta como entrada
    ; LDR     R0, =GPIOA_MODER
    ; LDR     R1, [R0]
    ; MOVW    R2, #0x4000
    ; ORR     R1,R1,R2
    ; STR     R1,[R0]

    ; Pull Down mode 10
    LDR     R0, =GPIOA_PUPDR
    LDR     R1, [R0]
    ORR     R2,R1, #0x02 
    STR     R1,[R0]



    ;--- PORTC ---
    LDR     R0, =GPIOC_MODER
    LDR     R1, [R0]
    LDR     R2, #0x40000000
    ORR     R1,R1,R2
    STR     R1,[R0]

    LDR     R0, =GPIOC_OSPEED
    LDR     R1, [R0]
    LDR     R2, #0x0C000000
    ORR     R1,R1,R2
    STR     R1,[R0]

    BX      LR



Config_TIMER
	; -- Values --
    LDR     R0,=TIM2_PSC  ;Tim_prescaler
    MOVW 	R1, #999
	STR     R1,[R0]
	
	LDR     R0,=TIM2_ARR ; Tim_Period     
    MOVW 	R1, #23999
	STR     R1,[R0]
	
	
	; CKD    ARPE  CMS  DIR  OPM  URS   UDIS CEN
	; 00      1    00    0   0    0      0    1
    LDR     R0,=RCC_APB2ENR     
    LDR     R1,[R0]         
    ORR     R1,#0x81      
    STR     R1,[R0]


	BX		LR
	
	ALIGN 
	END