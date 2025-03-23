.include "M8515def.inc"  

;DEFINICION DE VARIABLES CON REGISTROS 
.equ	var1	=0x60			; declaracion de variable en RAM
.def	var2	=r2				; delcaracion de registro como variable


.def	COMM	=r22			; declaracion de registro como variable para comando BT


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
			sbi	DDRD,1			; pin D.1 como salida TX

			cbi	DDRD,2			; pin D.2 como entrada
			sbi PORTD,2			; pull-up en D.2
			ldi	R16,0xFF
			out	DDRB,R16		; Todo el puerto B como salida 

			;Set baud rate 207=0x00CF U2X=1, para 9600B, para XTAL=16MHz
			ldi r16,0x00				
			out UBRRH, r16
			ldi r16,0xCF		;207
			out UBRRL, r16
			;Enable double speed U2X
			ldi r16, (1<<U2X)
			out UCSRA,r16
			;Enable receiver and transmitter
			ldi r16, (1<<RXCIE)|(1<<RXEN)|(1<<TXEN) 	;ldi r16, 0b10011000    
			out UCSRB,r16								;RX int, TX on, RX on
			;Set frame format: 8data, 1stop bit
			ldi r16, (1<<URSEL)|(3<<UCSZ0) 
			out UCSRC,r16

			sei
			
			

;PROGRAMA CICLADO PRINCIPAL
;F = Forward
;G = Forward Left
;I = Forward Right
;L = Left
;R = Right
;H = BackLeft
;J = BackRight
;B = Back
;S = Stop

;0-9,q	= speed

;W = Front lights ON
;w = Front Lights OFF
;U = Back Lights ON
;u = Back Lights OFF
;V = Horn ON
;v = Horn OFF
;X = Extra ON
;x = Extra OFF
;D = Stop all

MAIN:		;ldi		r16,'A'
			;sbis 	pind,2
			;rcall 	USART_Transmit

			;Decodificador
	LF:		cpi	COMM,'F'
			brne LG
			ldi r16,0b00000001
			out PORTB,r16

	LG:		cpi	COMM,'G'
			brne LI
			ldi r16,0b00000010
			out PORTB,r16

	LI:		cpi	COMM,'I'
			brne LL
			ldi r16,0b00000100
			out PORTB,r16

	LL:		cpi	COMM,'L'
			brne LR
			ldi r16,0b00001000
			out PORTB,r16

	LR:		cpi	COMM,'R'
			brne LH
			ldi r16,0b00010000
			out PORTB,r16
	
	LH:		cpi	COMM,'H'
			brne LJ
			ldi r16,0b00100000
			out PORTB,r16

	LJ:		cpi	COMM,'J'
			brne LB
			ldi r16,0b01000000
			out PORTB,r16

	LB:		cpi	COMM,'B'
			brne LS
			ldi r16,0b10000000
			out PORTB,r16

	LS:		cpi	COMM,'S'
			brne LX
			ldi r16,0b00000000
			out PORTB,r16

	LX:		rjmp MAIN			;regresa a MAIN (loop)



;*********************** SUBRUTINAS ***********************
USART_Transmit:	; Wait for empty transmit buffer
				sbis UCSRA,UDRE
				rjmp USART_Transmit
				; Put data (r16) into buffer, sends the data
				out UDR,r16
				rcall DELAY
				ret

DELAY:			lds		R19,255
D3:				ldi		R18,255		;espectativa de 100ms
D2:				ldi		R17,255
D1:				dec		R17			;48.25us
				brne	D1
				dec 	R18			;12.2ms
				brne	D2	
				dec		R19
				brne	D3
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

USART_RXC: 	in COMM,UDR			; USART RX Complete Handler
			reti				

USART_UDRE:	reti				; UDR Empty Handler
USART_TXC: 	reti				; USART TX Complete Handler
ANA_COMP: 	reti				; Analog Comparator Handler
EXT_INT2: 	reti				; IRQ2 Handler
TIM0_COMP: 	reti				; Timer0 Compare Handler
EE_RDY: 	reti				; EEPROM Ready Handler
SPM_RDY: 	reti				; Store Program Memory Ready Handler


