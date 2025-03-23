; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; -------------- 3 Ciclos --------------
; ------------- 19/02/2025 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
i RN 0
	AREA data,DATA,READONLY
	AREA juve3dstudio,CODE,READONLY
	ENTRY
	EXPORT main

main
	EOR i,i
ciclofor
	CMP i,#0x0A
	BEQ ciclodow
	;jaladas
	ADD i,i,#1
	B ciclofor
	
ciclodow 
	;instrucciones a ejecutardse
    adds i,i, #-1
    BNE ciclodow
	
ciclo
	B ciclo
	end
