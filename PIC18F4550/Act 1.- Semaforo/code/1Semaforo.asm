; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ------------- 1Semaforo -------------
; ------------- 19/02/2021 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
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

;---------- VECTOR DE PROGRAMA PRINCIPAL------------------------------
			ORG		0000H
			CALL	SO
			BRA		INICIO
				
;------------ PROGRAMA PRINCIPAL -------------------------------------
INICIO 		MOVLW	91H
			MOVWF	PORTC,0
			CALL	D3S
			MOVLW	41H
			MOVWF	PORTC,0
			CALL	D3S
			MOVLW	21H
			MOVWF	PORTC,0
			CALL	D3S
			MOVLW	19H
			MOVWF	PORTC,0
			CALL	D3S
			MOVLW	14H
			MOVWF	PORTC,0
			CALL	D3S
			MOVLW	12H
			MOVWF	PORTC,0
			CALL	D3S
			BRA		INICIO

SO			MOVLW	00H
			MOVWF	TRISC,0
			RETURN

D3S			MOVLW	10H
			MOVWF	T3,0
L3			MOVLW	30H
			MOVWF	T2,0
L2			MOVLW	80H
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


