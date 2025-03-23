;Programa que despliega una cadena en el LCD

.include "M8515def.inc"  

;DEFINICION DE VARIABLES CON REGISTROS 
.equ	var1	=0x60				;comentario
.def	var2	=r2


;defines para la libreria LCD
#define DATOS		PORTC		;puerto o bus de datos del LCD
#define dDATOS 		DDRC		;direccion del puerto de datos
#define CTRL		PORTA		;Puerto de bits de control E, R/W y RS
#define dCTRL		DDRA		;direccion del puerto de control
#define E			5			;pin E,  LCD Enable
#define RW			6			;pin RW, LCD Read/Write
#define RS			7			;pin RS, LCD data/command

;macros (seecion de codigo amigable)
#define SETE		sbi CTRL,E	;set E (sbi PORTA,5)
#define CLRE		cbi CTRL,E	;clr E
#define SETRW		sbi CTRL,RW	;set RW (sbi PORTA,6)
#define CLRRW		cbi CTRL,RW	;clr RW
#define SETRS		sbi CTRL,RS	;set RS (sbi PORTA,7)
#define CLRRS		cbi CTRL,RS	;clr RS

;constantes de funciones
#define CLCD_FUNCTION_SET	0x3C
#define CLCD_OFF			0x08
#define	CLCD_CLEAR			0x01
#define	CLCD_MODE_SET		0x06 ;LCD_MODE_SET 0x07 para corrimientos y 0x06 normal?
#define	CLCD_ON				0x0C
#define	CLCD_HOME			0x02
#define	CLCD_CURS_ON		0x0E
#define	CLCD_BLINK_ON		0x0D
#define	CLCD_SHIFT_RA		0x18
#define	CLCD_SHIFT_LA		0x1C
#define	CLCD_SHIFT_R		0x14
#define	CLCD_SHIFT_L		0x10



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


Cadena1: .db 	'H','o','l','a',' ','M','u','n','d','o',' ','U','A','A','.','.'

Cadena2: .db	"La UAA es bien chida"


;CONFIGURACION Y ARRANQUE DEL SISTEMA 
RESET: 		ldi r16,high(RAMEND) 	
			out SPH,r16 		; Set Stack Pointer to top of RAM
			ldi r16,low(RAMEND)	; Parte baja
			out SPL,r16			; Inicializar la pila
			cli 				; Disable interrupts

			;otras inicializaciones
			sbi	DDRB,0			;pin como salida para heartbeat
			ldi	R16,255
			sts	var1,R16

			rcall	LCD_Ini				;Inicializar display LCD
			ldi		zh,high(2*Cadena1)	;Apunta a Cadena1
			ldi		zl,low(2*Cadena1)	;Parte baja
			ldi		R16,16
			mov		R4,R16				;caracteres
			ldi		R16,1
			mov		R2,R16				;renglon
			ldi		R16,1
			mov		R3,R16				;columna
			rcall	LCD_String_Cte		;despliegue de cadena

			;Despliegue de un numero
			ldi		R16,2
			mov		R2,R16				;renglon
			ldi		R16,1
			mov		R3,R16				;columna
			rcall	LCD_Cursor
			ldi		R16, 127			;numero a desplegar
			rcall 	DISPLAY





;PROGRAMA CICLADO PRINCIPAL
MAIN:		;aqui van sus rutinas
			rcall 	LCD_Shift_RALL
			rcall 	DELAY
			sbi		PORTB,0				;heartbeat
			rcall 	LCD_Shift_RALL
			rcall 	DELAY
			cbi		PORTB,0
			rjmp MAIN			;regresa a MAIN (loop)


;*********************** SUBRUTINAS ***********************
DELAY:		lds		R19,var1
D3:			ldi		R18,255		;espectativa de 100ms
D2:			ldi		R17,8
D1:			dec		R17			;48.25us
			brne	D1
			dec 	R18			;12.2ms
			brne	D2	
			dec		R19
			brne	D3
			ret

;----------------------------------------------------------
DIV10:		ldi		R17,0		;R17(resultado), residuo(R16) = R16/10
	DI1:	inc		R17			
			subi	R16,10
			breq	DI2
			brsh	DI1
			subi	R16,-10
			dec		R17
	DI2:	ret

;----------------------------------------------------------
DISPLAY:	ldi		R17,' '		;R16 = numero a desplegar
			mov		R6,R17		;R6=' '  0x20
			mov		R5,R17		;R5=' '  0x20
			mov		R4,R17		;R4=' '  0x20

			cpi		R16,10		;solo un digito
			brlo	DIG1
			cpi		R16,100		;solo dos digitos
			brlo	DIG2	

	DIG3:	rcall	DIV10
			ori		R16,0x30
			mov		R6,R16
			
			mov		R16,R17
	DIG2:	rcall	DIV10
			ori		R16,0x30
			mov		R5,R16

			mov		R16,R17
	DIG1:	ori		R16,0x30
			mov		R4,R16

			mov		R16,R4
			rcall	LCD_WriteDATA
			mov		R16,R5
			rcall	LCD_WriteDATA
			mov		R16,R6
			rcall	LCD_WriteDATA

			ret
;----------------------------------------------------------

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




;*******************************************************************
;************************ LIBRERIA DEL LCD *************************
;*******************************************************************

;RECURSOS:
;Uso de R2,R3,R4 y R16
;puntero Z (R31:R30)

;----------------------------------------- USO -------------------------------------
;RUTINA				PARAMETROS										DESCRIPCIÓN
;LCD_Ini			no												;inicializar display
;LCD_WriteDATA		R16=caracter										;imprime un carcater en la posicion actual del cursor
;LCD_Clear			no												;limpiar display y dejar cursor inicial
;LCD_Home			no												;mandar cursor a posicion original
;LCD_Cursor_On		no												;poner cursor visible en el display
;LCD_Cursor_Off		no												;quitar cursor del display
;LCD_Display_Off	no												;apagar display
;LCD_Display_On		no												;prender display
;LCD_Blink_On		no												;activar parpadeo del cursor
;LCD_Shift_RALL		no												;Recorrer todo el LCD a la derecha
;LCD_Shift_LALL		no												;Recorrer todo el LCD a la izquierda
;LCD_Shift_R		no												;hacer 1 corrieminto a la derecha
;LCD_Shift_L		no												;hacer 1 corrimiento a la izquierda
;LCD_Cursor			R2=renglon, R3=columna							;Posiciona el cursor 
;LCD_String_Ram		R2=ren, R3=col, R1 = dir inicial, R4=longitud	;Escribe cadena variable (RAM)
;LCD_String_Ext		R2=ren, R3=col, Z  = dir inicial, R4=longitud	;Escribe cadena variable (RAM externa) 
;LCD_String_Cte		R2=ren, R3=col, Z  = dir inicial, R4=longitud	;Escribe cadena constante (ROM)
;----------------------------------------- USO -------------------------------------

LCD_Ini:		ldi		R16,0xFF	;Inicializar puertos
				out		dDATOS,R16	;Puerto como salida
				sbi		dCTRL,E		;pin PA5 como salida
				sbi		dCTRL,RW	;pin PA6 como salida
				sbi		dCTRL,RS	;pin PA7 como salida

				;inicializar display
				ldi		R16,CLCD_FUNCTION_SET
				rcall	LCD_WriteCTRL
				ldi		R16,CLCD_FUNCTION_SET
				rcall	LCD_WriteCTRL
				ldi		R16,CLCD_FUNCTION_SET
				rcall	LCD_WriteCTRL
				ldi		R16,CLCD_OFF
				rcall	LCD_WriteCTRL
				ldi		R16,CLCD_CLEAR
				rcall	LCD_WriteCTRL
				ldi		R16,CLCD_MODE_SET
				rcall	LCD_WriteCTRL
				ldi		R16,CLCD_ON
				rcall	LCD_WriteCTRL
				ldi		R16,CLCD_HOME
				rcall	LCD_WriteCTRL
				ret

LCD_Clear:		ldi		R16,CLCD_CLEAR
				rcall	LCD_WriteCTRL
				ret

LCD_Home:		ldi		R16,CLCD_HOME
				rcall	LCD_WriteCTRL
				ret

LCD_Cursor_On:	ldi		R16,CLCD_CURS_ON
				rcall	LCD_WriteCTRL
				ret

LCD_Cursor_Off:	ldi		R16,CLCD_ON			;quitar cursor del display
				rcall	LCD_WriteCTRL
				ret

LCD_Display_Off: ldi	R16,CLCD_OFF		;apagar display
				rcall	LCD_WriteCTRL
				ret

LCD_Display_On:	ldi		R16,CLCD_ON			;prender display
				rcall	LCD_WriteCTRL
				ret

LCD_Blink_On:	ldi		R16,CLCD_BLINK_ON 	;activar parpadeo del cursor
				rcall	LCD_WriteCTRL
				ret

LCD_Shift_RALL:	ldi		R16,CLCD_SHIFT_RA 	;Recorrer todo el LCD a la derecha
				rcall	LCD_WriteCTRL
				ret

LCD_Shift_LALL:	ldi		R16,CLCD_SHIFT_LA 	;Recorrer todo el LCD a la izquierda
				rcall	LCD_WriteCTRL
				ret

LCD_Shift_R:	ldi		R16,CLCD_SHIFT_R 	;hacer 1 corrieminto a la derecha
				rcall	LCD_WriteCTRL
				ret
	
LCD_Shift_L:	ldi		R16,CLCD_SHIFT_L 	;hacer 1 corrimiento a la izquierda
				rcall	LCD_WriteCTRL
				ret

LCD_Cursor:		mov		R16,R2				;Posiciona cursor, R2=renglon, R3=columna
				cpi		R16,1
				brne	LC2
				ldi		R16,0x7F			;0x7F = 0x80 - 0x01
				add		R16,R3				;pos = 0x80 + col - 1 = 0x7F + col
				rcall	LCD_WriteCTRL
				ret
	LC2:		cpi		R16,2				;renglon 2
				brne	LC3
				ldi		R16,0xBF			;para renglon 2
				add		R16,R3				;pos = 0xC0 + col - 1		
				rcall	LCD_WriteCTRL
	LC3:		ret


LCD_String_Cte:	rcall 	LCD_Cursor  		;Escribe cadena de texto cte (ROM), R2=ren, R3=col, Z=dir inicial, R4=longitud de cadena
		LCC:	lpm		R16,Z+				;leer byte(char) de flash
				rcall	LCD_WriteDATA		;desplegar caracter
				dec		R4
				brne	LCC
				ret

				 

LCD_WriteCTRL:	rcall	DDELAY		;esperar 5ms
				CLRE				;apagar E
				CLRRW				;apagar RW
				CLRRS				;apagar RS
				out		DATOS,R16	;funcion en el puerto
				SETE				;prender E
				nop
				nop
				CLRE				;apagar E
				ret

LCD_WriteDATA:	rcall	DDELAY		;esperar 5ms
				CLRE				;apagar E
				CLRRW				;apagar RW
				SETRS				;prender RS
				out		DATOS,R16	;dato en el puerto
				SETE				;prender E
				nop
				nop
				CLRE				;apagar E
				ret

DDELAY:			ldi		R18,255		;delay 5.004ms con xtal=16MHz
DD2:			ldi		R17,103
DD1:			dec		R17			;48.25us
				brne	DD1
				nop
				nop
				dec 	R18			;12.2ms
				brne	DD2	
				ret
