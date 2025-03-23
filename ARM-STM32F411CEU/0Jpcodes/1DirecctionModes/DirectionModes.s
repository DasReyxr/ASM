; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ----------- DirectionModes -----------
; ------------- 12/02/2025 -------------
; ------------- Variables -------------
GPIOA_BASE EQU 0x40020000
; ---------------- Main ----------------
	AREA myCode,CODE,READONLY
	ENTRY
	EXPORT main

main
    ;--- Immediate 16 bits ---
    MOV R0, #0x7D45 ; Delete High part 0x00007D45
    MOV R1, #1234 ; Decimal
    ;MOV R2, #0b1111111100011010
    ;MOV R2, #0b1111111;
	;MOVW R3, #0x12345678;
    MOVW R3, #0xBEEF
	MOV R0, #0x0F0000000;
    MOVT R0, #0xFEED; ; R0 = FEED7D45 
	;------- 13-02-2025 -------
	;---- Adding ----
	SUB R0,R1,#4000;
	ADD R4,R2,#-0x10;
	ADD R4,R4,R3;
	SUB R3,R3,#0x10; 

	;------- 17-02-2025 -------
	;---- Multiply and Division
	MOV R0, #0x0A
	MOV R1, #0x02
	MUL R2,R1,R0
	
	UDIV R2, R2, R1
	MOV R0, #21 ; 0x15
	UDIV R2, R0, R1 ; R2 = 21/0A
	;---- And Or
	MOV R0, #15
	AND R2, R0, R1
	ORR R2, R2,#08
	EOR R2, R2 ; Clear 

	;---- Immediate by Register 
	LDR R0, =GPIOA_BASE ;Load Data 
	MOV R1, 0x0A
	LDR R1,[R0]
	
	
ciclo B ciclo
    end

