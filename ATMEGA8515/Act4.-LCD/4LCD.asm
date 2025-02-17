; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ---------------- LCD  ----------------
; ------------- 15/10/2024 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
.include "M8515def.inc"
.def WREG =R17


; --- Interruptions Config ---
RJMP CONFIG   ; Reset Handler  
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
CONFIG:
	LDI WREG,high(RAMEND)
	OUT SPH,WREG   ; Set Stack Pointer to top of RAM
	LDI WREG,low(RAMEND) ; Parte baja
	OUT SPL,WREG  ; Inicializar la pila
	CLI    ; Disable interrupts 
	
	
	;---- Set Outputs ----
	LDI WREG, 0xFF
		OUT DDRC, WREG
	LDI WREG, 0xC0
		OUT DDRA, WREG


	RCALL SET_LCD
; ----------- Init -----------
INIT: 
		CBI PORTA,6 ; Command Mode RS = 0 A5
		LDI WREG, 0x02 ; Display OFF
		RCALL LCDOUT
		SBI PORTA,6 ; Command Mode RS = 0 A5

		
		LDI WREG, 0x1C;0b 0001 1011 1
		RCALL LCDOUT
		LDI WREG, 'r' 
		RCALL LCDOUT
		LDI WREG, 'l' 
		RCALL LCDOUT
		LDI WREG, 'a' 
		RCALL LCDOUT
		LDI WREG, 'n' 
		RCALL LCDOUT
		LDI WREG, 'd' 
		RCALL LCDOUT
		LDI WREG, 'o' 
		RCALL LCDOUT
		LDI WREG, ' ' 
		RCALL LCDOUT
		LDI WREG, 'R' 
		RCALL LCDOUT
		LDI WREG, 'e' 
		RCALL LCDOUT
		LDI WREG, 'y' 
		RCALL LCDOUT
		LDI WREG, 'e' 
		RCALL LCDOUT
		LDI WREG, 's' 
		RCALL LCDOUT
		LDI WREG, ' ' 
		RCALL LCDOUT
		LDI WREG, '1' 
		RCALL LCDOUT
		LDI WREG, '0' 
		RCALL LCDOUT

		


		CBI PORTA,6 ; Command Mode RS = 0 A5
		LDI WREG, 0xC0 ; 2nd Line
		RCALL LCDOUT
		SBI PORTA,6 ; Command Mode RS = 0 A5
	
		LDI WREG, 'E' 
		RCALL LCDOUT
		LDI WREG, 'm' 
		RCALL LCDOUT
		LDI WREG, 'i' 
		RCALL LCDOUT
		LDI WREG, 'l' 
		RCALL LCDOUT
		LDI WREG, 'i' 
		RCALL LCDOUT
		LDI WREG, 'o' 
		RCALL LCDOUT
		LDI WREG, ' ' 
		RCALL LCDOUT
		LDI WREG, 'P' 
		RCALL LCDOUT
		LDI WREG, 'e'
		RCALL LCDOUT
		LDI WREG, 'r'
		RCALL LCDOUT
		LDI WREG, 'e'
		RCALL LCDOUT
		LDI WREG, ' '
		RCALL LCDOUT
		LDI WREG, '1'
		RCALL LCDOUT
		LDI WREG, '0'
		RCALL LCDOUT

		

	RJMP INIT

;------------- Subrutines ------------- 

SET_LCD:
			CBI PORTA,7 ;Enable A7
            CBI PORTA,6 ; Command Mode RS = 0 A5

            RCALL DELAY_5ms
			RCALL DELAY_5ms
			RCALL DELAY_5ms
			LDI WREG, 0x38
				RCALL LCDOUT				
			LDI WREG, 0x38
				RCALL LCDOUT
			LDI WREG, 0x38
				RCALL LCDOUT
			LDI WREG, 0x38
				RCALL LCDOUT
			
			LDI WREG, 0x08 ; Display OFF
				RCALL LCDOUT
			LDI WREG, 0x01 ; Clear Display 
				RCALL LCDOUT			
			LDI WREG, 0x06 ; Entry Mode Set 
				RCALL LCDOUT				
			LDI WREG, 0x0C ; Display ON
				RCALL LCDOUT
			SBI PORTA, 6 ; Character Mode RS = 1

		RET


LCDOUT: 	
			OUT PORTC, WREG
			SBI PORTA,7 
			RCALL DELAY_5ms
			CBI PORTA,7 
			RET

DELAY_5ms:
		 	LDI		R19,157
D2:			LDI		R18,255
D1:			DEC 	R18			;12.2ms
			BRNE	D1	
			DEC		R19
			BRNE 	D2
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