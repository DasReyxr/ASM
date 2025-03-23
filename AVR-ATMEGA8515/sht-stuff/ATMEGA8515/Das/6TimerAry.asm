; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; --------------- 6Timer ---------------
; ------------- 01/11/2024 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
.include "M8515def.inc"

; --- Registers ---

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
	LDI R16,high(RAMEND)
	OUT SPH,R16   ; Set Stack Pointer to top of RAM
	LDI R16,low(RAMEND) ; Parte baja
	OUT SPL,R16  ; Inicializar la pila
	CLI    ; Disable interrupts 

	LDI R16, 0xFF
	OUT DDRA, R16
	LDI R16, 0xFF ; LCD
		OUT DDRC, R16
	LDI R16, 0x06 ; RS EN
		OUT DDRE, R16
	LDI R16, 01      ; Set seconds to 25
	STS SEG, R16
	LDI R16, 00      ; Set minutes to 59
	STS MIN, R16
	LDI R16, 00      ; Set hours to 23
	STS HR, R16

    CBI	DDRD,2			; pin D2 como entrada
    SBI PORTD,2			; pull-up en D2
    CBI	DDRD,3			; pin D3 como entrada
    SBI PORTD,3			; pull-up en D3

    LDI R16,0b00001010	;MCUCR = x x x x ISC11 ISC10 ISC01 ISC00 = flancos negativos
    OUT MCUCR,R16		;		 0 0 0 0   1     0     1     0

    LDI R16,0b11000000	;GICR = INT1 INT0 INT2 x x x x x
    OUT GICR,R16		;        1     1    0  0 0 0 0 0


    SEI					;Activar la mascara I general de interrupciones
		
    LDI R16,0x3D	;F4
    OUT OCR1AH,R16
    OUT OCR1BH,R16
    LDI R16,0x09	;24
    OUT OCR1AL,R16
    OUT OCR1BL,R16
    LDI R16,0x40	
    OUT TCCR1A,R16	;Toggle OC1A cada compare match, modo normal
    LDI R16,0x0C
    OUT TCCR1B,R16	;modo CTC, start

    ;interrupciones para el timer en OCR1A
    LDI R16,0x40
    OUT TIMSK,R16
    SEI				;mascara general de interrupciones

	RCALL SET_LCD


; ----------- Init -----------
INIT: 
	RCALL LCD_PRINT
    RJMP INIT

;------------- Subrutines ------------- 

;--- LCD ---

LCD_PRINT: 
	CBI PORTE,RS ; Command Mode RS = 0 A5
		LDI R16, 0x02 ; Return Home
		RCALL LCDOUT
		SBI PORTE,RS ; Command Mode RS = 0 A5
	LDI R16, ' '
	RCALL LCDOUT
	RCALL LCDOUT
	RCALL LCDOUT
	RCALL LCDOUT
	RCALL LCDOUT
	RCALL LCDOUT

	LDS R18, HR
		RCALL DIV10
		ORI R19, 0x30
		MOV R16, R19
		RCALL LCDOUT
		ORI R18, 0x30
		MOV R16, R18
		RCALL LCDOUT
		LDI R16, ':'
		RCALL LCDOUT

	LDS R18, MIN
		RCALL DIV10
		ORI R19, 0x30
		MOV R16, R19
		RCALL LCDOUT
		ORI R18, 0x30
		MOV R16, R18
		RCALL LCDOUT
		LDI R16, ':'
		RCALL LCDOUT
		
	LDS R18, SEG
		RCALL DIV10
		ORI R19, 0x30
		MOV R16, R19
		RCALL LCDOUT
		ORI R18, 0x30
		MOV R16, R18
		RCALL LCDOUT


		
	CBI PORTE,RS ; Command Mode RS = 0 A5
		LDI R16, 0x01
		RCALL LCDOUT
		SBI PORTE,RS ; Command Mode RS = 0 A5
	RET

SET_LCD:
			CBI PORTE,E ;Enable A7
            CBI PORTE,RS ; Command Mode RS = 0 A5

            RCALL DELAY_5ms
			RCALL DELAY_5ms
			RCALL DELAY_5ms
			LDI R16, 0x38
				RCALL LCDOUT				
			LDI R16, 0x38
				RCALL LCDOUT
			LDI R16, 0x38
				RCALL LCDOUT
			LDI R16, 0x38
				RCALL LCDOUT
			
			LDI R16, 0x08 ; Display OFF
				RCALL LCDOUT
			LDI R16, 0x01 ; Clear Display 
				RCALL LCDOUT			
			LDI R16, 0x06 ; Entry Mode Set 
				RCALL LCDOUT				
			LDI R16, 0x0C ; Display ON
				RCALL LCDOUT
			SBI PORTE, RS ; Character Mode RS = 1

		RET

LCDOUT: 	
			OUT DATA, R16
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



;--- Division ---
; 
DIV10:
	    CLR R19 ; DECENA
		

	CICLO: 
		CPI R18, 10
		BRLO ES10
		INC R19          
		SUBI R18,10      
		CPI R18, 10      
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
        LDI R16,0			; Timer1 CompareA Handler
        OUT TCNT1H,R16		;reiniciar timer
        OUT TCNT1L,R16
        
        LDI R16, 0x01
		EOR R17, R16
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
