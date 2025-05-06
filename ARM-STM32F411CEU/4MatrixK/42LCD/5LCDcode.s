; ----------- Iker | Das -----------
; ------------- 3 Oscillator -------------
; ------------- 01/04/2025 -------------
;---------- I date 24/04/2025 ----------
;---------- C date 24/04/2025 ----------
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

led_delay       EQU 900000

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
	
loopi
    
    B      loopi

    
; ============== Configuration ==============

    
confRCC
    LDR     R0,=RCC_AHB1ENR     ;   0        00         0     00        0      0       0      0     0
    LDR     R1,[R0]             ;  GPIOH  RESERVED  GPIOE  RESERVED  GPIOE   GPIOD  GPIOC   GPIOB   GPIOA
    ORR     R1,R1,#0x03         ;   0        00        0      00        0       0      0      1      1
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

; r2,r3,r4,r7,r8,r10,r11,r12
; r5

confLCD
    
    LDR     R0,=GPIOB_IDR
    LDR		R3,[R0]

    AND     R3, #0xFFFFFFFC ; Turn off RS and Enable  
    STR     R3, [R0]
    ; push 
    BL      Delay_5ms
    BL      Delay_5ms
    BL      Delay_5ms   
    
    MOV     R4,#0x38
    BL      LCDOUT
    MOV     R4,#0x38
    BL      LCDOUT
    MOV     R4,#0x38
    BL      LCDOUT
    MOV     R4,#0x38
    BL      LCDOUT
    
    MOV     R4,#0x08; Display OFF
    BL      LCDOUT
    MOV     R4,#0x01; Clear Display
    BL      LCDOUT
    MOV     R4,#0x06; Entry Mode Set
    BL      LCDOUT
    MOV     R4,#0x0C; Display ON
    BL      LCDOUT

    LDR     R0,=GPIOB_IDR
    LDR		R3,[R0]
    ORR     R3, #0x00000002 ; Character Mode RS = 1
	LDR     R0,=GPIOB_ODR
    STR     R3, [R0]
    POP{LR}
    BX      LR

    
LCDOUT 	
    PUSH{LR}
    LDR     R0,=GPIOA_IDR
    LDR		R5,[R0]

    AND     R5, #0xFFFFFF00    
    ORR     R5,R4
    LDR     R0,=GPIOA_ODR
	STR     R5, [R0]

    LDR     R0,=GPIOB_IDR
    LDR		R3,[R0]
    ORR     R3, #0x00000001 ;Enable = 1
	LDR     R0,=GPIOB_ODR
    STR     R3, [R0]
    
    BL      Delay_5ms

    LDR     R0,=GPIOB_IDR
    LDR		R3,[R0]
    AND     R3, #0xFFFFFFFE ;Enable = 0
	LDR     R0,=GPIOB_ODR
    STR     R3, [R0]
    
    POP{LR}
    BX      LR

Delay_5ms 
    ldr   r9, =led_delay
dei  
    subs    r9,r9,#1
    bne     dei
    
    BX      LR

    ALIGN
    END