; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; -------------- Transfer --------------
; ------------- 18/02/2025 -------------
; ------------- Variables -------------
    AREA myData, DATA, READWRITE

array DCB 99,56,98,12,11,01,2,56,99,112
ALIGN
bloque SPACE 50
bloque2 FILL 32, 'F'
; ---------------- Main ----------------
	AREA myCode,CODE,READONLY
	ENTRY
	EXPORT main

main
    LDR  R0,=array
    LDR  R1,[R0]
    MOVW R1, #0x1234
    MOVT R1, #0x5678
    LDR R0, =bloque 
    STR R1, [R0]
    
ciclo B ciclo
    ALIGN
    end
