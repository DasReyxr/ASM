; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ------------- 5 Stepper -------------
; ------------- 20/10/2024 -------------
; ---------------- Main ----------------
.include "M8515def.inc"
; ------------- Variables -------------
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
#define E 1
#define RS 	2

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

; DER : .db "--->"
; IZQ : .db "<---"
; ST  : .db "ROBER"
; ------ Configuration ------
SETCONFIG:
	LDI WREG,high(RAMEND)
	OUT SPH,WREG   ; Set Stack Pointer to top of RAM
	LDI WREG,low(RAMEND) ; Parte baja
	OUT SPL,WREG  ; Inicializar la pila
	CLI    ; Disable interrupts 

	;--- Pinout ---
	;---- RS-EN ----
	LDI WREG, 0x06 ; RS EN
		OUT DDRE, WREG
	;---- Stepper ----
	LDI WREG, 0x0F ; Stepper
		OUT DDRA, WREG
	
	;---- Buttons ----
	LDI WREG, 0x83
		OUT DDRD, WREG
	LDI WREG, 0xFF ; PULLUP
		OUT PORTD, WREG
	
	; D 0111 1100 7
	;   1000 0011 83

	LDI WREG,88
	STS TIME, WREG
	;------ Interruptions ----
	LDI WREG,0b00001010	;MCUCR = x x x x ISC11 ISC10 ISC01 ISC00 = flancos negativos
	OUT MCUCR,WREG		;		 0 0 0 0   1     0     1     0

	LDI WREG,0b11000000	;GICR = INT1 INT0 INT2 x x x x x
	OUT GICR,WREG		;        1     1    0  0 0 0 0 0
	SEI
	

; ----------- Init -----------
INIT: 

	RCALL LIAM

    RJMP INIT

;------------- Subrutines ------------- 
;--- Buttons ---
LIAM:

	SBIS PIND,4 ; Left
		RCALL CWVar
		
	SBIS PIND,5 ; Right
		RCALL CCWVar
		
	SBIS PIND, 6 ; Stop
		RCALL STOPVar
	
	
	LDS WREG, OPT
	TST WREG
		BREQ STOP
	CPI WREG, 1
		BREQ CW
	CPI WREG, 2
		BREQ CCW

	RET
;--- Speed ---
;---- Motor ----
STOPVar:
	LDI WREG, 0
		STS OPT, WREG
	RET

CWVar:
	LDI WREG, 1
		STS OPT, WREG
	RET

CCWVar:
	LDI WREG, 2
		STS OPT, WREG
	RET

CW:
		LDI WREG, 0x01
	CW1:	
		OUT PORTA, WREG
		RCALL DELAY_100ms
		LSL WREG
		SBIS PIND,5
		RJMP LIAM
		SBIS PIND, 6
		RJMP LIAM
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
		RJMP LIAM
		SBIS PIND, 6
		RJMP LIAM
		CPI WREG, 0x00
		BREQ CCW
		RJMP CCW1 
	
STOP:
	LDI WREG,0x00
		OUT PORTA, WREG
	SBIS PIND,4 ; Left
		RET
	SBIS PIND,5 ; Right
		RET
	
	RJMP STOP

; TRANSICION:
; 		LDI WREG,0x01
; 		STS TIMESTOP, WREG
; 	TR1:
; 		RCALL DELAY_AGUANTA
; 		LDS WREG,TIMESTOP
; 		INC WREG
; 		STS TIMESTOP,WREG
; 		CPI WREG, 0xFF
; 			RJMP INIT
; 		RJMP TRANSICION



;--- Division ---

DIV100:
	    CLR R19          
		LDI WREG, 0
		STS T_Cen, WREG
		STS T_Dec, WREG
		STS T_Uni, WREG
	CICLO1:
		CPI T_Time, 100
		BRLO ES100	

		INC R19          
		SUBI T_Time,100     
		CPI T_Time,100      
		
		BRPL CICLO1 

	SAVE1:     
		STS T_Cen, R19    ; Centenas
		CLR R19          

	CICLO2:
		CPI T_Time, 10
		BRLO ES10
		INC R19          
		SUBI T_Time,10      
		CPI T_Time, 10      
		BRPL CICLO2      

	SAVE2:
		STS T_Dec, R19    ; Decenas
		STS T_Uni, T_Time ; Unidades

		RET

	ES100:
		LDI R19, 0
		RJMP SAVE1

	ES10:
		LDI R19, 0
		RJMP SAVE2


;---- LCD ----

; ----- Delays ------

DELAY_100ms:
		LDS R19, TIME ; this is from SRAM
	TA3:
		LDI R18, 200
	TA2:   
		LDI R17, 80
	TA1:
		DEC R17
		BRNE TA1
		DEC R18
		BRNE TA2
		DEC R19
		BRNE TA3
		RET



DELAY_5ms:
		LDI		R19,15
	D2:
		LDI		R18,255
	D1:
		DEC 	R18			;12.2ms
		BRNE	D1	
		DEC		R19
		BRNE 	D2
		RET


; ------ Interrupciones ------ 
EXT_INT0:  
    LDS R22, TIME         
    CPI R22, 5         
    BRLO SAVE             
    SUBI R22, 11          
    CPI R22, 11            
    BRLO LIMIT_LOW        
    STS TIME, R22         
    RETI                  

LIMIT_LOW:
    LDI R22, 11            
    STS TIME, R22         
    RETI                  

EXT_INT1:  
    LDS R22, TIME         
    CPI R22, 0xFD         
    BRSH SAVE             
    SUBI R22, -11         
    CPI R22, 0xFF         
    BRSH LIMIT_HIGH       
    STS TIME, R22         
    RETI                  

LIMIT_HIGH:
    LDI R22, 0xFD         
    STS TIME, R22         
    RETI                  

SAVE: 
    STS TIME, R22         ; Store the current value of R22 to TIME
    RETI                  ; Return from interrupt



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
