; ------ Orlando Reyes ------
; --------- Auf Das ---------
; --------- IEEE Out ---------
; ---- I date 16/06/2025 ----
; ---- C date 16/06/2025 ----
; -------- Variables --------
; ----------- Main -----------
USART1_BASE      EQU 0x40011000
USART1_SR        EQU (USART1_BASE + 0x00)
USART1_DR        EQU (USART1_BASE + 0x04)
USART1_BRR       EQU (USART1_BASE + 0x08)
USART1_CR1       EQU (USART1_BASE + 0x0C)

RExp RN 9
RMant RN 8
Rshift RN 7
Rint   RN 6
Rlow    RN 4
Rhigh   RN 5
	AREA data, DATA, READWRITE
	AREA juve3dstudio,CODE,READONLY
	
	EXPORT OUT

; R10 IEEE Result
; 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16
; S  Exponent                Val
OUT
    ;LDR 	R10,=0x4F7FFFFF;0x41CE0000 ; 27.75
ciclo
	TST 	R10,#(1<<31) ; Check Sign Bit
	BLNE	SignoMenos

	LSL 	RExp,R10,#1 ; Shift left to remove sign bit
	LSR 	RExp,#24 ;
    
    TST 	R10,#(1<<30) ; Check MSB of EXP 
    BEQ     ZeroInt     ; if Exp <128
    SUB     RExp,#127 ; If Exp>=128 Exp-127
	
    LDR     R1,=0x007FFFFF; Mask for Mantissa    
    AND     RMant,R10,R1 ; Extract Mantissa
	ORR     RMant,#(1<<23)
    
    CMP     RExp,#23
    BLGT    Intg1
    BLLS     Intg2
    MOV		R1,Rint
    MOV R2, #0         ; Bandera de entero
    BL PrintNumber
    ; Fraccionario 	
    
    ADD     RExp,#1
    LSL     RMant,RExp
    	
    LDR     R2,=0x00FFFFFF
    AND     RMant, RMant, R2
    LDR     R2,=0x2710
    UMULL   Rlow, Rhigh, RMant, R2      ; 64-bit result in Rhigh:Rlow
    LSL     Rhigh,#8
	LSR		Rlow,#24
    ORR     Rhigh,Rlow
    MOV     R1, Rhigh
	ADDS 	R1,#0
	ITE		NE
    ADDNE	R1,#1
    ADDEQ	R1,#0
	;MOV     R1, Rhigh      ; Valor fraccionario (ej: 2500 para 0.25)
    MOV     R2, #1         ; Bandera de fracción
    BL      PrintNumber

    B       .
Intg1
    PUSH {LR}
    SUB Rshift,RExp,#23; Exp-22
    LSL Rint,RMant,Rshift
    POP {PC}
Intg2
    PUSH {LR}
    RSB     Rshift,RExp,#23 ;22-4= 19
    LSR     Rint,RMant,Rshift
    POP {PC}
SignoMenos
	PUSH{LR}
	LDR  R1,='-'
	BL  Write_UART
	LDR  R1,=' '
	BL  Write_UART
	
	POP{PC}
ZeroInt 
    RSB   RExp,#127  ; If Exp< 128 127-EXP 
    LDR     R1,=0x007FFFFF; Mask for Mantissa    
    AND     RMant,R10,R1 ; Extract Mantissa
	ORR     RMant,#(1<<23)
    
    EOR     Rint,Rint

    SUB     RExp,#1
    LSR     RMant,RExp

    LDR     R2,=0x2710
    UMULL   Rlow, Rhigh, RMant, R2      ; 64-bit result in Rhigh:Rlow
    LSL     Rhigh,#8
	LSR		Rlow,#24
    ORR     Rhigh,Rlow
    MOV     R1, Rhigh
    ADD		R1,#1
	
		MOV     R1, #0x0D
    BL      Write_UART
	MOV     R1, #0x0A
    BL      Write_UART

    B       .    
    
; Función unificada para enteros y fracciones
; Parámetros:
;   R1 = valor numérico
;   R2 = bandera (0=entero, 1=fracción)
PrintNumber
    PUSH {LR, R4-R7}
    
    ; Primero determinar si es entero o fracción
    CMP R2, #1
    BNE print_integer
    
    ; Si es fracción, imprimir punto primero
    PUSH{R1}
	MOV R1, #'.'
    BL Write_UART
    POP{R1}
	ADDS	R1,#0
	BNE start_conversion
    LDR R1,=0x30
	BL Write_UART
    B end_function
print_integer
    ; Para enteros, verificar si es negativo (bit 31)
    TST R1, #0x80000000
    BEQ start_conversion
    ; Si es negativo, imprimir signo y convertir a positivo
    MOV R0, #'-'
    BL Write_UART
    RSB R1, R1, #0
    
start_conversion
    MOV R4, #10         ; divisor
    EOR R5, R5          ; contador de dígitos
    MOV R6, R1          ; copia del valor
    EOR R7, R7          ; flag de dígitos significativos
    
    ; Caso especial para cero
    ADDS R6, #0
    BNE conversion_loop
    MOV R0, #'0'
    BL Write_UART
    B print_end
    
conversion_loop
    UDIV    R0, R6, R4     ; dividir por 10
    MLS     R3, R0, R4, R6  ; obtener residuo (dígito)
    PUSH    {R3}           ; guardar dígito
    ADD     R5, R5, #1      ; incrementar contador
    MOV     R6, R0          ; actualizar cociente
    ADDS    R6, #0          ; ¿terminamos?
    BNE     conversion_loop
    
send_digits
    POP {R0}            ; recuperar dígito
    CMP     R7, #0          ; ¿ya encontramos dígito significativo?
    BNE     print_digit     ; si sí, imprimir todos
    
    ADDS    R0, #0          ; ¿es cero no significativo?
    BEQ     skip_digit      ; si sí, saltar
    
print_digit
    MOV     R7, #1          ; marcar dígito significativo encontrado
    ADD     R0, #0x30    ; convertir a ASCII
    MOV		R1,R0
	BL      Write_UART
    
skip_digit
    SUBS    R5, R5, #1     ; decrementar contador
    BNE     send_digits
    
    ; Si todos eran ceros (solo para fracciones)
    CMP     R7, #0
    BNE     print_end
    MOV     R0, #'0'
	MOV		R1,R0
    BL  Write_UART
    
print_end
    ; Solo agregar espacio si es entero
    
end_function
    POP {LR, R4-R7}
    BX LR

Write_UART
    PUSH{LR}
    LDR    R0, =USART1_DR
    STR    R1, [R0] ; Write data to transmit register
    LDR    R0, =USART1_SR
writeCycle
    LDR   R1, [R0] ; Read status register
    TST   R1, #(1<<6) ; Check if TXE is set
    BEQ   writeCycle ; If not, wait
    
    POP{PC}

    align
	end
