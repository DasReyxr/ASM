; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; -------------- LED --------------
; ------------- 25/03/2025 -------------
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

    mov     R2, #0x2000
    eor     r3,r3

loop
    ldr     r0, =GPIOC_PUPDR
    ldr     r1,[r0]
    and     r1,#0x4000
    cmp     r1,#0x4000
    bne     presionado

    ldr     r0, =GPIOC_ODR
    ldr     r1,[r0]
    orr     r1,r2
    str     r1,[r0]
    b       loop
    
    
presionado 
    ldr     r0, =GPIOC_ODR
    ldr     r1,[r0]
    and     r1,r3
    str     r1,[r0]


Config_RCC
    ldr     R0,=RCC_AHB1
    ldr     R1,[R0]
    orr     R1,R1,#4
    str     R1,[R0]
    bx      LR

Config_GPIO
    ;Configuramos el PC13 como salida de proposito general PushPull (pp) y el pC14 como entrada
    LDR     R0, =GPIOC_MODER
    LDR     R1, [R0]
    ldr     r2, =0x04000000
    orr     r1,r1,r2
    str     r1,[r0]


    ldr     R0, =GPIOC_OSPEED
    ldr     R1, [R0]
    mov     R2, #0x0C000000
    orr     R1,R1,R2
    str     R1,[R0]

	;Configuramos el PC14 como salida de proposito general PushPull (pp)
	ldr     r0,=GPIOx_PUPDR
	ldr     r1,[R0]
	ldr     r2,=0x10000000
	orr     r1,r2, r2
	str     r1,[R0]

    BX      LR

dilei 
    ldr   R0, =ledilei
dei  
    subs    r0,r0,#1
    bne     dei
    BX LR
	align
	end