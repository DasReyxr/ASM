.include "M8515def.inc"  

;DEFINICION DE REGISTROS 
.equ D1 = 0x60
.equ D2 = 0x61
.equ D3 = 0x62
.equ D4 = 0x64
.def WREG = R16

;El registro r16, r18, r19 se usa como scratch


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
;CONFIGURACION Y ARRANQUE DEL SISTEMA 
numbers:.db 0b00111111 ,0b00000110, 0b01011011, 0b01001111, 0b01100110,0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111
;Inicializacion de D1, D2, D3 y D4

ldi WREG,0
sts D1, WREG
sts D2, WREG
sts D3, WREG
sts D4, WREG


SETCONFIG: 		
	ldi r16,high(RAMEND) 	
	out SPH,r16 		; Set Stack Pointer to top of RAM
	ldi r16,low(RAMEND)	; Parte baja
	out SPL,r16			; Inicializar la pila
	cli 				; Disable interrupts		 

	ldi R16, 0xFF
	out DDRA, R16
	ldi R16, 0x0F
	out DDRB, R16

	LDI WREG,0xFF
	OUT DDRC,WREG
	

	RCALL SET_TIMER

			
;* Inicializaciones *


Main:
	
	;rcall herbie
	;Display unidades
    ldi r16, 0x00       ; Turn off all displays
    out PORTB, r16
	OUT PORTC,WREG

    ; Display D4 (units of seconds)
    lds r24, D4         ; Load data for D4
    rcall Desplegar     ; Send data to 7-segment
    ldi r16, 0x08        ; Enable D4
    
    out PORTB, r16

    ; Disable all displays
    ldi r16, 0x00       ; Turn off all displays
    out PORTB, r16

    ; Display D3 (tens of seconds)
    lds r24, D3         ; Load data for D3
    rcall Desplegar     ; Send data to 7-segment
    ldi r16, 0x04      ; Enable D3
    
    out PORTB, r16

    ; Disable all displays
    ldi r16, 0x00       ; Turn off all displays
    out PORTB, r16

    ; Display D2 (units of minutes)
    lds r24, D2         ; Load data for D2
    rcall Desplegar     ; Send data to 7-segment
    ldi r16, 0x02       ; Enable D2
    
    out PORTB, r16

    ; Disable all displays
    ldi r16, 0x00       ; Turn off all displays
    out PORTB, r16

    ; Display D1 (tens of minutes)
    lds r24, D1         ; Load data for D1
    rcall Desplegar     ; Send data to 7-segment
    ldi r16, 0x01       ; Enable D1
    
    out PORTB, r16

    cpi r24, 2          ; Example condition to control motor
    breq MOTOR_ON
    cbi PORTE, 2
    rjmp Main


MOTOR_ON: 
	SBI PORTE,2
	RJMP main


Desplegar: 
	LDI ZH, high(numbers*2) ; Apunta a la tabla (parte alta del puntero)
    LDI ZL, low(numbers*2)  ; Apunta a la tabla (parte baja del puntero)
    ADD ZL, r24         ; Selecciona el índice en la tabla
    LPM r16, Z               ; Carga el patrón en temp
	com r16
    OUT PORTA, r16
	ret

Contador:
	lds r20,D1
	lds r21,D2
	lds r22,D3
	lds r23,D4
	
	inc r20
	cpi r20,10
	brne continue
	ldi r20, 0
	inc r21	
	cpi r21,7
	brne continue
	ldi r21, 0
	inc r22
	cpi r22,10
	brne continue
	ldi r22, 0
	inc r23	
	cpi r23,7
	brne continue
	ldi r23, 0
	sts D1, r20
	sts D2, r21
	sts D3, r22
	sts D4, r23
	
	reti
		
continue: 			
	sts D1, r20
	sts D2, r21
	sts D3, r22
	sts D4, r23
	
reti
	
SET_TIMER:
        LDI WREG,0x3D	;F4
        OUT OCR1AH,WREG
        OUT OCR1BH,WREG
        LDI WREG,0x09	;24
        OUT OCR1AL,WREG
        OUT OCR1BL,WREG
        LDI WREG,0x40	
        OUT TCCR1A,WREG	;Toggle OC1A cada compare match, modo normal
        LDI WREG,0x0C
        OUT TCCR1B,WREG	;modo CTC, start

        ;interrupciones para el timer en OCR1A
        LDI WREG,0x40
        OUT TIMSK,WREG
        SEI				;mascara general de interrupciones
    RET




; ------ Interrupciones ------ 

EXT_INT0: 	
		RETI				

EXT_INT1: 	
		RETI	

TIM1_CAPT:  RETI    ; Timer1 Capture Handler 



TIM1_COMPA:	
        LDI WREG,0xFF
			OUT PORTC,WREG

		LDI WREG,0			; Timer1 CompareA Handler
        OUT TCNT1H,WREG		;reiniciar timer
        OUT TCNT1L,WREG
       
		RCALL Contador
        
		RETI 
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
