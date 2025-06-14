; ----------- Iker | Das -----------
; ------------- 3 Oscillator -------------
; ------------- 01/04/2025 -------------
; ------------- Variables -------------
;---- Registers Used ----
; -- Main Code --
; R2    Contador
; R3	PortB Handling Col
; R4	PortA Handling Row
; R5	Coordinates
; R6	Val
; R7	LED
; R12   gbg
; -- Config --
; R0 -> &Temp pointer address
; R1 -> *Temp Pointer value
; R2 -> Temp Config Value 
; ---------------- Main ----------------

; --------- Clocks ---------
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

led_delay       EQU 400000

    AREA my_data, DATA, READWRITE

    AREA myCode, CODE, READONLY
    ENTRY
    EXPORT __main
;           31  29  27  25  23  21  19  17  15  13  11  9   7   4   2   1   
;           15  14  13  12  11  10  9   8   7   6   5   4   3   2   1   0   
; PORTA     RR  RR  RR  RR  KK  KK  KK  KK  LL  LL  LL  LL  LL  LL  LL  LL
; AND MASK  F      F      K      K      F      F      F      F
; AND #FFKK FFFF  

; PORTB     XX  XX  XX  KK  KK  KK  KK  XX  XX  XX  XX  RR  RR  XX  XX  XX  XX
; AND MASK  00      0K      KK      K0  00      00      FF      00                    

__main
    BL      confRCC
    BL      confGPIO
    EOR     R2,R2

    ;Turn On columns with ones (Columns are in port A)
    LDR     R0, =GPIOA_ODR ; Hacer una vez 
aqui    
    EOR     R2,R2
	EOR		R12,R12
	ORR		R12, #(1<<8)

loopi
    CMP     R2, #4
    BEQ     aqui

    AND     R7, #0xFFFF00FF
    ORR     R7, R12
    STR		R7,[R0]
	LSL     R12, #1
    ADD     R2,#1
	
    ADDS    R3,#0
    BLNE    FindCol

    B      loopi

FindCol 
    LDR     R0,=GPIOB_IDR
    LSR	    R3,#3
    CMP 	R3,#0x01
    BEQ	    Caso1
    CMP 	R3,#0x02
    BEQ	    Caso2
    CMP 	R3,#0x04
    BEQ	    Caso3
    CMP 	R3,#0x08
    BEQ	    Caso4
    BX      LR

Caso1	
    LSR	    R3,#8
	CMP	    R4,#01
	BNE	    n11
    LDR	    R6,=1
	STR	    R6,[R0]
n11	
    CMP	    R4,#02
	BNE	    n12
    LDR	    R6,=2
	STR	    R6,[R0]
n12	
    CMP	    R4,#04
	BNE	    n13
    LDR	    R6,=3
	STR	    R6,[R0]
n13	
    CMP	    R4,#04
	BXNE	LR
    LDR	    R6,=4
	STR	    R6,[R0]	
    BX      LR

Caso2	
    LSR	    R3,#8
	CMP	    R4,#01
	BNE	    n21
    LDR	    R6,=5
	STR	    R6,[R0]
n21	
    CMP	    R4,#02
	BNE	    n22
    LDR	    R6,=6
	STR	    R6,[R0]
n22	
    CMP	    R4,#04
	BNE	    n23
    LDR	    R6,=7
	STR	    R6,[R0]
n23	
    CMP	    R4,#04
	BXNE	LR
    LDR	    R6,=8
	STR	    R6,[R0]	
    BX      LR

Caso3	
    LSR	    R3,#8
	CMP	    R4,#01
	BNE	    n31
    LDR	    R6,=9
	STR	    R6,[R0]
n31	
    CMP	    R4,#02
	BNE	    n32
    LDR	    R6,=10
	STR	    R6,[R0]
n32	
    CMP	    R4,#04
	BNE	    n33
    LDR	    R6,=11
	STR	    R6,[R0]
n33	
    CMP	    R4,#04
	BXNE	LR
    LDR	    R6,=12
	STR	    R6,[R0]	
    BX      LR

Caso4	
    LSR	    R3,#8
	CMP	    R4,#01
	BNE	    n41
    LDR	    R6,=13
	STR	    R6,[R0]
n41	
    CMP	    R4,#02
	BNE	    n42
    LDR	    R6,=14
	STR	    R6,[R0]
n42	
    CMP	    R4,#04
	BNE	    n43
    LDR	    R6,=15
	STR	    R6,[R0]
n43	
    CMP	    R4,#04
	BXNE	LR
    LDR	    R6,=16
	STR	    R6,[R0]	
    BX      LR

; ============== Configuration ==============

confRCC
    LDR     R0,=RCC_AHB1ENR     ;   0        00         0     00        0      0       0      0     0
    LDR     R1,[R0]             ;  GPIOH  RESERVED  GPIOE  RESERVED  GPIOE   GPIOD  GPIOC   GPIOB   GPIOA
    ORR     R1,R1,#0x03         ;   0        00        0      00        0       0      0      1      1
    STR     R1,[R0]
    BX      LR

confGPIO
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
    BX      LR

    ALIGN
    END