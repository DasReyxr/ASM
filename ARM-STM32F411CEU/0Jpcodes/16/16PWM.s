; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ------------- 16 Input -------------
; ------------- 15/04/2025 -------------
; ------------- Variables -------------

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

	AREA myData, DATA, READWRITE

    AREA bobostudio,CODE,READONLY
	ENTRY
	EXPORT __main

__main
    BL      Config_RCC
    BL      Config_GPIO
	BL 		Config_TIM
	
loop
    LDR     R0, =TIM2_SR
    LDR     R1,[R0]
    TST     R1,#(1<<1)
    BEQ     loop
         
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
    ORR     R1,#0x0001      
    STR     R1,[R0]

    BX      LR

Config_GPIO

    ;--- PORTA ---
    ; PA0 as alternate function
    LDR     R0, =GPIOA_MODER
    LDR     R1, [R0]
    LDR     R2, =0x00000002
    ORR     R1,R1,R2
    STR     R1,[R0]

    ; Pull Down mode 10
    LDR     R0, =GPIOA_OSPEED
    LDR     R1, [R0]
    ORR     R2,R1, #0x03 
    STR     R1,[R0]

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
	MOV 	R1, #999 ; Tim_Prescaler -->(1000-1)
	STR		R1,[R0]
	
	LDR 	R0, =TIM2_ARR
	MOV 	R1, #23999 ; Tim_Period -->(24000-1)
	STR		R1,[R0]
	
    ;   IC2F    IC2PSC  CC2S    IC1F    IC1PSC  CC1S
    ;   000     00      00      000     00      00
    ;                                           10 = 0x0002
    
    LDR 	R0, =TIM2_CCMR1
    LDR 	R1, [R0]
	ORR 	R1, #0x02
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
	;MOV 	R1, #4799 ; Tim_PWM -->(4800-1)
	MOV 	R1, #19199 ; Tim_PWM -->(19199-1)
	
    STR		R1,[R0]
	
	
	BX 	LR
	

	align
	end