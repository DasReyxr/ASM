; ----------- Iker | Das -----------
; ------------- 4 MITRIX & LCD -------------
; ------------- 01/04/2025 -------------
; ------------- Variables -------------
;---- Registers Used ----
; -- Main Code --
;-- Matrix K--
; R2    Contador Shifteos
; R3	PortB Handling Col
; R4	PortA Handling Row
; R7	Sequencer A[15:12]
; R8    n r4 =  1 | 2 | 3 | 4
;         r8   -1  -1  -4  -5
; R10   4(3-R11)
; r11   number of zeros of r4
; R12   shifted bit
; -- Config --
; R0 -> &Temp pointer address
; R1 -> *Temp Pointer value
; R2 -> Temp Config Value 
; R3 -> RS and Enable PortB
; R4 -> ValConfig

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

led_delay       EQU 400000 ; 1.2 M de cilcos

    AREA my_data, DATA, READWRITE

    AREA juve3dstudio, CODE, READONLY
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
    LDR     R0, =GPIOA_ODR 
aqui    
    EOR     R2,R2
	EOR		R12,R12
	ORR		R12, #(1<<8)

loopi	
    ; Clean the registers
	EOR		R7,R7
	EOR		R3,R3
	EOR		R4,R4
    CMP     R2, #4
    BEQ     aqui

    ;Read the high part[12:8] of the port A and shift it to the right storaged in R4
    AND     R7, #0xFFFF00FF
    ORR     R7, R12
    LDR     R0, =GPIOA_ODR 
    STR		R7, [R0]
    LSR     R4,R7,#8
    
	;Read the high part[15:12] of the port B and shift it to the right storaged in R3
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
;parameters used:
; R3 -> PortB Handling Col
; R4 -> PortA Handling Row
; R10 ->
    ; The equation to get the value of Key Pressed is: = 4(3-R11) - R8 
    ;Count the number of zeros in R4 saved in R11 and subtract 28 to get the number of bits to shift
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
    ; Clean the PortA in the low part[7:0] to write the new value
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
;    ADD     R7, #0x30   ; Add 0x30 to the value of R7 to get the correct value for the LCD
    
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
    ;mandar 4
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
; Parameters Used:
; R0 -> &Temp pointer address   | Doesnt care if are cleaned
; R1 -> *Temp Pointer value     | Doesnt care if are cleaned

    LDR     R0,=RCC_AHB1ENR     ;   0        00         0     00        0      0       0      0     0
    LDR     R1,[R0]             ;  GPIOH  RESERVED  GPIOE  RESERVED  GPIOE   GPIOD  GPIOC   GPIOB   GPIOA
    ORR     R1,R1,#0x03         ;   0        00        0      00        0       0      0      1      1
    STR     R1,[R0]
    BX      LR

confGPIO
; Parameters Used:
; R0 -> &Temp pointer address   | Doesnt care if are cleaned
; R1 -> *Temp Pointer value     | Doesnt care if are cleaned
; R2 -> Temp Config Value       | Doesnt care if are cleaned
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

    ;       15  14  13  12  11  10  9   8   7   6   5   4   3   2   0   0 
    ;       O   O   O   O   X   X   X   X   X   X   X   R   R   X   1   1                                  
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
; Parameters Used:
; R0 -> &Temp pointer address   | Doesnt care if are cleaned
; R1 -> *Temp Pointer value     | Doesnt care if are cleaned
; R3 -> Value to PortA          | Doesnt care if are cleaned
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
; Args needed:
; R3 -> Value to PortA (From confLCD or FindCol)
; R7 -> Next Value to PortA (From FindCol)
; Parameters Used:
; R0 -> &Temp pointer address   | Doesnt care if are cleaned
; R1 -> *Temp Pointer value     | Doesnt care if are cleaned
; R5 -> Temp Config Value       | Doesnt care if are cleaned

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