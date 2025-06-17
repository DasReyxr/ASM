	AREA myData, DATA, READWRITE

EXP1 EQU 0x46202000; 10248
EXP2 EQU 0xBF800000 ; -1

    AREA myCode, CODE, READONLY
    ENTRY
    EXPORT main

main
	;PUSH{LR} Para poner codigos como bloque
	LDR R0, =EXP1 ; Los dos valores del IEEE tienen que entrar en R0 y R1
	LDR R1, =EXP2
	BL Normalizar
	BL Sign
	MOV R0, R4 ; Queda en R0 la salida en IEEE
	BL Limpiar	
	B .

Normalizar	
	PUSH{LR}
	EOR	R4,R4
	EOR	R5,R5
	EOR R6, R6
	EOR R12, R12
	MOV R4, R0
	MOV R5, R1
	CMP R4, #0
	BEQ CuandoR4esCero
	CMP R5, #0
	BEQ CuandoR5esCero
	AND R4, #0x7F800000
	AND R5, #0x7F800000
	LSR R4, #23
	LSR R5, #23
	B Checador

CuandoR4esCero
	MOV R4, R5
	POP{LR}
	ADD LR, #4
	BX LR

CuandoR5esCero
	POP{LR}
	ADD LR, #4
	BX LR

Checador
	CMP R4,R5
	BGT Resta
	BLT Inverso
	MOV R9, R4
	
	MOV R4, R0
	MOV R5, R1
	EOR R7,R7
	LDR R7, =0x007FFFFF
	
	AND R4, R7
	AND R5, R7
		
	ORR R4, #0x00800000
	ORR R5, #0x00800000
	BX  LR ;Aqui no hace nada y se regresa

Resta
	SUB R3, R4, R5
	MOV R9, R4
	B Mantisa

Inverso
	SUB R3, R5, R4
	MOV R9, R5
	ADD R12, #1
	B Mantisa


Mantisa
	MOV R4, R0
	MOV R5, R1
	EOR R7,R7
	LDR R7, =0x007FFFFF
	
	AND R4, R7
	ORR R4, #0x00800000
	
	AND R5, R7
	ORR R5, #0x00800000
	
	CMP R12, #1
	BLEQ ShifteoValuno
	BLNE ShifteoValdos
	POP{LR}
	BX LR

ShifteoValuno
	CMP R4, #0
	BEQ Ceros
	LSR R4, R3
	CMP R4, #4
	BLT UNOA
	POP{LR}
	BX LR

ShifteoValdos
	CMP R5, #0
	BEQ Ceros
	LSR R5, R3
	CMP R5, #4
	BLT UNOB
	POP{LR}
	BX LR

UNOA
	ADD R4, #1
	POP{LR}
	BX LR

UNOB
	ADD R5, #1
	POP{LR}
	BX LR

Ceros 
	POP{LR}
	BX LR

Sign
	PUSH{LR}
	MOV R7, R0
	MOV R8, R1
	EOR R6,R6

	LSR R7, #31
	LSR R8, #31

	EORS R6, R7,R8 ;Para checar el signo 
	BEQ SumaMantisaDirecta
	BNE SumaMantisaSigno

SumaMantisaSigno
	SUBS R11, R4, R5
	BEQ Final
	CMP R7, #1 ; Signo primer valor
	BEQ Reg0Neg
	BNE Reg1Neg

Reg0Neg
	;Si R7 es negativo
	CMP R4,R5
	BGT Reg4MayorReg0Neg
	BLT Reg4MenorReg0Neg

Reg4MayorReg0Neg
	SUB R4, R5
	MOV R6, #1
	B AcomodoMantisa
	
Reg4MenorReg0Neg
	SUB R4, R5, R4
	EOR R6,R6
	B AcomodoMantisa

Reg1Neg
	;Si R8 es negativo
	CMP R4,R5
	BGT Reg4MayorReg1Neg
	BLT Reg4MenorReg1Neg
	
	;Caso que sean iguales
	MOV R4, #0
	B Final
	
Reg4MayorReg1Neg
	SUB R4, R5
	EOR R6,R6
	B AcomodoMantisa

Reg4MenorReg1Neg
	SUB R4, R5, R4
	MOV R6, #1
	B AcomodoMantisa ; b 
	
SumaMantisaDirecta
	CMP R4, R7
	BEQ NumeroMaximoR4
	CMP R5, R7
	BEQ NumeroMaximoR4
	
	ADD R4, R5
	CMP R4, #0
	BEQ Final
	
NumeroMaximoR4
	MOV R4, #0x7FFFFFFF
	B ComparacionSigno

NumeroMaximoR5
	MOV R4, #0x7FFFFFFF
	B ComparacionSigno
	
AcomodoMantisa
	;Contar ceros
	EOR R12,R12
	CLZ R10, R4
	CMP R10 ,#8 ;32-24
	BEQ AcomodoMantisaDos
	BGT Restarunoalexponente
	rsb R12,r10, #8
	ADD R9, R12 
	B AcomodoMantisaDos

Restarunoalexponente	
	SUB R12, R10, #8 
	SUB R9, #1  ; Si aqui es mas gramde seria restarle clz -8 

AcomodoMantisaDos
	;Tronar el 1 mas significativo

	ADD R10, #1
	LSL R4, R10

	LSR R4, #9
	
	LSL R9, #23 ; Exponente
	ORR R4, R9

ComparacionSigno
	ADD R7, R8
	CMP R7, #2
	BNE CargaSigno
	ADD R6, #1

CargaSigno
	;Signo
	LSL R6, #31
	ORR R4, R6

	POP{LR}
	BX LR

Final
	MOV R4, #0
	POP{LR}
	BX LR

Limpiar
	EOR	 R1,R1
	EOR  R2,R2
	EOR  R3,R3
	EOR  R4,R4
	EOR  R5,R5
	EOR  R6,R6
	EOR  R7,R7
	EOR  R8,R8
	EOR  R9,R9
	EOR  R10,R10
	EOR  R11,R11
	EOR  R12,R12
	BX LR

ciclo B ciclo 

    END