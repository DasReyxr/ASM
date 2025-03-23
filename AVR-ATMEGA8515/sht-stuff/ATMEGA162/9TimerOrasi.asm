.include "M8515def.inc"  

;DEFINICION DE REGISTROS 
;Carga y descarga r16, r17, 18, 19
.def D1 = R2 
.def D2 = R3
.def D3 = R4 
.def D4 = R5 
; Contador R24
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

numbers:
    .db 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07
    .db 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71
    .db 0x00



SETCONFIG: 		
	ldi r16,high(RAMEND) 	
	out SPH,r16 		
	ldi r16,low(RAMEND)	
	out SPL,r16			
	cli 						 

    ; PORTA -> Yeaperdonen 4displays rap
	ldi R16, 0xFF
	out DDRA, R16
	ldi R16, 0x0F
	out DDRB, R16

	LDI R16,0xFF
	OUT DDRC,R16
	

	RCALL SET_TIMER



Main:
    ;Display unidades
	ldi r20, 0x01	; 0001
    com r20
    out PORTB, r20
	mov r1, D1
	Rcall Desplegar
	
	ldi r20, 0x02	;0010
	com r20
    out PORTB, r20
	mov r1, D2
	Rcall Desplegar
	
	ldi r20, 0x04	;0100
	com r20
    out PORTB, r20
	mov r1, D3
	Rcall Desplegar
	
	ldi r20, 0x08   ;1000	
	com r20
    out PORTB, r20
	mov r1, D4
	Rcall Desplegar
    
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
    ADD ZL, r1         ; Selecciona el índice en la tabla
    LPM r16, Z               ; Carga el patrón en temp
	;com r16
    OUT PORTA, r16
	ret

Contador:
	mov r16, D1
	inc r16
    mov D1, r16
	cpi r16,10
	    brne continue
	clr D1
	
    mov r17, D2 
	inc r17
    mov D2, r17	
	cpi r17,7
	    brne continue
	
    clr D2
	mov r18, D3 
	inc r18
	mov D3, r18

    add r18, D4
    cpi r18, 23
        breq reset_numbers  
	cpi r18,10
	    brne continue
	

    clr D3
	mov r19, D4 
	inc r19	
	mov D4, r19

	cpi r19,3 
	    brne continue
    ;23:59
    ;43 21
    reti

reset_numbers: 
    CLR D1
    CLR D2
    CLR D3
    CLR D4 
    RET
continue: 
	reti
	
SET_TIMER:
        LDI R16,0x3D	;F4
        OUT OCR1AH,R16
        OUT OCR1BH,R16
        LDI R16,0x09	;24
        OUT OCR1AL,R16
        OUT OCR1BL,R16
        LDI R16,0x40	
        OUT TCCR1A,R16	;Toggle OC1A cada compare match, modo normal
        LDI R16,0x0C
        OUT TCCR1B,R16	;modo CTC, start

        ;interrupciones para el timer en OCR1A
        LDI R16,0x40
        OUT TIMSK,R16
        SEI				;mascara general de interrupciones
        RET




; ------ Interrupciones ------ 

EXT_INT0: 	
		RETI				

EXT_INT1: 	
		RETI	

TIM1_CAPT:  RETI    ; Timer1 Capture Handler 



TIM1_COMPA:	
        LDI R16,0xFF
			OUT PORTC,R16

		LDI R16,0			; Timer1 CompareA Handler
        OUT TCNT1H,R16		;reiniciar timer
        OUT TCNT1L,R16
       
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
