.include "M8515def.inc"  

;DEFINICION DE REGISTROS 
.def	D1 = r20				
.def	D2 = r21
.def	D3 = r22
.def	D4 = r23

;El registro r16, r18, r19 se usa como scratch

;LCD 
.equ Data = 0x15 ; Port C

.cseg
.org 0000
rjmp RESET
;CONFIGURACION Y ARRANQUE DEL SISTEMA 
RESET: 		
	ldi r16,high(RAMEND) 	
	out SPH,r16 		; Set Stack Pointer to top of RAM
	ldi r16,low(RAMEND)	; Parte baja
	out SPL,r16			; Inicializar la pila
	cli 				; Disable interrupts		 
	;otras inicializaciones
	;---- LCD set Outputs ----
	ldi R16, 0xFF
	out DDRA, R16
	ldi R16, 0x0F
	out DDRB, R16
	LDI WREG,0b110
	OUT DDRE,WREG
	
	sei		
;******* Inicializaciones *******

numbers:.db 0b00111111 ,0b00000110, 0b01011011, 0b01001111, 0b01100110,0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111
;Inicializacion de D1, D2, D3 y D4
ldi D1, 0
ldi D2, 0
ldi D3, 0
ldi D4, 0

Main:
	;Display unidades
	ldi r16, 0x0E	; 1110
	com r16
	out PORTB, r16
	
	mov r24, D1
	Rcall Desplegar
	
	ldi r16, 0x0D	;1101
	com r16
	out PORTB, r16
	mov r24, D2
	Rcall Desplegar

	ldi r16, 0x0B	;1011
	com r16
	out PORTB, r16
	mov r24, D3
	Rcall Desplegar

	ldi r16, 0x07   ;0111	
	com r16
	out PORTB, r16
	mov r24, D4
	Rcall Desplegar	
	
	RCALL CONTADOR
	;RCALL DELAY 
	CPI D1, 7
	BRLO MOTOR_ON 
	CBI PORTE,2
	RJMP Main

MOTOR_ON: 
	SBI PORTE,2
	RCALL Delay
	RJMP INIT

Desplegar: 
	LDI ZH, high(numbers*2) ; Apunta a la tabla (parte alta del puntero)
    LDI ZL, low(numbers*2)  ; Apunta a la tabla (parte baja del puntero)
    ADD ZL, r24         ; Selecciona el índice en la tabla
    LPM r16, Z               ; Carga el patrón en temp
	com r16
    OUT PORTA, r16
	ret

Contador:
	inc D1
	cpi D1,10
	brne continue
	ldi D1, 0
	inc D2	
	cpi D2,7
	brne continue
	ldi D2, 0
	inc D3
	cpi D3,10
	brne continue
	ldi D3, 0
	inc D4	
	cpi D4,7
	brne continue
	ldi D4, 0
	ret
		
continue: ret
	
Delay:  ldi    R19, 10
DS3:   ldi    R18, 100
DS2:   ldi    R17, 100
DS1:   dec    R17
       brne   DS1
       dec    R18
       brne   DS2
       dec    R19
       brne   DS3
		ret