
;Programa que guarda 10 numeros entre 0 y 100 a partir de la localidad 0x60 en RAM
;despues obtiene el promedio de los 10 y guarda el resultado en la localidad 0x70 en RAM
;la división se hace por restas sucesivas
;NOTA: valor maximo en un byte(char) es de 255, en 16 bits (entero) es de 65536

;Multiplicacion por sumas sucesivas: 34 x 6 = 34 + 34 + 34 + 34 + 34 + 34
;Division por restas sucesivas:      20 / 6 = 20-6=14, 14-6=8, 8-6=2, 2-6=0
;                    contador                    1        2      3     no   
;		por lo tanto 20/6 = 3
        

.include "M8515def.inc"  

;DEFINICION DE VARIABLES CON REGISTROS 
.def	var1	=r1				;comentario
.def	var2	=r2

;VECTOR DE INTERRUPCIONES
			rjmp RESET 			; Reset Handler
			rjmp EXT_INT0 		; IRQ0 Handler
			rjmp EXT_INT1 		; IRQ1 Handler
			rjmp TIM1_CAPT 		; Timer1 Capture Handler
			rjmp TIM1_COMPA 	; Timer1 CompareA Handler
			rjmp TIM1_COMPB 	; Timer1 CompareB Handler
			rjmp TIM1_OVF 		; Timer1 Overflow Handler
			rjmp TIM0_OVF 		; Timer0 Overflow Handler
			rjmp SPI_STC 		; SPI Transfer Complete Handler
			rjmp USART_RXC 		; USART RX Complete Handler
			rjmp USART_UDRE 	; UDR Empty Handler
			rjmp USART_TXC 		; USART TX Complete Handler
			rjmp ANA_COMP		; Analog Comparator Handler
			rjmp EXT_INT2		; IRQ2 Handler						(no AT90S8515)
			rjmp TIM0_COMP		; Timer0 Compare Handler			(no AT90S8515)
			rjmp EE_RDY 		; EEPROM Ready Handler				(no AT90S8515)
			rjmp SPM_RDY 		; Store Program Memory Ready Handler(no AT90S8515)


;CONFIGURACION Y ARRANQUE DEL SISTEMA 
RESET: 		ldi r16,high(RAMEND) 	
			out SPH,r16 		; Set Stack Pointer to top of RAM
			ldi r16,low(RAMEND)	; Parte baja
			out SPL,r16			; Inicializar la pila
			cli 				; Disable interrupts		 

			;otras inicializaciones
			;guardar 10 numeros en RAM
			LDI	R16,35
			STS 0x60,R16
			LDI R16,80
			STS 0x61,R16
			LDI R16,75
			STS 0x62,R16
			LDI R16,100
			STS 0x63,R16			
			LDI R16,100
			STS 0x64,R16		
			LDI R16,95
			STS 0x65,R16
			LDI R16,0
			STS 0x66,R16
			LDI R16,60
			STS 0x67,R16
			LDI R16,64
			STS 0x68,R16
			LDI R16,78
			STS 0x69,R16

			RCALL PROMEDIO


;PROGRAMA CICLADO PRINCIPAL
MAIN:		;aqui van sus rutinas
			

			
			rjmp MAIN			;regresa a MAIN (loop)


;*********************** SUBRUTINAS ***********************
;usar R17:R16 + R19:R18 para sumas de 16 bits
PROMEDIO:		CLR R16		;parte baja de la suma
			CLR R17		;parte alta de la suma
			CLR R19		;parte alta del numero a sumar
			LDI	R20,10	;contador hasta 10
			LDI ZH,0x00	;parte alta de puntero
			LDI ZL,0x60 ;parte baja de puntero Z=0x0060

	PROM1:		LD 	R18,Z+	;carga con postincremento, Z se incrementa despues solo
			ADD R16,R18	;suma partes bajas
			ADC R17,R19	;suma partes altas
			DEC R20		;decrementa contador
			BRNE PROM1	;regresa si contador no vale cero

			;division por restas sucesivas suma/10
			LDI R20,0
			MOV R24,R16
			MOV R25,R17
						
	PROM2:  	INC  R20
			SBIW R24,10 	;R25:R24 = R25:R24 - 10
			BREQ PROM3
			BRPL PROM2 
			DEC  R20		
	PROM3:	RET



;INTERRUPCIONES
EXT_INT0: 	reti				; IRQ0 Handler
EXT_INT1: 	reti				; IRQ1 Handler
TIM1_CAPT: 	reti				; Timer1 Capture Handler
TIM1_COMPA:	reti				; Timer1 CompareA Handler
TIM1_COMPB:	reti				; Timer1 CompareB Handler
TIM1_OVF: 	reti				; Timer1 Overflow Handler
TIM0_OVF: 	reti				; Timer0 Overflow Handler
SPI_STC: 	reti				; SPI Transfer Complete Handler
USART_RXC: 	reti				; USART RX Complete Handler
USART_UDRE:	reti				; UDR Empty Handler
USART_TXC: 	reti				; USART TX Complete Handler
ANA_COMP: 	reti				; Analog Comparator Handler
EXT_INT2: 	reti				; IRQ2 Handler
TIM0_COMP: 	reti				; Timer0 Compare Handler
EE_RDY: 	reti				; EEPROM Ready Handler
SPM_RDY: 	reti				; Store Program Memory Ready Handler


