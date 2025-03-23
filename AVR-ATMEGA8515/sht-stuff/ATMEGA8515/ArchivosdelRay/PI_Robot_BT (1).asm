
//PINES ATMEGA8515             __
//1  PB0 (OC0/T0) - INA2      |* | 40 VCC
//2  PB1 (T1)     - INA1      |  | 39 PA0 (AD0)      - 
//3  PB2 (AIN0)   - INB1      |  | 38 PA1 (AD1)      - 
//4  PB3 (AIN1)   - INB2      |  | 37 PA2 (AD2)      - 
//5  PB4 (SS)     -           |  | 36 PA3 (AD3)      - 
//6  PB5 (MOSI)   - PROG_MOSI |  | 35 PA4 (AD4)      - 
//7  PB6 (MISO)   - PROG_MISO |  | 34 PA5 (AD5)      - 
//8  PB7 (SCK)    - PTOG_SCK  |  | 33 PA6 (AD6)      - 
//9  RESET                    |  | 32 PA7 (AD7)      - 
//10 PD0 (RXD)    - TX_BT     |  | 31 PE0 (ICP/INT2) - 
//11 PD1 (TXD)    - RX_BT     |  | 30 PE1 (ALE)      - 
//12 PD2 (INT0)   -           |  | 29 PE2 (OC1B)     - PWMB
//13 PD3 (INT1)   -           |  | 28 PC7 (A15)      - 
//14 PD4 (XCK)    -           |  | 27 PC6 (A14)      - 
//15 PD5 (OC1A)   - PWMA      |  | 26 PC5 (A13)      - 
//16 PD6 (WR)     -       	  |  | 25 PC4 (A12)      - 
//17 PD7 (RD)     -           |  | 24 PC3 (A11)      - 
//18 XTAL1					  |  | 23 PC2 (A10)      - 
//19 XTAL2                    |  | 22 PC1 (A9)       - 
//20 GND                      |__| 21 PC0 (A8)       - 

.include "M8515def.inc"  

;DEFINICION DE VARIABLES CON REGISTROS 
.equ	var1	=0x60			; declaracion de variable en RAM
.def	velH	=r20			; delcaracion de registro como variable de velocidad parte alta
.def	velL	=r21			; delcaracion de registro como variable de velocidad parte baja
.def	COMM	=r22			; delcaracion de registro como variable de comando BT	


//DEFINICIONES (convenientes)

#define	PTO_INAB	PORTB				;Puerto de señales INA1,INA2,INB1,INB2
#define DDR_INAB	DDRB				;Direccion del puerto de señales INA1,INA2,INB1,INB2
#define INA2		0					;señal driver INA2				
#define INA1		1					;señal driver INA1 
#define INB1		2					;señal driver INB1
#define INB2		3					;señal driver INB2

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
			
			

;PROGRAMA CICLADO PRINCIPAL
;COMANDO				INA1 	INA2	OCRAH:OCRAL		INB1	INB2	OCRBH:OCRAL		VELH:VELL
;F = Forward			1		0		VELH:VELL		1		0		VELH:VELL		-
;G = Forward Left		1		0		VELH:VELL		1		0		VELH:VELL/2		-
;I = Forward Right		1		0		VELH:VELL/2		1		0		VELH:VELL		-
;L = Left				0		1		VELH:VELL/2		1		0		VELH:VELL/2		-
;R = Right				1		0		VELH:VELL/2		0		1		VELH:VELL/2		-
;H = BackLeft			0		1		VELH:VELL/2		0		1		VELH:VELL		-
;J = BackRight			0		1		VELH:VELL		0		1		VELH:VELL/2		-
;B = Back				0		1		VELH:VELL/2		0		1		VRLH:VELL/2		-
;S = Stop				0		0		-				0		0		-				-

;0 = speed 0			-		-		-				-		-		-				511*0   = 0x00:00 (0)
;1 = speed 10			-		-		-				-		-		-				511*0.1 = 0x00:33 (51)
;2 = speed 20			-		-		-				-		-		-				511*0.2 = 0x00:66 (102)
;3 = speed 30			-		-		-				-		-		-				511*0.3 = 0x00:99 (153)
;4 = speed 40			-		-		-				-		-		-				511*0.4 = 0x00:CC (204)
;5 = speed 50			-		-		-				-		-		-				511*0.5 = 0x00:FF (255)
;6 = speed 60			-		-		-				-		-		-				511*0.6 = 0x01:33 (307)
;7 = speed 70			-		-		-				-		-		-				511*0.7 = 0x01:66 (358)
;8 = speed 80			-		-		-				-		-		-				511*0.8 = 0x01:99 (409)
;9 = speed 90			-		-		-				-		-		-				511*0.9 = 0x01:CC (460)
;q = speed 100			-		-		-				-		-		-				511*1.0 = 0x01:FF (511)

;W = Front lights ON																-
;w = Front Lights OFF																-
;U = Back Lights ON																	-
;u = Back Lights OFF																-
;V = Horn ON																		-
;v = Horn OFF																		-
;X = Extra ON																		-
;x = Extra OFF																		-
;D = Stop all																		-

MAIN:		;ldi		r16,'A'
			;sbis 	pind,2
			;rcall 	USART_Transmit

	LF:		cpi COMM,'F'		;Forward
			brne LG
			SET_INA1
			CLR_INA2
			SET_INB1
			CLR_INB2
			rcall VelRmax
			rcall VelLmax

	LG:		cpi COMM,'G'		;Forward left
			brne LI
			SET_INA1
			CLR_INA2
			SET_INB1
			CLR_INB2
			rcall VelRmax
			rcall VelLmin

	LI:		cpi COMM,'I'		;Forward right
			brne LL
			SET_INA1
			CLR_INA2
			SET_INB1
			CLR_INB2
			rcall VelRmin
			rcall VelLmax

	LL:		cpi COMM,'L'		;Left (sobre su propio eje)
			brne LR
			CLR_INA1
			SET_INA2
			SET_INB1
			CLR_INB2
			rcall VelRmin
			rcall VelLmin

	LR:		cpi COMM,'R'		;Right (sobre su propio eje)
			brne LH
			SET_INA1
			CLR_INA2
			CLR_INB1
			SET_INB2
			rcall VelRmin
			rcall VelLmin

	LH:		cpi COMM,'H'		;Back left
			brne LJ
			CLR_INA1
			SET_INA2
			CLR_INB1
			SET_INB2
			rcall VelRmin
			rcall VelLmax

	LJ:		cpi COMM,'J'		;Back right
			brne LB
			CLR_INA1
			SET_INA2
			CLR_INB1
			SET_INB2
			rcall VelRmax
			rcall VelLmin

	LB:		cpi COMM,'B'		;Back
			brne LS
			CLR_INA1
			SET_INA2
			CLR_INB1
			SET_INB2
			rcall VelRmin
			rcall VelLmin

	LS:		cpi COMM,'S'		;Stop
			brne L0
			CLR_INA1
			CLR_INA2
			CLR_INB1
			CLR_INB2


	L0:		cpi COMM,'0'		;speed 0
			brne L1 
			ldi	VELL,0x00
			ldi	VELH,0x00
			rcall ActualVel
	L1:		cpi COMM,'1'		;speed 1
			brne L2 
			ldi	VELL,0x33
			ldi	VELH,0x00
			rcall ActualVel
	L2:		cpi COMM,'2'		;speed 2
			brne L3 
			ldi	VELL,0x66
			ldi	VELH,0x00
			rcall ActualVel
	L3:		cpi COMM,'3'		;speed 3
			brne L4 
			ldi	VELL,0x99
			ldi	VELH,0x00
			rcall ActualVel
	L4:		cpi COMM,'4'		;speed 4
			brne L5 
			ldi	VELL,0xCC
			ldi	VELH,0x00
			rcall ActualVel
	L5:		cpi COMM,'5'		;speed 5
			brne L6 
			ldi	VELL,0xFF
			ldi	VELH,0x00
			rcall ActualVel
	L6:		cpi COMM,'6'		;speed 6
			brne L7
			ldi	VELL,0x33
			ldi	VELH,0x01
			rcall ActualVel
	L7:		cpi COMM,'7'		;speed 7
			brne L8 
			ldi	VELL,0x66
			ldi	VELH,0x01
			rcall ActualVel
	L8:		cpi COMM,'8'		;speed 8
			brne L9 
			ldi	VELL,0x99
			ldi	VELH,0x01
			rcall ActualVel
	L9:		cpi COMM,'9'		;speed 9
			brne Lq  
			ldi	VELL,0xCC
			ldi	VELH,0x01
			rcall ActualVel
	Lq:		cpi COMM,'q'		;speed 10
			brne LX 
			ldi	VELL,0xFF
			ldi	VELH,0x01
			rcall ActualVel



	LX:		ldi	 COMM,0						;resetear comando
			rjmp MAIN						;regresa a MAIN (loop)
	
	
			
		



;*********************** SUBRUTINAS ***********************
ActualVel:						;visualizar velocidades OCR1A=0x0000;
			out OCR1AH,VELH		;OCR1A motor derecho
			out OCR1AL,VELL
			out OCR1BH,VELH		;OCR1B motor izquierdo
			out OCR1BL,VELL
			ret

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
			reti				; Leer comando y retornar 

USART_UDRE:	reti				; UDR Empty Handler
USART_TXC: 	reti				; USART TX Complete Handler
ANA_COMP: 	reti				; Analog Comparator Handler
EXT_INT2: 	reti				; IRQ2 Handler
TIM0_COMP: 	reti				; Timer0 Compare Handler
EE_RDY: 	reti				; EEPROM Ready Handler
SPM_RDY: 	reti				; Store Program Memory Ready Handler

