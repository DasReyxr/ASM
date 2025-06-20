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
	IMPORT UART
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
        
        CMP		R10,#0x4F800000
        BEQ		Infty
        CMP		R10,#0xCF800000
        BEQ		Infty

        TST 	R10,#(1<<30) ; Check MSB of EXP 
        BEQ.W   ZeroInt     ; if Exp <128
        ; Mantisa Mayor
        SUB     RExp,#127 ; If Exp>=128 Exp-127
        
        LDR     R1,=0x007FFFFF; Mask for Mantissa    
        AND     RMant,R10,R1 ; Extract Mantissa
        ORR     RMant,#(1<<23)
        
        CMP     RExp,#23
        BLGT    Intg1
        BLLS    Intg2
        
        MOV		R1,Rint
        MOV     R2, #0         ; Bandera de entero
        BL      PrintNumber
        ; Fraccionario 	
  
        CLZ     R5, RMant
        ADD     R5, #1
        LSL     RMant, R5
        LSL     RMant, RExp
	

FINAL3
        LSR     RMant,#8
        LDR     R2,=0x2710
        UMULL   Rlow, Rhigh, RMant, R2      ; 64-bit result in Rhigh:Rlow
        LSL     Rhigh,#8
        LSR		Rlow,#24
        ORR     Rhigh,Rlow
        MOV     R1, Rhigh
        
        ADDS    R1, #0
        ITE     NE
        ADDNE   R1, #1           ; Ajuste si es necesario
        ADDEQ   R1, #0
        MOV     R2, #1           ; Bandera de fracción
        BL      PrintNumber
PRINT
        MOV     R1, #0x0D
        BL      Write_UART
        MOV     R1, #0x0A
        BL      Write_UART
        BL 		LIMPIAR
        LDR		R15,=UART

Infty
	MOV R1, #'I'
    BL Write_UART
	MOV R1, #'n'
    BL Write_UART
	MOV R1, #'f'
    BL Write_UART
	B	PRINT
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
    RSB     RExp,#127  ; If Exp< 128 127-EXP 
    LDR     R1,=0x007FFFFF; Mask for Mantissa    
    AND     RMant,R10,R1 ; Extract Mantissa
	ADDS	RMant,#0
	BEQ		escerowe
    ORR     RMant,#(1<<23)
    
	EOR     Rint,Rint

    CLZ     R5, RMant
    LSL     RMant, R5
    CLZ     R5, RMant
    SUB     RExp, #1
    LSR     RMant, RExp
    B       FINAL3

escerowe
	MOV     R1, #0x30
    BL      Write_UART
	B		FINAL3

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
	BNE convert_fraction
    LDR R1,=0x30
	BL Write_UART
    B end_function
convert_fraction
    ; Configurar parámetros para 4 dígitos
    MOV R4, #1000       ; divisor inicial (para 4 dígitos)
    MOV R5, #4          ; contador de dígitos
    MOV R6, R1          ; copia del valor
    MOV	R10,#10
fract_loop
    ; Obtener dígito más significativo
    UDIV R1, R6, R4     ; R0 = dígito actual
    MLS R6, R1, R4, R6  ; R6 = resto
    
    ; Convertir a ASCII y enviar
    ADD R1, R1, #'0'
    BL Write_UART
    
    ; Preparar para siguiente dígito
    UDIV R4, R4, R10    ; reducir divisor
    SUBS R5, R5, #1     ; decrementar contador
    BNE fract_loop
    
fract_end
    POP {LR, R4-R7}
    BX LR
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
    MOV R1, #'0'
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
LIMPIAR
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

    align
	end
