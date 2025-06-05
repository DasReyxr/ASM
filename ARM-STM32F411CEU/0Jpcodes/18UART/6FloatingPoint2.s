; -------------- Iker | Das -----------
; ------------ Floating Point ------------
; ------------- 23/05/2025 ------------
; ------------- Variables -------------
; ---------------- Main ---------------

; ---- Registers Used ----
;
;R2     Exponente 
;R3     CLZ
;R5     shiiftear
;R6    shiftear
;R3     IEEE
;R9
;---------
;15     14      13      12      11      10      9       8       7       6       5       4       3       2       1       0
;                                                                                                                       number
;Q 4.12
Sign1        EQU 0
Val1         EQU 0
Frac1        EQU 29000

Sign2       EQU 0
Val2        EQU 0
Frac2       EQU 200000
Decimal0s   EQU 1000000 ;10^6       Cada cero una divicion entre 10
; SIGN << 32
; EXP=158-CLZ(Val)=31-CLZ(Val)+127
; EXP <<23

; VAL<<EXP-104=23-EXP-127


	AREA data, DATA, READWRITE
	AREA juve3dstudio,CODE,READONLY
	ENTRY
	EXPORT __main

__main
    
    LDR     R9,=Decimal0s
    LDR     R3,=Sign1
    LDR     R2,=Val1
    BL      enTB

    BL      enFC
    orr 	r3,r8

    MOV     R9,R3
    ORR     R7,#(1<<0) ; Bandera para elegir el segundo valor
    LDR     R3,=Sign2
    LDR     R2,=Val2
    BL      enTB

    BL      enFC
    orr 	r3,r8



ciclo
	b ciclo

enTB
    EOR     R4,R4 ; el valor para la mantiza
    EOR     R5,R5 ; Numero de veces que se va a shiftear
    EOR     R6,R6 ; TOPE DE LA PARTE FRACCIONARIA

    LSL     R3, #31 

    ADDS     R4, R2
    BEQ     zeroVal

    CLZ     R2,R2
    RSB     R2,#31 ; 31-CLZ(Val) ; here got the exp
    ADD     R6, #23 ; calculo
    SUB     R6, R2
    
imback     
    ADD     R5, #1 ; 1 shift to rip up the last bit

	ADD     R2,#127 ; 31-CLZ(Val)+127
    
    LSL     R2,#23 ; EXP << 23 [30:23]
    ORR     R3,R2
    
    LSL     R4, R5 ; Removemos el 1 implicito
    LSR     R4, R5 ; 

    LSL     R4, R6 ;Lo acomoda el numero
    ORR     R3, R4 ; Se lo carga al valor final

    BX      LR

secondVal 
    LDR     R2,=Frac2
    b       cycleFractionary

enFC
    ;bandera para elegir fraccion
    TST     R7,#(1<<0)
    BNE     secondVal     
    LDR     R2,=Frac1
    
cycleFractionary
;2x125=250*2=500*2=1000 = 0
;        0    0      1    0
    SUBS    r6,#1 ; r6 iterations
    BXEQ     LR

    LSL     R2,#1
    CMP     R2,R9
    BHS     onesshift
	LSL     R8,#1
	b       cycleFractionary
onesshift
    ORR     R8,#1
	LSL     R8,#1
	SUB     R2,R9
    
    b cycleFractionary


zeroVal
    PUSH  {LR}
    LDR     R6,=24;24
    BL      enFC
	ADD		R8,#1
    POP {LR}

    CLZ     R5,R8
    RSB     R2,R5,#0 ; -CLZ(Val) ; here got the exp    
    ADD		R2,#7;#7
	MOV     R4,R8
    EOR     R8,R8
	SUB		R6,R5,#8
	
   
    B   imback

    end