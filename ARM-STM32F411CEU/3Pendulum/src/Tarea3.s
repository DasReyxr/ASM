; ----------- Iker | Das -----------
; ------------- 3 Pendulum -------------
; ------------- 01/04/2025 -------------
; ------------- Variables -------------
;---- Registers Used
; R0    Port Register
; R1    Interrupt number
; R2    Number Dela
; R3    Pointer
; R4    buttonpresed
; PORTA LEDs
; PORTB  Buttons

; ---------------- Main ----------------

;Direcciones relojes
RCC_BASE EQU 0x40023800
RCC_AHB1ENR EQU (RCC_BASE + 0x30)

; --------- GPIO A ---------
GPIOA_BASE      EQU 0x40020000
GPIOA_MODER     EQU (GPIOA_BASE + 0x00)
;-- Configuration Registers --
GPIOA_OTYPER    EQU (GPIOA_BASE + 0x04)
GPIOA_OSPEED    EQU (GPIOA_BASE + 0x08)
GPIOA_PUPDR     EQU (GPIOA_BASE + 0x0C)
;-- Comm Registers --
GPIOA_IDR       EQU (GPIOA_BASE + 0x10)
GPIOA_ODR       EQU (GPIOA_BASE + 0x14)

;-- Special Registers --
GPIOA_BSSR       EQU (GPIOA_BASE + 0x18) ; Bit Set Set Register
; --------- GPIO B ---------
GPIOB_BASE       EQU 0x40020400
GPIOB_MODER      EQU (GPIOB_BASE + 0x00)
;-- Configuration Registers --
GPIOB_OTYPER     EQU (GPIOB_BASE + 0x04)
GPIOB_OSPEED     EQU (GPIOB_BASE + 0x08)
GPIOB_PUPDR      EQU (GPIOB_BASE + 0x0C)
;-- Comm Registers --
GPIOB_IDR        EQU (GPIOB_BASE + 0x10)
GPIOB_ODR        EQU (GPIOB_BASE + 0x14)
 
;-- Special Registers --
GPIOB_BSSR       EQU (GPIOB_BASE + 0x18) ; Bit Set Set Register

led_delay EQU 400000
;Area de datos para haer uso de la SRAM
	AREA my_data, DATA, READWRITE

	AREA myCode, CODE, READONLY
	ENTRY
	EXPORT __main

__main
	BL	confRCC
	BL  confGPIOC
	LDR R4,=led_delay
	MOVW R2, #0x0070
	EOR R3,R3

MOVDER
	LDR R0,=GPIOA_ODR
	LSR R3, R2, #2
	MOV R1, R3
	STR R1,[R0]
	CMP R2, #7
	BEQ MOVIZQ 
	LSR R2,R2, #1
	BL Delay
	B MOVDER

MOVIZQ
	LSR R3, R2, #2
	MOV R1, R3
	STR R1,[R0]
	CMP R2, #0xE00
	BEQ MOVDER 
	LSL R2,R2, #1
	BL Delay
	B MOVIZQ


;ciclo B ciclo igual a B .

;================= Subrutinas =================
;Configuracion de los relojes
confRCC
	LDR R0,=RCC_AHB1ENR; 0		 00 	  0		  00		0	   0	  0		  0		  0
	LDR R1,[R0]	    ;  GPIOH  RESERVED  GPIOE  RESERVED  GPIOEEN GPIOD  GPIOC   GPIOB   GPIOA
	ORR R1,R1,#0x03  ; 	 0		 00  	  0 	  00		0	   0	  0 	  1		  1
	STR R1,[R0]
	BX LR

;Configuramos del GPIOC
confGPIOC
	;Configuramos del 0-7 del moder como salida de proposito general 
	LDR R0,=GPIOA_MODER
	LDR R1,[R0]
	LDR R2,=0x00005555
	ORR R1,R2
	STR R1,[R0]
	;Configuramos la velocidad de los pines 0-7 a full 11 cada uno por eso los FF
	LDR R0,=GPIOA_OSPEED
	LDR R1,[R0]
	LDR R2,=0x0000FFFF
	ORR R1,R2
	STR R1,[R0]
	BX LR

	;Configuramos el 0 y 1 como pull down para la entrada A 1010 para pull down
	LDR R0,=GPIOB_PUPDR
	LDR R1,[R0]
	LDR R2,=0x0000000A
	ORR R1,R2
	STR R1,[R0]
	;Configuramos la velocidad de los pines 0-1 a full 11 cada uno por eso la F
	LDR R0,=GPIOB_OSPEED
	LDR R1,[R0]
	LDR R2,=0x0000000F
	ORR R1,R2
	STR R1,[R0]
	BX LR

; El delay es de 5 Millones 
Delay
	MOV R5, R4

delay1
	SUBS R5,R5,#1

	ldr     r6, =GPIOB_IDR
    ldr     R7,[R6]    ; B7 B6 B5 B4 B3 B2 B1 B0
	and     R7,#0x0001 ; 0 0   0  0  0  0  0  1
;    cmp     R7,#0x0001
;	BEQ suma

	ldr     R6, =GPIOB_IDR
    ldr     R7,[R6]    ; B7 B6 B5 B4 B3 B2 B1 B0
	and     R7,#0x0002 ; 0 0   0  0  0  0  0  1
;    cmp     R7,#0x0002
;	BEQ resta

	BNE delay1
	BX LR

suma
	ADD     R4,R4,#1
	B delay1

resta
	SUB     R4,R4,#1
	B delay1

	ALIGN
	END