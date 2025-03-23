; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; -------------- PORTS --------------
; ------------- 18/03/2025 -------------
; ------------- Variables -------------

; ---------------- Main ----------------
; -- CLocks --
RCC_BASE        EQU 0x4002_3800
RCC_AHB1        EQU (RCC_BASE  + 0x30)
; -- GPIO --
GPIOC_BASE       EQU 0x40020800
GPIOC_MODER     EQU (GPIOC_BASE + 0x00)
;-- Configuration Registers --
GPIOC_OTYPER    EQU (GPIOC_BASE + 0x04)
GPIOC_OSPEED    EQU (GPIOC_BASE + 0x08)
GPIOC_PUPDR     EQU (GPIOC_BASE + 0x0C)
;-- Comm Registers --
GPIOC_IDR       EQU (GPIOC_BASE + 0x10)
GPIOC_ODR       EQU (GPIOC_BASE + 0x14)

;-- Special Registers --
GPIOC_BSSR       EQU (GPIOC_BASE + 0x18) ; Bit Set Set Register


	AREA myData, DATA, READWRITE
arrayDes DCB 123, 27, 50, 255, 01, 03, 06, 07, 99, 1, 0,33,120,200,240,158,190, 254, 76, 18

    AREA juve3dstudio,CODE,READONLY
	ENTRY
	EXPORT main

main
    BL      Config_RCC
    BL      Config_GPIO
    
Config_RCC
    LDR     R0,=RCC_AHB1
    LDR     R1,[R0]
    ORR     R1,R1,#4
    STR     R1,[R0]
    BX      LR

Config_GPIO
    LDR     R0, =GPIOC_MODER
    LDR     R1, [R0]
    MOV     R2, #0x4000
    LSL     R2, R2, #12     ;4000 0000 0000 0000 
    ORR     R1,R1,R2
    STR     R1,[R0]


    LDR     R0, =GPIOC_OSPEED
    LDR     R1, [R0]
    MOV     R2, #0x0C00
    LSL     R2, R2, #12     ;4000 0000 0000 0000 
    ORR     R1,R1,R2
    STR     R1,[R0]


    BX      LR

ciclo b ciclo
	align
	
	end