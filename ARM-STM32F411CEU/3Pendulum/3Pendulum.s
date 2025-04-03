; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ------------- 3 Pendulum -------------
; ------------- 01/04/2025 -------------
; ------------- Variables -------------
;---- Registers Used
; R0    Port Register
; R1    Interrupt number
; R2    Number Dela
; R3    Pointer
; R4    buttonpresed
; PORTA LEDs
; PORTB  Buttons

; ---------------- Main ----------------

; --------- GPIO A ---------
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


; --------- GPIO B ---------
GPIOB_BASE       EQU 0x40020400
GPIOB_MODER     EQU (GPIOB_BASE + 0x00)
;-- Configuration Registers --
GPIOB_OTYPER    EQU (GPIOB_BASE + 0x04)
GPIOB_OSPEED    EQU (GPIOB_BASE + 0x08)
GPIOB_PUPDR     EQU (GPIOB_BASE + 0x0C)
;-- Comm Registers --
GPIOB_IDR       EQU (GPIOB_BASE + 0x10)
GPIOB_ODR       EQU (GPIOB_BASE + 0x14)

;-- Special Registers --
GPIOB_BSSR       EQU (GPIOB_BASE + 0x18) ; Bit Set Set Register


ledilei        EQU 10000000


 AREA data, DATA, READWRITE
 AREA juve3dstudio,CODE,READONLY
 ENTRY
 EXPORT main

main
            bl      Config_Port
            ldr     r3, =GPIOC_PUPDR
            ldr     r1,[r3]
            and     r1,#0x4000
            cmp     r1,#0x4000
            bne     presionado
            
            ldr     r3, =GPIOC_ODR
            str     r0,[r3]
sleft    
            lsr     r0,r0,2
            str     r0,[r3]
            bx      tilei
            cmp     r0,#1
            bne     sleft
    
sright    
           lsl     r0,r0,2
           str     r0,[r3]
           bx      tilei
           cmp     r0,#0x80
           bne     sright
           beq     sleft

            b       .

dilei    
   ldr     r2,r1
tilei    
    ldr     r3, =GPIOB_PUPDR
    ldr     r4,[r3]    ; B7 B6 B5 B4 B3 B2 B1 B0
    and     r4,#0x0001 ; 0 0   0  0  0  0  0  1
    cmp     r4,#0x0001
    bne     t1
suma    
   add     r1,r1,1
   bvs     resta
t1    
    ldr     r3, =GPIOB_PUPDR
    ldr     r4,[r3]    ; B7 B6 B5 B4 B3 B2 B1 B0
    and     r4,#0x0002 ; 0 0   0  0  0  0  1  0
    cmp     r4,#0x0002
    cmp     b2, presionado
    bne     t2
resta    
    sub     r1,r1,#1
    bvs     suma
t2    
    subs    r2,r2,#1
    bpl     tilei
    bx      lr



Config_Port
        ;Configuramos el PC13 como salida de proposito general PushPull (pp) y el pC14 como entrada
        ldr     r3, =GPIOA_MODER
        ldr     R1, [r3]
        ldr     r2, =0x04000000
        orr     r1,r1,r2
        str     r1,[r3]


        ldr     r3, =GPIOA_OSPEED
        ldr     R1, [r3]
        mov     R2, #0x0C000000
        orr     R1,R1,R2
        str     R1,[r3]

        ;Configuramos el PC14 como salida de proposito general PushPull (pp)
        ldr     r3,=GPIOA_PUPDR
        ldr     r1,[r3]
        ldr     r2,=0x10000000
        orr     r1,r2, r2
        str     r1,[r3]

        ldr     r3, =GPIOB_MODER
        ldr     R1, [r3]
        ldr     r2, =0x0000000A
        orr     r1,r1,r2
        str     r1,[r3]


        BX      LR

 end