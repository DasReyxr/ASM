; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ---------- Matrix Keyboard ----------
; ------------- 13/12/2024 -------------
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

;numbers:.db 0b00111111 ,0b00000110, 0b01011011, 0b01001111, 0b01100110,0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111, 0b01110111, 0b01111100, 0b00111001, 0b01011110, 0b01111001, 0b01110001, 0b00000000
;numbers: .db 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71, 0x6F, 0x00
numbers:
.db 0x3F ; 0
    .db 0x06 ; 1
    .db 0x5B ; 2
    .db 0x4F ; 3
    .db 0x66 ; 4
    .db 0x6D ; 5
    .db 0x7D ; 6
    .db 0x07 ; 7
    .db 0x7F ; 8
    .db 0x6F ; 9
    .db 0x77 ; A
    .db 0x7C ; b
    .db 0x39 ; C
    .db 0x5E ; d
    .db 0x79 ; E
    .db 0x71 ; F

; ------ Configuration ------
SETCONFIG:
	LDI R16,high(RAMEND)
	OUT SPH,R16   ; Set Stack Pointer to top of RAM
	LDI R16,low(RAMEND) ; Parte baja
	OUT SPL,R16  ; Inicializar la pila
    
    
    LDI R16, 0x00 ; Input
    OUT DDRC, R16
    LDI R16, 0xFF
    OUT PORTC, R16 
    LDI R17,0x11

    LDI R16, 0xFF ; Output
    OUT DDRA, R16
    OUT DDRB, R16    
    
    
	CLI    ; Disable interrupts 

; ----------- Init -----------
INIT: 
    
    RCALL SEQUENCER
    RCALL DELAY
    RJMP INIT

;------------- Subrutines ------------- 

SEQUENCER: 
    LDI R16, 0x08
    OUT PORTA, R16
    
    CPI R16, 0x08 
    BREQ C0 
L1:    
    
    LDI R16, 0x04
    OUT PORTA, R16
    
    CPI R16, 0x04 
    BREQ C1 
L2:    
    LDI R16, 0x02
    OUT PORTA, R16

    CPI R16, 0x02
    BREQ C2
L3:
    LDI R16, 0x01
    OUT PORTA, R16
    
    CPI R16,0x01
    BREQ C3
    RET

C0:
    SBIS PINC, 0
        RCALL B0
    
    SBIS PINC, 1
        RCALL B1

    SBIS PINC, 2
        RCALL B2
    
    SBIS PINC, 3
        RCALL B3

    RJMP L1

C1:
    SBIS PINC, 0
        RCALL B4
    
    SBIS PINC, 1
        RCALL B5

    SBIS PINC, 2
        RCALL B6
    
    SBIS PINC, 3
        RCALL B7
    RJMP L2

C2:
    SBIS PINC, 0
        RCALL B8
    
    SBIS PINC, 1
        RCALL B9

    SBIS PINC, 2
        RCALL B10
    
    SBIS PINC, 3
        RCALL B11
    RJMP L3
C3:
    SBIS PINC, 0
        RCALL B12
    
    SBIS PINC, 1
        RCALL B13

    SBIS PINC, 2
        RCALL B14
    
    SBIS PINC, 3
        RCALL B15
    RJMP SEQUENCER
DISPLAY:
    LDI ZH, high(numbers*2) ; Apunta a la tabla (parte alta del puntero)
    LDI ZL, low(numbers*2)  ; Apunta a la tabla (parte baja del puntero)
    ADD ZL, r17         ; Selecciona el índice en la tabla
    LPM r16, Z               ; Carga el patrón en temp
	OUT PORTB, r16
    RCALL HALF_SEC_DELAY
LOOP:
    IN R20, PORTC
    CPI R20,0xFF
    BRNE LOOP
    RET

B0:
    LDI R17,0
    RCALL DISPLAY
    RET
B1:
    LDI R17,1
    RCALL DISPLAY
    RET
B2:
    LDI R17,2
    RCALL DISPLAY
    RET
B3:
    LDI R17,3
    RCALL DISPLAY
    RET
B4:
    LDI R17,4
    RCALL DISPLAY
    RET
B5:
    LDI R17,5
    RCALL DISPLAY
    RET
B6:
    LDI R17,6
    RCALL DISPLAY
    RET
B7:
    LDI R17,7
    RCALL DISPLAY
    RET
B8:
    LDI R17,8
    RCALL DISPLAY
    RET
B9:
    LDI R17,9
    RCALL DISPLAY
    RET
B10:
    LDI R17,10
    RCALL DISPLAY
    RET
B11:
    LDI R17,11
    RCALL DISPLAY
    RET
B12:
    LDI R17,12
    RCALL DISPLAY
    RET
B13:
    LDI R17,13
    RCALL DISPLAY
    RET
B14:
    LDI R17,14
    RCALL DISPLAY
    RET
B15:
    LDI R17,15
    RCALL DISPLAY
    RET

; Subroutine for 1/2 second delay (16 MHz clock)
HALF_SEC_DELAY:
    LDI R20, 100       ; Outer loop count (100 iterations)
OUTER_LOOP:
    LDI R21, 20       ; Inner loop count (100 iterations)
INNER_LOOP:
    LDI R22, 80        ; Innermost loop count (80 iterations)
INNERMOST_LOOP:
    NOP                ; No operation (1 clock cycle)
    DEC R22            ; Decrement innermost loop counter
    BRNE INNERMOST_LOOP; Repeat until R22 = 0
    DEC R21            ; Decrement inner loop counter
    BRNE INNER_LOOP    ; Repeat until R21 = 0
    DEC R20            ; Decrement outer loop counter
    BRNE OUTER_LOOP    ; Repeat until R20 = 0
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
