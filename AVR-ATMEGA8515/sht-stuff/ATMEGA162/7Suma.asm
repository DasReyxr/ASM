.INCLUDE "M8515def.inc"
.cseg
.org 0x0000

; ---- Code Section  ----
RJMP CONFIG           

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
    LDI R20, 0x00
    IN R18, PINA
    IN R19, PIND
	COM R18
	COM R19
    ADD R20, R18
    ADD R20, R19
    
    BRCS BLINK

    OUT PORTC, R20
    
    RJMP AGAIN


BLINK:
    LDI R20, 0xFF
    OUT PORTC,R20
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



; ---- Delays ----
