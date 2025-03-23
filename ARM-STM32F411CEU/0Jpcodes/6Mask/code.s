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
    ldr     R0, =aGPIOA_Moder   ; PA3 PA2 PA1 PA0
    mov     r1, #0x55           ; 01  01  01  01
    orr     r0, r0, r1

    ldr     r2, =aGPIOA_SPEED   ; PA3 PA2 PA1 PA0
    mov     r1, #0xAA           ; 01  01  01  01
    orr     r2, r2, r1

    ldr     r3, =0x4444444
    movw    r1, #0x0007
    movt    r1, #0x7000
    eor     r3,r3,r1
ciclo
    B ciclo
    end
