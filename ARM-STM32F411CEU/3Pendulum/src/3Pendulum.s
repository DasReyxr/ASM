; ----------- Iker | Das -----------
; ------------- 3 Oscillator -------------
; ------------- 01/04/2025 -------------
; ------------- Variables -------------
;---- Registers Used ----
; -- Main Code --
; R2 -> 8 Bit value Oscillator
; R3 -> 12 Bit value
; R5 -> Delay Actual Value
; R10 -> Min Value
; R11 -> Max Value
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

__main
    BL      confRCC
    BL      confGPIOC
    LDR     R5,=led_delay
    MOVW    R2, #0x0070
    EOR     R3,R3
    LDR     R11, =1000000
    MOV     R10, #54000
    LDR     R0,=GPIOA_ODR

ShiftR
    LSR     R3, R2, #2
    MOV     R1, R3
    STR     R1,[R0]
    CMP     R2, #7
    BEQ     ShiftL 
    LSR     R2,R2, #1
    BL      Delay

    LDR     R0, =GPIOB_IDR
    LDR     R1,[R0]    ; B7 B6 B5 B4 B3 B2 B1 B0 
    AND     R1,#0x0003 ; 0 0   0  1  1  0  0  0
    CMP     R1,#0x0002
    BEQ     ADD1
    CMP     R1,#0x0001
    BEQ     SUB1
    B       ShiftR

ShiftL
    LSR     R3, R2, #2
    MOV     R1, R3 
    STR     R1,[R0]
    CMP     R2, #0xE00
    BEQ     ShiftR 
    LSL     R2,R2, #1
    BL      Delay

    LDR     R6, =GPIOB_IDR
    LDR     R1,[R6]    ; B7 B6 B5 B4 B3 B2 B1 B0 
    AND     R1,#0x0003 ; 0 0   0  1  1  0  0  0
    CMP     R1,#0x0002
    BLEQ    ADD1
    CMP     R1,#0x0001
    BLEQ    SUB1
    B       ShiftL

ADD1
    CMP     R5, R11  ; if R5>r11 we substract 1 to the count (normal cycle) 
    BXHI    LR 
    ADD     R5,R5,#1 ; if R5 < r11, we add 1 to the next counter 
    BX      LR

SUB1
    CMP     R5,R10 ; if R5<r10 we substract 1 to the count (normal cycle)
    BXLO    LR
    SUB     R5,R5,#1 ; if r5>r10 we substract 1 to the next counter
    BX      LR

; ============== Configuration ============== 
confRCC
    LDR     R0,=RCC_AHB1ENR     ;   0        00         0     00        0      0       0      0     0
    LDR     R1,[R0]             ;  GPIOH  RESERVED  GPIOE  RESERVED  GPIOE   GPIOD  GPIOC   GPIOB   GPIOA
    ORR     R1,R1,#0x03         ;   0        00        0      00        0       0      0      1      1
    STR     R1,[R0]
    BX      LR

confGPIOC
    ;Configuramos del 0-7 del moder como salida de proposito general 
    LDR     R0,=GPIOA_MODER
    LDR     R1,[R0]
    LDR     R2,=0x00005555
    ORR     R1,R2
    STR     R1,[R0]
    ;Configuramos la velocidad de los pines 0-7  11 cada uno por eso los FF
    LDR     R0,=GPIOA_OSPEED
    LDR     R1,[R0]
    LDR     R2,=0x0000FFFF
    ORR     R1,R2
    STR     R1,[R0]

    ;Configuramos el 0 y 1 como pull down para la entrada A 1010 para pull down
    LDR     R0,=GPIOB_PUPDR
    LDR     R1,[R0]
    LDR     R2,=0x00000005
    ORR     R1,R2
    STR     R1,[R0]
    BX      LR

Delay
    SUBS    R5,R5,#1 ; Resta 1 al contador del delay
    BNE     Delay ; Brinca de regreso a Delay 1
    BX      LR

    ALIGN
    END