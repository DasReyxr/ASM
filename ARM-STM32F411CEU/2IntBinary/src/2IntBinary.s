; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; -------------- Division --------------
; ------------- 24/02/2025 -------------
; ------------- Variables -------------
; times   rn 2
; i       rn 1
; bin     rn 4
; res     rn 0
val     EQU 12
	;128

; ---------------- Main ----------------

	AREA myData, DATA, READWRITE
pul SPACE 32

    AREA juve3dstudio,CODE,READONLY
	ENTRY
	EXPORT main

main
    ldr r3, =pul
    ldr r0, =val
    ldr r1,=33
    eor r4,r4
    eor r2, r2
    

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