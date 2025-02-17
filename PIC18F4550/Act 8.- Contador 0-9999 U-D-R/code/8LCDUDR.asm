; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ---------- LCD UpDownReset ----------
; ------------- 14/03/2021 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
      #INCLUDE "P18F452.INC"
      LIST P=18F452
;---------- CONFIGURACI�N DE FUSIBLES DEL PROCESADOR -----------------
 __CONFIG _CONFIG1H, _HS_OSC_1H
 __CONFIG _CONFIG2L, _BOR_OFF_2L & _PWRT_ON_2L
 __CONFIG _CONFIG2H, _WDT_OFF_2H 
   
;--------- DECLARACION DE VARIABLES TIPO BIT -------------------------
#DEFINE  ENABLE   PORTD,0,0
#DEFINE  RS       PORTD,1,0
#DEFINE  B_UP  PORTB,0,0
#DEFINE  B_DW   PORTB,1,0
#DEFINE  B_RST PORTB,2,0

;--------- DECLARACION DE VARIABLES TIPO BYTE -------------------------
LCD         EQU      PORTC
T1 EQU      21H
T2 EQU      22H
T3 EQU   23H
UNI    EQU   33H
DEC     EQU   32H
CEN    EQU   31H
MIL       EQU      30H

;---------- VECTOR DE PROGRAMA PRINCIPAL------------------------------
         ORG      0000H
         CALL  SET_OUTPUTS
         CALL    SET_LCD
         BRA      INICIO
            
;------------ PROGRAMA PRINCIPAL ------------

;------------ Compara BU ------------
INICIO      CALL RS_V
P_LCD         CALL    PRINT_LCD 
         BTFSS B_UP
            BRA     UP_DWN
         MOVLW 09H
            CPFSEQ   UNI,0
            BRA     UP_U
         MOVLW   09H
            CPFSEQ  DEC,0
            BRA     UP_D
         MOVLW   09H
            CPFSEQ   CEN,0
            BRA      UP_C
         MOVLW   09H
            CPFSEQ   MIL,0
            BRA      UP_M
         CLRF MIL,0
         BRA CL_C

;------------ Incrementa BU------------

UP_U         INCF    UNI,1,0
VALOR         CALL    PRINT_LCD
         BTFSC B_UP
            BRA     VALOR
         CALL DELAY_R
         BRA      P_LCD


UP_D         INCF    DEC,1,0
CL_U         CLRF UNI,0
            BRA     VALOR

UP_C         INCF  CEN,1,0
CL_D         CLRF DEC,0
               BRA     CL_U

UP_M         INCF  MIL,1,0
CL_C         CLRF CEN,0
            BRA      CL_D
;------------ Enlace UP-DW ------------

UP_DWN     BTFSS B_DW
         BRA      DWN_RS
;------------ Comparador BD ------------         
         MOVLW 00H
            CPFSEQ   UNI,0
            BRA     DW_U
         MOVLW   00H
            CPFSEQ  DEC,0
            BRA     DW_D
         MOVLW   00H
            CPFSEQ   CEN,0
            BRA      DW_C
         MOVLW   00H
            CPFSEQ   MIL,0
            BRA      DW_M
            BRA      ST_M


;------------ Decrementa BU------------
DW_U     DECF  UNI,1,0
VALOR_D     CALL  PRINT_LCD
         BTFSC B_DW
         BRA     VALOR_D
         CALL DELAY_R
         BRA P_LCD

DW_D     DECF  DEC,1,0
ST_U     MOVLW 09H
         MOVWF UNI,0
         BRA   VALOR_D

DW_C     DECF  CEN,1,0
ST_D     MOVLW 09H
         MOVWF DEC,0
         BRA      ST_U

DW_M     DECF  MIL,1,0
ST_C     MOVLW 09H
         MOVWF CEN,0
         BRA   ST_D
         

ST_M      MOVLW 09H
          MOVWF MIL,0
          BRA ST_C
;------------ Enlace DW-RS ------------
DWN_RS     BTFSS B_RST
            BRA   P_LCD
            BRA RS_V
;------------ RESET ------------
VALOR_R     CALL  PRINT_LCD
         BTFSC B_RST
         BRA      VALOR_R
         CALL DELAY_R
         
               
            
;--------------SUBRUTINAS----------------    
RS_V     CLRF MIL,0
         CLRF CEN,0
         CLRF DEC,0
         CLRF UNI,0
         RETURN         

SET_LCD         CLRF LCD,0
               BCF      ENABLE
               BCF   RS
               CALL  DELAY_45
               MOVLW 38H
               	MOVWF   LCD,0
               	CALL    ENA_DIS
               MOVLW 38H
               	MOVWF   LCD,0
               	CALL    ENA_DIS
               MOVLW 38H
               	MOVWF   LCD,0
               	CALL    ENA_DIS
               MOVLW 38H
               	MOVWF   LCD,0
               	CALL    ENA_DIS
               MOVLW   01H
              	MOVWF   LCD,0
               	CALL    ENA_DIS
               MOVLW   06H
               	MOVWF   LCD,0
               	CALL    ENA_DIS
               MOVLW   0CH
               MOVWF   LCD,0
               CALL    ENA_DIS
               BCF     RS
               RETURN

ENA_DIS           BSF      ENABLE
               CALL    DELAY_4100
               BCF     ENABLE
               CALL  DELAY_4100
               RETURN
               
CLR_LCD             BCF    RS
               MOVLW   01H
               MOVWF   LCD,0
               CALL    ENA_DIS
               BSF      RS
               RETURN
               

PRINT_LCD         CALL  CLR_LCD
               MOVLW 20H
               		MOVWF LCD,0
               		CALL  ENA_DIS
               MOVLW 20H
               		MOVWF LCD,0
               		CALL  ENA_DIS
               MOVLW 'C'
               		MOVWF LCD,0
               		CALL     ENA_DIS
               MOVLW 'O'
               		MOVWF LCD,0
               		CALL     ENA_DIS
               MOVLW 'N'
               		MOVWF LCD,0
               		CALL     ENA_DIS
               MOVLW 'T'
               		MOVWF LCD,0
               		CALL     ENA_DIS
               MOVLW 'E'
               		MOVWF LCD,0
               		CALL     ENA_DIS
               MOVLW 'O'
               		MOVWF LCD,0
               		CALL     ENA_DIS
               MOVLW 20H
               		MOVWF LCD,0
               		CALL     ENA_DIS
               MOVLW 30H
               		ADDWF MIL,0,0
               		MOVWF LCD,0
               		CALL  ENA_DIS
               MOVLW 30H
               		ADDWF   CEN,0,0
               		MOVWF LCD,0
               		CALL  ENA_DIS
               MOVLW 30H
              		ADDWF DEC,0,0
               		MOVWF LCD,0
               		CALL  ENA_DIS
               MOVLW 30H
               		ADDWF UNI,0,0
               		MOVWF LCD,0
               		CALL  ENA_DIS
               CALL  DELAY_R
               RETURN

SET_OUTPUTS       CLRF  TRISC,0
               CLRF  TRISD,0
               SETF  TRISB,1
               RETURN
;------------ Delays ------------
DELAY_R      MOVLW 0FFH  
               MOVWF T3,0
O_3           MOVLW 0FH   
               MOVWF T2,0
O_2           MOVLW 0EH   
               MOVWF T1,0
O_1           DECFSZ   T1,1,0
               BRA      O_1
               DECFSZ   T2,1,0
               BRA      O_2
               DECFSZ   T3,1,0
               BRA      O_3
               RETURN

DELAY_45          MOVLW 0A8H  
               MOVWF T3,0
O_6           MOVLW 08H   
               MOVWF T2,0
O_5           MOVLW 0AH   
               MOVWF T1,0
O_4           DECFSZ   T1,1,0
               BRA      O_4
               DECFSZ   T2,1,0
               BRA      O_5
               DECFSZ   T3,1,0
               BRA      O_6
               RETURN
               
DELAY_4100        MOVLW 06H
               MOVWF T3,0
O_9           MOVLW 06H
               MOVWF T2,0
O_8           MOVLW 06H
               MOVWF T1,0
O_7           DECFSZ   T1,1,0
               BRA      O_7
               DECFSZ   T2,1,0
               BRA      O_8
               DECFSZ   T3,1,0
               BRA      O_9
               RETURN  


               END         
;***** FINAL DEL PROGRAMA PRINCIPAL ********
