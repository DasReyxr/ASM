; ------ Orlando Reyes ------
; --------- Auf Das ---------
; ----- CONFIG -----
; ---- I date 13/06/2025 ----
; ---- C date 13/06/2025 ----
; -------- Variables --------
; ----------- Main -----------

NVIC_BASE       EQU 0xE000E100 
NVIC_ISER0      EQU (NVIC_BASE + 0x00)
NVIC_ISER1      EQU (NVIC_BASE + 0x04) ; IER1 for USART1
NVIC_IPR7       EQU (NVIC_BASE + 0x300+(4*7)) ; IPR7 for TIM2
NVIC_IPR9       EQU (NVIC_BASE + 0x300+(4*9)) ; IPR7 for TIM2
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
	IMPORT UART
	EXPORT __main
    EXPORT USART1_IRQHandler


__main
    BL      Config_RCC
    BL      Config_GPIO
	BL 		Config_NVIC
	BL      Config_UART
    EOR     R1,R1
    EOR     R2,R2
    
	LDR 	R15,=UART
	;BX 		R0



USART1_IRQHandler 
    PUSH{R0-R2,LR}

    LDR     R0, =USART1_SR     
    LDR     R1, [R0]
    TST     R1, #(1 << 5)      ; Check RXNE bit (bit 5)
    BEQ     done           

    LDR     R0,=USART1_DR
    LDR     R1, [R0]           ; Write received data back to DR (echo)
    bl		Write_UART
    
done
    POP{R0-R2,PC}

Write_UART
    LDR     R0,=USART1_DR
    STR     R1,[R0]
    LDR     R0,=USART1_SR
WRITECIC
    LDR     R1,[R0]
    TST     R1,#(1 << 6)
    BEQ     WRITECIC
    BX LR


Config_RCC
    LDR     R0,=RCC_AHB1     ; 0    00           0     0     0     0     0
    LDR     R1,[R0]          ;GPIOH RESERVE   GPIOE  GPIOD GPIOC GPIOB GPIOA
    ORR     R1,#(0x2)       ; 0    00           0    0      0    1     0
    STR     R1,[R0]


    ; Activamos el CLK del USART 
    LDR     R0,=RCC_APB2     
    LDR     R1,[R0]         
    ORR     R1,#(1<<4)  ; USART   
    STR     R1,[R0]


    BX      LR 

Config_GPIO
    LDR     R0, =GPIOB_MODER
    LDR     R1, [R0]
    ORR     R1, #(0xA << 12)  ;Alternate function for PB6
    STR     R1, [R0]

    LDR     R0,=GPIOB_AFRL     
    LDR     R1,[R0]         
    ORR     R1,#((7<<24)|(7<<28))  ; USART   
    STR     R1,[R0]    
    BX      LR


Config_NVIC
    
    LDR R0,=NVIC_ISER1 ;interrupcion con registro
	LDR R1, [R0]
	ORR R1, #(1<<5) ;Uno en el bit 0
	STR R1, [R0]
    
	BX	LR

Config_UART
    PUSH{LR}
    ;966 Baud rate
    LDR     R0, =USART1_BRR
    LDR     R1, =0x683 ; Baud rate 9600
    STR     R1, [R0] ; Set baud rate
    
    ;Configuramos nuestro uart a una trama de 1 bit start
    LDR     R0,yyyyyyy=USART1_CR1
	LDR     R1,[R0]
    MOV     R1, #(1 << 13) ; UE: Habilitar USART
    ORR     R1, R1, #(1 << 3) ; TE: Habilitar transmisor
    ORR     R1, R1, #(1 << 2) ; RE: Habilitar receptor
    ORR     R1, R1, #(1 << 5) ; RXNEIE: Habilitar interrupción RX
	STR     R1,[R0]
    POP{PC}


	align
	end