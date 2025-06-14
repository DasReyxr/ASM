; -------------- Iker | Das --------------
; -------------- PWM LED --------------
; ------------- 11/05/2025 -------------
; ------------- Variables -------------
; ---------------- Main ----------------

NVIC_BASE 	EQU   0xE000E100 
NVIC_ISER0	EQU	 (NVIC_BASE)
		
;Direccion relojes
RCC_BASE 	EQU 0x40023800 
RCC_AHB1ENR EQU (0x40023800 + 0x30)
RCC_APB2ENR EQU (RCC_BASE + 0x44)
;PortA
;Direcciones puertos8

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
GPIOC_MODER 	EQU (GPIOC_BASE + 0X00)
GPIOC_OTYPER 	EQU (GPIOC_BASE + 0X04)
GPIOC_OSPEEDR 	EQU (GPIOC_BASE + 0X08)
GPIOC_PUPDR 	EQU (GPIOC_BASE + 0X0C)
	
;Estos son registros de comunicacion

GPIOC_IDR 		EQU (GPIOC_BASE + 0X10)
GPIOC_ODR 		EQU (GPIOC_BASE + 0X14)
GPIOC_BSRR 		EQU (GPIOC_BASE + 0X18)


;EXTI
EXTI_BASE 		EQU 0x40013C00
EXTI_IMR 		EQU (EXTI_BASE + 0X00 )
EXTI_RTSR 		EQU (EXTI_BASE + 0X08)
EXTI_FTSR 		EQU (EXTI_BASE +0X0C)
EXTI_PR 		EQU (EXTI_BASE +0X14)

;SYSCFG
SYSCFG_BASE 	EQU 0x40013800
SYSCFG_EXTICR1 	EQU (SYSCFG_BASE  + 0X08)	

led_delay 		EQU 4000000
led_del	  		EQU 1000000

	AREA data, DATA, READWRITE
	AREA juve3dstudio,CODE,READONLY

	ENTRY
	EXPORT __main
	EXPORT exti0Handler
	EXPORT exti1Handler
		
__main
	LDR R5, =0x7
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
	LDR 	R0,= RCC_AHB1ENR
	LDR 	R1, [R0] ;guardo el contenido que apunta la direccion de R0
	ORR 	R1, #0X05 ; Aqui se esta encendiendo el puerto A y C 
	STR 	R1, [R0]
		
	LDR 	R0,= RCC_APB2ENR
	LDR 	R1, [R0] ;guardo el contenido que apunta la direccion de R0
	ORR 	R1, #0X4000 
	STR 	R1, [R0]
	BX		LR



confGPIOA

	LDR 	R0,= GPIOA_PUPDR
	LDR 	R1, [R0] 
	ORR 	R1,R1,#0x0A
	STR 	R1, [R0]
	
	LDR 	R0,= GPIOC_MODER
	LDR 	R1, [R0] 
	LDR 	R2,= 0x04000000 
	ORR 	R1,R1,R2
	STR 	R1, [R0]
	
	LDR 	R0,= GPIOC_OSPEEDR
	LDR 	R1, [R0] 
	LDR 	R2,=(0x0C00 << 16) 
	ORR 	R1,R1,R2
	STR 	R1, [R0]
	
	BX		LR

confEXTI
	LDR 	R0,= EXTI_IMR 
	LDR 	R1, [R0]
	ORR 	R1,R1, #0x03
	STR 	R1, [R0]
	
	LDR 	R0,= EXTI_RTSR 
	LDR 	R1, [R0]
	ORR 	R1,R1, #0x03
	STR 	R1, [R0]
	
	BX		LR

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
	LDR 	R0,= NVIC_ISER0 ;interrupcion con registro
	LDR 	R1, [R0]
	ORR 	R1, #(1<<6) 
	ORR 	R1, #(1<<7) 
	
	STR 	R1, [R0]
	BX		LR

exti0Handler
	PUSH {LR} ;Guarda la direccion del retorno 
	
    CMP     R5, #0xB  ; if R5>r11 we substract 1 to the count (normal cycle) 
    BHI     Juan
    ADD     R5,R5,#1 ; if R5 < r11, we add 1 to the next counter 
Juan
	POP {LR}

    BX      LR


	
exti1Handler
	PUSH {LR} ;Guarda la direccion del retorno 
    CMP     R5,#0x5 ; if R5<r10 we substract 1 to the count (normal cycle)
    BLO    Juan
    SUB     R5,R5,#1 ; if r5>r10 we substract 1 to the next counter
	POP {LR}
	BX      LR

	


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