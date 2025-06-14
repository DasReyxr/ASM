; -------------- Iker | Das -----------
; ------------ Fixed Point ------------
; ------------- 16/05/2025 ------------
; ------------- Variables -------------
; ---------------- Main ---------------

; ---- Registers Used ----
;R4 iteration
;R5 Float
; r6 log_2(x)=31-clz(x)
; r7 log_10(2)
;R8 10
;r9

;Q 4.12

Integer  EQU 0
Float    EQU 125; 2 = 0.2, 20 = 0.002
Accuracy EQU 24
SACAME       EQU 0x20001000

	AREA data, DATA, READWRITE
	AREA juve3dstudio,CODE,READONLY
	ENTRY
	EXPORT __main

__main
    LDR     R9,=Accuracy
    LDR     r0,=Integer
    LDR     r1,=Float
    LDR     r7,=SACAME
    ;BL      xd
    ldr     r8,=1000 ;max val

ciclo
;2x125=250*2=500*2=1000 = 0
;        0    0      1    0
    ; r9 iterations, r8 log(max val) 10 log(x) r6 fractional x r5 val
    SUBS    r9,#1
    BEQ     .

    lsl     r1,#1
    cmp     r1,r8
    bhs     poner1
	lsl     r6,#1
	b ciclo
poner1
    orr r6,#1
	lsl r6,#1
	sub r1,r8

    b ciclo
    end