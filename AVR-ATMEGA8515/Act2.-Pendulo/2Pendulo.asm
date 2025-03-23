; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; -------------- Pendulo --------------
; ------------- 06/10/2024 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
.include "M8515def.inc"
.equ TIME = 0x60
.def WREG = R16

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
	OUT SPH, WREG   
	LDI WREG,low(RAMEND) 
	OUT SPL, WREG  
	CLI     

	LDI WREG, 0xFF
	OUT DDRB, WREG  ;Set Outputs
	CBI DDRD, 2 ; Clear bit I/O Pin D2  in
	SBI PORTD,2 ; Set bit I/O (when is activated on an input is pull up)
	CBI DDRD, 3  
	SBI PORTD,3 

	LDI WREG,200 ; initial value of delay
	STS TIME, WREG

; ----------- Init -----------
INIT: 
	LDI WREG,0x01
M1:	
    COM WREG  ; Cast to output
	OUT PORTB, WREG
	COM WREG
	RCALL DELAY
	RCALL BOTONES
	LSL WREG ;Shift left
	BRNE M1 	;To prevent overflow

    LDI WREG,0x80
M2:
    COM WREG
    OUT PORTB, WREG
    COM WREG
    RCALL DELAY
    RCALL BOTONES
    LSR WREG
    BRNE M2

	RJMP INIT

;------------- Subrutines ------------- 

DELAY:
        LDS R19, TIME ; this is from SRAM
T3:
        LDI R18, 255
T2:   
        LDI R17, 8
T1:
        DEC R17
        BRNE T1
        DEC R18
        BRNE T2
        DEC R19
        BRNE T3
        RET


BOTONES:
        LDS R19,TIME ; this is from SRAM
        SBIS PIND,2  ; Skip if Bit  is Set 
	        RJMP B1
        SBIS PIND,3 ; Skif If Bit is Set
            RJMP B2
        RET

B1:     
        TST R19
        BREQ SAVE        
        DEC R19
        STS TIME, R19; Storage To Sram
        RET

B2: 
        CPI R19, 0xFF
        BREQ SAVE
        INC R19
        STS TIME, R19; Storage To Sram
        RET

SAVE:      
        STS TIME, R19; Storage To Sram
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