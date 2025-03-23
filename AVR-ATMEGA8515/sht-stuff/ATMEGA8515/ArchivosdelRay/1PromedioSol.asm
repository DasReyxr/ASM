.include "M8515def.inc"  

;DEFINICION DE VARIABLES CON REGISTROS 
.equ	var1	=0x60			; declaracion de variable en RAM
.def	var2	=r2				; delcaracion de registro como variable

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
RESET: 		ldi r16,high(RAMEND) 	
			out SPH,r16 		; Set Stack Pointer to top of RAM
			ldi r16,low(RAMEND)	; Parte baja
			out SPL,r16			; Inicializar la pila
			cli 				; Disable interrupts

			;otras inicializaciones
			ldi	R16,0xFF
			out	DDRB,R16		; Todo el puerto B como salida 
		
			cbi	DDRD,2			; pin D.2 como entrada
			sbi PORTD,2			; pull-up en D.2
			cbi	DDRD,3			; pin D.3 como entrada
			sbi PORTD,3			; pull-up en D.3
			
			ldi R16,200			; valor inicial del DELAY
			sts	var1,R16
			

;PROGRAMA CICLADO PRINCIPAL
MAIN:		ldi		R16,0x02		;aqui van sus rutinas
M1:			com		R16
			out 	PORTB,R16
			com		R16
			rcall 	DELAY
			rcall	BOTONES
			lsl		R16
			brne	M1			

			;de regreso
			ldi		R16,0x40		
M2:			com		R16
			out 	PORTB,R16
			com		R16
			rcall 	DELAY
			rcall	BOTONES
			lsr		R16
			brne	M2
			
			rjmp MAIN			;regresa a MAIN (loop)



;*********************** SUBRUTINAS ***********************
DELAY:		lds		R19,var1
D3:			ldi		R18,255		;espectativa de 100ms
D2:			ldi		R17,8
D1:			dec		R17			;48.25us
			brne	D1
			dec 	R18			;12.2ms
			brne	D2	
			dec		R19
			brne	D3
			ret

BOTONES:	lds		R19,var1
			sbis 	pind,2
			rjmp 	B1
			sbis 	pind,3
			rjmp 	B2
			ret
B1: 		dec 	r19
			sts		var1,R19
			ret
B2:			inc 	r19
			sts		var1,R19
			ret



;INTERRUPCIONES
EXT_INT0: 	reti				; IRQ0 Handler
EXT_INT1: 	reti				; IRQ1 Handler
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


