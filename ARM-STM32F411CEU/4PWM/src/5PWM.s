; -------------- Iker | Das --------------
; -------------- PWM LED --------------
; ------------- 11/05/2025 -------------

; ----------- Direcciones de periféricos -----------

; EXTI (interrupciones externas)
EXTI_BASE       EQU 0x40013C00
EXTI_IMR        EQU (EXTI_BASE + 0x00)
EXTI_EMR        EQU (EXTI_BASE + 0x04)
EXTI_RTSR       EQU (EXTI_BASE + 0x08)
EXTI_FTSR       EQU (EXTI_BASE + 0x0C)
EXTI_PR         EQU (EXTI_BASE + 0x14)

; NVIC (controlador de interrupciones)
NVIC_BASE       EQU 0xE000E100 
NVIC_ISER0      EQU (NVIC_BASE + 0x00)

; SYSCFG (asocia EXTI con GPIOs)
SYSCFG_BASE     EQU 0x40013800 
SYSCFG_EXTICR1  EQU (SYSCFG_BASE + 0x08)

; TIM2 (temporizador para PWM)
TIM2_BASE 		EQU 0x40000000
TIM2_CR1 		EQU (TIM2_BASE + 0x00)
TIM2_SR			EQU (TIM2_BASE + 0x10)
TIM2_CCMR1 		EQU (TIM2_BASE + 0x18)
TIM2_CCER       EQU (TIM2_BASE + 0x20)
TIM2_CNT 		EQU (TIM2_BASE + 0x24)
TIM2_PSC 		EQU (TIM2_BASE + 0x28)
TIM2_ARR 		EQU (TIM2_BASE + 0x2C)
TIM2_CCR1       EQU (TIM2_BASE + 0x34)

; RCC (control de reloj)
RCC_BASE        EQU 0x40023800
RCC_AHB1        EQU (RCC_BASE  + 0x30)
RCC_APB1        EQU (RCC_BASE  + 0x40)
RCC_APB2        EQU (RCC_BASE  + 0x44)

; GPIOA (PWM y LED)
GPIOA_BASE       EQU 0x40020000
GPIOA_MODER     EQU (GPIOA_BASE + 0x00)
GPIOA_OTYPER    EQU (GPIOA_BASE + 0x04)
GPIOA_OSPEED    EQU (GPIOA_BASE + 0x08)
GPIOA_PUPDR     EQU (GPIOA_BASE + 0x0C)
GPIOA_IDR       EQU (GPIOA_BASE + 0x10)
GPIOA_ODR       EQU (GPIOA_BASE + 0x14)
GPIOA_AFRL       EQU (GPIOA_BASE + 0x20)
GPIOA_AFRH       EQU (GPIOA_BASE + 0x24)
GPIOA_BSSR       EQU (GPIOA_BASE + 0x18)

; GPIOB (botones)
GPIOB_BASE       EQU 0x40020400
GPIOB_MODER      EQU (GPIOB_BASE + 0x00)
GPIOB_OTYPER    EQU (GPIOB_BASE + 0x04)
GPIOB_OSPEED    EQU (GPIOB_BASE + 0x08)
GPIOB_PUPDR     EQU (GPIOB_BASE + 0x0C)
GPIOB_IDR       EQU (GPIOB_BASE + 0x10)
GPIOB_ODR       EQU (GPIOB_BASE + 0x14)
GPIOB_AFRL       EQU (GPIOB_BASE + 0x20)
GPIOB_AFRH       EQU (GPIOB_BASE + 0x24)

; ----------- Áreas de memoria -----------

AREA myData, DATA, READWRITE
AREA bobostudio,CODE,READONLY
ENTRY
EXPORT __main
EXPORT exti0Handler
EXPORT exti1Handler

; ----------- Función principal -----------

__main
    ; Configura todo el hardware necesario
    BL      Config_RCC
    BL      Config_GPIO
	BL 		Config_TIM
	BL      Conf_NVIC
    BL      Config_EXTI
    BL      Config_Syscfg

    ; Inicializa valores PWM
    LDR     R5,=12000         ; ciclo de trabajo inicial
    LDR     R6,=24000         ; ciclo de trabajo máximo

loop
    ; Aplica el valor del ciclo de trabajo al PWM
    LDR 	R0, =TIM2_CCR1
    STR		R5,[R0]
    B 		loop

; ----------- Configuración de Relojes -----------

Config_RCC
    ; Habilita GPIOA y GPIOB
    LDR     R0,=RCC_AHB1     
    LDR     R1,[R0]          
    ORR     R1,#(0x3)       
    STR     R1,[R0]

    ; Habilita el reloj para TIM2
    LDR     R0,=RCC_APB1     
    LDR     R1,[R0]         
    ORR     R1,#0x0001      
    STR     R1,[R0]

    ; Habilita el reloj para SYSCFG
    LDR     R0,=RCC_APB2
    LDR     R1, [R0]
    ORR     R1, R1, #(1 << 14)  
    STR     R1, [R0]
    BX      LR

; ----------- Configuración de GPIOs -----------

Config_GPIO
    ; Configura PA0 como salida alternativa (PWM)
    LDR     R0, =GPIOA_MODER
    LDR     R1, [R0]
    LDR     R2, =0x02
    ORR     R1,R1,R2
    STR     R1,[R0]

    ; Configura velocidad de PA0
    LDR     R0, =GPIOA_OSPEED
    LDR     R1, [R0]
    ORR     R1,R1, #0x03 
    STR     R1,[R0]

    ; Asigna función alternativa a PA0 (AF1 para TIM2_CH1)
    LDR     R0, =GPIOA_AFRL
    LDR     R1, [R0]
    ORR     R1,#(1 << 0)
    STR     R1,[R0]

    ; Configura PB0 y PB1 con resistencias pull-down
	LDR 	R0,= GPIOB_PUPDR
	LDR 	R1, [R0] 
	ORR 	R1,R1,#0x0A
	STR 	R1, [R0]
    BX      LR

; ----------- Configuración de NVIC (interrupciones) -----------

Conf_NVIC
    ; Habilita interrupciones para EXTI0 y EXTI1
	LDR 	R0,= NVIC_ISER0
	LDR 	R1, [R0]
	ORR 	R1, #(1<<6) 
	ORR 	R1, #(1<<7) 
	STR 	R1, [R0]
	BX		LR

; ----------- Configuración de EXTI (interrupciones externas) -----------

Config_EXTI
    ; Desenmascara EXTI0 y EXTI1 (habilita interrupción)
	LDR 	R0,= EXTI_IMR 
	LDR 	R1, [R0]
	ORR 	R1,R1, #0x03
	STR 	R1, [R0]

    ; Configura flanco de subida (rising edge) para ambos
	LDR 	R0,= EXTI_RTSR 
	LDR 	R1, [R0]
	ORR 	R1,R1, #0x03
	STR 	R1, [R0]
	BX		LR

; ----------- Configura qué GPIO activa EXTI0 y EXTI1 -----------

Config_Syscfg
    ; Asocia EXTI0 y EXTI1 al puerto B (PB0 y PB1)
    LDR     R0, =SYSCFG_EXTICR1
    MOV     R1, #0x0011
    STR     R1, [R0]
    BX      LR

; ----------- Manejador de interrupción EXTI0 -----------

exti0Handler
	PUSH {LR} 
    CMP     R5, R6   
    BHI     salto        ; Si ya está en el máximo, no aumenta más
    ADD     R5,R5,#1200  ; Aumenta ciclo de trabajo
salto
	POP {LR}
    BX      LR

; ----------- Manejador de interrupción EXTI1 -----------

exti1Handler
	PUSH {LR} 
    CMP     R5,#0x1 
    BLO     salto         ; Si ya está en el mínimo, no disminuye
    SUB     R5,R5,#1200   ; Disminuye ciclo de trabajo
	POP {LR}
	BX      LR

; ----------- Configuración del Timer para PWM -----------

Config_TIM
    ; Configura el prescaler
	LDR 	R0, =TIM2_PSC
	MOV 	R1, #999
	STR		R1,[R0]
	
    ; Configura el ARR (auto-reload)
	LDR 	R0, =TIM2_ARR
	MOV 	R1, #23990
	STR		R1,[R0]
	
    ; Modo PWM en canal 1
    LDR 	R0, =TIM2_CCMR1
    LDR 	R1, [R0]
	ORR 	R1, #0x68
	STR		R1,[R0]
	
    ; Habilita salida del canal 1
    LDR 	R0, =TIM2_CCER
	LDR 	R1, [R0]
	ORR 	R1, #(1 << 0)
	STR		R1,[R0]

    ; Habilita el contador y ARPE (auto-reload preload enable)
	LDR 	R0, =TIM2_CR1
	LDR 	R1, [R0]
	ORR 	R1, #0x81
	STR		R1,[R0]
	
	BX 	LR

align
end