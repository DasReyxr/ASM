# ExamenCalcIEEE

## Descripcion

Este proyecto implementa una calculadora de punto flotante en ensamblador ARM para un STM32F411CEU. El flujo completo trabaja asi:

1. recibe dos numeros por UART como texto ASCII
2. separa signo, parte entera y parte fraccionaria
3. convierte cada operando a formato IEEE 754 de 32 bits
4. realiza la operacion aritmetica segun los signos de entrada
5. convierte el resultado a texto decimal y lo imprime por UART

La aplicacion esta pensada para correrse desde Keil uVision sobre un Cortex-M4 y usa acceso directo a registros de perifericos.

## Objetivo del examen

El proyecto demuestra tres ideas principales:

- parseo de numeros decimales desde una interfaz serial
- conversion decimal a IEEE 754 simple precision
- suma y resta de operandos IEEE 754 en ensamblador

## Plataforma

- MCU: STM32F411CEUx
- CPU: Cortex-M4
- Entorno de proyecto: Keil uVision / MDK-ARM
- Toolchain registrada en el proyecto: ArmClang 6.22 / ArmAsm 6.22
- Proyecto principal: `tst.uvprojx`

El archivo del proyecto indica soporte para los paquetes CMSIS y STM32F4xx Device Family Pack.

## Estructura del proyecto

| Archivo | Rol principal |
| --- | --- |
| `config.s` | Punto de entrada. Configura RCC, GPIO, TIM2 y USART1, y luego transfiere control a la interfaz UART. |
| `1UART.s` | Captura texto desde UART, valida caracteres, separa entero y fraccion, detecta signo y prepara los datos para conversion. |
| `2IEEE.s` | Convierte el numero capturado a IEEE 754 de 32 bits. Maneja primer y segundo operando. |
| `3ALU.s` | Alinea exponentes, opera mantisas y recompone el resultado IEEE. |
| `4INTGOUT.s` | Convierte el resultado IEEE a una salida decimal legible y la envia por UART. |
| `configBlinBlin.s` | Variante de configuracion auxiliar. |
| `1UARTBlinBlin.txt` | Notas o respaldo relacionado con la rutina UART. |
| `RTE/` | Archivos CMSIS y de arranque generados por Keil. |
| `Objects/` | Binarios y artefactos de compilacion. |
| `Listings/` | Salidas de listado del ensamblador y linker. |

## Flujo de ejecucion

### 1. Arranque y configuracion

`config.s` define `__main` y realiza:

- habilitacion de relojes RCC
- configuracion de GPIOB para funcion alternativa de USART1
- configuracion de TIM2
- configuracion de USART1
- salto a `UART`

En el codigo actual, USART1 se configura escribiendo directamente `BRR` y `CR1`.

## 2. Captura del numero por UART

`1UART.s` muestra el mensaje `Enter Number:` y procesa la entrada caracter por caracter.

La rutina acepta:

- digitos `0` a `9`
- punto decimal `.`
- signo negativo `-`
- Enter para confirmar el numero

Internamente usa dos buffers:

- `ENTERO` para la parte entera
- `FRAC` para la parte fraccionaria

Despues convierte los digitos ASCII a valores numericos y genera dos cantidades:

- `R2`: parte entera
- `R11`: parte fraccionaria escalada

## 3. Conversion a IEEE 754

`2IEEE.s` contiene la rutina `calc`, que construye el numero IEEE a partir de:

- signo
- entero
- fraccion

Las subrutinas principales son:

- `Fract`: genera la mantisa fraccionaria a partir de una escala decimal de 10000
- `Integer`: inserta la parte entera en la mantisa normalizada
- `Exponente`: calcula el exponente sesgado y atiende el caso de numero menor que 1

El flujo primero convierte el primer operando, vuelve a pedir el segundo por UART y despues entrega ambos operandos a la ALU.

## 4. Operacion aritmetica

`3ALU.s` recibe los dos operandos IEEE y realiza:

- extraccion de signo, exponente y mantisa
- alineacion de exponentes
- desplazamiento de la mantisa del operando con menor exponente
- suma o resta de mantisas segun los signos
- normalizacion del resultado
- reconstruccion del IEEE final

El resultado final queda en `R10` antes de enviarse a la rutina de salida.

## 5. Impresion del resultado

`4INTGOUT.s` toma el valor IEEE final y lo convierte a texto decimal.

La rutina:

- detecta el signo
- extrae exponente y mantisa
- reconstruye la parte entera
- calcula una fraccion decimal con 4 digitos
- imprime el resultado por UART

Tambien contempla salidas de texto para casos como `Inf`.

## Interfaz serial

Por la configuracion actual del proyecto, la aplicacion usa USART1 con registros base en `0x40011000`.

Detalles visibles en el codigo:

- `USART1_BRR = 0x683`
- `USART1_CR1` habilita UART, transmision y recepcion
- GPIOB se configura en funcion alternativa AF7 para USART1

Para probarlo en hardware, conecta una terminal serial y envia los operandos como texto, uno por uno, terminando cada uno con Enter.

## Formato de entrada esperado

El codigo esta pensado para trabajar con numeros decimales con este estilo:

- `15`
- `27.75`
- `-1.5`
- `0.1250`

Observaciones practicas:

- el buffer de entero reserva 10 bytes
- la conversion fraccionaria esta pensada alrededor de una escala decimal de 10000
- la salida impresa muestra 4 digitos de fraccion

## Compilacion

La forma mas directa de usar el proyecto es abrirlo en Keil:

1. abrir `tst.uvprojx`
2. seleccionar `Target_1`
3. compilar el proyecto
4. programar el STM32F411CEU o correr en el entorno configurado

## Estado de build

El log incluido en `Objects/tst.build_log.htm` muestra una compilacion exitosa del proyecto.

Resumen del ultimo build registrado:

- toolchain MDK-Lite 5.41.0.0
- assembler ArmAsm 6.22
- linker exitoso
- salida generada: `Objects/tst.axf`
- tamano reportado: `Code=2484`, `RO-data=408`, `RW-data=16`, `ZI-data=1536`

Durante ese build aparecen advertencias menores del ensamblador, pero el ejecutable se genera correctamente.

## Observaciones tecnicas

- El proyecto usa acceso directo a registros, no HAL ni LL.
- `TIM2` se configura en `config.s`, pero no participa de forma visible en el flujo principal de la calculadora.
- La ALU implementa el camino base de suma/resta y normalizacion, pero no pretende ser una implementacion completa de IEEE 754.
- El manejo de casos especiales existe de forma parcial, por ejemplo `Inf` y algunas rutas de error.
- El codigo esta orientado a fines academicos y a demostrar el algoritmo mas que a cubrir todos los corner cases del estandar.

## Flujo resumido de archivos

`config.s` -> `1UART.s` -> `2IEEE.s` -> `3ALU.s` -> `4INTGOUT.s` -> `1UART.s`

Ese ciclo permite ingresar operandos, calcular y volver a pedir un nuevo numero por UART.