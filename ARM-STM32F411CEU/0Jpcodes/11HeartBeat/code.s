; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; -------------- PORTS --------------
; ------------- 18/03/2025 -------------
; ------------- Variables -------------

; ---------------- Main ----------------
; -- CLocks --
RCC_BASE        EQU 0x40023800
RCC_AHB1        EQU (RCC_BASE  + 0x30)
; -- GPIO --
GPIOC_BASE       EQU 0x40020800
GPIOC_MODER     EQU (GPIOC_BASE + 0x00)
;-- Configuration Registers --
GPIOC_OTYPER    EQU (GPIOC_BASE + 0x04)
GPIOC_OSPEED    EQU (GPIOC_BASE + 0x08)
GPIOC_PUPDR     EQU (GPIOC_BASE + 0x0C)
;-- Comm Registers --
GPIOC_IDR       EQU (GPIOC_BASE + 0x10)
GPIOC_ODR       EQU (GPIOC_BASE + 0x14)

;-- Special Registers --
GPIOC_BSSR       EQU (GPIOC_BASE + 0x18) ; Bit Set Set Register

ledilei        EQU 10000000

	AREA myData, DATA, READWRITE

    AREA juve3dstudio,CODE,READONLY
	ENTRY
	EXPORT __main

__main
    BL      Config_RCC
    BL      Config_GPIO


;    LDR     R0, =GPIOC_BSSR
;    EOR     R1,R1
;    ORR     R1,R1, #0x0200 ; 0010 0000 0000 0000
;    STR     R1,[R0] 

loop
    ldr     r0, =GPIOC_ODR
    ldr     r1,[r0]
    movw    r2, #0x2000
    eor     r1,r2
    str     r1,[r0]
    bl      dilei
    b       loop
    


Config_RCC
    LDR     R0,=RCC_AHB1
    LDR     R1,[R0]
    ORR     R1,R1,#4
    STR     R1,[R0]
    BX      LR

Config_GPIO
    LDR     R0, =GPIOC_MODER
    LDR     R1, [R0]
    MOVW    R2, #0x4000
    ORR     R1,R1,R2
    STR     R1,[R0]


    LDR     R0, =GPIOC_OSPEED
    LDR     R1, [R0]
    MOVW    R2, #0x3
    ORR     R1,R1,R2
    STR     R1,[R0]


    BX      LR
dilei 
    ldr   R0, =ledilei
dei  
    subs    r0,r0,#1
    bne     dei
    BX LR
	align
	end