# M12 — Mapa de E/S y configuraciones de autómata

**Estado:** 🔶 censo de señales cerrado · **hardware Schneider fijado (Ruta A — lote 2ª mano + 0-10V)** · cuentas exactas de canales Eliwell pendientes de catálogo.
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

### Salidas analógicas — bombas modulantes (0-10V)

> Las dos bombas modulantes se gobiernan por **señal analógica 0-10V** (módulo TM3AQ), no por PWM. Ver M09 (decisión Ruta A: CPU relé 24R, que no genera PWM).

| # | Señal | Tipo | Módulo |
|---|---|---|---|
| AO1 | Consigna velocidad P-SOL | 0-10V | M02 |
| AO2 | Consigna velocidad P-ACS | 0-10V | M04 |

**Bombas: con entrada de control 0-10V** (Wilo Stratos/Yonos con modo 0-10V o equivalente; **NO** las iPWM3, que son PWM).

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

### Salidas digitales / relé (on/off)

> Buena práctica: **no usar los relés internos del PLC** para las cargas. Cada DO → **relé de interposición** → carga. La **depuradora** (motor mayor) por **contactor** mandado por relé (ver M13). Las dos bombas modulantes NO están aquí: van por salida analógica 0-10V (ver arriba).

| # | Señal | Módulo | Notas |
|---|---|---|---|
| DO1 | P1 (trasvase clima) | M05 | on/off, relé interp. |
| DO2 | P2 (fancoils) | M05 | on/off, relé interp. |
| DO3 | P-POOL (primario HX piscina) | M06 | on/off, relé interp. |
| DO4 | V3V1 (desviadora impulsión) | M05 | actuador-dependiente |
| DO5 | V3V2 (desviadora retorno) | M05 | actuador-dependiente |
| DO6 | V3V modo BC (estacional) | M03 | |
| DO7 | V3V disipación solar | M02 | enclavada con depuradora |
| DO8–9 | 2× corte antitermosifón serpentín D2 | M05 | spring-return |
| DO10–13 | V3V apartamentos ×4 | M07 | spring-return |
| DO14–15 | Persianas (subir/bajar) | M02 | fail-safe cierra |
| DO16 | Sirena AV1 | M10 | |
| DO17 | Habilitación BC | M03 | línea propia + contacto |
| DO18 | Mando contactor **depuradora** | M06 | relé → contactor |

**Total: ~18 DO on/off.**

### Comunicaciones

| Señal | Uso |
|---|---|
| RS-485 (Modbus RTU) | hacia la BC (estado, consignas) |
| Ethernet | HMI web (M09) + supervisión remota (M11) |

## Configuraciones de autómata

### Opción A — Schneider Modicon M241 (FIJADA — Ruta A)

Configuración elegida: **lote de 2ª mano (CPU relé) + bombas a 0-10V**. La CPU relé **no genera PWM**, por lo que las dos bombas modulantes pasan a **control 0-10V** mediante un módulo de salida analógica TM3AQ (que el propietario ya posee). Esto rescata el lote completo y resulta más económico que la ruta con CPU a transistor.

| Recurso | Hardware | Cubre |
|---|---|---|
| **CPU** | **TM241CE24R** (relé) | 14 DI, 10 DO relé, Ethernet + línea serie |
| **Temperatura** | **2× TM3TI8T** | 16 canales (PT1000) |
| **Salidas analógicas** | **1× TM3AQ** | 0-10V para P-SOL y P-ACS |
| **Salidas extra on/off** | **1× TM3DQ16R** (del lote) | DO relé adicionales hasta ~18 |
| **Entradas analógicas** | **1× TM3AI4** (del lote) | libre, para presiones futuras (no usado hoy) |
| **DI** | 14 integradas en la CPU | ~11 necesarias (1 rápida para el Hall) |
| **Interposición** | Relés externos por cada DO | Conmutan la potencia |
| **RS-485** | Línea serie integrada | Modbus RTU a BC |
| **Ethernet** | Integrado | Web server (HMI) + Modbus TCP + supervisión |
| **Programación** | EcoStruxure Machine Expert (CODESYS 3.5) | — |

**Sondas: PT1000.** **Bombas: 0-10V** (no iPWM3).

#### Lista de compra del autómata (Ruta A, precios de referencia may-2026)

| Ud. | Referencia | Descripción | Origen | Precio ref. |
|---|---|---|---|---|
| 1 | Lote: TM241CE24R + TM3TI8T + TM3DQ16R + TM3AI4 | CPU relé + 1 temp + 16 DO relé + 4 AI | oferta 2ª mano | **150 €** |
| 1 | TM3TI8T | 2.º módulo de temperatura (faltan 8 canales) | 2ª mano (eBay) | ~100 € |
| 1 | TM3AQ | salida analógica 0-10V para las 2 bombas | ya en posesión | 119 € |

Total orientativo: **~369 €** (TM3AI4 incluido de regalo, queda libre para presiones).

**Plan B (si el lote falla o se prefiere PWM):** CPU **TM241CE24T** (transistor, PWM nativo) + 2× TM3TI8T + 1× TM3DQ16T + bombas Wilo iPWM3 (con divisor 24V→~9,6V). ~445 € nuevo. Es la configuración alternativa; la Ruta A la sustituye salvo problema con el lote.

> **Antes de comprar/montar:**
> - Verificar referencias exactas en el **catálogo de EcoStruxure Machine Expert** (fuente definitiva).
> - **Probar el lote de 2ª mano al recibirlo:** CPU arranca, los 8 canales del TM3TI8T, las salidas del TM3DQ16R y las entradas del TM3AI4.
> - Confirmar referencia exacta del 2.º TM3TI8T con el vendedor.
> - **Elegir bombas con entrada 0-10V** (no las iPWM3 del plan B).

### Opción B — Eliwell FREE Evolution + módulo Ethernet

Controlador modular con display, RS-485 y **módulo Ethernet** (necesario para el HMI web y la supervisión). I/O base + módulos de expansión hasta cubrir el censo (16 NTC, ~11 DI, ~18 DO, 2 salidas analógicas 0-10V para bombas). **Sondas: NTC 10K.**

| Recurso | Cobertura |
|---|---|
| NTC | I/O analógica del base + expansiones hasta 16 |
| DI / DO | base + expansiones hasta el censo |
| AO bombas | salida analógica 0-10V según modelo |
| RS-485 | integrada |
| Ethernet | **módulo Ethernet** |
| Display | sí |
| Programación | FREE Studio (CODESYS 2.3) |

### Opción C — Eliwell FREE Smart (compacta, alternativa)

Controlador compacto con display y RS-485. **Sin Ethernet** (confirmado): no hay HMI web ni supervisión remota — se opera por display local + RS-485. Menos I/O; apto si se reduce alcance.

## Consecuencias de la elección

- **Modicon M241 (TM241CE24R, Ruta A)** y **Evolution + Ethernet** mantienen todo (HMI web M09, supervisión M11). Son equivalentes funcionales.
- **FREE Smart** sin Ethernet pierde el HMI web; M09/M11 habría que replantearlos (display local).
- En las tres, las **Cadenas de Seguridad (M10) son cableadas e independientes del autómata**.
- **El tipo de sonda cambia con el autómata:** PT1000 (Schneider) / NTC 10K (Eliwell).
- **Las bombas modulantes son 0-10V** en la configuración fijada (no PWM).

## Pendientes

- Verificar referencias/canales del hardware Schneider en el catálogo de EcoStruxure y **probar el lote de 2ª mano** al recibirlo.
- Seleccionar bombas P-SOL y P-ACS con **entrada 0-10V**.
- **Confirmar con catálogo Eliwell** las cuentas de canales del FREE Evolution y expansiones.
- Recuento fino de DO (actuadores de V3V: 1 vs 2 DO según sean SPDT u open/close).
- Cerrar si las seguridades térmicas (corte ACS, Z1/Z2, TK1) se llevan al autómata como avisos además de su corte por hardware (recomendado sí).
- Fijar referencia de sonda PT1000 (rama Schneider) y NTC 10K (rama Eliwell).
