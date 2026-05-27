# M12 — Mapa de E/S y configuraciones de autómata

**Estado:** 🔶 censo de señales cerrado · **hardware Schneider fijado (CPU transistor + PWM)** · cuentas exactas de canales Eliwell pendientes de catálogo.
**Transversal a:** todos los módulos. **Relacionado con:** M09 (control).

## Principio

El diseño hidráulico y la lógica de control son **independientes del autómata**. El código (ST, IEC 61131-3) es portable entre ambos entornos. Lo único que cambia entre **Eliwell** y **Modicon** es **a qué borne físico va cada señal** y **el tipo de sonda de temperatura** (ver aviso). Este módulo mantiene las dos opciones vivas mapeando el censo único de señales a cada hardware.

> **Portabilidad del código:** FREE Studio (Eliwell) es CODESYS 2.3.x; EcoStruxure Machine Expert (Modicon) es CODESYS 3.5. El código ST es conceptualmente el mismo pero **no se transfiere automáticamente entre IDEs**: hay que reintroducir/adaptar los POU al cambiar de plataforma. Las dos opciones comparten diseño, no proyecto compilado.

> ⚠️ **Tipo de sonda según autómata:** el censo cita NTC 10K (estándar Eliwell). Los módulos de temperatura TM3 de Schneider (TM3TI8T) leen **termopar y RTD (PT100/PT1000)**, **no NTC 10K**. → **Rama Eliwell: sondas NTC 10K. Rama Schneider: sondas PT1000.** Es una sustitución de componente, no de diseño; la lógica de control es la misma.

## Censo de señales del sistema

### Entradas analógicas — sondas de temperatura

> Tipo: **NTC 10K** (rama Eliwell) / **PT1000** (rama Schneider). En vaina.

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

**Total: 13 + 3 reserva = 16 canales.**

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
| DI11 | Confirmación marcha/caudal depuradora | contacto | M06/M02 |

**~11 usadas de 14 → 3 de reserva.**

### Salidas digitales / relé

> Buena práctica: **no usar los relés internos del PLC** para las cargas. Cada DO → **relé de interposición** → carga. La **depuradora** (motor mayor) por **contactor** mandado por relé (ver M13).

| # | Señal | Módulo | Notas |
|---|---|---|---|
| DO1 | P-SOL (PWM) | M02 | salida rápida CPU + divisor |
| DO2 | P-ACS (PWM) | M04 | salida rápida CPU + divisor |
| DO3 | P1 (trasvase clima) | M05 | on/off, relé interp. |
| DO4 | P2 (fancoils) | M05 | on/off, relé interp. |
| DO5 | P-POOL (primario HX piscina) | M06 | on/off, relé interp. |
| DO6 | V3V1 (desviadora impulsión) | M05 | actuador-dependiente |
| DO7 | V3V2 (desviadora retorno) | M05 | actuador-dependiente |
| DO8 | V3V modo BC (estacional) | M03 | |
| DO9 | V3V disipación solar | M02 | enclavada con depuradora |
| DO10–11 | 2× corte antitermosifón serpentín D2 | M05 | spring-return |
| DO12–15 | V3V apartamentos ×4 | M07 | spring-return |
| DO16–17 | Persianas (subir/bajar) | M02 | fail-safe cierra |
| DO18 | Sirena AV1 | M10 | |
| DO19 | Habilitación BC | M03 | línea propia + contacto |
| DO20 | Mando contactor **depuradora** | M06 | relé → contactor |

**~20 DO** (2 PWM en salidas rápidas de la CPU + ~18 on/off vía relé de interposición).

### Comunicaciones

| Señal | Uso |
|---|---|
| RS-485 (Modbus RTU) | hacia la BC (estado, consignas) |
| Ethernet | HMI web (M09) + supervisión remota (M11) |

## Configuraciones de autómata

### Opción A — Schneider Modicon M241 (FIJADA)

**CPU a transistor (PWM nativo para las bombas) + relés de interposición para las cargas.** Las dos bombas modulantes (P-SOL, P-ACS) son **PWM** (Wilo iPWM3 u OEM tipo UPM3/HEP Plus en variante PWM; abundantes y económicas). La CPU a transistor genera el PWM por hardware (ver M09); no se usan salidas analógicas.

| Recurso | Hardware | Cubre |
|---|---|---|
| **CPU** | **TM241CE24T** (transistor) | 14 DI, 10 DO transistor (incl. salidas rápidas para PWM), Ethernet + línea serie |
| **Temperatura** | **2× TM3TI8T** | 16 canales (PT1000) |
| **Salidas extra** | **1× TM3DQ16T** | 16 DO transistor → 26 DO en total (sobre ~20 necesarias) |
| **PWM bombas** | 2 salidas rápidas de la CPU | P-SOL, P-ACS (+ divisor 24V→~9,6V para iPWM3) |
| **DI** | 14 integradas | ~11 necesarias (1 rápida para el Hall), 3 reserva |
| **Interposición** | Relés externos por cada DO | Conmutan la potencia |
| **RS-485** | Línea serie integrada | Modbus RTU a BC |
| **Ethernet** | Integrado | Web server (HMI) + Modbus TCP + supervisión |
| **Programación** | EcoStruxure Machine Expert (CODESYS 3.5) | — |

**Sondas: PT1000.** **Bombas: PWM.**

#### Lista de compra del autómata (precios de referencia may-2026)

| Ud. | Referencia | Descripción | Precio ref. |
|---|---|---|---|
| 1 | **TM241CE24T** | CPU transistor, 14 DI / 10 DO, Ethernet + serie | ~150 € |
| 2 | **TM3TI8T** | 8 canales temperatura (PT1000) c/u | ~100 € c/u (1 usada posible) |
| 1 | **TM3DQ16T** | 16 DO transistor | ~86 € |

Total orientativo: **~440 €** (menos con una TM3TI8T de 2ª mano). Precios eBay, a contrastar.

> **Antes de comprar:** confirmar en el catálogo de EcoStruxure Machine Expert que la CPU es **24T** (transistor source — la 24U es sink, la 24R es relé y NO genera PWM) y los módulos TM3TI8T y TM3DQ16T. Si una TM3TI8T es usada, confirmar referencia y funcionamiento con el vendedor.
>
> **Descartado:** lote de 2ª mano con CPU relé (24R no hace PWM), TM3AQ (era para 0-10V) y TM3AI4 (sin sensores analógicos en el diseño). Bombas 0-10V descartadas por precio frente a las PWM.
>
> Margen: el M241 admite añadir módulos TM3 más adelante (p.ej. TM3AI4 para presiones, o TM3DI) sin rehacer nada, si en el futuro hiciera falta.

### Opción B — Eliwell FREE Evolution + módulo Ethernet

Controlador modular con display, RS-485 y **módulo Ethernet**. I/O base + expansiones hasta cubrir el censo (16 NTC, ~11 DI, ~20 DO, PWM para bombas). **Sondas: NTC 10K.**

| Recurso | Cobertura |
|---|---|
| NTC | I/O analógica del base + expansiones hasta 16 |
| DI / DO | base + expansiones hasta el censo |
| PWM bombas | salida PWM según modelo |
| RS-485 | integrada |
| Ethernet | **módulo Ethernet** |
| Display | sí |
| Programación | FREE Studio (CODESYS 2.3) |

### Opción C — Eliwell FREE Smart (compacta, alternativa)

Controlador compacto con display y RS-485. **Sin Ethernet**: no hay HMI web ni supervisión remota — se opera por display local + RS-485. Menos I/O; apto si se reduce alcance.

## Consecuencias de la elección

- **Modicon M241 (TM241CE24T)** y **Evolution + Ethernet** mantienen todo (HMI web M09, supervisión M11). Son equivalentes funcionales.
- **FREE Smart** sin Ethernet pierde el HMI web; M09/M11 habría que replantearlos (display local).
- En las tres, las **Cadenas de Seguridad (M10) son cableadas e independientes del autómata**.
- **El tipo de sonda cambia con el autómata:** PT1000 (Schneider) / NTC 10K (Eliwell).

## Pendientes

- Verificar referencias/canales del hardware Schneider en el catálogo de EcoStruxure antes de comprar.
- Seleccionar bombas P-SOL y P-ACS **PWM** (la del solar, apta glicol/alta temperatura).
- **Confirmar con catálogo Eliwell** las cuentas de canales del FREE Evolution y expansiones.
- Recuento fino de DO (actuadores de V3V: 1 vs 2 DO según sean SPDT u open/close).
- Fijar referencia de sonda PT1000 (rama Schneider) y NTC 10K (rama Eliwell).
