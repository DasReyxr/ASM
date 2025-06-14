RCC_BASE        EQU 0x40023800
RCC_AHB1ENR     EQU (RCC_BASE + 0x30)
; --------- GPIO A ---------
GPIOA_BASE      EQU 0x40020000
GPIOA_MODER     EQU (GPIOA_BASE + 0x00)
;-- Configuration Registers --
GPIOA_OTYPER    EQU (GPIOA_BASE + 0x04)
GPIOA_OSPEED    EQU (GPIOA_BASE + 0x08)
GPIOA_PUPDR     EQU (GPIOA_BASE + 0x0C)
;-- Comm Registers --
GPIOA_IDR       EQU (GPIOA_BASE + 0x10)
GPIOA_ODR       EQU (GPIOA_BASE + 0x14)

;-- Special Registers --
GPIOA_BSSR      EQU (GPIOA_BASE + 0x18) ; Bit Set Set Register
; --------- GPIO B ---------
GPIOB_BASE      EQU 0x40020400
GPIOB_MODER     EQU (GPIOB_BASE + 0x00)
;-- Configuration Registers --
GPIOB_OTYPER    EQU (GPIOB_BASE + 0x04)
GPIOB_OSPEED    EQU (GPIOB_BASE + 0x08)
GPIOB_PUPDR     EQU (GPIOB_BASE + 0x0C)
;-- Comm Registers --
GPIOB_IDR       EQU (GPIOB_BASE + 0x10)
GPIOB_ODR       EQU (GPIOB_BASE + 0x14)

;-- Special Registers --
GPIOB_BSSR      EQU (GPIOB_BASE + 0x18) ; Bit Set Set Register

led_delay       EQU 400000 ; 1.2 M de cilcos

    AREA my_data, DATA, READWRITE

    AREA juve3dstudio, CODE, READONLY
    ENTRY
    EXPORT __main

__main
    BL      confRCC
    BL      confGPIO
    EOR     R2,R2
    LDR     R0, =GPIOA_ODR 
aqui    
    EOR     R2,R2
	EOR		R12,R12
	ORR		R12, #(1<<8)

loopi	
	EOR		R7,R7
	EOR		R3,R3
	EOR		R4,R4
    CMP     R2, #4
    BEQ     aqui

    AND     R7, #0xFFFF00FF
    ORR     R7, R12
    LDR     R0, =GPIOA_ODR 
    STR		R7, [R0]
    LSR     R4,R7,#8
    
    LDR     R0,=GPIOB_IDR
	LDR		R3,[R0]
    LSR	    R3,#12

    LSR     R5,R3, #1
    ANDS    R5, R3
    BEQ     Well
    MOV     R3, R5
Well
    ADDS    R3,#0
    BLNE    FindCol
	LSL     R12, #1
    ADD     R2,#1
	
    B      loopi

; ============== Subrutines ==============

FindCol 
    EOR     R8,R8
    MOV     R10, #3	
    CLZ     R11, R4
	SUB		R11,#28
    SUB     R10,R11
    LSL     R10, #2
	
    CMP     R3, #4
    BEQ     is4
    CMP     R3,#8
    BEQ     is8         
    SUB		R8, #1
	
Done
	PUSH{LR}	
	ADD     R3,R8
    ADD     R10,R3
	LDR     R0, =GPIOA_ODR 
	AND     R7, #0xFFFFFF00
	STR		R7, [R0]
    LSL     R10,#4
    ORR     R7, R10 ;

    CMP     R10, #0x90
    bhi     isA 
    MOV     R3, #0x30
Ditto
    bl      LCDOUT    
	CMP		R7,R6
	BLNE	previousVal
    
    BL      Delay_5ms
    BL      Delay_5ms
    BL      Delay_5ms

	POP		{LR}
	
    BX      LR

is4 
    SUB     R8, #2
    b       Done
is8
    SUB     R8, #5
    b       Done
isA
    MOV     R3, #0x40
    sub     R7,#0x90
    b       Ditto

Delay_5ms 
    ldr   r9, =led_delay
delay  
    subs    r9,r9,#1
    bne     delay
    
    BX      LR
    
; ============== Configuration ==============

confRCC
    LDR     R0,=RCC_AHB1ENR
    LDR     R1,[R0]
    ORR     R1,R1,#0x03
    STR     R1,[R0]
    BX      LR

confGPIO
    push{lr}
    ; ----- PORTA ------
    LDR     R0,=GPIOA_MODER
    LDR     R1,[R0]
    LDR     R2,=0x00555555 
    ORR     R1,R2
    STR     R1,[R0]

    LDR     R0,=GPIOA_OSPEED
    LDR     R1,[R0]
    LDR     R2,=0x00FFFFFF
    ORR     R1,R2
    STR     R1,[R0]
    
    ; ----- PORTB ------
    LDR     R0,=GPIOB_PUPDR
    LDR     R1,[R0]
    LDR     R2,=0xAA000000
    ORR     R1,R2
    STR     R1,[R0]

    LDR     R0,=GPIOB_MODER
    LDR     R1,[R0]
    LDR     R2,=0x00000005 
    ORR     R1,R2
    STR     R1,[R0]

    LDR     R0,=GPIOB_OSPEED
    LDR     R1,[R0]
    LDR     R2,=0x0000000F
    ORR     R1,R2
    STR     R1,[R0]

confLCD
    LDR     R0,=GPIOB_IDR
    LDR		R1,[R0]

    AND     R1, #0xFFFFFFFC ; Turn off RS and Enable  
    STR     R1, [R0]
    
    BL      Delay_5ms
    BL      Delay_5ms
    BL      Delay_5ms   
    
    MOV     R3,#0x30
    BL      LCDOUT
    MOV     R3,#0x20
    BL      LCDOUT
    MOV     R3,#0x80
    BL      LCDOUT
    MOV     R3,#0x20
    BL      LCDOUT
    
    MOV     R3,#0x00; Display OFF
    BL      LCDOUT
    MOV     R3,#0xC0; Clear Display
    BL      LCDOUT
    MOV     R3,#0x00; Entry Mode Set
    BL      LCDOUT
    MOV     R3,#0x10; Display ON
    BL      LCDOUT
    
    MOV     R3,#0x00; Display ON
    BL      LCDOUT    
    MOV     R3,#0x60; Display ON
    BL      LCDOUT
    LDR     R0,=GPIOB_IDR
    LDR		R1,[R0]
    ORR     R1, #0x00000002 ; Character Mode RS = 1
	LDR     R0,=GPIOB_ODR
    STR     R1, [R0]

    POP{LR}
    BX      LR
previousVal

    MOV 	R3,R7  
LCDOUT 	
	PUSH{LR}
    LDR     R0,=GPIOA_IDR
    LDR		R5,[R0]

    AND     R5, #0xFFFFFF00    
    ORR     R5,R3
    LDR     R0,=GPIOA_ODR
	STR     R5, [R0]

    LDR     R0,=GPIOB_IDR
    LDR		R5,[R0]
    ORR     R5, #0x00000001 ;Enable = 1
	LDR     R0,=GPIOB_ODR
    STR     R5, [R0]
    
    BL      Delay_5ms

    LDR     R0,=GPIOB_IDR
    LDR		R5,[R0]
    AND     R5, #0xFFFFFFFE ;Enable = 0
	LDR     R0,=GPIOB_ODR
    STR     R5, [R0]

    POP{LR}


    BX      LR

    ALIGN
    END