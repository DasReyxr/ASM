; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; --------------- 6Timer ---------------
; ------------- 01/11/2024 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
.include <M162DEF.INC>

; --- Registers ---
.def WREG = R16
.def T_Time = R18

; ----- RAM -----
.dseg 

.equ OPT = 0x60
.equ TIMESTOP = 0x61
.equ TIME = 0x62
; ----- Time Var -----
.equ T_Cen = 0x90
.equ T_Dec = 0x91
.equ T_Uni = 0x92


.cseg
.org 0
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
ldi r16,high(RAMEND) 	
			out SPH,r16 		; Set Stack Pointer to top of RAM
			ldi r16,low(RAMEND)	; Parte baja
			out SPL,r16			; Inicializar la pila
			cli 				; Disable interrupts

			cbi	DDRD,2			; pin D2 como entrada
			sbi PORTD,2			; pull-up en D2
			cbi	DDRD,3			; pin D3 como entrada
			sbi PORTD,3			; pull-up en D3

			;otras inicializaciones
			;heartbeat copia desde interrupcion en PB0
			ldi r16,0x01 
			out DDRB,r16
			ldi r17,1	;bandera para on/off de copia heartbeat
			;heartbit en OC1A PD5
			ldi	r16,0x20		
			out DDRD,R16
			;configurar TIMER1
			ldi r16,0xF4	;F4
			out OCR1AH,r16
			out OCR1BH,r16
			ldi r16,0x24	;24
			out OCR1AL,r16
			out OCR1BL,r16
			ldi r16,0x40	
			out TCCR1A,r16	;Toggle OC1A cada compare match, modo normal
			ldi r16,0x0C
			out TCCR1B,r16	;modo CTC, start


			;INTERRUPCIONES DE BOTON
			ldi R21,0b00001010	;MCUCR = x x x x ISC11 ISC10 ISC01 ISC00 = flancos negativos
			out MCUCR,R21		;		 0 0 0 0   1     0     1     0
			ldi R21,0b11000000	;GICR = INT1 INT0 INT2 x x x x x
			out GICR,R21		;        1     1    0  0 0 0 0 0

			;interrupciones para el timer en OCR1A
			ldi r16,0x40
			out TIMSK,r16
			ldi r16,0x00
			sei					;Activar la mascara I general de interrupciones

			ldi r16,0
			sts SEGUNDOS, r16
			ldi r16,0
			sts MINUTOS,r16
			ldi r16,0
			sts HORAS, r16
			rcall	LCD_Ini				;Inicializar display LCD
			rcall LCD_Home


; ----------- Init -----------
INIT: 

    rcall VG
			rjmp MAIN

;* SUBRUTINAS *


VG:			ldi     R26,0x0A
			ldi     R29,0x30
			lds     R25,HORAS;MANDO HORAS
			mov     R23,R25
			rcall	SEP;subrutina de separacion
			ldi 	R20,':'
			rcall   LCD_WriteDATA
			lds     R25,MINUTOS;MANDO MINUTOS
			mov     R23,R25
			rcall   SEP
			ldi 	R20,':'
			rcall   LCD_WriteDATA
			lds     R25,SEGUNDOS;MANDO SEGUNDOS
			mov     R23,R25
			rcall   SEP
			rcall 	LCD_Home
			ret

SEP:        cpi     R25,10 
			brpl    SEP2
			cpi     R23,10
			brlo   SEP1
			ret

SEP1:		ldi 	R20,'0';UN DIGITO
			rcall   LCD_WriteDATA
			add     R23,R29;UNIDADES
			mov 	R20,R23
			rcall   LCD_WriteDATA
			ret
			   
			
SEP2:		sub     R25,R26;DOS DIGITOS
			inc     R27
            cp      R25,R26
			brsh    SEP2
			add     R25,R29;UNIDADES
			add     R27,R29;DECENAS
			mov     R20,R27
			rcall   LCD_WriteDATA
			mov 	R20,R25
			rcall   LCD_WriteDATA
			ldi R21,0x00
			mov R25,R21
			mov R27,R21
			ret

HRSp:		lds R29,HORAS
			cpi R29,23
			brpl CLRHRS
			inc R29
			sts HORAS,R29
			ldi R29,0x00
			ret

HRSm:		lds R29,HORAS
			cpi R29,1
			brmi AUHRS
			dec R29
			sts HORAS,R29
			ldi R29,0x00
			ret

AUHRS:		ldi R29,23
			sts HORAS,R29
			ldi R29,0x00
			ret


REF:		ldi R29,0x00
			sts SEGUNDOS,R29
			sts MINUTOS,R29
CLRHRS:		ldi R29,0x00
			sts HORAS,R29
			reti

MIN: 		lds R29,MINUTOS
			inc R29
			sts MINUTOS,R29
			ldi R29,0x00
			sts SEGUNDOS,R29
			reti

HRS:		lds R29,HORAS
			inc R29
			sts HORAS,R29
			ldi R29,0x00
			sts MINUTOS,R29
			sts SEGUNDOS,R29
			reti
;INTERRUPCIONES
Bpl: rcall HRSp
	 reti       	

Bmi: rcall HRSm
	 reti 		

TIM1_CAPT: 	reti				; Timer1 Capture Handler

TIM1_COMPA:	ldi r16,0			; Timer1 CompareA Handler
			out TCNT1H,r16		;reiniciar timer
			out TCNT1L,r16
			ldi R29,0x00
			lds R29,SEGUNDOS
			inc R29
			sts SEGUNDOS,R29
			cpi R29,60
			breq MIN
			lds R29,MINUTOS
			cpi R29,60
			breq HRS
			lds R29,HORAS
			cpi R29,24
			brsh REF
			cpi r17,0			;revisar bandera
			breq palla
			cbi PORTB,0			;si r17 vale 1 activa
			ldi r17,0
			reti
	palla:	sbi PORTB,0			;si r17 vale 0 apaga
			ldi r17,1
			reti


;--