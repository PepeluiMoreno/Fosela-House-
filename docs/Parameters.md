# Parámetros del sistema — Fusela House

Documento de referencia de todos los parámetros configurables, setpoints, histéresis y offsets del sistema de instalación térmica integrada. Fuente única de verdad para programación, puesta en marcha y mantenimiento.

**Revisión:** 1.0  
**Fecha:** Mayo 2026  
**Controladores:** FREE Smart SMD4500C (solar) + FREE Evolution (sistema principal)

---

## Índice

1. [Convenciones](#1-convenciones)
2. [Solar — FREE Smart](#2-solar--free-smart)
3. [ACS — Agua Caliente Sanitaria](#3-acs--agua-caliente-sanitaria)
4. [Climatización — Fancoils](#4-climatización--fancoils)
5. [Piscina](#5-piscina)
6. [Apartamentos](#6-apartamentos)
7. [Pasteurización antilegionela](#7-pasteurización-antilegionela)
8. [Prioridades BDC](#8-prioridades-bdc)
9. [Protecciones y alarmas hardware](#9-protecciones-y-alarmas-hardware)
10. [Comunicación Modbus RS485](#10-comunicación-modbus-rs485)
11. [HMI — Acceso y seguridad](#11-hmi--acceso-y-seguridad)
12. [Offsets de sondas](#12-offsets-de-sondas)
13. [Tabla resumen](#13-tabla-resumen)

---

## 1. Convenciones

| Símbolo | Significado |
|---|---|
| `SP` | Setpoint (consigna) |
| `HS` | Histéresis (banda muerta, valor total) |
| `OS` | Offset de calibración de sonda |
| `[min – max]` | Rango admisible |
| `paso` | Incremento mínimo de edición desde HMI |
| `DEF` | Valor por defecto de fábrica |
| `RETAIN` | Se conserva tras corte de alimentación |
| `R/O` | Solo lectura (no editable desde HMI) |

**Histéresis**: valor total de la banda muerta. Una histéresis de 4 K sobre un SP de 65 °C significa activación a 63 °C y desactivación a 67 °C (modo calor).

**Encoding Modbus**: todas las temperaturas se transmiten como entero ×10. Ejemplo: 42,5 °C → registro = 425.

---

## 2. Solar — FREE Smart

### 2.1 Bomba solar P1 (lazo PI de ΔT constante)

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `SP_DT_solar` | ΔT objetivo entre colector (TT1) y D1 fondo (TT2) | 8,0 | 3,0 – 15,0 | 0,5 | K | RETAIN |
| `DT_arranque` | ΔT de arranque de P1 | 6,0 | 2,0 – 10,0 | 0,5 | K | RETAIN |
| `DT_parada` | ΔT de parada de P1 (histéresis paro) | 3,0 | 1,0 – 6,0 | 0,5 | K | RETAIN |
| `P1_min_on` | Tiempo mínimo de marcha de P1 (anti-cicleo) | 30 | 10 – 120 | 5 | s | RETAIN |
| `P1_min_off` | Tiempo mínimo de parada de P1 (anti-cicleo) | 20 | 10 – 120 | 5 | s | RETAIN |
| `P1_vel_min` | Velocidad mínima P1 en marcha | 10 | 5 – 30 | 1 | % | RETAIN |

**Lazo PI — parámetros del regulador:**

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `PI_Kp` | Ganancia proporcional | 0,50 | 0,10 – 2,00 | 0,05 | — | RETAIN |
| `PI_Ki` | Ganancia integral | 0,08 | 0,01 – 0,50 | 0,01 | 1/s | RETAIN |

> **Nota puesta en marcha**: con los valores por defecto el lazo es estable para la mayoría de las instalaciones de 6–12 m². Si P1 oscila (sube y baja de velocidad continuamente), reducir `PI_Ki`. Si la respuesta es lenta, aumentar `PI_Kp`.

### 2.2 Válvula V3V_SOL (desvío ACS ↔ piscina)

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `SP_TT3_pool` | TT3 mínimo para autorizar desvío a piscina | 75,0 | 60,0 – 90,0 | 1,0 | °C | RETAIN |
| `modo_solar` | Modo de operación solar | AUTO | AUTO/ACS/PISC/OFF | — | enum | RETAIN |
| `V3V_travel` | Tiempo de maniobra de la válvula | 30 | 15 – 60 | 5 | s | RETAIN |

**Modos solar:**

| Valor | Código | Descripción |
|---|---|---|
| 0 | AUTO | Lógica automática por temperatura |
| 1 | ACS | Forzar siempre a ACS (serp. inf D1) |
| 2 | PISC | Forzar siempre a piscina |
| 3 | OFF | Solar completamente desactivado |

### 2.3 Persianas de colectores (PERS_SOL)

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `SP_TT2_diss` | TT2 (D1 fondo) que activa cierre de persianas | 85,0 | 75,0 – 92,0 | 1,0 | °C | RETAIN |
| `HS_TT2_diss` | Histéresis TT2 para reapertura | 4,0 | 2,0 – 8,0 | 1,0 | K | RETAIN |

> **Cadena hardware TK1**: independiente del software, cierra persianas a ~88 °C. El parámetro `SP_TT2_diss` debe configurarse siempre por debajo de TK1 para que el software actúe antes.

---

## 3. ACS — Agua Caliente Sanitaria

### 3.1 Acumulador D2 — control BDC (V3V1)

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `SP_TT5` | Setpoint temperatura D2 cabeza | 65,0 | 50,0 – 80,0 | 0,5 | °C | RETAIN |
| `HS_TT5` | Histéresis TT5 (banda muerta total) | 4,0 | 1,0 – 8,0 | 0,5 | K | RETAIN |
| `SP_TT4_start` | TT4 D2 fondo: umbral de inicio de carga BDC | 50,0 | 40,0 – 62,0 | 0,5 | °C | RETAIN |
| `HS_TT4` | Histéresis TT4 (banda muerta total) | 3,0 | 1,0 – 6,0 | 0,5 | K | RETAIN |

> **Lógica de carga ACS**: la BDC carga D2 cuando TT4 < (SP_TT4_start − HS_TT4/2) y para cuando TT5 > (SP_TT5 + HS_TT5/2).

### 3.2 Control HTR (V3V3)

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `SP_TT5_HTR_stop` | TT5 que inhibe el HTR hacia D2 | 68,0 | 55,0 – 78,0 | 0,5 | °C | RETAIN |
| `HS_HTR` | Histéresis TT5 para reactivación del HTR | 3,0 | 1,0 – 6,0 | 0,5 | K | RETAIN |

> **HTR por defecto va a D2**: V3V3 = posición A. Solo cambia a piscina (posición B) cuando D2 está satisfecho y piscina tiene demanda.

### 3.3 Válvula VMT1 (mezcladora termostática ACS)

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `VMT1_setpoint` | Temperatura de mezcla ACS en salida | 55,0 | 50,0 – 60,0 | 0,5 | °C | — |

> **Ajuste físico**: VMT1 es una válvula termostática mecánica. No es controlada por el autómata. Su setpoint se ajusta manualmente durante la puesta en marcha con un destornillador. El valor indicado es el objetivo de ajuste.

### 3.4 Antiescaldadura terminal (punto de uso)

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `TAP_max_temp` | Temperatura máxima en grifo/ducha | 45,0 | 38,0 – 48,0 | 1,0 | °C | — |

> **Ajuste físico**: válvulas termostáticas individuales en cada toma. Ajuste mecánico. No controlado por autómata.

---

## 4. Climatización — Fancoils

### 4.1 Buffer D3 — modo calefacción

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `SP_heat` | Setpoint D3 cabeza en modo calefacción | 45,0 | 35,0 – 60,0 | 0,5 | °C | RETAIN |
| `HS_heat` | Histéresis calefacción (total) | 4,0 | 1,0 – 8,0 | 0,5 | K | RETAIN |

> La BDC carga D3 cuando TT6 < (SP_heat − HS_heat/2) en modo V3V2→D3.

### 4.2 Buffer D3 — modo refrigeración

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `SP_cool` | Setpoint D3 fondo en modo refrigeración | 9,0 | 5,0 – 15,0 | 0,5 | °C | RETAIN |
| `HS_cool` | Histéresis refrigeración (total) | 2,0 | 0,5 – 4,0 | 0,5 | K | RETAIN |

> La BDC enfría D3 cuando TT7 > (SP_cool + HS_cool/2) en modo refrigeración.

### 4.3 Bomba P3 (fancoils)

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `P3_min_on` | Tiempo mínimo marcha P3 | 60 | 30 – 300 | 30 | s | RETAIN |
| `P3_min_off` | Tiempo mínimo parada P3 | 30 | 10 – 120 | 10 | s | RETAIN |

---

## 5. Piscina

### 5.1 Temperatura de piscina

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `SP_pool` | Setpoint temperatura piscina (TT11) | 27,0 | 20,0 – 35,0 | 0,5 | °C | RETAIN |
| `HS_pool` | Histéresis temperatura piscina (total) | 1,0 | 0,5 – 3,0 | 0,5 | K | RETAIN |
| `SP_pool_max` | Temperatura máxima piscina (alarma) | 32,0 | 28,0 – 36,0 | 0,5 | °C | RETAIN |

### 5.2 Intercambiadores — lado piscina

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `VP_open_delay` | Retardo apertura VP tras orden | 5 | 2 – 30 | 1 | s | RETAIN |
| `VP_min_open` | Tiempo mínimo apertura VP | 10 | 5 – 60 | 5 | s | RETAIN |
| `VP_travel` | Tiempo de maniobra VP | 15 | 10 – 30 | 5 | s | RETAIN |

### 5.3 Cadena de seguridad piscina (hardware)

| Elemento | Función | Ajuste | Tipo |
|---|---|---|---|
| `IF_PISC` | Interruptor de flujo (NA) en retorno filtro | Paleta calibrada a caudal nominal | Físico |
| `EV_BYPASS` | Electroválvula NC bypass filtración | Cableada en paralelo con VP_HX | Físico |
| `Relé aux.` | Lógica NC→VP en paralelo sin salida Eliwell | 230 VAC | Físico |

> Estos parámetros son ajustes físicos en cuadro eléctrico, no configurables desde HMI.

---

## 6. Apartamentos

### 6.1 Modos V3V_APT

| Código | Descripción | DEF | Valores | Tipo |
|---|---|---|---|---|
| `apt_mode_01` | Modo alimentación CE-01 | PREC | 0=PREC / 1=AFS | RETAIN |
| `apt_mode_02` | Modo alimentación CE-02 | PREC | 0=PREC / 1=AFS | RETAIN |
| `apt_mode_03` | Modo alimentación CE-03 | PREC | 0=PREC / 1=AFS | RETAIN |
| `apt_mode_04` | Modo alimentación CE-04 | PREC | 0=PREC / 1=AFS | RETAIN |
| `apt_mode_05` | Modo alimentación CE-05 | PREC | 0=PREC / 1=AFS | RETAIN |

**Reglas de conmutación automática:**

| Condición | Acción automática | Prioridad |
|---|---|---|
| Mantenimiento central activo | Todos → AFS | Alta |
| Vacancia > `vacancia_threshold` días | Apartamento → AFS | Media |
| Ciclo pasteurización activo | Todos → PREC (forzado) | Máxima |
| Estado normal | PREC (por defecto) | — |

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `vacancia_threshold` | Días sin uso para cambio automático a AFS | 14 | 3 – 30 | 1 | días | RETAIN |

### 6.2 Tiempo de conmutación V3V_APT

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `APT_switch_window` | Ventana horaria para conmutaciones | 03:00 | 00:00–06:00 | 30 min | hh:mm | RETAIN |

> Las conmutaciones programadas de V3V_APT se ejecutan en la franja nocturna configurada para evitar cambios bruscos de temperatura en el grifo durante el uso.

---

## 7. Pasteurización antilegionela

### 7.1 Ciclo principal (D2 → 70 °C)

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `past_target` | Temperatura objetivo D2 durante pasteurización | 70,0 | 65,0 – 75,0 | 0,5 | °C | RETAIN |
| `past_HS` | Histéresis mantenimiento temperatura | 2,0 | 1,0 – 4,0 | 0,5 | K | RETAIN |
| `past_hold_min` | Tiempo de mantenimiento a temperatura | 60 | 30 – 120 | 5 | min | RETAIN |
| `past_day_of_week` | Día de la semana del ciclo automático | LUN | LUN–DOM | — | día | RETAIN |
| `past_hour` | Hora de inicio del ciclo automático | 03:00 | 00:00–05:00 | 30 min | hh:mm | RETAIN |

### 7.2 Purgado de apartamentos

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `past_flush_min` | Tiempo de purgado por apartamento | 30 | 15 – 60 | 5 | min | RETAIN |
| `past_flush_order` | Orden de purgado | 1→5 | configurable | — | — | RETAIN |
| `past_min_temp_flush` | Temperatura mínima en grifo para validar purgado | 60,0 | 55,0 – 65,0 | 0,5 | °C | RETAIN |

### 7.3 Protección antilegionela en D1

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `legionella_D1_days` | Días máximos sin alcanzar 60 °C en TT2 | 7 | 3 – 14 | 1 | días | RETAIN |
| `legionella_D1_temp` | Temperatura mínima objetivo en TT2 | 60,0 | 55,0 – 65,0 | 0,5 | °C | RETAIN |

> Si transcurren `legionella_D1_days` sin que TT2 alcance `legionella_D1_temp`, el controlador fuerza un arranque de P1 de 15 min para mezclar el volumen de D1 con cualquier calor residual.

---

## 8. Prioridades BDC

| Código | Descripción | DEF | Valores | Tipo |
|---|---|---|---|---|
| `bdc_priority` | Orden de prioridad para uso del primario BDC | 0 | 0 = ACS>CLIM>PISC / 1 = ACS>PISC>CLIM | RETAIN |

**Perfil 0 — ACS > Climatización > Piscina** (por defecto):
Adecuado para temporada de ocupación normal. La climatización tiene prioridad sobre la piscina.

**Perfil 1 — ACS > Piscina > Climatización**:
Útil cuando el propietario quiere asegurar temperatura de baño y la demanda de climatización es flexible (p.ej. primavera/otoño con temperatura exterior moderada).

| Subsistema | Condición de activación |
|---|---|
| ACS (máxima prioridad) | TT4 < (SP_TT4_start − HS_TT4/2) |
| Climatización (según perfil) | Demanda activa fancoils Y ACS satisfecho |
| Piscina (según perfil) | TT11 < (SP_pool − HS_pool/2) Y ACS satisfecho Y CLIM satisfecho (en perfil 0) |

---

## 9. Protecciones y alarmas hardware

### 9.1 Alarmas software (FREE Evolution)

| Código | Descripción | Condición | Acción | Latch | Filtro |
|---|---|---|---|---|---|
| `ALM_TT1_HIGH` | Sobretemperatura colector | TT1 > 95 °C | Alarma + parada P1 | No | 10 s |
| `ALM_TT2_HIGH` | Sobretemperatura D1 | TT2 > 88 °C | Alarma + cierre PERS | No | 10 s |
| `ALM_TT5_LOW` | D2 temperatura baja | TT5 < 40 °C durante 2h | Alarma informativa | Sí | 10 s |
| `ALM_TT5_HIGH` | D2 sobretemperatura | TT5 > 90 °C | Alarma + corte BDC | No | 10 s |
| `ALM_COMM_SMART` | Pérdida comunicación FREE Smart | Sin respuesta > 15 s | Alarma | Sí | 15 s |
| `ALM_PISC_T_HIGH` | Piscina sobretemperatura | TT11 > SP_pool_max | Alarma + cierre VP | No | 10 s |
| `ALM_PISC_FLUJO` | Sin flujo en piscina durante calentamiento | IF_PISC=0 con VP abierta | Alarma + avisador | Sí | 30 s |
| `ALM_INUNDACION` | Inundación bandeja fancoil | Sensor inundación activo | Alarma + parada FC | Sí | 5 s |
| `ALM_BDC_FAULT` | Fallo BDC | DI_BDC_FAULT activo | Alarma + parada BDC | Sí | 5 s |

### 9.2 Protecciones hardware (independientes del software)

| Dispositivo | Temperatura actuación | Acción | Rearme |
|---|---|---|---|
| `TK1` — termostato contacto | ~88 °C (ajuste físico) | Cierra PERS_SOL + abre V3V_SOL a piscina + arranca P_PISC | Manual |
| `Z1` — termostato seguridad D1 | 105 °C | Corta P1 (HW) | Manual |
| `Z2` — termostato seguridad D2 | 95 °C | Corta BDC y HTR (HW) | Manual |
| `VS1` — válvula seguridad solar | 6 bar | Descarga circuito solar | Automático |
| `VS_D1/D2` — válvulas seguridad ACS | 8 bar | Descarga circuito ACS | Automático |

### 9.3 Avisador acústico (AV1)

| Condición de activación | Lógica |
|---|---|
| TK1 activo + IF_PISC sin flujo tras retardo `AV1_delay` | TMP1 ON-delay, contacto R2 → AV1 |

| Código | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `AV1_delay` | Retardo desde TK1 hasta activación AV1 si no hay flujo | 45 | 20 – 120 | 5 | s | Físico |

> `AV1_delay` se ajusta en el temporizador TMP1 del cuadro eléctrico.

---

## 10. Comunicación Modbus RS485

| Código | Descripción | DEF | Rango | Paso | Tipo |
|---|---|---|---|---|---|
| `mb_slave_addr` | Dirección esclavo FREE Smart | 1 | 1 – 247 | 1 | RETAIN |
| `mb_baudrate` | Velocidad RS485 | 19200 | 9600/19200/38400 | — | RETAIN |
| `mb_parity` | Paridad | Ninguna | N/E/O | — | RETAIN |
| `mb_stop_bits` | Bits de parada | 1 | 1/2 | — | RETAIN |
| `mb_poll_period` | Periodo de polling maestro | 5 | 2 – 30 | 1 | s | RETAIN |
| `mb_timeout` | Timeout comunicación → alarma | 15 | 5 – 60 | 1 | s | RETAIN |

**Resistencias de terminación**: 120 Ω en cada extremo de la línea RS485.  
**Cable**: apantallado 2 pares trenzados, pantalla a tierra en un solo extremo.

---

## 11. HMI — Acceso y seguridad

| Código | Descripción | DEF | Rango | Tipo |
|---|---|---|---|---|
| `pin_test` | PIN acceso menú TEST | 1234 | 0000–9999 | RETAIN |
| `pin_cfg` | PIN acceso menú CFG | 9999 | 0000–9999 | RETAIN |
| `pin_max_attempts` | Intentos fallidos antes de bloqueo | 3 | 2–5 | RETAIN |
| `pin_lockout_time` | Duración del bloqueo tras fallos | 5 | 1–60 | min | RETAIN |
| `session_timeout_test` | Timeout inactividad sesión TEST | 10 | 2–60 | min | RETAIN |
| `session_timeout_cfg` | Timeout inactividad sesión CFG | 10 | 2–60 | min | RETAIN |

---

## 12. Offsets de sondas

Todos los offsets se suman algebraicamente al valor medido antes de ser usados por cualquier lógica de control.  
`valor_corregido = valor_medido + offset`

| Sonda | Descripción | DEF | Rango | Paso | Unidad | Tipo |
|---|---|---|---|---|---|---|
| `OS_TT1` | Offset TT1 — salida colector | 0,0 | −5,0 – +5,0 | 0,1 | K | RETAIN |
| `OS_TT2` | Offset TT2 — D1 fondo | 0,0 | −5,0 – +5,0 | 0,1 | K | RETAIN |
| `OS_TT3` | Offset TT3 — D1 cabeza | 0,0 | −5,0 – +5,0 | 0,1 | K | RETAIN |
| `OS_TT4` | Offset TT4 — D2 fondo | 0,0 | −5,0 – +5,0 | 0,1 | K | RETAIN |
| `OS_TT5` | Offset TT5 — D2 cabeza | 0,0 | −5,0 – +5,0 | 0,1 | K | RETAIN |
| `OS_TT6` | Offset TT6 — D3 cabeza | 0,0 | −5,0 – +5,0 | 0,1 | K | RETAIN |
| `OS_TT7` | Offset TT7 — D3 fondo | 0,0 | −5,0 – +5,0 | 0,1 | K | RETAIN |
| `OS_TT8` | Offset TT8 — ida primario BDC | 0,0 | −5,0 – +5,0 | 0,1 | K | RETAIN |
| `OS_TT9` | Offset TT9 — retorno primario BDC | 0,0 | −5,0 – +5,0 | 0,1 | K | RETAIN |
| `OS_TT10` | Offset TT10 — ida HTR | 0,0 | −5,0 – +5,0 | 0,1 | K | RETAIN |
| `OS_TT11` | Offset TT11 — piscina | 0,0 | −5,0 – +5,0 | 0,1 | K | RETAIN |
| `OS_TT12` | Offset TT12 — exterior | 0,0 | −5,0 – +5,0 | 0,1 | K | RETAIN |
| `OS_TT13` | Offset TT13 — retorno fancoils | 0,0 | −5,0 – +5,0 | 0,1 | K | RETAIN |
| `OS_TT14` | Offset TT14 — mini bucle intermedio | 0,0 | −5,0 – +5,0 | 0,1 | K | RETAIN |

> **Procedimiento de calibración**: con termómetro de referencia calibrado (precisión ±0,1 °C), comparar lectura del autómata con referencia en condiciones estables. El offset se ajusta para eliminar la desviación. Repetir tras cualquier sustitución de sonda.

---

## 13. Tabla resumen

Todos los parámetros RETAIN por subsistema:

| # | Código | Subsistema | DEF | Rango | Unidad |
|---|---|---|---|---|---|
| 1 | `SP_DT_solar` | Solar | 8,0 | 3,0–15,0 | K |
| 2 | `DT_arranque` | Solar | 6,0 | 2,0–10,0 | K |
| 3 | `DT_parada` | Solar | 3,0 | 1,0–6,0 | K |
| 4 | `PI_Kp` | Solar | 0,50 | 0,10–2,00 | — |
| 5 | `PI_Ki` | Solar | 0,08 | 0,01–0,50 | 1/s |
| 6 | `P1_vel_min` | Solar | 10 | 5–30 | % |
| 7 | `SP_TT3_pool` | Solar | 75,0 | 60,0–90,0 | °C |
| 8 | `SP_TT2_diss` | Solar | 85,0 | 75,0–92,0 | °C |
| 9 | `HS_TT2_diss` | Solar | 4,0 | 2,0–8,0 | K |
| 10 | `modo_solar` | Solar | AUTO | 0–3 | — |
| 11 | `SP_TT5` | ACS | 65,0 | 50,0–80,0 | °C |
| 12 | `HS_TT5` | ACS | 4,0 | 1,0–8,0 | K |
| 13 | `SP_TT4_start` | ACS | 50,0 | 40,0–62,0 | °C |
| 14 | `HS_TT4` | ACS | 3,0 | 1,0–6,0 | K |
| 15 | `SP_TT5_HTR_stop` | ACS/HTR | 68,0 | 55,0–78,0 | °C |
| 16 | `HS_HTR` | ACS/HTR | 3,0 | 1,0–6,0 | K |
| 17 | `SP_heat` | Climatización | 45,0 | 35,0–60,0 | °C |
| 18 | `HS_heat` | Climatización | 4,0 | 1,0–8,0 | K |
| 19 | `SP_cool` | Climatización | 9,0 | 5,0–15,0 | °C |
| 20 | `HS_cool` | Climatización | 2,0 | 0,5–4,0 | K |
| 21 | `SP_pool` | Piscina | 27,0 | 20,0–35,0 | °C |
| 22 | `HS_pool` | Piscina | 1,0 | 0,5–3,0 | K |
| 23 | `SP_pool_max` | Piscina | 32,0 | 28,0–36,0 | °C |
| 24 | `apt_mode_01..05` | Apartamentos | PREC | 0–1 | — |
| 25 | `vacancia_threshold` | Apartamentos | 14 | 3–30 | días |
| 26 | `past_target` | Pasteurización | 70,0 | 65,0–75,0 | °C |
| 27 | `past_hold_min` | Pasteurización | 60 | 30–120 | min |
| 28 | `past_flush_min` | Pasteurización | 30 | 15–60 | min |
| 29 | `legionella_D1_days` | Antilegionela | 7 | 3–14 | días |
| 30 | `bdc_priority` | BDC | 0 | 0–1 | — |
| 31 | `mb_slave_addr` | Modbus | 1 | 1–247 | — |
| 32 | `mb_baudrate` | Modbus | 19200 | 3 valores | bps |
| 33 | `mb_poll_period` | Modbus | 5 | 2–30 | s |
| 34 | `mb_timeout` | Modbus | 15 | 5–60 | s |
| 35–48 | `OS_TT1..TT14` | Offsets sondas | 0,0 | ±5,0 | K |
| 49 | `pin_test` | HMI | 1234 | 0–9999 | — |
| 50 | `pin_cfg` | HMI | 9999 | 0–9999 | — |

**Total: 50 parámetros RETAIN** gestionados por el sistema.

---

*Fusela House · Instalación térmica integrada · Jerez de la Frontera*  
*Documento generado automáticamente desde el repositorio del proyecto*
