.include "M8515def.inc"

.equ keyport = PORTA
.equ colport = PINA
.equ rowdir = DDRA
.equ coldirdir = DDRA
.equ pressed = 0

SETCONFIG:
    LDI R17, high(RAMEND)
    OUT SPH, R17
    LDI R17, low(RAMEND)
    OUT SPL, R17

    LDI R17, 0xF0
    OUT rowdir, R17
    LDI R17, 0x0F
    OUT PORTA, R17

    LDI R17, 0xFF
    OUT DDRD, R17
    LDI R16, 0x10

    CLI
    RJMP INIT

INIT:
    RCALL GET_KEY
    RCALL DISPLAY_KEY
    RJMP INIT

GET_KEY:
    CLR R18

    LDI R20, 0x00
    LDI R17, 0b01111111
    OUT keyport, R17
    RCALL READ_COL
    CPI R18, 0x01
    BREQ EPA

    LDI R20, 0x04
    LDI R17, 0b10111111
    OUT keyport, R17
    RCALL READ_COL
    CPI R18, 0x01
    BREQ EPA

    LDI R20, 0x08
    LDI R17, 0b11011111
    OUT keyport, R17
    RCALL READ_COL
    CPI R18, 0x01
    BREQ EPA

    LDI R20, 0x0C
    LDI R17, 0b11101111
    OUT keyport, R17
    RCALL READ_COL
    CPI R18, 0x01
    BREQ EPA
    RET

EPA:
    MOV R16, R20
    RET

READ_COL:
    CBR R18, (1 << pressed)

    SBIC colport, 0
    RJMP NEXT_COL
    RCALL WAIT_RELEASE
    RET

NEXT_COL:
    SBIC colport, 1
    RJMP NEXT_COL1
    INC R20
    RCALL WAIT_RELEASE
    RET

NEXT_COL1:
    SBIC colport, 2
    RJMP NEXT_COL2
    INC R20
    INC R20
    RCALL WAIT_RELEASE
    RET

NEXT_COL2:
    SBIC colport, 3
    RJMP DONE
    INC R20
    INC R20
    INC R20
    RCALL WAIT_RELEASE
    RET

DONE:
    RET

WAIT_RELEASE:
    RCALL DELAY
    IN R17, PORTA
    CPI R17, 0x0F
    BRLO WAIT_RELEASE
    SBR R18, (1 << pressed)
    RET

DISPLAY_KEY:
    LDI ZH, high(numbers * 2)
    LDI ZL, low(numbers * 2)
    ADD ZL, R16
    LPM R17, Z

	com r17
    OUT PORTD, R17
    RET

DELAY:
    LDI R23, 100
OUTER_LOOP:
    LDI R21, 1
INNER_LOOP:
    LDI R22, 80
INNERMOST_LOOP:
    NOP
    DEC R22
    BRNE INNERMOST_LOOP
    DEC R21
    BRNE INNER_LOOP
    DEC R23
    BRNE OUTER_LOOP
    RET

numbers:
    .db 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07
    .db 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71
    .db 0x00
