-- IKGB ----

;Direcciones relojes
RCC_BASE EQU 0x40023800
RCC_AHB1ENR EQU (RCC_BASE + 0x30)

;Direccion GPIO
;GPIOA_BASE 		EQU 0xA8000000 ; No se debe de modificar
;Estamos usando el GPIO C
GPIOA_BASE 		EQU 0x40020000  ; Direccion de GPIOC
GPIOA_MODER		EQU (GPIOA_BASE)
GPIOA_OTYPER	EQU (GPIOA_BASE + 0x04)
GPIOA_OSPEEDR 	EQU (GPIOA_BASE + 0x08)
GPIOA_PUTDR		EQU (GPIOA_BASE + 0x0C)

GPIOA_IDR		EQU (GPIOA_BASE + 0x10)
GPIOA_ODR		EQU (GPIOA_BASE + 0x14)
GPIOA_BSRR		EQU (GPIOA_BASE + 0x18)

led_delay EQU 3333333 * 3
;Area de datos para haer uso de la SRAM
	AREA my_data, DATA, READWRITE

	AREA myCode, CODE, READONLY
	ENTRY
	EXPORT __main

__main
	BL	confRCC
	BL  confGPIOC
	MOVW R2, #0x0070
	EOR R3,R3


loop
	LDR R0,=GPIOA_ODR
	LSR R3, R2, #2
	MOV R1, R3
	STR R1,[R0]
	CMP R2, #7
	BEQ MOVIZQ 
	LSR R2,R2, #1
	B loop
	;B .

MOVIZQ
	LSR R3, R2, #2
	MOV R1, R3
	STR R1,[R0]
	CMP R2, #0xE00
	BEQ loop 
	LSL R2,R2, #1
	B MOVIZQ


;ciclo B ciclo igual a B .

;================= Subrutinas =================
;Configuracion de los relojes
confRCC
	LDR R0,=RCC_AHB1ENR; 0		 00 	  0		  00		0	   0	  0		  0		  0
	LDR R1,[R0]	    ;  GPIOH  RESERVED  GPIOE  RESERVED  GPIOEEN GPIOD  GPIOC   GPIOB   GPIOA
	ORR R1,R1,#0x01  ; 	 0		 00  	  0 	  00		0	   0	  1 	  0		  0
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
	LDR R0,=GPIOA_OSPEEDR
	LDR R1,[R0]
	LDR R2,=0x0000FFFF
	ORR R1,R2
	STR R1,[R0]
	BX LR

	ALIGN
	END
