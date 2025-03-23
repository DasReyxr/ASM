; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ---------------- Led ----------------
; ------------- 20/09/2024 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
.include "M8515def.inc"
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
	LDI r16,high(RAMEND)
	OUT SPH,r16   ; Set Stack Pointer to top of RAM
	LDI r16,low(RAMEND) ; Parte baja
	OUT SPL,r16  ; Inicializar la pila
	cli    ; Disable interrupts 
	LDI R16, 0x02
	OUT DDRB, R16
; ----------- Init -----------
INIT: 
	LDI R16, 0x02
	OUT PORTB, R16
	LDI R17, 0x00
	OUT PORTB, R17
	RJMP INIT

;------------- Subrutines ------------- 

BOTONES:
	ret


; ------ Interrupciones ------ 
EXT_INT0:  reti    ; IRQ0 Handler 
EXT_INT1:  reti    ; IRQ1 Handler 
TIM1_CAPT:  reti    ; Timer1 Capture Handler 
TIM1_COMPA: reti    ; Timer1 CompareA Handler 
TIM1_COMPB: reti    ; Timer1 CompareB Handler 
TIM1_OVF:  reti    ; Timer1 Overflow Handler 
TIM0_OVF:  reti    ; Timer0 Overflow Handler 
SPI_STC:  reti    ; SPI Transfer Complete Handler 
USART_RXC:  reti    ; USART RX Complete Handler 
USART_UDRE: reti    ; UDR Empty Handler 
USART_TXC:  reti    ; USART TX Complete Handler 
ANA_COMP:  reti    ; Analog Comparator Handler 
EXT_INT2:  reti    ; IRQ2 Handler 
TIM0_COMP:  reti    ; Timer0 Compare Handler 
EE_RDY:  reti    ; EEPROM Ready Handler 
SPM_RDY:  reti    ; Store Program Memory Ready Handler
