; ----------- Iker | Das -----------
; ------------- 3 Oscillator -------------
; ------------- 01/04/2025 -------------
; ------------- Variables -------------
;---- Registers Used ----
; -- Main Code --
; R2    Contador
; R3	PortB Handling Col
; R4	PortA Handling Row
; R7	LED
; R8    n r4 =  1 | 2 | 3 | 4
;         r8   -1  -1  -4  -5
; r10   4(3-R11)
; r11   number of zeros of r4
; R12   shifted bit
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
    LDR     R0, =GPIOA_ODR ; Sacar valores
    STR		R7, [R0]
    LSR     R4,R7,#8
    
	
    LDR     R0,=GPIOB_IDR
	LDR		R3,[R0]
    LSR	    R3,#12;12 ;le calamos

    ADDS    R3,#0
    BLNE    FindCol
	

	
	LDR     R0, =GPIOA_ODR ; Sacar valores
    STR		R7, [R0]
	AND     R7, #0xFFFF00FF
    ORR     R7, R10
    LDR     R0, =GPIOA_ODR ; Sacar valores
    STR		R7, [R0]

	LSL     R12, #1
    ADD     R2,#1
	
	
    B      loopi

FindCol 

    MOV     R10, #3
    EOR     R8,R8
		
    CLZ     R11, R4
	SUB		R11,#28
    SUB     R10,R11
    LSL     R10, #2
	
    CMP     R3, #4
    BEQ     es4
    CMP     R3,#8
    BEQ     es8         
    SUB		R8, #1
	
yasta
    ADD     R3,R8
    ADD     R10,R3
	LDR     R0, =GPIOA_ODR ; Sacar valores
    
	AND     R7, #0xFFFFFF00
	STR		R7, [R0]
	BX      LR

es4 
    SUB     R8, #2
    b       yasta
es8
    SUB     R8, #5
    b       yasta
    
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