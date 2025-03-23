; ----------- Orlando Reyes -----------
; -------------- Auf Das --------------
; -------------- 7DCMotor -------------
; ------------- 15/11/2024 ------------
; Optimized Motor Control Code for ATmega8515

; ------------- Variables -------------

.def    WREG    = R16
.def    var1    = R18          ; General-purpose variable
.def    VELH    = R19          ; Velocity high byte
.def    VELL    = R20          ; Velocity low byte
.def    COMM    = R22          ; Command register (Bluetooth)

; --------- Port and Pin Definitions ---------
#define PORT_MOTOR   PORTB
#define DDR_MOTOR    DDRB

#define INLB    1               ; Motor driver INLB
#define INLF    0               ; Motor driver INLF
#define INRB    2               ; Motor driver INRB
#define INRF    3               ; Motor driver INRF

; -------------- Macros --------------

.macro LEFT_Front
    SBI PORT_MOTOR, INLB
    CBI PORT_MOTOR, INLF
.endmacro

.macro LEFT_Back
    CBI PORT_MOTOR, INLB
    SBI PORT_MOTOR, INLF
.endmacro

.macro LEFT_STOP
    CBI PORT_MOTOR, INLB
    CBI PORT_MOTOR, INLF
.endmacro

.macro RIGHT_Front
    SBI PORT_MOTOR, INRF
    CBI PORT_MOTOR, INRB
.endmacro

.macro RIGHT_Back
    CBI PORT_MOTOR, INRF
    SBI PORT_MOTOR, INRB
.endmacro

.macro RIGHT_STOP
    CBI PORT_MOTOR, INRF
    CBI PORT_MOTOR, INRB
.endmacro

; ------------ Speed Table ------------
SpeedTable:
    .db 0x00, 0x33, 0x66, 0x99, 0xCC, 0xFF

; ------------ Main Program -----------
.include "M8515def.inc"
RJMP SETCONFIG
RJMP INIT
RJMP EXT_INT0
RJMP TIM1_OVF
RJMP USART_RXC

; --------- Configuration -------------
SETCONFIG:
    LDI WREG, high(RAMEND)
    OUT SPH, WREG
    LDI WREG, low(RAMEND)
    OUT SPL, WREG
    CLI

    RCALL SET_COM
    SBI DDR_MOTOR, INLB
    SBI DDR_MOTOR, INLF
    SBI DDR_MOTOR, INRB
    SBI DDR_MOTOR, INRF

    RCALL SET_TIMER
    CLR COMM

; ----------- Initialization ----------
INIT:
    cpi COMM, 'F'
    breq LF_FWD_INLINE
    cpi COMM, 'G'
    breq LG_FWD_INLINE
    cpi COMM, 'I'
    breq LI_FWD_INLINE
    cpi COMM, 'L'
    breq LL_SPIN_INLINE
    cpi COMM, 'R'
    breq LR_SPIN_INLINE
    cpi COMM, 'H'
    breq LH_BWD_INLINE
    cpi COMM, 'J'
    breq LJ_BWD_INLINE
    cpi COMM, 'B'
    breq LB_BWD_INLINE
    cpi COMM, '0'
    breq L0_STOP_INLINE

    subi COMM, '0'
    cpi COMM, 6
    brsh LX_STOP_INLINE

    ldi ZH, high(SpeedTable)
    ldi ZL, low(SpeedTable)
    add ZL, COMM
    adc ZH, r0
    ld VELL, Z+
    ld VELH, Z
    rjmp ActualVel

LF_FWD_INLINE:
    LEFT_Front
    RIGHT_Front
    ldi VELL, 0xFF
    ldi VELH, 0xFF
    rjmp ActualVel

LG_FWD_INLINE:
    LEFT_STOP
    RIGHT_Front
    lsr VELH
    ror VELL
    rjmp ActualVel

LI_FWD_INLINE:
    LEFT_Front
    RIGHT_STOP
    lsr VELH
    ror VELL
    rjmp ActualVel

LL_SPIN_INLINE:
    LEFT_Front
    RIGHT_Back
    lsr VELH
    ror VELL
    rjmp ActualVel

LR_SPIN_INLINE:
    LEFT_Back
    RIGHT_Front
    lsr VELH
    ror VELL
    rjmp ActualVel

LH_BWD_INLINE:
    LEFT_STOP
    RIGHT_Back
    ldi VELL, 0xFF
    ldi VELH, 0xFF
    rjmp ActualVel

LJ_BWD_INLINE:
    LEFT_Back
    RIGHT_STOP
    lsr VELH
    ror VELL
    rjmp ActualVel

LB_BWD_INLINE:
    LEFT_Back
    RIGHT_Back
    lsr VELH
    ror VELL
    rjmp ActualVel

L0_STOP_INLINE:
    ldi VELL, 0x00
    ldi VELH, 0x00
    rjmp ActualVel

LX_STOP_INLINE:
    ldi COMM, 0
    LEFT_STOP
    RIGHT_STOP
    rjmp INIT

; --------- Speed Control ------------
ActualVel:
    out OCR1AH, VELH
    out OCR1AL, VELL
    out OCR1BH, VELH
    out OCR1BL, VELL
    ret

; --------- USART Configuration ---------
SET_COM:
    sbi DDRD, 1
    LDI WREG, 0x00
    OUT UBRRH, WREG
    LDI WREG, 0xCF
    OUT UBRRL, WREG
    LDI WREG, (1<<U2X)
    OUT UCSRA, WREG
    LDI WREG, (1<<RXCIE) | (1<<RXEN) | (1<<TXEN)
    OUT UCSRB, WREG
    LDI WREG, (1<<URSEL) | (3<<UCSZ0)
    OUT UCSRC, WREG

; --------- Timer Configuration ---------
SET_TIMER:
    SBI DDRE, 2
    SBI DDRD, 5
    LDI WREG, 0xA1
    OUT TCCR1A, WREG
    LDI WREG, 0x0B
    OUT TCCR1B, WREG
    SEI
    RET

; --------- Interrupts -------------
USART_RXC:
    in COMM, UDR
    rjmp INIT

EXT_INT0:  RETI
TIM1_OVF:  RETI

; --------- End of Code ------------
