; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; -------------- Pendulo --------------
; ------------- 03/10/2024 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
.include "M8515def.inc"
.equ var1 =0x60
.def aux =r16

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
    LDI aux,200
    STS var1, aux
    
    LDI aux,0xFF
    OUT DDRB,aux
;--- DDRX inicia direccion 0 entrada y 1 salida
;--- PORTX salida o pull up (entrada) 1
;--- PINX leer puerto (Solamente viene en la datasheet)

    CBI DDRD,2  ; Pin puerto d2 como entrada
    SBI PORTD,2 ; Pull up en 2
    CBI DDRD,3  ;
    SBI PORTD,3 ; Pull up en 3

; ----------- Init -----------
INIT: 
    LDI aux,0b00000001
    OUT PORTB, aux ;se usa out cuando es registro 
    RCALL boton
    RCALL delay
    
    LDI aux,0b00000010
    OUT PORBT, aux
    RCALL boton
    RCALL delay

    LDI aux,0b00000100
    OUT PORBT, aux
    RCALL boton
    RCALL delay

    LDI aux,0b00001000
    OUT PORBT, aux
    RCALL boton
    RCALL delay

    LDI aux,0b00010000
    OUT PORBT, aux
    RCALL boton
    RCALL delay

    LDI aux,0b00100000
    OUT PORBT, aux
    RCALL boton
    RCALL delay

    LDI aux,0b01000000
    OUT PORBT, aux
    RCALL boton
    RCALL delay

    LDI aux,0b10000000
    OUT PORBT, aux
    RCALL boton
    RCALL delay



	RJMP INIT

;------------- Subrutines ------------- 

BOTONES:
	ret


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
