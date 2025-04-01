; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; -------------- PORTS --------------
; ------------- 18/03/2025 -------------
; ------------- Variables -------------

; ---------------- Main ----------------
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
GPIOA_BSSR       EQU (GPIOA_BASE + 0x18) ; Bit Set Set Register


	AREA myData, DATA, READWRITE
arrayDes DCB 123, 27, 50, 255, 01, 03, 06, 07, 99, 1, 0,33,120,200,240,158,190, 254, 76, 18

    AREA juve3dstudio,CODE,READONLY
	ENTRY
	EXPORT main

main
	eor 	r4,r4
forouter
	cmp 	r4,#20
    beq 	ciclo
	ldr     r0, =arrayDes
    eor     r3,r3
	add 	r4,r4,#1
	
forinner
	cmp		r3,#19
	beq		forouter
    ldrb    r1, [r0],#1
    ldrb    r2, [r0]  ; r2= r0  r0 = r0+ 1 
    cmp     r1,r2
    blgt     xchange
    add     r3,r3,#1
    cmp     r3, #20
    B       forinner

xchange
    strb    r1,[r0]
    strb    r2,[r0,#-1] ; decrementa pero no modifica
    bx		LR

brinquitos
    subs 	r0,r0, #2
	add		r2, r2, #1
	cmp 	r0,#2
	bhs		brinquitos
    
    ; add     r2,r2,#1
    ; subs    r0,r0,#2
    ; bpl     brinquitos
    ; add     r0,r0,#2
    ; subs    r2,r2, #1
	
    mov r4, r0
	
    strb r4, [r3,r1]
    sub r1,r1,#1
    mov r0,r2
	eor r2,r2
	
	cmp r0, #1
	bhi brinquitos

ciclo b ciclo
	align
	
	end