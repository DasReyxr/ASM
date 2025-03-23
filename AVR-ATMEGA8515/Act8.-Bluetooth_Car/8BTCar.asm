; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ---------------- tcar ----------------
; ------------- 16/02/2025 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
.include "M8515def.inc"


.def	velH	=r20			; delcaracion de registro como variable de velocidad parte alta
.def	velL	=r21			; delcaracion de registro como variable de velocidad parte baja
.def	COMM	=r22			; delcaracion de registro como variable de comando BT	

#define	PTO_INAB	PORTB				;Puerto de seÃ±ales INA1,INA2,INB1,INB2
#define DDR_INAB	DDRB				;Direccion del puerto de seÃ±ales INA1,INA2,INB1,INB2
#define INA2		0					;seÃ±al driver INA2				
#define INA1		1					;seÃ±al driver INA1 
#define INB1		2					;seÃ±al driver INB1
#define INB2		3					;seÃ±al driver INB2

;Macros
.macro Forward
    ldi r16, 0x0A            ;(INA2 = 1, INA1 = 0, INB2 = 1, INB1 = 0)
    out PTO_INAB, r16       
.endmacro

.macro left
    ldi r16, 0x09            ;(INA1 = 1, INB2 = 1)
    out PTO_INAB, r16
.endmacro

.macro right
    ldi r16, 0x06            ;(INA2 = 1, INB1 = 1)
    out PTO_INAB, r16
.endmacro

.macro Backward
    ldi r16, 0x05            ;(INA2 = 0, INA1 = 1, INB2 = 0, INB1 = 1)
    out PTO_INAB, r16
.endmacro


.macro stop
    ldi r16, 0x00       
    out PTO_INAB, r16
.endmacro


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
			
			;----------------- PUERTOS
			cbi	DDRD,2			; pin D.2 como entrada para push
			sbi PORTD,2			; pull-up en D.2
			sbi DDR_INAB,INA2	; INA2 como salida
			sbi DDR_INAB,INA1	; INA1 como salida
			sbi DDR_INAB,INB1	; INB1 como salida
			sbi DDR_INAB,INB2	; INB2 como salida
			
			cbi DDRC,0
			sbi PORTC,0


			ldi	R16,0x0F
			out	DDRB,R16		; medio puerto B como salida
			 
			;----------------- PUERTO SERIE
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

			;---------------- TIMER 1 para PWM 9 bits (Modo 6), XTAL/1, XTAL=16MHz, No INTs 
			sbi DDRE,2	;PE2 (OC1B) - PWMB
			sbi DDRD,5	;PD5 (OC1A) - PWMA 
    		//                                  XTAL/1	  XTAL/8     XTAL/64
			//8  bits TIM1 (OCRmax=00FF)	    62,500Hz  7,812Hz    9,76Hz
			//9  bits TIM1 (OCRmax=01FF)	    31,250Hz  3,906Hz    4,48Hz
    		//10 bits TIM1 (OCRmax=03FF) 		15,625Hz  1,953Hz    2,44Hz
			ldi r16,0x00					;TCNT1=0x0000;
			out TCNT1H,r16
			out TCNT1L,r16
			ldi r16,0x00					;OCR1A=OCR1B=0x0000;
			out OCR1AH,r16
			out OCR1AL,r16
			out OCR1BH,r16
			out OCR1BL,r16
    		ldi r16,0xA2					;TCCR1A=0b10100010=0xA2, OCR1A y OCR1B pines y PWM modo 6 
			out TCCR1A,r16
    		ldi r16,0x09					;TCCR1B=0b00001001=x05  clk/1, PWM modo 6 9bits 
			out TCCR1B,r16
    
			;--------------- MASCARA I
			sei

Main:
	OUT 
Act_Vel:
    out OCR1AH, VELH
    out OCR1AL, VELL
    out OCR1BH, VELH
    out OCR1BL, VELL
	rjmp Main

	
LF:		Forward
		rjmp Act_Vel

LG:		Forward  ; este ;Forward left
		rcall VelRmax
		rcall VelLmin
		rjmp Main

LI:		Forward		;;Forward right
		rcall VelRmin
		rcall VelLmax
		rjmp Main

LL:		left
		rjmp Act_Vel

LR:		right
		rjmp Act_Vel
		
LH:		Backward ;Back left
		rcall VelRmin
		rcall VelLmax
		rjmp Main

LJ:		Backward ;este Back right
		rcall VelRmax
		rcall VelLmin
		rjmp Main

LB:		Backward
		rjmp Act_Vel

LS:		Stop
		rjmp Act_Vel



VelRmax:	out OCR1AH,VELH		;OCR1A motor derecho
			out OCR1AL,VELL
			ret


VelRmin:	mov r17,VELH		;dividir velocidad / 2 = 1 corrimiento a la derecha
			mov r16,VELL
			clc					;C=0
			ror r17
			ror r16
			out OCR1AH,r17		;OCR1A motor derecho
			out OCR1AL,r16
			ret

VelLmax:	out OCR1BH,VELH		;OCR1B motor izquierdo
			out OCR1BL,VELL
			ret

VelLmin:	mov r17,VELH		;dividir velocidad / 2 = 1 corrimiento a la derecha
			mov r16,VELL
			clc					;C=0
			ror r17
			ror r16
			out OCR1BH,r17		;OCR1B motor izquierdo
			out OCR1BL,r16
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
			reti				; Leer comando y retornar 

USART_UDRE:	reti				; UDR Empty Handler
USART_TXC: 	reti				; USART TX Complete Handler
ANA_COMP: 	reti				; Analog Comparator Handler
EXT_INT2: 	reti				; IRQ2 Handler
TIM0_COMP: 	reti				; Timer0 Compare Handler
EE_RDY: 	reti				; EEPROM Ready Handler
SPM_RDY: 	reti				; Store Program Memory Ready Handler
