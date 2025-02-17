; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ------------- 5 Stepper -------------
; ------------- 20/10/2024 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
.include "M8515def.inc"
.equ TIME = 0x62
.equ TIMESTOP = 0x61
.def WREG = R16 

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

	;--- Pinout ---
	LDI WREG, 0xFF ; LCD
		OUT DDRC, WREG
	LDI WREG, 0x06 ; RS EN
		OUT DDRE, WREG
	LDI WREG, 0x0F ; Stepper
		OUT DDRA, WREG
	
	LDI WREG, 0x87
		OUT DDRD, WREG
	LDI WREG, 0xFF ; PULLUP
		OUT PORTD, WREG
	; D 0111 1000 78
	;   1000 0111 87
	LDI WREG,0x00
	STS TIMESTOP, WREG
	LDI WREG, 125
	STS TIME, WREG




; ----------- Init -----------
INIT: 
	SBIS PIND,4 ; Left
		RCALL CWVar
		;RJMP CW
	SBIS PIND,5 ; Right
		RCALL CCWVar
		;RJMP CCW
	
	SBIS PIND, 6 ; Stop
		RCALL STOPVar
	

	LDS WREG, 0x60
	TST WREG
		BREQ STOP
	CPI WREG, 1
		BREQ CW
	CPI WREG, 2
		BREQ CCW
	
    RJMP INIT

;------------- Subrutines ------------- 
;--- Buttons ---
LIAM:

	RJMP LIAM


;---- Motor ----
STOPVar:
	LDI WREG, 0
		STS 0x60, WREG
	RET


CWVar:
	LDI WREG, 1
		STS 0x60, WREG
	RET

CCWVar:
	LDI WREG, 2
		STS 0x60, WREG
	RET



CW:
	LDI WREG, 0x01
CW1:	
	OUT PORTA, WREG
	RCALL DELAY_100ms
	LSL WREG
	SBIS PIND,5
	RET
	SBIS PIND, 6
	RET
	CPI WREG, 0x10
	BREQ CW
	RJMP CW1 




CCW:
	LDI WREG, 0x08
		
CCW1:	
	OUT PORTA, WREG
	RCALL DELAY_100ms
	LSR WREG
	SBIS PIND,4
	RET
	SBIS PIND, 6
	RET
	CPI WREG, 0x00
	BREQ CCW
	RJMP CCW1 
	

STOP:
	LDI WREG,0x00
		OUT PORTA, WREG
	SBIS PIND,4 ; Left
		RET
		;RJMP CW
	SBIS PIND,5 ; Right
		RET
		;RJMP CCW

	RJMP STOP	

TRANSICION:
	RCALL DELAY_AGUANTA
	LDS WREG,TIMESTOP
	INC WREG
	STS TIMESTOP,WREG
	CPI WREG, 0xFF
		RET
	RJMP TRANSICION


; ----- Delays ------

DELAY_100ms:
        LDS R19, TIME ; this is from SRAM
T3:
        LDI R18, 255
T2:   
        LDI R17, 4
T1:
        DEC R17
        BRNE T1
        DEC R18
        BRNE T2
        DEC R19
        BRNE T3
        RET

DELAY_AGUANTA:
		LDS R20, TIMESTOP
TA4:
        LDS R19, TIME ; this is from SRAM
TA3:
        LDI R18, 255
TA2:   
        LDI R17, 4
TA1:
        DEC R17
        BRNE TA1
        DEC R18
        BRNE TA2
        DEC R19
        BRNE TA3
		DEC R20
		BRNE TA4
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
USART_RXC:  RETI    ; USART RX Complete Handler 
USART_UDRE: RETI    ; UDR Empty Handler 
USART_TXC:  RETI    ; USART TX Complete Handler 
ANA_COMP:  RETI    ; Analog Comparator Handler 
EXT_INT2:  RETI    ; IRQ2 Handler 
TIM0_COMP:  RETI    ; Timer0 Compare Handler 
EE_RDY:  RETI    ; EEPROM Ready Handler 
SPM_RDY:  RETI    ; Store Program Memory Ready Handler