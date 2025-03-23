;
; Act_3_4_displays.asm
;
; Created: 03/12/2024 01:30:22 p. m.
; Author : USER
;
.include "m162def.inc"

.org 0x000                ; Direcci�n de inicio del programa (Reset)
    RJMP PRINCIPAL         ; Inicia desde la secci�n PRINCIPAL

.org 0x002                ; Direcci�n de interrupci�n externa 0 (INT0)
    RJMP INT_EXT_0

.org    0x004               ; Direcci�n de la interrupci�n externa 1 (INT1)
    RJMP   INT_EXT_1         ; Redirigir a la rutina de interrupci�n INT1

.org 0x020
PRINCIPAL:
    ; Configuraci�n de puertos
    LDI R16, 0
    OUT DDRD, R16         ; Puerto D como entrada (para botones, si es necesario)
    LDI R16, 0xFF
    OUT DDRA, R16         ; Puerto A como salida (para los segmentos de los displays)
    OUT PORTD, R16        ; Activamos las resistencias de Pull-Up en el puerto D
    
    LDI R16, 0b00001111   ; Configuramos las primeras 4 l�neas de PORTB como salidas
    OUT DDRB, R16         ; Puerto B como salida (para los transistores de los displays)

    ; Configuraci�n del puntero de pila (SP)
    LDI R16, HIGH(RAMEND)
    OUT SPH, R16
    LDI R16, LOW(RAMEND)
    OUT SPL, R16

        ; Configuraci�n de interrupciones
    LDI     R16, 0b00000010  ; Configurar INT0 para flanco de bajada
    OUT     MCUCR, R16

    LDI     R16, 0b11000000  ; Habilitar INT0 e INT1 en GICR
    OUT     GICR, R16

    SEI                       ; Habilitar interrupciones globales

INICIO:
    LDI R16, 0            ; Inicializar el registro de control (offset)

CICLO:
;0
	LDI R16, 0b00001110            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0xC0         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1
;1
	LDI R16, 0b00001101            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0xF9         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2
;2
	LDI R16, 0b00001011            ; Activar display 3 (PINA2)
    OUT PORTB, R16        ; Activar el display 3
    LDI R17, 0xA4         ; Datos para mostrar "2" en display 3
    OUT PORTA, R17        ; Mostrar "2" en el display 3
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 3
    OUT PORTB, R16        ; Apagar el display 3
;3
	LDI R16, 0b00000111            ; Activar display 4 (PINA3)
    OUT PORTB, R16        ; Activar el display 4
    LDI R17, 0xB0         ; Datos para mostrar "3" en display 4
    OUT PORTA, R17        ; Mostrar "3" en el display 4
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 4
    OUT PORTB, R16        ; Apagar el display 4
;4
	LDI R16, 0b00001110            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0x99         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1

;5
	LDI R16, 0b00001101            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0x92         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2
;6
	LDI R16, 0b00001011            ; Activar display 3 (PINA2)
    OUT PORTB, R16        ; Activar el display 3
    LDI R17, 0x82         ; Datos para mostrar "2" en display 3
    OUT PORTA, R17        ; Mostrar "2" en el display 3
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 3
    OUT PORTB, R16        ; Apagar el display 3
;7
	LDI R16, 0b00000111            ; Activar display 4 (PINA3)
    OUT PORTB, R16        ; Activar el display 4
    LDI R17, 0xf8         ; Datos para mostrar "3" en display 4
    OUT PORTA, R17        ; Mostrar "3" en el display 4
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 4
    OUT PORTB, R16        ; Apagar el display 4
;8
	LDI R16, 0b00001110            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0x80         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1
;9
	LDI R16, 0b00001101            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0x98         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2
RJMP CICLO


TIEMPO:                   ; Subrutina de espera de 1 segundo (aproximadamente)
    LDI  r25, 4
    LDI  r26, 150
    LDI  r27, 128
L1:
    DEC r27
    BRNE L1
    DEC r26
    BRNE L1
    DEC r25
    BRNE L1
    RET                    ; Retornar de la subrutina

; Tabla de patrones para los displays de 7 segmentos (0-9)
TABLA:
    .db 0xc0, 0xf9, 0xa4, 0xb0, 0x99, 0x92, 0x82, 0xf8
    .db 0x80, 0x98        ; Representaci�n de los n�meros 0-9

INT_EXT_0:                 ; Manejo de interrupci�n externa
    PUSH R25

	RCALL CERO

	RCALL UNO

	RCALL DOS

	RCALL TRES

	RCALL CUATRO

	RCALL CINCO

	RCALL SEIS

	RCALL SIETE

	RCALL OCHO

	RCALL NUEVE
   ; LDI R18, 0            ; Apagar todos los displays
    ;OUT PORTA, R18
    ;RCALL TIEMPO
    ;LDI R18, 0xFF         ; Encender todos los displays
    ;OUT PORTA, R18
    ;RCALL TIEMPO
    ;LDI R18, 0            ; Apagar todos los displays
    ;OUT PORTA, R18
    ;RCALL TIEMPO
    ;LDI R18, 0xFF         ; Encender todos los displays
    ;OUT PORTA, R18
    ;RCALL TIEMPO
    POP R25
    RETI                   ; Retornar de la interrupci�n

CERO:
	LDI R16, 0b00001110            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0xC0         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1

	LDI R16, 0b00001101            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0xC0         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1

	LDI R16, 0b00001011            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0xC0         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1

	LDI R16, 0b00000111            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0xC0         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1
	RETI

UNO:	
	LDI R16, 0b00001110            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0xF9         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2

	LDI R16, 0b00001101            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0xF9         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2

	LDI R16, 0b00001011            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0xF9         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2

	LDI R16, 0b00000111            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0xF9         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2
	RETI

DOS:
	LDI R16, 0b00001110            ; Activar display 3 (PINA2)
    OUT PORTB, R16        ; Activar el display 3
    LDI R17, 0xA4         ; Datos para mostrar "2" en display 3
    OUT PORTA, R17        ; Mostrar "2" en el display 3
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 3
    OUT PORTB, R16        ; Apagar el display 3

	LDI R16, 0b00001101            ; Activar display 3 (PINA2)
    OUT PORTB, R16        ; Activar el display 3
    LDI R17, 0xA4         ; Datos para mostrar "2" en display 3
    OUT PORTA, R17        ; Mostrar "2" en el display 3
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 3
    OUT PORTB, R16        ; Apagar el display 3

	LDI R16, 0b00001011            ; Activar display 3 (PINA2)
    OUT PORTB, R16        ; Activar el display 3
    LDI R17, 0xA4         ; Datos para mostrar "2" en display 3
    OUT PORTA, R17        ; Mostrar "2" en el display 3
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 3
    OUT PORTB, R16        ; Apagar el display 3

	LDI R16, 0b00000111            ; Activar display 3 (PINA2)
    OUT PORTB, R16        ; Activar el display 3
    LDI R17, 0xA4         ; Datos para mostrar "2" en display 3
    OUT PORTA, R17        ; Mostrar "2" en el display 3
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 3
    OUT PORTB, R16        ; Apagar el display 3
	RETI

TRES:
	LDI R16, 0b00001110           ; Activar display 4 (PINA3)
    OUT PORTB, R16        ; Activar el display 4
    LDI R17, 0xB0         ; Datos para mostrar "3" en display 4
    OUT PORTA, R17        ; Mostrar "3" en el display 4
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 4
    OUT PORTB, R16        ; Apagar el display 4

	LDI R16, 0b00001101            ; Activar display 4 (PINA3)
    OUT PORTB, R16        ; Activar el display 4
    LDI R17, 0xB0         ; Datos para mostrar "3" en display 4
    OUT PORTA, R17        ; Mostrar "3" en el display 4
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 4
    OUT PORTB, R16        ; Apagar el display 4

	LDI R16, 0b00001011            ; Activar display 4 (PINA3)
    OUT PORTB, R16        ; Activar el display 4
    LDI R17, 0xB0         ; Datos para mostrar "3" en display 4
    OUT PORTA, R17        ; Mostrar "3" en el display 4
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 4
    OUT PORTB, R16        ; Apagar el display 4

	LDI R16, 0b00000111            ; Activar display 4 (PINA3)
    OUT PORTB, R16        ; Activar el display 4
    LDI R17, 0xB0         ; Datos para mostrar "3" en display 4
    OUT PORTA, R17        ; Mostrar "3" en el display 4
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 4
    OUT PORTB, R16        ; Apagar el display 4

	RETI

CUATRO:
	LDI R16, 0b00001110            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0x99         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1

	LDI R16, 0b00001101            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0x99         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1

	LDI R16, 0b00001011            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0x99         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1

	LDI R16, 0b00000111            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0x99         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1

	RETI

CINCO:
	LDI R16, 0b00001110            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0x92         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2

	LDI R16, 0b00001101            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0x92         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2

	LDI R16, 0b00001011            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0x92         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2

	LDI R16, 0b00000111            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0x92         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2
	RETI

SEIS:
	LDI R16, 0b00001110            ; Activar display 3 (PINA2)
    OUT PORTB, R16        ; Activar el display 3
    LDI R17, 0x82         ; Datos para mostrar "2" en display 3
    OUT PORTA, R17        ; Mostrar "2" en el display 3
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 3
    OUT PORTB, R16        ; Apagar el display 3

	LDI R16, 0b00001101            ; Activar display 3 (PINA2)
    OUT PORTB, R16        ; Activar el display 3
    LDI R17, 0x82         ; Datos para mostrar "2" en display 3
    OUT PORTA, R17        ; Mostrar "2" en el display 3
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 3
    OUT PORTB, R16        ; Apagar el display 3

	LDI R16, 0b00001011            ; Activar display 3 (PINA2)
    OUT PORTB, R16        ; Activar el display 3
    LDI R17, 0x82         ; Datos para mostrar "2" en display 3
    OUT PORTA, R17        ; Mostrar "2" en el display 3
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 3
    OUT PORTB, R16        ; Apagar el display 3

	LDI R16, 0b00000111            ; Activar display 3 (PINA2)
    OUT PORTB, R16        ; Activar el display 3
    LDI R17, 0x82         ; Datos para mostrar "2" en display 3
    OUT PORTA, R17        ; Mostrar "2" en el display 3
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 3
    OUT PORTB, R16        ; Apagar el display 3
	RETI

SIETE:
	LDI R16, 0b00001110            ; Activar display 4 (PINA3)
    OUT PORTB, R16        ; Activar el display 4
    LDI R17, 0xf8         ; Datos para mostrar "3" en display 4
    OUT PORTA, R17        ; Mostrar "3" en el display 4
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 4
    OUT PORTB, R16        ; Apagar el display 4

	LDI R16, 0b00001101            ; Activar display 4 (PINA3)
    OUT PORTB, R16        ; Activar el display 4
    LDI R17, 0xf8         ; Datos para mostrar "3" en display 4
    OUT PORTA, R17        ; Mostrar "3" en el display 4
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 4
    OUT PORTB, R16        ; Apagar el display 4

	LDI R16, 0b00001011            ; Activar display 4 (PINA3)
    OUT PORTB, R16        ; Activar el display 4
    LDI R17, 0xf8         ; Datos para mostrar "3" en display 4
    OUT PORTA, R17        ; Mostrar "3" en el display 4
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 4
    OUT PORTB, R16        ; Apagar el display 4

	LDI R16, 0b00000111            ; Activar display 4 (PINA3)
    OUT PORTB, R16        ; Activar el display 4
    LDI R17, 0xf8         ; Datos para mostrar "3" en display 4
    OUT PORTA, R17        ; Mostrar "3" en el display 4
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 4
    OUT PORTB, R16        ; Apagar el display 4
	RETI

OCHO:
	LDI R16, 0b00001110            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0x80         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1

	LDI R16, 0b00001101            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0x80         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1

	LDI R16, 0b00001011            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0x80         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1

	LDI R16, 0b00000111            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0x80         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1
	RETI

NUEVE:
	LDI R16, 0b00001110            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0x98         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2

	LDI R16, 0b00001101            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0x98         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2

	LDI R16, 0b00001011            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0x98         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2

	LDI R16, 0b00000111            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0x98         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2
	RETI

INT_EXT_1:
	;0
	LDI R16, 0b00001110            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0xC0         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO_I          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1
;1
	LDI R16, 0b00001101            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0xF9         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO_I          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2
;2
	LDI R16, 0b00001011            ; Activar display 3 (PINA2)
    OUT PORTB, R16        ; Activar el display 3
    LDI R17, 0xA4         ; Datos para mostrar "2" en display 3
    OUT PORTA, R17        ; Mostrar "2" en el display 3
    RCALL TIEMPO_I          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 3
    OUT PORTB, R16        ; Apagar el display 3
;3
	LDI R16, 0b00000111            ; Activar display 4 (PINA3)
    OUT PORTB, R16        ; Activar el display 4
    LDI R17, 0xB0         ; Datos para mostrar "3" en display 4
    OUT PORTA, R17        ; Mostrar "3" en el display 4
    RCALL TIEMPO_I          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 4
    OUT PORTB, R16        ; Apagar el display 4
;4
	LDI R16, 0b00001110            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0x99         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO_I          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1

;5
	LDI R16, 0b00001101            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0x92         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO_I          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2
;6
	LDI R16, 0b00001011            ; Activar display 3 (PINA2)
    OUT PORTB, R16        ; Activar el display 3
    LDI R17, 0x82         ; Datos para mostrar "2" en display 3
    OUT PORTA, R17        ; Mostrar "2" en el display 3
    RCALL TIEMPO_I          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 3
    OUT PORTB, R16        ; Apagar el display 3
;7
	LDI R16, 0b00000111            ; Activar display 4 (PINA3)
    OUT PORTB, R16        ; Activar el display 4
    LDI R17, 0xf8         ; Datos para mostrar "3" en display 4
    OUT PORTA, R17        ; Mostrar "3" en el display 4
    RCALL TIEMPO_I          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 4
    OUT PORTB, R16        ; Apagar el display 4
;8
	LDI R16, 0b00001110            ; Activar display 1 (PINA0)
    OUT PORTB, R16        ; Activar el display 1
    LDI R17, 0x80         ; Datos para mostrar "0" en display 1
    OUT PORTA, R17        ; Mostrar "0" en el display 1
    RCALL TIEMPO_I          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 1
    OUT PORTB, R16        ; Apagar el display 1
;9
	LDI R16, 0b00001101            ; Activar display 2 (PINA1)
    OUT PORTB, R16        ; Activar el display 2
    LDI R17, 0x98         ; Datos para mostrar "1" en display 2
    OUT PORTA, R17        ; Mostrar "1" en el display 2
    RCALL TIEMPO_I          ; Esperar 1 segundo
    LDI R16, 0xFF         ; Desactivar display 2
    OUT PORTB, R16        ; Apagar el display 2
	RETI

TIEMPO_I:
    LDI  r26, 200            ; Cargar 200 en r26
    LDI  r27, 160            ; Cargar 160 en r27
L2:
    DEC r27                  ; Decrementar r27
    BRNE L2                  ; Si r27 no es cero, continuar bucle L2
    DEC r26                  ; Decrementar r26
    BRNE L2                  ; Si r26 no es cero, continuar bucle L2
    RETI                     ; Retornar de la subrutina
	
	