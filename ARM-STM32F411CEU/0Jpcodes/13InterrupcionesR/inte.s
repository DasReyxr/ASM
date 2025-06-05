	;TTL inte  ; Esto es el titulo de nuestro programa
; Aqui van nuestras constantes, definiciones, etc
; Ejemplo 
; Un area de datos para hacer uso de la SRAM

NVIC_BASE 	EQU   0xE000E100 
NVIC_ISER0	EQU	 (NVIC_BASE)
		
;Direccion relojes
RCC_BASE 	EQU 0x40023800 
RCC_AHB1ENR EQU (0x40023800 + 0x30)
RCC_APB2ENR EQU (RCC_BASE + 0x44)
;PortA
;Direcciones puertos

GPIOA_BASE  EQU 0x40020000
;Estos son registros de configuracion
GPIOA_MODER EQU (GPIOA_BASE + 0X00)
GPIOA_OTYPER EQU (GPIOA_BASE + 0X04)
GPIOA_OSPEEDR EQU (GPIOA_BASE + 0X08)
GPIOA_PUPDR EQU (GPIOA_BASE + 0X0C)
	
;Estos son registros de comunicacion

GPIOA_IDR EQU (GPIOA_BASE + 0X10)
GPIOA_ODR EQU (GPIOA_BASE + 0X14)
GPIOA_BSRR EQU (GPIOA_BASE + 0X18)

;--------------------------------------------------------------------

;PortC
;Direcciones puertos
GPIOC_BASE EQU 0x40020800
;Estos son registros de configuracion
GPIOC_MODER EQU (GPIOC_BASE + 0X00)
GPIOC_OTYPER EQU (GPIOC_BASE + 0X04)
GPIOC_OSPEEDR EQU (GPIOC_BASE + 0X08)
GPIOC_PUPDR EQU (GPIOC_BASE + 0X0C)
	
;Estos son registros de comunicacion

GPIOC_IDR EQU (GPIOC_BASE + 0X10)
GPIOC_ODR EQU (GPIOC_BASE + 0X14)
GPIOC_BSRR EQU (GPIOC_BASE + 0X18)


;EXTI
EXTI_BASE EQU 0x40013C00
EXTI_IMR EQU (EXTI_BASE + 0X00 )
EXTI_RTSR EQU (EXTI_BASE + 0X08)
EXTI_FTSR EQU (EXTI_BASE +0X0C)
EXTI_PR EQU (EXTI_BASE +0X14)

;SYSCFG
SYSCFG_BASE 	EQU 0x40013800
SYSCFG_EXTICR1 EQU (SYSCFG_BASE  + 0X08)	

led_delay EQU 4000000
led_del	  EQU 1000000

	AREA myData, DATA, READWRITE
;La direccion de comienzo es la 0x20000000


;Obligatoriamente nuestro codigo debe llevar un area de codigo
	AREA myCode, CODE, READONLY
	ENTRY
	EXPORT __main
	EXPORT exti0Handler
		
__main
	
	;Configuracion
	BL	confRCC
	BL	confGPIOA
	BL confEXTI
	;BL confSYSCFG
	BL	confNVIC
loop
	LDR R0,= GPIOC_ODR
	LDR R1,[R0]
	MOVW R2, #0x2000
	EOR R1, R2
	STR R1,[R0]
	BL delay
	B loop
	
ciclo	B ciclo	
;Subrutinas
confRCC ; Configuracion de los relojes
	LDR R0,= RCC_AHB1ENR
	LDR R1, [R0] ;guardo el contenido que apunta la direccion de R0
	ORR R1, #0X05 ; Aqui se esta encendiendo el puerto A y C 
	STR R1, [R0]
	
	LDR R0,= RCC_APB2ENR
	LDR R1, [R0] ;guardo el contenido que apunta la direccion de R0
	ORR R1, #0X4000 
	STR R1, [R0]
	BX	LR


confGPIOA
	;Esto ya esta configuardo por defecto
;	LDR R0,= GPIOA_MODER
;	LDR R1, [R0] ;0000 0100 0000 0000 0000 0000 0000 0000
;	LDR R2,= 0x04000000 ;Se hace una mascara para activar el reloj del puerto c
;	ORR R1,R1,R2
;	STR R1, [R0]
	
	;Se configuro el PA0 Como Pull Down
	LDR R0,= GPIOA_PUPDR
	LDR R1, [R0] 
	ORR R1,R1,#0x02
	STR R1, [R0]
	
	LDR R0,= GPIOC_MODER
	LDR R1, [R0] ;0000 0100 0000 0000 0000 0000 0000 0000
	LDR R2,= 0x04000000 ;Se hace una mascara para activar el reloj del puerto c
	ORR R1,R1,R2
	STR R1, [R0]
	
;Esto es para la speed en PC13
	LDR R0,= GPIOC_OSPEEDR
	LDR R1, [R0] ;0000 0100 0000 0000 0000 0000 0000 0000
	LDR R2,=(0x0C00 << 16) ;Se hace una mascara para activar el reloj del puerto c
	ORR R1,R1,R2
	STR R1, [R0]
	
	BX	LR

confEXTI
;Estamos activando el bit de la exti 0
	LDR R0,= EXTI_IMR ;interrupcion con registro
	LDR R1, [R0]
	ORR R1,R1, # 0x01
	STR R1, [R0]
	
	LDR R0,= EXTI_RTSR ; de subida
	LDR R1, [R0]
	ORR R1,R1, # 0x01
	STR R1, [R0]
	
	
	BX	LR

;confSYSCFG
;	Selecccionamos el puerto A bit 0 para el EXTI0
;	LDR R0,= SYSCFG_EXTICR1 ; de subida
;	LDR R1, [R0]
;	BIC R1, # (0<<0); AND  a nivel de un solo bit 
;	STR R1, [R0]
;	
;	BX	LR

confNVIC
	;Habilitamos la EXTI0
	LDR R0,= NVIC_ISER0 ;interrupcion con registro
	LDR R1, [R0]
	ORR R1, # (1<<6) ;Uno en el bit 0
	STR R1, [R0]
	BX	LR

;Esto es lo que la interrupcion hará 
exti0Handler
	PUSH {LR} ;Guarda la direccion del retorno 
	
	LDR R0,= GPIOC_ODR
	EOR R3,R3
loop1
	LDR R1,[R0]
	MOVW R2, #0x2000
	EOR R1, R2
	STR R1,[R0]
	PUSH{R0}
	BL del
	POP{R0}
	ADD R3,#1
	CMP R3, #0XA
	BNE loop1
	
	POP {LR}
	BX LR

delay 
	LDR R0,= led_delay
delay1
	
	SUBS R0, R0, #1
	BNE delay1
	BX LR 
	
del 
	LDR R0,= led_del
del1
	
	SUBS R0, R0, #1
	BNE delay1
	BX LR 


	
	ALIGN
	END