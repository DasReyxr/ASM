.include "M8515def.inc"  

;DEFINICION DE VARIABLES CON REGISTROS 
.equ	var1	=0x60			; declaracion de variable en RAM
.def	var2	=r2				; delcaracion de registro como variable

.cseg
.org 0
RJMP RESET    
; ---- Data section ----
.org 0x0100






RESET: ;-- Set Stack Pointer
    LDI R16, 0x04
    OUT SPH, R16           
    LDI R16, 0xFF
    OUT SPL, R16
	cli
	;-- OUTPUT
	
	LDI R17, 0xFF
    OUT DDRA, R17
	;input

	LDI R17, 0x00
    OUT DDRB, R17
	;-- PULL UP--
	ldi r17,0
	ldi r18, 0
;Tabla del multiplexor
numbers:.db 0b00111111 ,0b00000110, 0b01011011, 0b01001111, 0b01100110,0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111, 0b01110111, 0b01111100, 0b00111001, 0b01011110, 0b01111001, 0b01110001
    ; ---- Main ----
Main:
	;Display unidades
	LDI ZH, high(numbers * 2) ; Apunta a la tabla (parte alta del puntero)
    LDI ZL, low(numbers * 2)  ; Apunta a la tabla (parte baja del puntero)
    ADD ZL, r17          ; Selecciona el ï¿½ndice en la tabla
    LPM r16, Z               ; Carga el patrï¿½n en temp
	com r16
    OUT PORTA, r16    ; Muestra el patrï¿½n en el display
	
	RCALL CONTADOR
	RCALL DELAY 
	RJMP Main

CONTADOR:
	inc r17
	cpi r17, 16
	brne  Continue
	ldi r17, 0
	ret
Continue:	ret

Delay:  ldi 	R21, 10 
DS3:	ldi		R20,100; 5ms				
DS2:	ldi		R19,100
DS1:	dec 	R19			;12.2ms
		brne	DS1	
		dec		R20
		brne 	DS2
		dec 	R21			;12.2ms
		brne	DS3	
		ret