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
| AI3 | TT salida placa ACS (crítica para control ACS) | M04 |
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
| DI1 | Caudalímetro Hall ACS | pulsos (rápida CPU/HSC) | M04 |
| DI2 | Aviso corte térmico ACS (NC) | contacto | M04/M10 |
| DI3 | Aviso Z1 (D1, ~90°C) | contacto | M01/M10 |
| DI4 | Aviso Z2 (D2, ~90°C) | contacto | M01/M10 |
| DI5 | Aviso TK1 (~88°C solar) | contacto | M02/M10 |
| DI6 | **Demanda de clima agregada (OR de las 12 zonas, vía Zelio)** | contacto | M05 |
| DI7 | Alarma/estado BC (si no va por RS-485) | contacto | M03 |
| DI8 | Confirmación marcha/caudal depuradora | contacto | M06/M02 |

**~8 usadas de 14 → reserva amplia.** (El detalle zona a zona NO entra al PLC: se agrega en el Zelio, ver abajo.)

### Demandas de termostatos y corte por zona (M05) — RESUELTO con Zelio

**13 fancoils físicos = 12 zonas de control**, porque los **dos fancoils del salón comparten termostato** (van siempre juntos, un solo contacto de demanda). El resto (dormitorios, estudio, invitados, 2 pasillos) son zonas individuales: 11 + 1 (salón) = **12 contactos de demanda**.

Cada zona lleva su cableado a los termostatos para: el **contacto de demanda** on/off y el **change-over** (calor/frío). El **actuador electrotérmico NC de la PICV se gobierna localmente** en cada fancoil con el contacto de su termostato (no se centraliza, por ser distribución arborescente). Los dos fancoils del salón, con su termostato común, abren/cierran a la vez.

**OR de demandas — resuelta con Zelio Logic (FIJADO, opción A):**
- Se usa un **Zelio Logic de 12 entradas** (ya disponible) ubicado en la **vivienda (2ª planta)**, donde están los termostatos.
- Recoge los **12 contactos de demanda**, hace la **OR**, y baja **una sola señal digital** a la **planta baja (sala de máquinas)**, directamente al **cuadro**: *"hay demanda de agua técnica en fancoils"*.
- Esa señal entra al M241 como **DI6** (y/o gobierna el arranque de P2 vía relé).
- **Ventajas:** OR independiente del M241 (la parada de P2 por "sin demanda" sigue operando aunque el PLC falle, en línea con M10); no carga el censo de DI (1 señal en vez de 12); un solo hilo de señal sube/baja entre plantas en vez de 12.

> Descartada la opción B (TM3DI16 con las 12 zonas individuales al PLC): el Zelio ya disponible lo resuelve sin tarjeta extra y con la ventaja de independencia del PLC. Se renuncia a ver zona por zona en el HMI (no necesario).

### Salidas digitales / relé

> Buena práctica: **no usar los relés internos del PLC** para las cargas. Cada DO → **relé de interposición** → carga. La **depuradora** (motor mayor) por **contactor** mandado por relé (ver M13).

| # | Señal | Módulo | Notas |
|---|---|---|---|
| DO1 | P-SOL (PWM) | M02 | salida rápida CPU + divisor. **FIJADO PWM** |
| DO2 | P-ACS (PWM) | M04 | salida rápida CPU + divisor. **FIJADO PWM** |
| DO3 | P1 (trasvase clima) | M05 | on/off, relé interp. |
| DO4 | P2 (fancoils) | M05 | on/off, relé interp. Arranca/para por OR de demandas (vía Zelio) |
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
| DO21 | Change-over calor/frío a termostatos (común) | M05 | gestionable desde el PLC o desde el Zelio |

**~20-21 DO** (2 PWM en salidas rápidas de la CPU + resto on/off vía relé de interposición). Los **actuadores electrotérmicos de las PICV NO son DO del PLC**: se gobiernan localmente con el contacto del termostato de cada zona.

### Comunicaciones

| Señal | Uso |
|---|---|
| RS-485 (Modbus RTU) | hacia la BC (estado, consignas) |
| Ethernet | HMI web (M09) + supervisión remota (M11) |

## Configuraciones de autómata

### Opción A — Schneider Modicon M241 (FIJADA)

**CPU a transistor (PWM nativo para las bombas) + relés de interposición para las cargas.** Las dos bombas modulantes (P-SOL, P-ACS) son **PWM** (Wilo iPWM3 / Grundfos Alpha Solar en variante PWM; ver M02/M08). La CPU a transistor genera el PWM por hardware (ver M09); no se usan salidas analógicas.

| Recurso | Hardware | Cubre |
|---|---|---|
| **CPU** | **TM241CE24T** (transistor) | 14 DI, 10 DO transistor (incl. salidas rápidas para PWM), Ethernet + línea serie |
| **Temperatura** | **2× TM3TI8T** | 16 canales (PT1000) |
| **Salidas extra** | **1× TM3DQ16T** | 16 DO transistor → 26 DO en total (sobre ~20 necesarias) |
| **Demanda fancoils** | **Zelio Logic de 12 entradas** (externo, ya disponible) | OR de 12 zonas → 1 DI (DI6) |
| **PWM bombas** | 2 salidas rápidas de la CPU | P-SOL, P-ACS (+ divisor 24V→nivel de la bomba) |
| **DI** | 14 integradas | ~8 necesarias (1 rápida HSC para el Hall), amplia reserva |
| **Interposición** | Relés externos por cada DO | Conmutan la potencia |
| **RS-485** | Línea serie integrada | Modbus RTU a BC |
| **Ethernet** | Integrado | Web server (HMI) + Modbus TCP + supervisión |
| **Programación** | EcoStruxure Machine Expert (CODESYS 3.5) | — |

**Sondas: PT1000.** **Bombas modulantes: PWM.**

#### Lista de compra del autómata (precios de referencia may-2026)

| Ud. | Referencia | Descripción | Precio ref. |
|---|---|---|---|
| 1 | **TM241CE24T** | CPU transistor, 14 DI / 10 DO, Ethernet + serie | ~150 € |
| 2 | **TM3TI8T** | 8 canales temperatura (PT1000) c/u | ~100 € c/u (1 usada posible) |
| 1 | **TM3DQ16T** | 16 DO transistor | ~86 € |
| — | **Zelio Logic 12 entradas** | OR de demandas de fancoils | **ya disponible (no se compra)** |

Total orientativo autómata: **~440 €**. El Zelio para la OR de demandas **ya se tiene** (12 entradas, suficientes para las 12 zonas). Precios eBay, a contrastar.

> **Antes de comprar:** confirmar en el catálogo de EcoStruxure Machine Expert que la CPU es **24T** (transistor source — la 24U es sink, la 24R es relé y NO genera PWM) y los módulos TM3TI8T y TM3DQ16T. Si una TM3TI8T es usada, confirmar referencia y funcionamiento con el vendedor.
>
> **Descartado:** lote de 2ª mano con CPU relé (24R no hace PWM), TM3AQ (era para 0-10V) y TM3AI4 (sin sensores analógicos en el diseño). Bombas 0-10V descartadas por precio frente a las PWM. Tarjeta TM3DI16 para las demandas (la resuelve el Zelio ya disponible).
>
> Margen: el M241 admite añadir módulos TM3 más adelante (p.ej. TM3AI4 para presiones, o TM3DI) sin rehacer nada, si en el futuro hiciera falta.

### Opción B — Eliwell FREE Evolution + módulo Ethernet

Controlador modular con display, RS-485 y **módulo Ethernet**. I/O base + expansiones hasta cubrir el censo (16 NTC, DI, ~20 DO, PWM para bombas). **Sondas: NTC 10K.**

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
- Verificar compatibilidad de la salida del Zelio (contacto seco/tensión) con la DI del M241 / arranque de P2.
