; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; --------------- LCDLxL ---------------
; ------------- 10/03/2021 -------------
; ------------- Variables -------------
; ---------------- Main ----------------


      #INCLUDE "P18F452.INC"
      LIST P=18F452

;---------- CONFIGURACI�N DE FUSIBLES DEL PROCESADOR -----------------
 __CONFIG _CONFIG1H ,   _HS_OSC_1H
 __CONFIG   _CONFIG2L ,    _BOR_OFF_2L &  _PWRT_ON_2L
 __CONFIG   _CONFIG2H ,    _WDT_OFF_2H
 ;------------------DECLARACION DE VARIABLES TIPO BIT----------------
#DEFINE     ENABLE      PORTD, 0, 0
#DEFINE     RS          PORTD, 1, 0 ;Cuando RS valga 1 se imprimir�n los datos
 ;------------------DECLARACION DE VARIABLES TIPO BYTE-------------- 
LCD            EQU   PORTC
T1       EQU   20H
T2       EQU   21H
T3       EQU   22H
  ;------------------VECTOR DE PROGRAMA PRINCIPAL--------------------------
               ORG   0000H
               CALL  SET_OUTPUTS
               CALL  SET_LCD
               BRA   INICIO
   ;-----------------------PROGRAMA PRINCIPAL---------------------------
INICIO            MOVLW 20H            ;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H            ;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H            ;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 42H            ;B
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 49H            ;I
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 45H            ;E
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 4EH            ;N
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 56H            ;V
                     MOVWF LCD, 0
                     CALL  PUERTA   
                  MOVLW 45H            ;E
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 4EH            ;N
                     MOVWF LCD, 0   
                     CALL  PUERTA
                  MOVLW 49H            ;I
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 44H            ;D
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 4FH            ;O
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 53H            ;S
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H            ;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H            ;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  ;BIENVENIDOS

                  CALL     SALTO;Brinco de linea a Linea 2 
               
                  MOVLW 20H			;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H         ;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 43H         ;C
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 42H         ;B
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 54H         ;T
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 49H         ;I
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 53H         ;S
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H         ;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 4EH         ;N
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 4FH         ;O
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H         ;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 31H         ;1
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 36H         ;6
                     MOVWF   LCD, 0
                     CALL  PUERTA   
                  MOVLW 38H         ;8
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H         ;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H
                     MOVWF LCD, 0
                     CALL  PUERTA
                  ;CBTIS NO 168
                  CALL     DELAY_3S
                  CALL     CLR_LCD
                  
                 MOVLW 20H         ;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H         ;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H         ;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H         ;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 4FH         ;O
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 52H         ;R
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 4CH         ;L
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 41H         ;A
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 4EH         ;N
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 44H         ;D
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 4FH         ;O
                     MOVWF LCD, 0
                     CALL  PUERTA
				  ;ORLANDO
                  CALL     SALTO
                  
                  MOVLW 43H			;C
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 4FH			;O
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 4EH			;N
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 54H			;T
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 52H			;R
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 45H			;E
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 52H			;R
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 41H			;A
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 53H			;S
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H			;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 52H			;R
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 45H			;E
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 59H			;Y
                     MOVWF   LCD, 0
                     CALL  PUERTA
                  MOVLW 45H			;E
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 53H			;S
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H			;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  ;CONTRERAS REYES

                  CALL     DELAY_3S
                  CALL     CLR_LCD;Limpia LCD
                  
                  MOVLW 20H			;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H			;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H			;-
                     MOVWF LCD, 0
                     CALL  PUERTA	
                  MOVLW 4EH			;N
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 4FH			;O
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H			;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 43H			;C
                     MOVWF LCD, 0
                     CALL  PUERTA   
                  MOVLW 4FH			;O
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 4EH			;N
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 54H			;T
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 52H			;R
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 4FH			;O
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 4CH			;L
                     MOVWF LCD, 0
                     CALL  PUERTA
                  
                  CALL     SALTO;Salto de l�nea 
                  
                  MOVLW 20H 		;-
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 31H			;1
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 39H			;9
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 33H			;3
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 30H			;0
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 31H			;1
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 30H			;0
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 35H			;5
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 31H			;1
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 36H			;6
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 38H			;8
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 30H			;0
                     MOVWF LCD, 0
                     CALL  PUERTA	
                  MOVLW   34H			;4
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 30H			;0
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 35H			;5
                     MOVWF LCD, 0
                     CALL  PUERTA
                  MOVLW 20H			;-
                     MOVWF LCD, 0
                     CALL  PUERTA

                  CALL     DELAY_3S
                  CALL     CLR_LCD
                  BRA      INICIO
                  
SET_LCD        CLRF     LCD, 0
               BCF      ENABLE
               BCF      RS
               CALL     DELAY_4100
               MOVLW 38H
                  MOVWF LCD, 0
                  CALL  PUERTA
               MOVLW 38H
                  MOVWF LCD, 0
                  CALL  PUERTA
               MOVLW 38H
                  MOVWF LCD, 0
                  CALL     PUERTA
               MOVLW 38H
                  MOVWF LCD, 0
                  CALL     PUERTA
               MOVLW 01H
                  MOVWF LCD, 0
                  CALL     PUERTA
               MOVLW 06H
                  MOVWF LCD, 0
                  CALL     PUERTA
               MOVLW 0EH
                  MOVWF LCD, 0
                  CALL     PUERTA
               BSF      RS
               RETURN            

   
CURSOR_OFF     BCF      RS
                  MOVLW 0EH
                     MOVWF LCD, 0
                     CALL     PUERTA
                  BCF      RS
                  RETURN
   
PUERTA            BSF      ENABLE
                  CALL     DELAY_4100
                  BCF      ENABLE
                  CALL     DELAY_4100
                  RETURN
                  
SALTO          BCF      RS
               MOVLW 0C0H
                  MOVWF LCD, 0
                  CALL     PUERTA
               BSF      RS 
               RETURN
                  
CLR_LCD        BCF      RS
                  MOVLW 01H
                  MOVWF LCD, 0
                  CALL     PUERTA
                  BSF      RS
                  RETURN
                  
SET_OUTPUTS    CLRF  TRISC, 0
                  CLRF  TRISD, 0
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

DELAY_3S    MOVLW    40H
               MOVWF    T3 , 0
L6             MOVLW    60H
               MOVWF    T2 , 0
L5          MOVLW    0C0H
               MOVWF    T1 , 0
L4             DECFSZ   T1 , 1, 0
               BRA      L4
               DECFSZ   T2 , 1, 0
               BRA      L5
               DECFSZ   T3 , 1, 0
               BRA      L6
               RETURN

               END
   ;---------------------FIN DEL PROGRAMA-----------------------
   
