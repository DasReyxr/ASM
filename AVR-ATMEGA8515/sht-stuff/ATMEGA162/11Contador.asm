.include "M8515def.inc" 

.def unidades = R17       ; Registro para las unidades
.def decenas = R18        ; Registro para las decenas
.def Cont = R19
;r16 Como carga y descarga
.cseg
.org 0
;VECTOR DE INTERRUPCIONES
			rjmp RESET 			; Reset Handler
			rjmp EXT_INT0 		; IRQ0 Handler
			rjmp EXT_INT1 		; IRQ1 Handler
			rjmp TIM1_CAPT 		; Timer1 Capture Handler
			rjmp TIM1_COMPA 	; Timer1 CompareA Handler
			rjmp TIM1_COMPB 	; Timer1 CompareB Handler
			rjmp TIM1_OVF 		; Timer1 Overflow Handler
			rjmp TIM0_OVF 		; Timer0 Overflow Handler
			rjmp SPI_STC 		; SPI Transfer Complete Handler
			rjmp USART_RXC 		; USART RX Complete Handler
			rjmp USART_UDRE 	; UDR Empty Handler
			rjmp USART_TXC 		; USART TX Complete Handler
			rjmp ANA_COMP		; Analog Comparator Handler
			rjmp EXT_INT2		; IRQ2 Handler						(no AT90S8515)
			rjmp TIM0_COMP		; Timer0 Compare Handler			(no AT90S8515)
			rjmp EE_RDY 		; EEPROM Ready Handler				(no AT90S8515)
			rjmp SPM_RDY 		; Store Program Memory Ready Handler(no AT90S8515)


;CONFIGURACION Y ARRANQUE DEL SISTEMA 
RESET: 		LDI R16, high(RAMEND)
			OUT SPH, R16
			LDI R16, low(RAMEND)
			OUT SPL, R16
			cli 	; Disable interrupts
			
			;OUTPUT
			LDI R16, 0xFF
    		OUT DDRC, R16

			LDI R16, 0xFF
    		OUT DDRA, R16
			
			cbi	DDRD,2			; pin D2 como entrada
			sbi PORTD,2			; pull-up en D2
			cbi	DDRD,3			; pin D3 como entrada
			sbi PORTD,3			; pull-up en D3

			ldi R16,0b00001010	
			out MCUCR,R16		


			ldi R16,0b11000000	
			out GICR,R16		;        1     1    0  0 0 0 0 0
			sei


numbers:.db 0b00111111 ,0b00000110, 0b01011011, 0b01001111, 0b01100110,0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111
Ldi R19, 0
; ---- Main ----
Main:
	;Display unidades
	Rcall Divide
	LDI ZH, high(numbers * 2) ; Apunta a la tabla (parte alta del puntero)
    LDI ZL, low(numbers * 2)  ; Apunta a la tabla (parte baja del puntero)
    ADD ZL, unidades          ; Selecciona el ï¿½ndice en la tabla
    LPM r16, Z               ; Carga el patrï¿½n en temp
	com r16
    OUT PORTC, r16    ; Muestra el patrï¿½n en el display
	;Display decenas
	LDI ZH, high(numbers * 2) ; Apunta a la tabla (parte alta del puntero)
    LDI ZL, low(numbers * 2)  ; Apunta a la tabla (parte baja del puntero)
    ADD ZL, decenas          ; Selecciona el ï¿½ndice en la tabla
    LPM r16, Z               ; Carga el patrï¿½n en temp
    com r16
	OUT PORTA, r16    ; Muestra el patrï¿½n en el display
	RJMP Main
Divide:
	clr unidades
	clr decenas
	mov R16, R19
D1:	cpi R16, 10
	Brlo Continue
	inc decenas
	subi R16, 10
	rjmp D1

Continue: mov unidades, R16
		  ret
;INTERRUPCIONES
/*WAIT_RELEASE:
    RCALL DELAY
    IN R17,PORTA
    CPI R17, 0x0F
    BRLO WAIT_RELEASE
    SBR R18, (1 << pressed); Set pressed flag
    RET
*/

EXT_INT0: 	
    cpi R19, 99
			Breq Return
			inc		R19
AQI:
            sbis PIND,3
            rjmp AQI 
			reti				

EXT_INT1: 	cpi		R19, 0
			breq Return
			dec		R19
			reti			
Return: reti

TIM1_CAPT: 	reti				; Timer1 Capture Handler
TIM1_COMPA:	reti				; Timer1 CompareA Handler
TIM1_COMPB:	reti				; Timer1 CompareB Handler
TIM1_OVF: 	reti				; Timer1 Overflow Handler
TIM0_OVF: 	reti				; Timer0 Overflow Handler
SPI_STC: 	reti				; SPI Transfer Complete Handler
USART_RXC: 	reti				; USART RX Complete Handler
USART_UDRE:	reti				; UDR Empty Handler
USART_TXC: 	reti				; USART TX Complete Handler
ANA_COMP: 	reti				; Analog Comparator Handler
EXT_INT2: 	reti				; IRQ2 Handler
TIM0_COMP: 	reti				; Timer0 Compare Handler
EE_RDY: 	reti				; EEPROM Ready Handler
SPM_RDY: 	reti				; Store Program Memory Ready Handler

		 


