; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ---------------- MxM ----------------
; ------------- 15/03/2021 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
      #INCLUDE "P18F452.INC"
      LIST P=18F452
;---------- CONFIGURACI�N DE FUSIBLES DEL PROCESADOR -----------------
 __CONFIG _CONFIG1H, _HS_OSC_1H
 __CONFIG _CONFIG2L, _BOR_OFF_2L & _PWRT_ON_2L
 __CONFIG _CONFIG2H, _WDT_OFF_2H 
   
;--------- DECLARACION DE VARIABLES TIPO BIT -------------------------
#DEFINE     ENABLE      PORTD, 0, 0
#DEFINE     RS          PORTD, 1, 0 ;Cuando RS valga 1 se imprimir�n los datos

;--------- DECLARACION DE VARIABLES TIPO BYTE -------------------------
LCD         EQU      PORTC
T1 EQU      21H
T2 EQU      22H
T3 EQU   23H

;---------- VECTOR DE PROGRAMA PRINCIPAL------------------------------
         ORG      0000H
         CALL  SET_OUTPUTS
         CALL    SET_LCD
         BRA      MXM
            
;------------ PROGRAMA PRINCIPAL ------------
MXM            MOVLW 10H      ;Mueve 10 a Wreg
                  MOVWF TBLPTRH,0  ;Mueve Wreg a TaBLePoinTeR High
               MOVLW 00H      ;Mueve 00 a Wreg
                  MOVWF TBLPTRL,0  ;Mueve Wreg a TaBLePoinTeR Low
               CALL CLR_LCD
               CALL PRINT_MXM
               CALL DELAY_3S
               
               MOVLW 10H      ;Mueve 10 a Wreg
                  MOVWF TBLPTRH,0
               MOVLW 30H
                  MOVWF TBLPTRL,0
               CALL CLR_LCD
               CALL PRINT_MXM
               CALL DELAY_3S

               MOVLW 10H
                  MOVWF TBLPTRH,0
               MOVLW 60H
                   MOVWF TBLPTRL,0
               CALL CLR_LCD
               CALL PRINT_MXM
               CALL DELAY_3S
               BRA MXM


               

PRINT_MXM      TBLRD*+
               MOVLW 00H ;Mueve 0 a Wreg para comparar
               CPFSEQ TABLAT,0 ;Compara TABLAT con 0
                  BRA COMP;No
               RETURN;Si

COMP           MOVLW 01H;Mueve 0 a Wreg para comparar
               CPFSEQ TABLAT,0
                  BRA FINLINEA;No
               CALL SAL_REN  ;Si
               BRA PRINT_MXM

FINLINEA       MOVFF TABLAT, LCD
               CALL ENA_DIS
               BRA PRINT_MXM



SET_LCD        CLRF     LCD, 0
               BCF      ENABLE
               BCF      RS
               CALL     DELAY_4100
               MOVLW 38H
                  MOVWF LCD, 0
                  CALL  ENA_DIS
               MOVLW 38H
                  MOVWF LCD, 0
                  CALL  ENA_DIS
               MOVLW 38H
                  MOVWF LCD, 0
                  CALL     ENA_DIS
               MOVLW 38H
                  MOVWF LCD, 0
                  CALL     ENA_DIS
               MOVLW 01H
                  MOVWF LCD, 0
                  CALL     ENA_DIS
               MOVLW 06H
                  MOVWF LCD, 0
                  CALL     ENA_DIS
               MOVLW 0EH
                  MOVWF LCD, 0
                  CALL     ENA_DIS
               BSF      RS
               RETURN            

SET_OUTPUTS       CLRF  TRISC,0
               CLRF  TRISD,0
               SETF  TRISB,1
               RETURN
;------------ SUBRUTINAS ------------
SAL_REN          BCF      RS
               MOVLW 0C0H
                  MOVWF LCD, 0
                  CALL     ENA_DIS
               BSF      RS 
               RETURN

CLR_LCD        BCF      RS
                  MOVLW 01H
                  MOVWF LCD, 0
                  CALL     ENA_DIS
                  BSF      RS
                  RETURN
ENA_DIS            BSF      ENABLE
                  CALL     DELAY_4100
                  BCF      ENABLE
                  CALL     DELAY_4100
                  RETURN


;------------ Delays ------------
DELAY_3S      MOVLW 60H  
               MOVWF T3,0
O_3           MOVLW 67H   
               MOVWF T2,0
O_2           MOVLW 64H   
               MOVWF T1,0
O_1           DECFSZ   T1,1,0
               BRA      O_1
               DECFSZ   T2,1,0
               BRA      O_2
               DECFSZ   T3,1,0
               BRA      O_3
               RETURN

DELAY_4100     MOVLW    0AH
               MOVWF    T3 , 0
L3             MOVLW    0AH
               MOVWF    T2 , 0
L2             MOVLW    0FH
               MOVWF    T1 , 0
L1             DECFSZ   T1 , 1, 0
               BRA      L1
               DECFSZ   T2 , 1, 0
               BRA      L2
               DECFSZ   T3 , 1, 0
               BRA      L3
               RETURN
;------------ MENSAJES ------------
			   ORG 1000H ;Mensaje 1
			   DB "   BIENVENIDO   ",1,"  CBTIs NO 168 ",0

			   ORG 1030H
			   DB "     ORLANDO    ",1,"CONTRERAS REYES ",0
			
            ORG 1060H; Mensaje 2
            DB "   NO CONTROL   ",1," 19301051680405 ",0         
            END   
			         
;***** FINAL DEL PROGRAMA PRINCIPAL ********
 