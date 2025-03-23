.INCLUDE "M8515def.inc"
; ---- Code Section  ----
.cseg
.org 0x0000
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
     
; ---- Data section ----
.org 0x0100          
CONFIG:  ;-- Set Stack Pointer
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
Main:
	in r16, pind
	in r17, pina
	com r16
	com r17
	
    cp r17, r16
	brlo RESTAR
	sub r17, r16
	out PORTC, r17       
    RJMP Main

RESTAR:
	sub r16, r17
	out PORTC, r16
	rjmp main



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
