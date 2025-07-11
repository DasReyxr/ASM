; -------------- Iker | Das -----------
; ------------ Floating Point ------------
; ------------- 23/05/2025 ------------
; ------------- Variables -------------
; ---------------- Main ---------------

; ---- Registers Used ----
;
; Global Registers
; R3 IEEE Result
; R7 Flag Register
; R9 Decimal0s
; R9 Resultado temperoal

; R10 Midvalue R10
; r11 y r12 Final Values
;---------
;15     14      13      12      11      10      9       8       7       6       5       4       3       2       1       0
;                                                                                                               Zint    number

;R9 Midvalue
Sign1        EQU 0
Val1         EQU 2147483648
Frac1        EQU 0
	
;Decimal0s   EQU 1000
Sign2       EQU 0
Val2        EQU 1
Frac2       EQU 1
Decimal0s   EQU 1000 ;10^6       Cada cero una divicion entre 10
; SIGN << 32
; EXP=158-CLZ(Val)=31-CLZ(Val)+127
; EXP <<23

; VAL<<EXP-104=23-EXP-127


	AREA data, DATA, READWRITE
	AREA juve3dstudio,CODE,READONLY
	ENTRY
	EXPORT __main

__main
    EOR     R2, R2

    LDR     R11, =Frac1
    LDR     R3, =Decimal0s
	;LDR     R4, =31
    BL      Fract

    LDR     R2, =Val1
    BL      Integer

	LDR     R2,=Val1
    BL      Exponente

	LDR     R7,=Sign1
    BL      Signo

	PUSH{R9}
	EOR 	R9,R9
	BL 		Limpiar

	EOR     R2, R2

    LDR     R11, =Frac2
    LDR     R3, =Decimal0s
    ;LDR     R4, =31
    BL      Fract

    LDR     R2, =Val2
    BL      Integer

	LDR     R2,=Val2
    BL      Exponente

	LDR     R7,=Sign2
    BL      Signo

	PUSH{R9}
	EOR 	R9,R9

	BL 		Limpiar
	EOR  R7,R7

	POP {R2}
	POP {R1}


ciclo
	b ciclo


Signo
    LSL     R7, #31
	ORR 	R9, R7
    BX      LR

Exponente
	PUSH{LR}

    CLZ     R3, R2
    RSB     R3, #158
    LSL     R3, #23
    ORR     R9,R3

	POP{LR}
    BX      LR

Integer
    CLZ    R3, R2
    ADD    R3, #1

    LSL    R2, R3
    LSR    R2, R3 ; aca tronamos el mas significativo

    ;CLZ    R3, R2
    RSB    R3, R3, #32 ; numero de digitos

	EOR    R12, R12
	ADD    R12, R5

    LSR    R5, R3

	RSB    R6, R3, #32

    LSL    R2, R6
    ORR    R5, R2

    LSR     R5, #9

    ORR     R9, R5

    BX      LR

Fract
	EOR  R9,R9
    ;R2 valor fraccionario
    ;R3 Presiocion
    ;R5 valor
    LSL  R11,#1
    CMP  R11,R3
    BLE  Zero
    ORR  R5,#1
    SUB  R11,R3

Zero
    LSL  R5,#1
    ADDS R4, #1
    CMP  R4,#31
	BNE  Fract
    BX   LR

Limpiar
	EOR	 R0,R0
	EOR	 R1,R1
	EOR  R2,R2
	EOR  R3,R3
	EOR  R4,R4
	EOR  R5,R5
	EOR  R6,R6
	EOR  R8,R8
	EOR  R11,R11
	EOR  R12,R12
	BX LR

    end
