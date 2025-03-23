    TTL Decimal-Binario

dividendo EQU 11 ; Este es el número que se llevará de decimal a binario

    AREA myData, DATA, READWRITE  
        
resi SPACE 32 ; Reserva 32 bytes de espacio en memoria para almacenar el residuo
    
    ; Un obligatorio de nuestro código es llevar un área de código
    AREA myCode, CODE, READONLY 
    ENTRY  
    EXPORT main

main
    LDR R1, =dividendo ; Cargar el valor decimal en R1
    LDR R3, =resi      ; Cargar la dirección de la memoria para almacenar los residuos
    MOV R4, #32        ; Contador para 32 iteraciones (32 bits)

cicloDivisor
    MOV R5, #0         ; Inicializar R5 para contar el número de restas (cociente)

divisionLoop
    CMP R1, #2         ; Comparar R1 con 2
    BLT storeRemainder ; Si R1 < 2, salir del bucle de división
    SUB R1, R1, #2     ; Restar 2 de R1
    ADD R5, R5, #1     ; Incrementar el contador de restas (cociente)
    B divisionLoop     ; Repetir la división

storeRemainder
    STRB R1, [R3], #1  ; Almacenar el residuo (R1) en memoria y avanzar al siguiente byte
    MOV R1, R5         ; Mover el cociente (R5) a R1 para la siguiente iteración

    SUBS R4, R4, #1    ; Decrementar el contador de iteraciones
    BNE cicloDivisor   ; Repetir hasta que se completen las 32 iteraciones

ciclofin
    B ciclofin         ; Bucle infinito al finalizar

    END ; Fin del programa