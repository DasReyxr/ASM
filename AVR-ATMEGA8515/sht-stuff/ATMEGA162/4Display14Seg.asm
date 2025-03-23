.INCLUDE <M162DEF.INC>
; ---- Code Section  ----
.cseg
.org 0x0000
JMP CONFIG          
; ---- Data section ----
.org 0x0100          
DATA_TABLE: 
.dw 0x00F7, 0x128F, 0x0039, 0x120F, 0x00F9, 0x00F1, 0x00BD, 0x00F6
.dw 0x1209, 0x001E, 0x2470, 0x0038, 0x0536, 0x2136, 0x003F, 0x00F3
.dw 0x203F, 0x20F3, 0x018D, 0x1201, 0x003E, 0x0C30, 0x2836, 0x2D00
.dw 0x1500, 0x0C09, 0x0C3F, 0x0406, 0x00DB, 0x008F, 0x00E6, 0x0ED
.dw 0x00FD ,0x1401, 0x00FF,0x00E7 
; ---- Configuracion ----
CONFIG:
    ;-- Set Stack Pointer
    LDI R16, 0x04
    OUT SPH, R16           
    LDI R16, 0xFF
    OUT SPL, R16
    ;-- Set Outputs --
    LDI R17, 0xFF
    OUT DDRA, R17
    LDI R17, 0xFF
    OUT DDRB, R17
    RJMP AGAIN

; ---- Main ----
AGAIN:
    LDI ZL, 0x00  
    LDI ZH, 0x02 
    LDI R20, 36              
LOOP: 
    LPM R18, Z+              
    OUT PORTB, R18           
    LPM R19, Z+              
    OUT PORTA, R19           
    RCALL DELAY1S            
    DEC R20                  
    BRNE LOOP                
    RJMP AGAIN               

; ---- Delays ----
DELAY1S:
    LDI R19, 255
T3:
    LDI R18, 255
T2:
    LDI R17, 6
T1:
    DEC R17
    BRNE T1
    DEC R18
    BRNE T2
    DEC R19
    BRNE T3
    RET

