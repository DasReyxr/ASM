; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; -------------- 3Display --------------
; ------------- 20/02/2021 -------------
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

;---------- VECTOR DE PROGRAMA PRINCIPAL------------------------------
			ORG		0000H
			CALL	SET_OUTPUTS
			BRA		INICIO
				
;------------ PROGRAMA PRINCIPAL -------------------------------------
INICIO 		MOVLW	3FH            ;0
				MOVWF	PORTC,0
				CALL	DELAY_3S
			MOVLW	06H            ;1
				MOVWF	PORTC,0
				CALL	DELAY_3S
			MOVLW	5BH            ;2
				MOVWF	PORTC,0
				CALL	DELAY_3S
			MOVLW	4FH            ;3
				MOVWF	PORTC,0
				CALL	DELAY_3S
			MOVLW	66H            ;4
				MOVWF	PORTC,0
				CALL	DELAY_3S
			MOVLW	6DH           ;5
				MOVWF	PORTC,0
				CALL	DELAY_3S
			MOVLW	7DH          ;6
				MOVWF	PORTC,0
				CALL	DELAY_3S
			MOVLW	07H          ;7
				MOVWF	PORTC,0
				CALL	DELAY_3S
			MOVLW	7FH         ;8
				MOVWF	PORTC,0
				CALL	DELAY_3S
			MOVLW	67H         ;9
				MOVWF	PORTC,0
				CALL	DELAY_3S
			MOVLW	77H         ;A
				MOVWF	PORTC,0
				CALL	DELAY_3S
			MOVLW	7CH         ;b
				MOVWF	PORTC,0
				CALL	DELAY_3S				
			MOVLW	39H         ;C
				MOVWF	PORTC,0
				CALL	DELAY_3S
			MOVLW	5EH         ;D
				MOVWF	PORTC,0
				CALL	DELAY_3S
			MOVLW	79H         ;E
				MOVWF	PORTC,0
				CALL	DELAY_3S
			MOVLW	71H         ;F
				MOVWF	PORTC,0
				CALL	DELAY_3S


			BRA		INICIO

SET_OUTPUTS	MOVLW	00H
			MOVWF	TRISC,0
			RETURN

DELAY_3S	MOVLW	10H
			MOVWF	T3,0
L3			MOVLW	30H-
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


