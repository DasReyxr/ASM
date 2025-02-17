//Pines PWM Timer1
//PE2 (OC1B)   - PWMB
//PD5 (OC1A)   - PWMA     

//Pines Driver
//PB0 (OC0/T0) - INA2 
//PB1 (T1)     - INA1 
//PB2 (AIN0)   - INB1 
//PB3 (AIN1)   - INB2 

//Interrupciones externas
//PD2 (INT0)   
//PD3 (INT1)   

.include "M8515def.inc"  

;DEFINICION DE VARIABLES CON REGISTROS 
.equ	var1	=0x60			; declaracion de variable en RAM


//DEFINICIONES (convenientes)

#define	PTO_INAB	PORTB				;Puerto de se�ales INA1,INA2,INB1,INB2
#define DDR_INAB	DDRB				;Direccion del puerto de se�ales INA1,INA2,INB1,INB2
#define INA2		0					;se�al driver INA2				
#define INA1		1					;se�al driver INA1 
#define INB1		2					;se�al driver INB1
#define INB2		3					;se�al driver INB2

#define	SET_INA2	sbi PTO_INAB,INA2	;set INA2
#define	CLR_INA2	cbi PTO_INAB,INA2	;clr INA2
#define	SET_INA1	sbi PTO_INAB,INA1	;set INA1
#define	CLR_INA1	cbi PTO_INAB,INA1	;clr INA1
#define	SET_INB1	sbi PTO_INAB,INB1	;set INB1
#define	CLR_INB1	cbi PTO_INAB,INB1	;clr INB1
#define	SET_INB2	sbi PTO_INAB,INB2	;set INB2
#define	CLR_INB2	cbi PTO_INAB,INB2	;clr INB2

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


;*********************** CONFIGURACION Y ARRANQUE DEL SISTEMA (SETUP) 
RESET: 		ldi r16,high(RAMEND) 	
			out SPH,r16 		; Set Stack Pointer to top of RAM
			ldi r16,low(RAMEND)	; Parte baja
			out SPL,r16			; Inicializar la pila
			cli 				; Disable interrupts

			ldi R24,0			;Velocidad Motor derecho
			ldi R25,0
			ldi R26,0			;Velocidad Motor izquierdo
			ldi R27,0

			ldi R22,5			;incremento de velocidad L
			ldi R23,0			;incremento de velocidad H

			;----------------- PUERTOS
			sbi DDR_INAB,INA2	; INA2 como salida
			sbi DDR_INAB,INA1	; INA1 como salida
			sbi DDR_INAB,INB1	; INB1 como salida
			sbi DDR_INAB,INB2	; INB2 como salida
		 
			SET_INA1			;giro CW ambos motores
			CLR_INA2
			SET_INB1
			CLR_INB2

			;---------------- INTERRUPCIONES EXTERNAS
			cbi	DDRD,2			; pin D.2 como entrada para push
			sbi PORTD,2			; pull-up en D.2
			cbi	DDRD,3			; pin D.3 como entrada para push
			sbi PORTD,3			; pull-up en D.3
			
			ldi R16,0x0A		;flancos negativos
			out MCUCR,R16
			ldi R16,0xC0		;mascaras
			out GICR,R16

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
			ldi r16,0x00					;OCR1A=OCR1B=0x0000; PWMA=0, PWMB=0
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
			

;*********************** PROGRAMA PPAL (LOOP) ***************
MAIN:		

			cpi	 R26,0xFF
			brne M2
			cpi  R27,1
			brne M1
			rjmp M3
	M1:		inc  R27
	M2:		inc  R26
			out  OCR1BH,R27		;OCR1B motor izquierdo
			out  OCR1BL,R26
			rcall DELAY10
			rjmp MAIN

	M3:		cpi  R26,0
			brne M5
			cpi  R27,1
			breq M4
			rjmp MAIN			;retornar
	M4:     dec  R27
	M5:		dec  R26
			out  OCR1BH,R27		;OCR1B motor izquierdo
			out  OCR1BL,R26
			rcall DELAY10
			rjmp M3
			rjmp MAIN						;regresa a MAIN (loop)
	
	
			
;*********************** SUBRUTINAS ***********************
DELAY10:	ldi		R18,10		
D2:			ldi		R17,255
D1:			dec		R17			
			brne	D1
			dec 	R18			
			brne	D2	
			ret


;*********************** INTERRUPCIONES *******************
			;incrementar PWM
EXT_INT0: 	cpi  R24,0xFF		;parte baja Vel Mot der
			brne EI01				;revisar si 0x1FF 9bits, tope PWM
			cpi  R25,1			;parte baja Vel Mot der (510)
			brne EI00
			reti				;tope, entonces retornar
	EI00:	ldi  R24,0xFB	
	EI01:	add  R24,R22		;incrementar de 10 en 10
			adc  R25,R23
			out  OCR1AH,R25		;OCR1A motor derecho
			out  OCR1AL,R24
			reti				; IRQ0 Handler

			;decrementar PWM
EXT_INT1: 	cpi  R24,0			;parte baja Vel Mot der
			brne EI11
			cpi	 R25,0
			brne EI10
			reti
    EI10:	ldi	 R24,0x04
	EI11:	sub  R24,R22
			sbc  R25,R23
			out  OCR1AH,R25		;OCR1A motor derecho
			out  OCR1AL,R24
			reti				; IRQ1 Handler

TIM1_CAPT: 	reti				; Timer1 Capture Handler
TIM1_COMPA:	reti				; Timer1 CompareA Handler
TIM1_COMPB:	reti				; Timer1 CompareB Handler
TIM1_OVF: 	reti				; Timer1 Overflow Handler
TIM0_OVF: 	reti				; Timer0 Overflow Handler
SPI_STC: 	reti				; SPI Transfer Complete Handler
USART_RXC: 	reti				; Leer comando y retornar 
USART_UDRE:	reti				; UDR Empty Handler
USART_TXC: 	reti				; USART TX Complete Handler
ANA_COMP: 	reti				; Analog Comparator Handler
EXT_INT2: 	reti				; IRQ2 Handler
TIM0_COMP: 	reti				; Timer0 Compare Handler
EE_RDY: 	reti				; EEPROM Ready Handler
SPM_RDY: 	reti				; Store Program Memory Ready Handler

