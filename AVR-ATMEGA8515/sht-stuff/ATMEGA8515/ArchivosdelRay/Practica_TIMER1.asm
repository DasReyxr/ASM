;Programa que implementa un heartbeat por medio del TIMER1
;XTAL=16MHz, 0.5s tiempo entre interrupciones



 .include "M8515def.inc"  

;DEFINICION DE VARIABLES CON REGISTROS 
.def	var1	=r1				;comentario
.def	var2	=r2

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
RESET: 		ldi r16,high(RAMEND) 	
			out SPH,r16 		; Set Stack Pointer to top of RAM
			ldi r16,low(RAMEND)	; Parte baja
			out SPL,r16			; Inicializar la pila
			cli 				; Disable interrupts		 
			rcall SET_TIMER

			;otras inicializaciones
			;heartbeat copia desde interrupcion en PB0
			ldi r16,0x01 
			out DDRB,r16
			ldi r17,1	;bandera para on/off de copia heartbeat
			;heartbit en OC1A PD5
			ldi	r16,0x20		
			out DDRD,R16

			

SET_TIMER:
			ldi r16,0x7A	;F4
			out OCR1AH,r16
			out OCR1BH,r16
			ldi r16,0x12	;24
			out OCR1AL,r16
			out OCR1BL,r16
			ldi r16,0x40	
			out TCCR1A,r16	;Toggle OC1A cada compare match, modo normal
			ldi r16,0x0C
			out TCCR1B,r16	;modo CTC, start

			;interrupciones para el timer en OCR1A
			ldi r16,0x40
			out TIMSK,r16
 			sei				;mascara general de interrupciones


		RET
;PROGRAMA CICLADO PRINCIPAL
MAIN:		;aqui van sus rutinas
			

			
			rjmp MAIN			;regresa a MAIN (loop)


;*********************** SUBRUTINAS ***********************




;INTERRUPCIONES
EXT_INT0: 	reti				; IRQ0 Handler
EXT_INT1: 	reti				; IRQ1 Handler
TIM1_CAPT: 	reti				; Timer1 Capture Handler

TIM1_COMPA:	ldi r16,0			; Timer1 CompareA Handler
			out TCNT1H,r16		;reiniciar timer
			out TCNT1L,r16
			tst r17			;revisar bandera
			breq palla
			cbi PORTB,0			;si r17 vale 1 activa
			ldi r17,0
			reti
	palla:	sbi PORTB,0			;si r17 vale 0 apaga
			ldi r17,1
			reti		
		
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


