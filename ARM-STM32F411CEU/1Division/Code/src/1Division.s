; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; -------------- Division --------------
; ------------- 24/02/2025 -------------
; ------------- Variables -------------
times   rn 2
var     EQU 9
dvd     EQU 3
; ---------------- Main ----------------
    AREA myData, DATA, READWRITE
pul SPACE 4

    AREA juve3dstudio,CODE,READONLY
	ENTRY
	EXPORT main

main
    ;Initialice Variables
    ldr r0, =var
    ldr r1, =dvd
    ldr r3, =pul
    eor times, times
    

brinqitos
    ; Increment the main count called times and substract the divisor storaged in r1 
    add     times,times,#1
    subs    r0,r0,r1
    ; If the value is overflowed positive->negative, it would turn on the c-flag  
    bhs     brinqitos
    ; Adjust the value obtained
    add     r0,r0,r1
    subs    times,times, #1
    ; Juanpeways
    ; Restar
    ; cont++
    ; cmp resta, divisro
    ; b condicion 
    ; str
    ; Storage the value
    strb    times, [r3,#1]
    strb    r0, [r3,#3]

ciclo b ciclo
    end

