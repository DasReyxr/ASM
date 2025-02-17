; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ------------ 4Displa0-9 --------------
; ------------- 23/02/2021 -------------
; ------------- Variables -------------
; ---------------- Main ----------------

;-------------- INCLUYO LA LIBRERIAS B�SICAS DEL PROCESADOR ----------
		#INCLUDE "P18F452.INC"
		LIST P=18F452
;---------- CONFIGURACI�N DE FUSIBLES DEL PROCESADOR -----------------
 __CONFIG _CONFIG1H, _HS_OSC_1H
 __CONFIG _CONFIG2L, _BOR_OFF_2L & _PWRT_ON_2L
 __CONFIG _CONFIG2H, _WDT_OFF_2H	
	
;--------- DECLARACION DE VARIABLES TIPO BIT -------------------------


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
INICIO 			MOVLW	00H            
				MOVWF	C1,0
INC				MOVFF	C1, PORTC             
				CALL    D1S
				MOVLW 	09H; Mueve el 9 H para compararlo
				CPFSEQ C1,0 ;Compara el file con Wreg
					BRA S1; No
				BRA INICIO;Si
				
S1				INCF C1,1,0
				BRA INC

SET_OUTPUTS	MOVLW	00H
			MOVWF	TRISC,0
			RETURN

D1S			MOVLW	41H
			MOVWF	T3,0
L3			MOVLW	37H
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


