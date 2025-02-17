; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; --------------- 6Timer ---------------
; ------------- 01/11/2024 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
.include "M8515def.inc"

; --- Registers ---
.def WREG = R16
.def DIVISOR = R18

; ----- RAM -----
.dseg 

.equ OPT = 0x60
.equ TIMESTOP = 0x61
.equ TIME = 0x62
; ----- Time Var -----
.equ SEG = 0x92
.equ MIN = 0x91
.equ HR = 0x90
; -- LCD --
#define E  1
#define RS 2

.equ DATA = 0x15; Port C

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
	LDI WREG,high(RAMEND)
	OUT SPH,WREG   ; Set Stack Pointer to top of RAM
	LDI WREG,low(RAMEND) ; Parte baja
	OUT SPL,WREG  ; Inicializar la pila
	CLI    ; Disable interrupts 

	LDI WREG, 0xFF
	OUT DDRA, WREG
	LDI WREG, 0xFF ; LCD
		OUT DDRC, WREG
	LDI WREG, 0x06 ; RS EN
		OUT DDRE, WREG
	LDI WREG, 01      ; Set seconds to 25
	STS SEG, WREG
	LDI WREG, 00      ; Set minutes to 59
	STS MIN, WREG
	LDI WREG, 00      ; Set hours to 23
	STS HR, WREG

	RCALL SET_BUTTON
    RCALL SET_TIMER
	RCALL SET_LCD


; ----------- Init -----------
INIT: 
	RCALL LCD_PRINT
    RJMP INIT

;------------- Subrutines ------------- 

;--- LCD ---

LCD_PRINT: 
	LDI WREG, '-'
	RCALL LCDOUT
	RCALL LCDOUT
	RCALL LCDOUT
	LDI WREG, ' '
	RCALL LCDOUT

	LDS DIVISOR, HR
		RCALL DIV10
		ORI R19, 0x30
		MOV WREG, R19
		RCALL LCDOUT
		ORI DIVISOR, 0x30
		MOV WREG, DIVISOR
		RCALL LCDOUT
		LDI WREG, ':'
		RCALL LCDOUT

	LDS DIVISOR, MIN
		RCALL DIV10
		ORI R19, 0x30
		MOV WREG, R19
		RCALL LCDOUT
		ORI DIVISOR, 0x30
		MOV WREG, DIVISOR
		RCALL LCDOUT
		LDI WREG, ':'
		RCALL LCDOUT
		
	LDS DIVISOR, SEG
		RCALL DIV10
		ORI R19, 0x30
		MOV WREG, R19
		RCALL LCDOUT
		ORI DIVISOR, 0x30
		MOV WREG, DIVISOR
		RCALL LCDOUT

	LDI WREG, ' '
	RCALL LCDOUT
	LDI WREG, '-'
	RCALL LCDOUT
	RCALL LCDOUT
	RCALL LCDOUT
		
	CBI PORTE,RS ; Command Mode RS = 0 A5
		LDI WREG, 0x02 ; Return Home
		RCALL LCDOUT
		LDI WREG, 0x01
		RCALL LCDOUT
		SBI PORTE,RS ; Command Mode RS = 0 A5
	RET

SET_LCD:
			CBI PORTE,E ;Enable A7
            CBI PORTE,RS ; Command Mode RS = 0 A5

            RCALL DELAY_5ms
			RCALL DELAY_5ms
			RCALL DELAY_5ms
			LDI WREG, 0x38
				RCALL LCDOUT				
			LDI WREG, 0x38
				RCALL LCDOUT
			LDI WREG, 0x38
				RCALL LCDOUT
			LDI WREG, 0x38
				RCALL LCDOUT
			
			LDI WREG, 0x08 ; Display OFF
				RCALL LCDOUT
			LDI WREG, 0x01 ; Clear Display 
				RCALL LCDOUT			
			LDI WREG, 0x06 ; Entry Mode Set 
				RCALL LCDOUT				
			LDI WREG, 0x0C ; Display ON
				RCALL LCDOUT
			SBI PORTE, RS ; Character Mode RS = 1

		RET

LCDOUT: 	
			OUT DATA, WREG
			SBI PORTE,E 
			RCALL DELAY_5ms
			CBI PORTE,E 
			RET

DELAY_5ms:
		 	LDI		R23,50
D2:			LDI		R24,255
D1:			DEC 	R24			;12.2ms
			BRNE	D1	
			DEC		R23
			BRNE 	D2
			RET

;--- Timer ---
SET_TIMER:
        LDI WREG,0x3D	;F4
        OUT OCR1AH,WREG
        OUT OCR1BH,WREG
        LDI WREG,0x09	;24
        OUT OCR1AL,WREG
        OUT OCR1BL,WREG
        LDI WREG,0x40	
        OUT TCCR1A,WREG	;Toggle OC1A cada compare match, modo normal
        LDI WREG,0x0C
        OUT TCCR1B,WREG	;modo CTC, start

        ;interrupciones para el timer en OCR1A
        LDI WREG,0x40
        OUT TIMSK,WREG
        SEI				;mascara general de interrupciones
    RET

SET_BUTTON:
		CBI	DDRD,2			; pin D2 como entrada
		SBI PORTD,2			; pull-up en D2
		CBI	DDRD,3			; pin D3 como entrada
		SBI PORTD,3			; pull-up en D3

		LDI WREG,0b00001010	;MCUCR = x x x x ISC11 ISC10 ISC01 ISC00 = flancos negativos
		OUT MCUCR,WREG		;		 0 0 0 0   1     0     1     0

		LDI WREG,0b11000000	;GICR = INT1 INT0 INT2 x x x x x
		OUT GICR,WREG		;        1     1    0  0 0 0 0 0
		

		SEI					;Activar la mascara I general de interrupciones
		

	RET

;--- Division ---
; 
DIV10:
	    CLR R19 ; DECENA
		

	CICLO: 
		CPI DIVISOR, 10
		BRLO ES10
		INC R19          
		SUBI DIVISOR,10      
		CPI DIVISOR, 10      
		BRPL CICLO      

	SAVE:
		RET

	ES10:
		LDI R19, 0
		RJMP SAVE

		

    

; ------ Interrupciones ------ 
INCREMENT:
    LDS R19, SEG
    INC R19
    CPI R19, 60
    BRLO SAVE_S
    LDI R19, 0

    LDS R20, MIN
    INC R20
    CPI R20, 60
    BRLO SAVE_M
    LDI R20, 0

    LDS R21, HR
    INC R21
    CPI R21, 24
    BRLO SAVE_H
    LDI R21, 0
SAVE_H:
    STS HR, R21
SAVE_M:
    STS MIN, R20
SAVE_S:
    STS SEG, R19
	RETI

INCREMENT_M:
    LDS R20, MIN
    INC R20
    CPI R20, 60
    BRLO SAVE_M
    LDI R20, 0
SAVE_M2:
    STS MIN, R20
	RETI

INCREMENT_H:
    LDS R21, HR
    INC R21
    CPI R21, 24
    BRLO SAVE_H
    LDI R21, 0
SAVE_H2:
    STS HR, R21
    RETI
	

DECREMENT:
    LDS R19, SEG
    DEC R19
    BRPL SAVE_S
    LDI R19, 59

    LDS R20, MIN
    DEC R20
    BRPL SAVE_M
    LDI R20, 59

    LDS R21, HR
    DEC R21
    BRPL SAVE_H
    LDI R21, 23
	RJMP SAVE_H

EXT_INT0: 	
		RCALL INCREMENT_H
		RETI				

EXT_INT1: 	
		RCALL INCREMENT_M
		RETI	

TIM1_CAPT:  RETI    ; Timer1 Capture Handler 


TIM1_COMPA:	
        LDI WREG,0			; Timer1 CompareA Handler
        OUT TCNT1H,WREG		;reiniciar timer
        OUT TCNT1L,WREG
        
        LDI WREG, 0x01
		EOR R17, WREG
        OUT PORTA, R17
		RCALL INCREMENT
        
		RETI 

TIM1_COMPB: RETI    ; Timer1 CompareB Handler 
TIM1_OVF:  RETI    ; Timer1 Overflow Handler 
TIM0_OVF:  RETI    ; Timer0 Overflow Handler 
SPI_STC:  RETI    ; SPI Transfer Complete Handler 
USART_RXC:  RETI    ; USART RX Complete Handler 
USART_UDRE: RETI    ; UDR Empty Handler 
USART_TXC:  RETI    ; USART TX Complete Handler 
ANA_COMP:  RETI    ; Analog Comparator Handler 
EXT_INT2:  RETI    ; IRQ2 Handler 
TIM0_COMP:  RETI    ; Timer0 Compare Handler 
EE_RDY:  RETI    ; EEPROM Ready Handler 
SPM_RDY:  RETI    ; Store Program Memory Ready Handler
