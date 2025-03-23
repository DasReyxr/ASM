.include "M8515def.inc"  

;DEFINICION DE REGISTROS 
.equ D1 = 0x60
.equ D2 = 0x61
.equ D3 = 0x62
.equ D4 = 0x64
.def WREG = R16

;El registro r16, r18, r19 se usa como scratch


.cseg
.org 0
; --- Interruptions Config ---
RJMP SETCONFIG   ; Reset Handler  
SETCONFIG: 		
	ldi r16,high(RAMEND) 	
	out SPH,r16 		; Set Stack Pointer to top of RAM
	ldi r16,low(RAMEND)	; Parte baja
	out SPL,r16			; Inicializar la pila
	cli 				; Disable interrupts		 

	LDI WREG,0xff
	OUT DDRC,WREG

			
;* Inicializaciones *


Main:
	LDI WREG,0xff
	OUT PORTC,WREG

    rjmp Main
