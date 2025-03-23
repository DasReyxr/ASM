.INCLUDE "M8515def.inc"
.cseg
.org 0x0000

; ---- Code Section  ----
RJMP CONFIG           
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

; ---- Configuracion ----
CONFIG:
    LDI R16, 0x04
    OUT SPH, R16           
    LDI R16, 0xFF
    OUT SPL, R16
    CLI
	;-- Set inputs --
    LDI R17, 0x00
    OUT DDRA, R17
    ;-- PULL UP--
	LDI R17, 0xFF
    OUT PORTA, R17	
	
	LDI R17, 0x00
    OUT DDRd, R17
	;-- PULL UP--
	LDI R17, 0xFF
    OUT PORTd, R17	


	;-- Set outputs --
	LDI R17, 0xFF
    OUT DDRC, R17
	

; ---- Main ----
AGAIN:
    IN R21, PINA
    IN R22, PIND
	COM R22
	COM R21
    CP R21, R22
    BREQ BLINK
    CP R21, R22
    BRSH ORPORT
    CP R21, R22
    BRLO ANDPORT
    RJMP AGAIN

BLINK:
    LDI R20, 0xFF
    OUT PORTC,R20
        LDI R19, 255 ; this is from SRAM
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

    LDI R20, 0x00
    OUT PORTC,R20
    LDI R19, 255 ; this is from SRAM
T32:
        LDI R18, 255
T22:   
        LDI R17, 8
T12:
        DEC R17
        BRNE T12
        DEC R18
        BRNE T22
        DEC R19
        BRNE T32
    RJMP AGAIN 

ORPORT:
    OR R20,R21
    OR R20,R22
    
    OUT PORTC, R20
    RJMP AGAIN

ANDPORT:
    LDI R20, 0xFF
    AND R20,R21
    AND R20,R22
    OUT PORTC, R20
    RJMP AGAIN


; ---- Delays ----



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
