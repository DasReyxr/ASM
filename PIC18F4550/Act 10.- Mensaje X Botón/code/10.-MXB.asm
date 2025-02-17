; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; ---------------- MxB ----------------
; ------------- 17/03/2021 -------------
; ------------- Variables -------------
; ---------------- Main ----------------
      #INCLUDE "P18F452.INC"
      LIST P=18F452
;---------- CONFIGURACIÓN DE FUSIBLES DEL PROCESADOR -----------------
 __CONFIG _CONFIG1H, _HS_OSC_1H
 __CONFIG _CONFIG2L, _BOR_OFF_2L & _PWRT_ON_2L
 __CONFIG _CONFIG2H, _WDT_OFF_2H 
    
;--------- DECLARACION DE VARIABLES TIPO BIT -------------------------
#DEFINE     ENABLE      PORTD, 0, 0
#DEFINE     RS          PORTD, 1, 0 ;Cuando RS valga 1 se imprimirán los datos
#DEFINE 	B_1			PORTB, 0,0   ;Msj 1
#DEFINE  B_2       PORTB, 1,0   ;Msj 2
#DEFINE  B_3       PORTB, 2,0   ;Msj 3
#DEFINE  B_4       PORTB, 3,0   ;Msj 4
#DEFINE  B_5       PORTB, 4,0   ;Msj 5
#DEFINE  B_6       PORTB, 5,0   ;Msj 6
#DEFINE  B_7       PORTB, 6,0   ;Msj 7
#DEFINE  B_8       PORTB, 7,0   ;Msj 8


;--------- DECLARACION DE VARIABLES TIPO BYTE -------------------------
LCD         EQU      PORTC
T1 EQU      21H
T2 EQU      22H
T3 EQU   23H

;---------- VECTOR DE PROGRAMA PRINCIPAL------------------------------
         ORG      0000H
         CALL     SET_OUTPUTS
         CALL     SET_LCD
         BRA      MXB
            
;------------ PROGRAMA PRINCIPAL ------------
MXB		MOVLW 11H
		MOVWF TBLPTRH,0
		MOVLW 80H
		MOVWF TBLPTRL,0
		CALL CLR_LCD
		CALL PRINT_LCD
		CALL DELAY_3S
      BRA EV1
		
               
EV1            BTFSS B_1 
                  BRA EV2;NO
               MOVLW 10H  
                  MOVWF TBLPTRH,0;Mueve Wreg a TablePointer High
               MOVLW 00H
                  MOVWF TBLPTRL,0;Mueve Wreg a Tablepointer Low
               CALL CLR_LCD
               CALL  PRINT_LCD
L1               BTFSC B_1
                  BRA L1 ;NO
DR                CALL DELAY_R ;SI
                
                                                  
EV2            BTFSS B_2 
                  BRA EV3;NO
               MOVLW 10H  
                  MOVWF TBLPTRH,0;Mueve Wreg a TablePointer High
               MOVLW 30H
                  MOVWF TBLPTRL,0;Mueve Wreg a Tablepointer Low
               CALL CLR_LCD
               CALL  PRINT_LCD
L2               BTFSC B_2
                  BRA L2 ;NO
               BRA DR
                     
EV3            BTFSS B_3 
                  BRA EV4;NO
               MOVLW 10H  
                  MOVWF TBLPTRH,0;Mueve Wreg a TablePointer High
               MOVLW 60H
                  MOVWF TBLPTRL,0;Mueve Wreg a Tablepointer Low
               CALL CLR_LCD
               CALL  PRINT_LCD
L3             BTFSC B_3
                  BRA L3 ;NO
               BRA DR
               
EV4            BTFSS B_4 
                  BRA EV5;NO
               MOVLW 10H  
                  MOVWF TBLPTRH,0;Mueve Wreg a TablePointer High
               MOVLW 90H
                  MOVWF TBLPTRL,0;Mueve Wreg a Tablepointer Low
               CALL CLR_LCD
               CALL  PRINT_LCD
L4             BTFSC B_4
                  BRA L4 ;NO
               BRA DR              

EV5            BTFSS B_5 
                  BRA EV6;NO
               MOVLW 10H  
                  MOVWF TBLPTRH,0;Mueve Wreg a TablePointer High
               MOVLW 0C0H
                  MOVWF TBLPTRL,0;Mueve Wreg a Tablepointer Low
               CALL CLR_LCD
               CALL  PRINT_LCD
L5             BTFSC B_5
                  BRA L5 ;NO
               BRA DR   

EV6            BTFSS B_6 
                  BRA EV7;NO
               MOVLW 10H  
                  MOVWF TBLPTRH,0;Mueve Wreg a TablePointer High
               MOVLW 0F0H
                  MOVWF TBLPTRL,0;Mueve Wreg a Tablepointer Low
               CALL CLR_LCD
               CALL  PRINT_LCD
L6             BTFSC B_6
                  BRA L6 ;NO
               BRA DR                 
               
EV7            BTFSS B_7 
                  BRA EV8;NO
               MOVLW 11H  
                  MOVWF TBLPTRH,0;Mueve Wreg a TablePointer High
               MOVLW 20H
                  MOVWF TBLPTRL,0;Mueve Wreg a Tablepointer Low
                CALL CLR_LCD
               CALL  PRINT_LCD
L7              BTFSC B_7
                  BRA L7 ;NO
               BRA DR 

EV8            BTFSS B_8 
                  BRA EV1;NO
               MOVLW 11H  
                  MOVWF TBLPTRH,0;Mueve Wreg a TablePointer High
               MOVLW 50H
                  MOVWF TBLPTRL,0;Mueve Wreg a Tablepointer Low
               CALL CLR_LCD
               CALL  PRINT_LCD
L8               BTFSC B_8
                  BRA L8 ;NO
               BRA DR 
;------ SUBRUTINAS DE LCD ------
PRINT_LCD      TBLRD*+
               MOVLW 00H ;Mueve 0 a Wreg para comparar
               CPFSEQ TABLAT,0 ;Compara TABLAT con 0
                  BRA COMP;No
               RETURN;Si
COMP           MOVLW 01H;Mueve 0 a Wreg para comparar
               CPFSEQ TABLAT,0 
                  BRA FINLINEA;No
               CALL SAL_REN  ;Si
               BRA PRINT_LCD  
FINLINEA       MOVFF TABLAT, LCD
               CALL ENA_DIS
               BRA PRINT_LCD
 

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
SAL_3             MOVLW    0AH
               MOVWF    T2 , 0
SAL_2             MOVLW    0FH
               MOVWF    T1 , 0
SAL_1             DECFSZ   T1 , 1, 0
               BRA      SAL_1
               DECFSZ   T2 , 1, 0
               BRA      SAL_2
               DECFSZ   T3 , 1, 0
               BRA      SAL_3
               RETURN
               
DELAY_R      MOVLW 0FFH  
               MOVWF T3,0
O_6           MOVLW 0FH   
               MOVWF T2,0
O_5           MOVLW 0EH   
               MOVWF T1,0
O_4           DECFSZ   T1,1,0
               BRA      O_4
               DECFSZ   T2,1,0
               BRA      O_5
               DECFSZ   T3,1,0
               BRA      O_6
               RETURN
;------------ MENSAJES ------------
			   ORG 1000H ;Mensaje 1
			   DB "CUENTAN QUE", 1,"ESTANDO CERCA EL",0

			   ORG 1030H ;Mensaje 2
			   DB "FINAL DE SU",1,"VIAJE VIO LLEGAR",0
			
            ORG 1060H; Mensaje 3
            DB "A UNA SILUETA",1,"QUE CON EL SOL",0    
                 
            ORG 1090H ;Mensaje 4
            DB "SU ARMADURA", 1,"HACIA BRILLAR",0

            ORG 10C0H ;Mensaje 5
            DB "CUENTAN QUE SU",1,"ROSTRO NUNCA VIO",0
         
            ORG 10F0H; Mensaje 6
            DB "PERO SU VOZ",1,"ANUNCIO",0    

            ORG 1120H ;Mensaje 7
            DB "SOY EL CABALLERO",1,"DE LA BLANCA",0
         
            ORG 1150H; Mensaje 8
            DB "LUNA Y A VOS HE",1,"VENIDO A BUSCAR",0

            ORG 1180H; Mensaje 8
            DB "MAGO DE OZ EL",1,"TEMPLO DEL ADIOS",0
          END   
			         
;***** FINAL DEL PROGRAMA PRINCIPAL ********
 