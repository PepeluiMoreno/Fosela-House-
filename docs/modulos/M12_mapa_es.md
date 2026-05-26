# M12 — Mapa de E/S y configuraciones de autómata

**Estado:** 🔶 censo de señales cerrado · asignación a bornes Modicon concreta · cuentas exactas de canales Eliwell **pendientes de catálogo**.
**Transversal a:** todos los módulos. **Relacionado con:** M09 (control).

## Principio

El diseño hidráulico y la lógica de control son **independientes del autómata**. El código (ST, IEC 61131-3) es portable entre ambos entornos. Lo único que cambia entre **Eliwell** y **Modicon** es **a qué borne físico va cada señal**. Este módulo mantiene las dos opciones vivas mapeando el censo único de señales a cada hardware.

> **Portabilidad del código:** FREE Studio (Eliwell) es CODESYS 2.3.x; EcoStruxure Machine Expert (Modicon) es CODESYS 3.5. El código ST es conceptualmente el mismo pero **no se transfiere automáticamente entre IDEs**: hay que reintroducir/adaptar los POU al cambiar de plataforma. Las dos opciones comparten diseño, no proyecto compilado.

## Censo de señales del sistema

### Entradas analógicas — sondas de temperatura (NTC 10K, en vaina)

| # | Señal | Módulo |
|---|---|---|
| AI1 | TT ida glicol | M02 |
| AI2 | TT retorno glicol | M02 |
| AI3 | TT salida placa ACS (rápida) | M04 |
| AI4 | TT retorno primario ACS | M04 |
| AI5 | TT5 tapa D2 (reservorio) | M01 |
| AI6 | TT D1 (solar) | M01 |
| AI7 | TT buffer clima | M05 |
| AI8 | TT piscina (lado técnico) | M06 |
| AI9 | TT impulsión fancoils | M05 |
| AI10 | TT retorno fancoils | M05 |
| AI11 | TT ACS distribución (post-VMT1) | M04 |
| AI12 | TT exterior / ambiente | M05 |
| AI13 | TT estratificación D2 (media) | M01 |
| — | 3 spare | — |

**Total: 13 NTC + 3 reserva = 16 canales.**

### Entradas digitales

| # | Señal | Tipo | Módulo |
|---|---|---|---|
| DI1 | Caudalímetro Hall ACS | pulsos (rápida) | M04 |
| DI2 | Aviso corte térmico ACS (NC) | contacto | M04/M10 |
| DI3 | Aviso Z1 (D1, ~90°C) | contacto | M01/M10 |
| DI4 | Aviso Z2 (D2, ~90°C) | contacto | M01/M10 |
| DI5 | Aviso TK1 (~88°C solar) | contacto | M02/M10 |
| DI6–9 | Demanda de zonas/fancoils (termostatos) | contacto | M05 |
| DI10 | Alarma/estado BC (si no va por RS-485) | contacto | M03 |

### Salidas digitales / relé

| # | Señal | Módulo | Notas |
|---|---|---|---|
| DO1 | P-SOL (PWM) | M02 | salida rápida + divisor |
| DO2 | P-ACS (PWM) | M04 | salida rápida + divisor |
| DO3 | P1 (trasvase clima) | M05 | on/off |
| DO4 | P2 (fancoils) | M05 | on/off |
| DO5 | P-POOL | M06 | on/off |
| DO6 | V3V1 (desviadora impulsión) | M05 | actuador-dependiente |
| DO7 | V3V2 (desviadora retorno) | M05 | actuador-dependiente |
| DO8 | V3V modo BC (estacional) | M03 | |
| DO9 | V3V disipación solar | M02 | |
| DO10–11 | 2× corte antitermosifón serpentín D2 | M05 | spring-return |
| DO12–15 | V3V apartamentos ×4 | M07 | spring-return |
| DO16–17 | Persianas (subir/bajar) | M02 | fail-safe cierra |
| DO18 | Sirena AV1 | M10 | |
| DO19 | Habilitación BC | M03 | |

### Comunicaciones

| Señal | Uso |
|---|---|
| RS-485 (Modbus RTU) | hacia la BC (estado, consignas) |
| Ethernet | HMI web (M09) + supervisión remota (M11) |

## Configuraciones de autómata

### Opción A — Schneider Modicon M241 (TM241CE24R)

| Recurso | Hardware |
|---|---|
| 16 NTC | 2× TM3TI8T |
| DI (incl. rápidas) | DI integradas del M241 (8 rápidas para Hall/PWM) |
| DO relé | DO del M241 + TM3DQ/DO16R según recuento |
| AI 0-10V/4-20mA | 2× TM3AI4 (presión, etc., mejoras) |
| PWM bombas | DO rápidas + divisor 24V→~9,6V (Wilo iPWM3) |
| RS-485 | ×2 integradas |
| Ethernet | integrado (web server + Modbus TCP) |
| Programación | EcoStruxure Machine Expert (CODESYS 3.5) |

### Opción B — Eliwell FREE Evolution + módulo Ethernet (recomendada Eliwell)

Controlador modular con display, RS-485 y **módulo Ethernet** (necesario para el HMI web y la supervisión). I/O base + módulos de expansión hasta cubrir el censo (16 NTC, ~10 DI, ~19 DO, salidas analógicas/PWM para bombas).

| Recurso | Cobertura |
|---|---|
| NTC | I/O analógica del base + expansiones hasta 16 |
| DI / DO | base + expansiones hasta el censo |
| PWM bombas | salida analógica/PWM según modelo (verificar nivel para iPWM3) |
| RS-485 | integrada |
| Ethernet | **módulo Ethernet** |
| Display | sí |
| Programación | FREE Studio (CODESYS 2.3) |

### Opción C — Eliwell FREE Smart (compacta, alternativa)

Controlador compacto con display y RS-485. ⚠️ **Sin Ethernet** (verificar): si no lo lleva, **no hay HMI web ni supervisión remota** — se opera por display local + RS-485. Menos I/O; apto si se reduce alcance o se acepta menos instrumentación.

## Consecuencias de la elección

- **Evolution + Ethernet** mantiene todo (HMI web M09, supervisión M11). Es la equivalente funcional al M241.
- **FREE Smart** sin Ethernet pierde el HMI web; M09/M11 habría que replantearlos (display local).
- En las tres, las **Cadenas de Seguridad (M10) son cableadas e independientes del autómata**: no dependen de qué modelo se monte.

## Pendientes

- **Confirmar con catálogo Eliwell** las cuentas exactas de canales del FREE Evolution y FREE Smart y los módulos de expansión necesarios para cubrir el censo.
- Confirmar si el FREE Smart admite módulo Ethernet; si no, decidir HMI alternativo o descartarlo para este alcance.
- Verificar nivel/forma de la salida de bombas en Eliwell para el rango iPWM3 de Wilo (4,5–15V).
- Recuento fino de DO (actuadores de V3V: 1 vs 2 DO según sean SPDT u open/close).
- Cerrar si las seguridades térmicas (corte ACS, Z1/Z2, TK1) se llevan al autómata como avisos además de su corte por hardware (recomendado sí).
