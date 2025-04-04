; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; -------------- Ext Int --------------
; ------------- 01/04/2025 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
; -- Extin --
EXTI_BASE       EQU 0x40013C00
EXTI_IMR        EQU (EXTI_BASE + 0x00) ; Interrupt Mask Register
EXTI_EMR        EQU (EXTI_BASE + 0x04) ; Event Mask Register
EXTI_RTSR       EQU (EXTI_BASE + 0x08); Rissing Triger Selectio
EXTI_FTSR       EQU (EXTI_BASE + 0x0C); Falling Triger Selectio
EXTI_PR         EQU (EXTI_BASE + 0x14); Pending Register

NVIC_BASE       EQU 0xE000E100 
NVIC_ISER0      EQU (NVIC_BASE + 0x00)


SYSCFG_BASE     EQU 0x40013800 
SYSCFG_EXTICR1  EQU (SYSCFG_BASE + 0x08)
; -- CLocks --
RCC_BASE        EQU 0x40023800
RCC_AHB1        EQU (RCC_BASE  + 0x30)
RCC_APB2        EQU (RCC_BASE  + 0x44)

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

;-- Special Registers --
GPIOA_BSSR       EQU (GPIOA_BASE + 0x18) ; Bit Set Set Register

ledilei        EQU 4000000
ledileicuarto  EQU 1000000

	AREA myData, DATA, READWRITE

    AREA juve3dstudio,CODE,READONLY
	ENTRY
	EXPORT __main
    EXPORT exti0Handler

__main
    BL      Config_RCC
    BL      Config_GPIO
    bl      Config_EXTI
   ; bl      Config_Syscfg
    bl      Config_NVIC
loop
    ldr     r0, =GPIOC_ODR
    ldr     r1,[r0]
    movw    r2, #0x2000
    eor     r1,r2
    str     r1,[r0]
    bl      dilei
    b       loop
    


Config_RCC
    LDR     R0,=RCC_AHB1     ; 0    00           0     0     0     0     0
    LDR     R1,[R0]          ;GPIOH RESERVE   GPIOE  GPIOD GPIOC GPIOB GPIOA
    ORR     R1,#(0x5)       ; 0    00           0    0     1     0     1
    STR     R1,[R0]

    LDR     R0,=RCC_APB2     
    LDR     R1,[R0]         
    ORR     R1,#0x4000      
    STR     R1,[R0]


    BX      LR

Config_GPIO
    ;--- PORTA ---
    ; Se omitio esta parte porque por default esta como entrada
    ; LDR     R0, =GPIOA_MODER
    ; LDR     R1, [R0]
    ; MOVW    R2, #0x4000
    ; ORR     R1,R1,R2
    ; STR     R1,[R0]

    ; Pull Down mode 10
    LDR     R0, =GPIOA_PUPDR
    LDR     R1, [R0]
    ORR     R2,R1, #0x02 
    STR     R1,[R0]



    ;--- PORTC ---
    LDR     R0, =GPIOC_MODER
    LDR     R1, [R0]
    MOVW    R2, #0x4000
    ORR     R1,R1,R2
    STR     R1,[R0]

    BX      LR

Config_EXTI
    ldr     R0, =EXTI_IMR
    ldr     R1, [R0]
    orr     R1,R1,#0x01 ; activando bit 0 de la exti
    str     R1,[R0]


    ldr     R0, =EXTI_RTSR
    ldr     R1, [R0]
    orr     R1,R1,#0x01 ; activando bit 0 de la exti
    str     R1,[R0]

    ldr     R0, =EXTI_RTSR
    ldr     R1, [R0]
    orr     R1,R1,#0x01 ; activando bit 0 de la exti
    str     R1,[R0]


    bx      lr

Config_Syscfg
    
    ldr     R0, =SYSCFG_EXTICR1
    ldr     R1, [R0]
    bic     r1, #(0<<0) ; and a nivel de un solo bit
    str     R1,[R0]
    
    bx      lr

Config_NVIC
    
    ldr     R0, =NVIC_ISER0
    ldr     R1, [R0]
    orr     r1, #(1<<6) ; es 6 el nivel d prioridad
    str     R1,[R0]
    
    bx      lr
; esto es lo que la interrupcion realizara
exti0Handler
    push{lr}
    ldr     r0, =GPIOC_ODR
    eor     r3,r3

loop1
    ldr     r1,[r0]
    movw    r2, #0x2000
    eor     r1,r2
    str     r1,[r0]
    push{r0}
    bl      dilei2
    push{r0}
    add     r3,#1
    cmp     r3,#0xA
    bne     loop1
    
    pop{lr}
    bx      lr

dilei2 
    ldr   R0, =ledilei
dei2  
    subs    r0,r0,#1
    bne     dei
    BX LR

dilei 
    ldr   R0, =ledilei
dei  
    subs    r0,r0,#1
    bne     dei
    BX LR
	align
	end