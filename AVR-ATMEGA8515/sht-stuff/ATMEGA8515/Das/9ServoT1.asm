; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; --------------- 9Servo ---------------
; ------------- 18/11/2024 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
;  0 - 1 ms
; 180 - 2 ms
; 45   1+ 45/180 = 1.25
; with xTal as 16 MHz 
; 1.25 *10**-3 * (16*10**6)/256


.include "M8515def.inc"
.def WREG =R16
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
	SBI DDRB,0
	SBI DDRC,0
	
	
	RCALL SET_PWM
	
; ----------- Init -----------
INIT: 
	RCALL GIRAR_DER
	RCALL Herbie
	RJMP INIT

;------------- Subrutines ------------- 

Herbie:
	LDI WREG,0x01
	OUT PORTC,WREG
	RCALL DELAYmedio
	LDI WREG,0x00
	OUT PORTC,WREG
	RCALL DELAYmedio
	RET
SET_PWM:
    ; Configure Fast PWM mode with ICR1 as TOP
    LDI WREG, (1 << WGM13) | (1 << WGM12)
    OUT TCCR1B, WREG
    LDI WREG, (1 << WGM11)
    OUT TCCR1A, WREG

    ; Set non-inverted mode for OC1A (COM1A1 = 1, COM1A0 = 0)
    LDI WREG, (1 << COM1A1)
    OUT TCCR1A, WREG

    ; Set prescaler to 8
    LDI WREG, (1 << CS11)
    OUT TCCR1B, WREG

    ; Set TOP value for 50 Hz (20 ms period)
    LDI WREG, LOW(39999)  ; ICR1 = 39999 for 50 Hz
    OUT ICR1L, WREG
    LDI WREG, HIGH(39999)
    OUT ICR1H, WREG

    SEI    ; Enable global interrupts
    RET

GIRAR_IZQ:
    ; Set OCR1A for 0° (1 ms pulse)
    LDI WREG, LOW(2000)
    OUT OCR1AL, WREG
    LDI WREG, HIGH(2000)
    OUT OCR1AH, WREG
    RET

GIRAR45:
    ; Set OCR1A for 45° (1.25 ms pulse)
    LDI WREG, LOW(2500)
    OUT OCR1AL, WREG
    LDI WREG, HIGH(2500)
    OUT OCR1AH, WREG
    RET

GIRAR_DER:
    ; Set OCR1A for 180° (2 ms pulse)
    LDI WREG, LOW(4000)
    OUT OCR1AL, WREG
    LDI WREG, HIGH(4000)
    OUT OCR1AH, WREG
    RET

DELAYmedio:
		LDI R19, 255 ; this is from SRAM
	TA3:
		LDI R18, 255
	TA2:   
		LDI R17, 20
	TA1:
		DEC R17
		BRNE TA1
		DEC R18
		BRNE TA2
		DEC R19
		BRNE TA3
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
