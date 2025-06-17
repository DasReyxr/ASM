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
	BL  Write_UART
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
    ADD		R1,#1
    BL  Write_UART
    B       ciclo
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
    B       ciclo    
    

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
