; ------ Orlando Reyes ------
; --------- Auf Das ---------
; --------- IEEE Out ---------
; ---- I date 16/06/2025 ----
; ---- C date 16/06/2025 ----
; -------- Variables --------
; ----------- Main -----------
RExp RN 9
RMant RN 8

	AREA data, DATA, READWRITE
	AREA juve3dstudio,CODE,READONLY
	ENTRY
	EXPORT main

; R10 IEEE Result
; 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16
; S  Exponent                Val
main

ciclo
	TST 	R10,(1<<31) ; Check Sign Bit
	BLNE	SignoMenos
	LSL 	RExp,R10,#1 ; Shift left to remove sign bit
	LSR 	RExp,R10,#24 ;
	LDR     R1,=0xFFFE0000 ; Mask for Mantissa
	AND     RMant,R10,R1 ; Extract Mantissa
	
B ciclo

SignoMenos
	PUSH{LR}
	LDR  R1,='-'
	;BL  Write_UART
	LDR  R1,=' '
	;BL  Write_UART
	
	POP{PC}


Read_UART
    PUSH{LR}
    LDR    R0, =USART1_SR
readCycle
    LDR   R1, [R0] ; Read status register
    TST   R1, #(1<<5) ; Check if RXNE is set
    BEQ   readCycle ; If not, wait
    LDR   R0, =USART1_DR ; Read data register
    LDR   R1, [R0] ; Read received data

    POP{PC}

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

	end
