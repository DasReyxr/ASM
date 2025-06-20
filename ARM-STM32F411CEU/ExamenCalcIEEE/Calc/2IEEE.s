; ------ Orlando Reyes ------
; --------- Auf Das ---------
; ----- Floating Point  -----
; ---- I date 23/05/2025 ----
; ---- C date 13/06/2025 ----
; -------- Variables --------
; ----------- Main -----------
; ---- Registers Used ----
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
Val1         EQU 0
Frac1        EQU 0
;Decimal0s   EQU 10000 
Sign2       EQU 0
Val2        EQU 0
Frac2       EQU 10
Decimal0s   EQU 10000 ;
; SIGN << 32
; EXP=158-CLZ(Val)=31-CLZ(Val)+127
; EXP <<23

; VAL<<EXP-104=23-EXP-127

	AREA data, DATA, READWRITE
	AREA juve3dstudio,CODE,READONLY
	IMPORT ALU
	IMPORT UART
	EXPORT calc
    EXPORT SEGUNDOVALOR
calc
    
	;Arg of Frac R11 
    EOR  R4,R4
    LDR     R4,=31
    BL      Fract
    
    MOV		R3,R2
	PUSH{R3}
    ;Arg of Integer R2
	BL      Integer

	POP{R2}
   ; Arg of Exp R2
    BL      Exponente

    PUSH {R2}
    AND     R2,R7,#(1<<1)    
    LSL     R2, #30   ;31-2
	ORR		R9,R2
	POP {R2}

    PUSH{R9}
    EOR 	R9,R9
    BL 		Limpiar
	; aqui activaras una bandera pa q se regrese pa aca
	ORR     R7,#(1<<0)
    LDR		R15,=UART
    EOR     R2, R2

SEGUNDOVALOR
 
	LDR		R4,=31
    BL      Fract

    MOV		R3,R2
	PUSH{R3}
   
	BL      Integer
	POP{R2}
    BL      Exponente	

    PUSH {R2}
    AND     R2,R7,#(1<<2)    
    LSL      R2, #29   ;31-2
	ORR		R9,R2
	POP {R2}


    PUSH{R9}
    EOR 	R9,R9	
    BL 		Limpiar
    EOR     R7,R7
    POP     {R1,R0}
	LDR		R15,=ALU
	
Exponente
    PUSH{LR}
    ADDS    R2, #0
    BEQ	ZeroVal
    CLZ     R3, R2
    RSB     R3, #158
    LSL     R3, #23
    ORR     R9,R3
    POP{LR}
    BX      LR

ZeroVal 	
	POP{LR}
	;LSL     R9, R7, #31   ;Signo se podria hacer tambien asi xd
	
	CMP		R11, #0	
	BXEQ	LR
	
	EOR 	R9, R9
	CLZ     R3, R12
	ADD		R3, #1
	
	RSB		R3, #127
	LSL     R3, #23
	 
	CLZ		R4, R12
	ADD 	R4, #1
	
	LSL 	R12, R4

	LSR		R12, #9
	
	ORR     R12,R3
	ORR		R9, R12
	CMP		R4,#10
	BHI	ExtendedPrecision
	BX		LR

ExtendedPrecision
	rsb 	r4,#17
	lsr		r8,r4
	orr		r9,r8
	BX		LR

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
	LDR  R3,=Decimal0s
    LSL  R11,#1
    CMP  R11,R3
    BLT  Zero
    ORR  R5,#1
    SUB  R11,R3
    
Zero
    LSL  R5,#1
    SUBS    R4,#1
	BNE	Fract
;	LSR	 R5,#1
	
	;R8 extended
	LDR  R4,=7
    

Extended
	LSL  R11,#1
    CMP  R11,R3
    BLT  Zero2
    ORR  R8,#1
    SUB  R11,R3
    
Zero2
    LSL  R8,#1
	SUBS R4, #1
    BPL  Extended
;	LSR	 R8,#1
	

	
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
