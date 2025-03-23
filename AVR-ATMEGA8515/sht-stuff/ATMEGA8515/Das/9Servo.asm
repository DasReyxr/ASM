; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; --------------- 9Servo ---------------
; ------------- 18/11/2024 -------------
; ------------- Variables -------------
; ---------------- INIT ----------------
;  0 - 1 ms
; 180 - 2 ms
; 45   1+ 45/180 = 1.25
; with xTal as 16 MHz 
; 1.25 *10**-3 * (16*10**6)/256


.include "M8515def.inc"
.def WREG =R16
.def	COMM	=r22			; delcaracion de registro como variable de comando BT	

.equ	PERIODO		= 312			; Valor de ICR1 para un periodo de 20 ms
.equ	PWM_MIN		= 15			; OCR1A para 1 ms (posición mínima)
.equ	PWM_CENTER	= 23			; OCR1A para 1.5 ms (posición central)
.equ	PWM_MAX		= 31			; OCR1A para 2 ms (posición máxima)


; --- Interruptions Config ---
RJMP SETCONFIG   ; Reset Handler  
RJMP EXT_INT0   ; IRQ0 Handler  
RJMP EXT_INT1   ; IRQ1 Handler  
RJMP TIM1_CAPT   ; Timer1 Capture Handler  
RJMP TIM1_COMPA   ; Timer1 CompareA Handler  
RJMP TIM1_COMPB   ; Timer1 CompareB Handler  
RJMP TIM1_OVF   ; Timer1 Overflow Handler  
RJMP TIM0_OVF   ; Timer0 Overflow Handler  
RJMP SPI_STC   ; SPI Transfer Complete Handler  
RJMP USART_RXC   ; USART RX Complete Handler  
RJMP USART_UDRE   ; UDR Empty Handler  
RJMP USART_TXC   ; USART TX Complete Handler  
RJMP ANA_COMP  ; Analog Comparator Handler  
RJMP EXT_INT2  ; IRQ2 Handler    (no AT90S8515)  
RJMP TIM0_COMP  ; Timer0 Compare Handler  (no AT90S8515)  
RJMP EE_RDY   ; EEPROM Ready Handler  (no AT90S8515)  
RJMP SPM_RDY   ; Store Program Memory Ready Handler(no AT90S8515) 

; ------ Configuration ------
SETCONFIG:
	LDI R16,high(RAMEND)
	OUT SPH,R16   ; Set Stack Pointer to top of RAM
	LDI R16,low(RAMEND) ; Parte baja
	OUT SPL,R16  ; Inicializar la pila
	CLI    ; Disable interrupts 
	

	rcall SET_USART
    ;---------------- TIMER 1 para PWM 9 bits (Modo 6), XTAL/1, XTAL=16MHz, No INTs 
    sbi DDRD,5	;PD5 (OC1A) - PWMA 
	; Configuración del Timer1
	
	ldi r16, (1 << COM1A1)|(1 << COM1B1)| (1 << WGM11) ; Clear on Compare Match, 
	out TCCR1A, r16     	

	
	; WGM13 = 1 WGM12 = 1 WGM11 = 1 WGM10 = 0 Fast pwm top icr1	
	ldi r16, (1 << WGM13) | (1 << WGM12) | (1<< CS12) | (1 << CS10) ; 1024 Prescaler
	out TCCR1B, r16
	
	
	ldi r16, low(PERIODO) 	
	out ICR1L, r16
	ldi r16, high(PERIODO) 	
	out ICR1H, r16
	ldi r16, low(PWM_CENTER)
	out OCR1AL, r16
	out OCR1BL, r16
	
	ldi r16, high(PWM_CENTER)
	out OCR1AH, r16
	out OCR1BL, r16
	; Configurar el valor inicial de OCR1A (1.5 ms, posición central)
	SEI

	                                                                                                                                                                                                            
; ----------- Init -----------
INIT: 
	CPI COMM, 'O'	
	breq ON
	CPI COMM, 'F'
	breq OFF
	rcall DELAYputiza
	
			ldi r16,0x00
			OUT PORTC,r16		

	ldi r16, low(23)
	out OCR1AL, r16
	out OCR1BL, r16

	ldi r16, high(23)
	out OCR1AH, r16
	out OCR1BH, r16
	RJMP INIT

;------------- Subrutines ------------- 

ON:	
			ldi r16,0x01
			OUT PORTC,r16		
		
			; Mover a posición mínima (izquierda)
			ldi r16, low(15)
			out OCR1AL, r16
			ldi r16, high(15)
			out OCR1AH, r16
			rcall DELAYmedio
			CLR COMM

			rjmp init
	
OFF:
			ldi r16,0x02
			OUT PORTC,r16		
			; Mover a posición mínima (izquierda)
			ldi r16, low(15)
			out OCR1BL, r16
			ldi r16, high(15)
			out OCR1BH, r16
			rcall DELAYmedio
			CLR COMM
			rjmp init

LOOP:
		ldi r16, low(23)
		out OCR1AL, r16
		out OCR1BL, r16
	
		ldi r16, high(23)
		out OCR1AH, r16
		out OCR1BH, r16
		rjmp init
SET_USART:
			sbi	DDRD,1			; pin D.1 como salida TX
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
			RET
DELAYmedio:
	LDI R19, 255; Adjusted to reduce loop count
TA3:
	LDI R18, 255 ; Adjusted to reduce loop count
TA2:
	LDI R17, 200  ; Adjusted to reduce loop count
TA1:
	DEC R17
	BRNE TA1
	DEC R18
	BRNE TA2
	DEC R19
	BRNE TA3
	RET


DELAYputiza:
	LDI R19, 255; Adjusted to reduce loop count
TA23:
	LDI R18, 255 ; Adjusted to reduce loop count
TA22:
	LDI R17, 50  ; Adjusted to reduce loop count
TA21:
	DEC R17
	BRNE TA21
	DEC R18
	BRNE TA22
	DEC R19
	BRNE TA23
	RET


; ------ Interrupciones ------ 
EXT_INT0:  RETI    ; IRQ0 Handler 
EXT_INT1:  RETI    ; IRQ1 Handler 
TIM1_CAPT:  RETI    ; Timer1 Capture Handler 
TIM1_COMPA: RETI    ; Timer1 CompareA Handler 
TIM1_COMPB: RETI    ; Timer1 CompareB Handler 
TIM1_OVF:  RETI    ; Timer1 Overflow Handler 
TIM0_OVF:  RETI    ; Timer0 Overflow Handler 
SPI_STC:  RETI    ; SPI Transfer Complete Handler 

USART_RXC: 	in COMM,UDR			; USART RX Complete Handler
			reti				; Leer comando y retornar 

USART_UDRE: RETI    ; UDR Empty Handler 
USART_TXC:  RETI    ; USART TX Complete Handler 
ANA_COMP:  RETI    ; Analog Comparator Handler 
EXT_INT2:  RETI    ; IRQ2 Handler 
TIM0_COMP:  RETI    ; Timer0 Compare Handler 
EE_RDY:  RETI    ; EEPROM Ready Handler 
SPM_RDY:  RETI    ; Store Program Memory Ready Handler
