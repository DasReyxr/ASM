; - - - - IKGB 02-11-25  
    TTL ConversionFDaFB

fracDec EQU 12555 ;CUANDO USEMOS EQU nO PONEMOS la #


;TOdas las directivas (Instrucciones, control y palabras reservadas; deben de llevar una sangria

    AREA myData, DATA, READWRITE

fracBin SPACE 32

    AREA myCode, CODE, READONLY
    ENTRY
    EXPORT main

main

	LDR R0, =fracDec 
	EOR R1,R1 ;CLEAR REGISTRO CON XOR 
	EOR R2,R2 ;Registro para mover cero
	MOV R3, #1 ;REgistro para mover unos
	
	LDR R4, =fracBin 	
	MOV R5, #2 ;AUXILIAR PARA LA CONVERSION
	LDR R6, =100000 ;ayuda en ajuste para colocar unos y para la comparacion
	
	
conDecBin
	MUL R0, R0,R5 ; Las multiplicaicones y divisiones no pueden llevar un inmediato
	
	CMP R0, R6
	BGE unos

	CMP R1, #32
	BEQ ciclo
	B conDecBin
	
    CMP R1, #31
	BNE conDecBin
	
ciclo B ciclo 

;Subrutinas
    
	
unos
	STRB R3,[R4,R1]
	SUB R0, R0, R6
	ADD R1, R1, #1
	BX LR ; Branch and Exchange (RET)

ceros
	STR R2, [R4,R1]
	ADD R1,R1, #1
    BX LR

    END