; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ---------- 5DisplayBotonUp ----------
; ------------- 01/03/2021 -------------
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
C1  EQU 20H
;---------- VECTOR DE PROGRAMA PRINCIPAL------------------------------
			ORG		0000H
			CALL	SET_OUTPUTS
			BRA		INICIO
				
;------------ PROGRAMA PRINCIPAL -------------------------------------
INICIO				MOVLW	00H            
					MOVWF	C1,0
CPC					MOVFF	C1, PORTC
				BTFSS   B_UP; Bit TestFile Skip 1
					BRA CPC;no  Salta al Contador puerto C
				MOVLW 	09H; SI, Mueve el 9 H para compararlo
				CPFSEQ C1,0 ;Compara el file con Wreg
					BRA S1; No
				BRA CF;Si

CF				CLRF C1,0
				BRA CPC2
				
S1				INCF C1,1,0
				BRA CPC2

CPC2			MOVFF C1,PORTC
				BTFSC B_UP; Bit TestFile Skip 0
					BRA CPC2;NO
				CALL DELAY_R; Llama subrutina Rebote
				BRA CPC

SET_OUTPUTS	CLRF TRISC,0
			SETF TRISB,0
			RETURN

DELAY_R		MOVLW	08H
			MOVWF	T3,0
L3			MOVLW	0AH
			MOVWF	T2,0
L2			MOVLW	5CH
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


