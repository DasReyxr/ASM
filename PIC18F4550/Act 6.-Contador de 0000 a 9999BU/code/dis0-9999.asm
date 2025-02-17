; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ------------ Display0-999 ------------
; ------------- 03/03/2021 -------------
; ------------- Variables -------------
; ---------------- Main ----------------

		#INCLUDE "P18F452.INC"
		LIST P=18F452
;---------- CONFIGURACI�N DE FUSIBLES DEL PROCESADOR -----------------
 __CONFIG _CONFIG1H, _HS_OSC_1H
 __CONFIG _CONFIG2L, _BOR_OFF_2L & _PWRT_ON_2L
 __CONFIG _CONFIG2H, _WDT_OFF_2H	
	
;--------- DECLARACION DE VARIABLES TIPO BIT -------------------------
#DEFINE B_UP PORTB,0,0
;--------- ECLARACION DE VARIABLES TIPO BYTE -------------------------
T1	EQU	21H
T2	EQU	22H
T3	EQU 23H
UN  EQU 30H
DEC EQU 31H
CEN EQU 32H
MIL EQU 33H

;---------- VECTOR DE PROGRAMA PRINCIPAL------------------------------
			ORG		0000H
			CALL	SET_OUTPUTS
			BRA		INICIO
				
;------------ PROGRAMA PRINCIPAL -------------------------------------
INICIO			CLRF MIL,0
				CLRF CEN,0
				CLRF DEC,0
				CLRF UN,0
ET_1			CALL DISP
				BTFSS B_UP ;Evalua si el boton est� presionado
					BRA ET_1
				MOVLW 09H ;Mueve el 9 para compararlo
				CPFSEQ UN,0 ;Compara unidades
					BRA UNIDADES;no
				MOVLW 09H	;si
				CPFSEQ DEC,0; Compara decenas
					BRA DECENAS	;no
				MOVLW 09H	;si
				CPFSEQ CEN,0
					BRA CENTENAS;No
				MOVLW 09H;
				CPFSEQ MIL,0
					BRA MILES;no
				BRA FINAL;

UNIDADES 		INCF UN,1,0;Incrementa unidades
UN_DIS			CALL DISP;Mueve valores a display
				BTFSC B_UP; Evalua si el bot�n no esta presionado
					BRA UN_DIS	;no
				CALL DELAY_R
				BRA ET_1;
	

DECENAS			INCF DEC,1,0;Incrementa decenas
CLR_UN			CLRF UN,0 ;Limpia unidades
				BRA UN_DIS	;
				
				
CENTENAS		INCF CEN,1,0;Incrementa centenas
CLR_DEC			CLRF DEC,0 ;Limpia decenas
				BRA CLR_UN; Limpia unidades
				
MILES			INCF MIL,1,0;Incrementa Miles
CLR_CEN			CLRF CEN,0 ;Limpia centenas
				BRA CLR_DEC; Limpia decenas

FINAL			CLRF MIL,0;Limpia miles
				BRA CLR_CEN

		
SET_OUTPUTS	CLRF TRISC,0
			SETF TRISB,0
			RETURN

DISP		MOVLW 10H; 1000
			IORWF MIL,0,0	; 1000 + 		
			MOVWF PORTC,0
			CALL DELAY_R

			MOVLW 20H; 0100
			IORWF CEN,0,0	
			MOVWF PORTC,0
			CALL DELAY_R

			MOVLW 40H; 0010
			IORWF DEC,0,0	
			MOVWF PORTC,0
			CALL DELAY_R

			MOVLW 80H; 0001
			IORWF UN,0,0	
			MOVWF PORTC,0
			CALL DELAY_R
			RETURN



DELAY_R		MOVLW	0AH
			MOVWF	T3,0
L3			MOVLW	0AH
			MOVWF	T2,0
L2			MOVLW	0FH
			MOVWF	T1,0
L1			DECFSZ	T1,1,0
				BRA		L1
			DECFSZ	T2,1,0
				BRA		L2
			DECFSZ	T3,1,0
				BRA		L3
			RETURN

			END			
;*************** FINAL DEL PROGRAMA PRINCIPAL ************************	


