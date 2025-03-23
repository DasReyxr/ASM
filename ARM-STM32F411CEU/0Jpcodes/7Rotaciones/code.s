; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ---------------- Mask ----------------
; ------------- 26/02/2025 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
aGPIOA_Moder EQU 0xA8000000
aGPIOA_SPEED EQU 0x0C000000

    AREA data, DATA, READWRITE
	AREA juve3dstudio,CODE,READONLY
	ENTRY
	EXPORT main

main
    ldr     r0, =0x0F0F0F0F
    lsl     r1, r0, #2
    lsr     r1, r0, #2\

    mov     r2, #2
    add     r3, r2, r2, lsl #1 ; R3 + (R2<<1) estro es R3<=
    mov     r2, #2
    add     r3, r2, r2, lsl #3
    add     r4, r3, r3, lsr #2

    asr     r4, r0, #3
    ldr     r5, =0xFFFF0000
    asr     r4, r5, #3
    
ciclo
    B ciclo
    end
