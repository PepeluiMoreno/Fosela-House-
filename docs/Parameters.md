# Tabla de parámetros — Fusela House

Nomenclatura definitiva de todos los parámetros del sistema.  
Identificador único `Pnn` válido en HMI, código ST, documentación y puesta en marcha.

**Niveles de acceso:**
- **CFG** — parámetros de equipo, acceso técnico instalador (PIN_CFG)
- **L1** — setpoints operativos, acceso operador autorizado (PIN_L1)
- **R/O** — solo lectura, cualquier usuario

**Unidades:** temperaturas en °C, tiempos en segundos salvo indicación.  
**Encoding Modbus:** temperaturas × 10 como entero (42,5 °C → 425).

---

## Bloque P00–P09 · Límites de equipo (CFG)

Fijan los límites físicos de los equipos instalados.  
Acotan automáticamente los rangos admisibles de los parámetros L1.  
Solo modificar en caso de sustitución de equipo.

| Código | Nombre programa | Unidad | Descripción |
|---|---|---|---|
| **P00** | `ip_AccumulatorMaxTemp` | °C | T máx trabajo acumuladores Tusol DB2 450 (dato de placa) |
| **P01** | `ip_AccumulatorMaxPressure` | bar | PS máx lado sanitario acumuladores (dato de placa) |
| **P02** | `ip_CoilMaxPressure` | bar | PS máx serpentines acumuladores (dato de placa) |
| **P03** | `ip_BDCMaxFlowTemp` | °C | T máx impulsión primario BDC en calefacción (ficha ecoAIR+) |
| **P04** | `ip_HTRMaxTemp` | °C | T máx producción HTR (ficha ecoAIR+) |
| **P05** | `ip_BDCMinCoolTemp` | °C | T mín impulsión BDC en refrigeración (ficha ecoAIR+) |
| **P06** | `ip_CollectorMaxOperTemp` | °C | T máx operación continuada colectores (ficha técnica) |
| **P07** | `ip_CollectorStagnationTemp` | °C | T estancamiento colectores (para cálculo VE1) |
| **P08** | `ip_HXMaxTemp` | °C | T máx intercambiadores titanio HX1/HX_BDC/HX_HTR |
| **P09** | `ip_PumpMaxFluidTemp` | °C | T máx fluido bomba solar TEU-III DN20 |

> Los valores de P00–P09 se extraen de las fichas técnicas durante
> la puesta en marcha. El software los usa como límites superiores
> para validar los rangos de P10–P89 en tiempo real.

---

## Bloque P10–P19 · Solar — FREE Smart (L1)

| Código | Nombre programa | Unidad | Defecto | Mín | Máx | Descripción |
|---|---|---|---|---|---|---|
| **P10** | `ip_SolarDeltaTTarget` | K | 8,0 | 3,0 | 15,0 | ΔT objetivo lazo PI bomba P1 |
| **P11** | `ip_SolarDeltaTStart` | K | 6,0 | 2,0 | 10,0 | ΔT arranque P1 |
| **P12** | `ip_SolarDeltaTStop` | K | 3,0 | 1,0 | 6,0 | ΔT parada P1 |
| **P13** | `ip_SolarPumpMinSpeed` | % | 10 | 5 | 30 | Velocidad mínima P1 en marcha |
| **P14** | `ip_SolarPumpMinOnTime` | s | 30 | 10 | 120 | Tiempo mínimo marcha P1 (anti-cicleo) |
| **P15** | `ip_SolarPumpMinOffTime` | s | 20 | 10 | 120 | Tiempo mínimo parada P1 (anti-cicleo) |
| **P16** | `ip_MinTempForPoolSolarHeating` | °C | 75 | 60 | P00−7 | T mínima D1 cabeza para habilitar solar→piscina |
| **P17** | `ip_SolarOverheatShutterClose` | °C | 85 | 75 | P00−3 | T D1 fondo que activa cierre de persianas |
| **P18** | `ip_SolarOverheatShutterHyst` | K | 4 | 2 | 8 | Histéresis reapertura persianas |
| **P19** | `ip_SolarMode` | — | 0 | 0 | 3 | 0=AUTO 1=ACS 2=PISC 3=OFF |

---

## Bloque P20–P21 · Regulador PI solar — FREE Smart (CFG)

| Código | Nombre programa | Unidad | Defecto | Mín | Máx | Descripción |
|---|---|---|---|---|---|---|
| **P20** | `ip_SolarPI_Kp` | — | 0,50 | 0,10 | 2,00 | Ganancia proporcional lazo PI |
| **P21** | `ip_SolarPI_Ki` | 1/s | 0,08 | 0,01 | 0,50 | Ganancia integral lazo PI |

---

## Bloque P30–P35 · ACS (L1)

| Código | Nombre programa | Unidad | Defecto | Mín | Máx | Descripción |
|---|---|---|---|---|---|---|
| **P30** | `ip_ACSStorageSetPoint` | °C | 65 | 50 | P03−5 | Consigna T D2 cabeza (TT5) |
| **P31** | `ip_ACSStorageHysteresis` | K | 4 | 1 | 8 | Histéresis TT5 (banda muerta total) |
| **P32** | `ip_ACSBDCStartTemp` | °C | 50 | 40 | P30−3 | T D2 fondo (TT4) que activa carga BDC |
| **P33** | `ip_ACSBDCStartHyst` | K | 3 | 1 | 6 | Histéresis TT4 |
| **P34** | `ip_HTRStopTemp` | °C | 68 | P30 | P04 | T D2 cabeza que inhibe HTR hacia D2 |
| **P35** | `ip_HTRStopHyst` | K | 3 | 1 | 6 | Histéresis inhibición HTR |

---

## Bloque P40–P46 · ACS apartamentos (L1)

| Código | Nombre programa | Unidad | Defecto | Mín | Máx | Descripción |
|---|---|---|---|---|---|---|
| **P40** | `ip_AptMode_01` | — | 0 | 0 | 1 | V3V_APT01: 0=precalentada 1=AFS |
| **P41** | `ip_AptMode_02` | — | 0 | 0 | 1 | V3V_APT02 |
| **P42** | `ip_AptMode_03` | — | 0 | 0 | 1 | V3V_APT03 |
| **P43** | `ip_AptMode_04` | — | 0 | 0 | 1 | V3V_APT04 |
| **P44** | `ip_AptMode_05` | — | 0 | 0 | 1 | V3V_APT05 |
| **P45** | `ip_VacancyThreshold` | días | 14 | 3 | 30 | Días sin uso → cambio automático a AFS |
| **P46** | `ip_AptSwitchHour` | hh | 3 | 0 | 5 | Hora de conmutación nocturna V3V_APT |

---

## Bloque P50–P53 · Climatización (L1)

| Código | Nombre programa | Unidad | Defecto | Mín | Máx | Descripción |
|---|---|---|---|---|---|---|
| **P50** | `ip_HeatingSetPoint` | °C | 45 | 35 | P03−5 | Consigna D3 cabeza en calefacción |
| **P51** | `ip_HeatingHysteresis` | K | 4 | 1 | 8 | Histéresis calefacción |
| **P52** | `ip_CoolingSetPoint` | °C | 9 | P05 | 15 | Consigna D3 fondo en refrigeración |
| **P53** | `ip_CoolingHysteresis` | K | 2 | 0,5 | 4 | Histéresis refrigeración |

---

## Bloque P60–P64 · Piscina (L1)

| Código | Nombre programa | Unidad | Defecto | Mín | Máx | Descripción |
|---|---|---|---|---|---|---|
| **P60** | `ip_PoolSetPoint` | °C | 27 | 20 | 35 | Consigna temperatura piscina (TT11) |
| **P61** | `ip_PoolHysteresis` | K | 1 | 0,5 | 3 | Histéresis temperatura piscina |
| **P62** | `ip_PoolMaxTemp` | °C | 32 | 28 | 36 | T máxima piscina → alarma y corte |
| **P63** | `ip_PoolDelay` | s | 30 | 10 | 120 | Tiempo bomba secundaria tras parada primaria (recupera calor residual HX) |
| **P64** | `ip_PoolValveTravelTime` | s | 15 | 10 | 30 | Tiempo de maniobra válvulas VP_HX |

---

## Bloque P70–P77 · Higienización térmica (L1/CFG)

| Código | Nivel | Nombre programa | Unidad | Defecto | Mín | Máx | Descripción |
|---|---|---|---|---|---|---|---|
| **P70** | L1 | `ip_HygienizationTarget` | °C | 70 | 65 | 75 | T objetivo D2 en ciclo de higienización |
| **P71** | L1 | `ip_HygienizationHysteresis` | K | 2 | 1 | 4 | Histéresis mantenimiento T |
| **P72** | L1 | `ip_HygienizationHoldTime` | min | 60 | 30 | 120 | Tiempo de mantenimiento a T objetivo |
| **P73** | L1 | `ip_HygienizationFlushTime` | min | 30 | 15 | 60 | Tiempo de purgado por apartamento |
| **P74** | L1 | `ip_HygienizationDayOfWeek` | día | 1 | 1 | 7 | Día ciclo automático (1=Lun…7=Dom) |
| **P75** | L1 | `ip_HygienizationHour` | hh | 3 | 0 | 5 | Hora de inicio del ciclo automático |
| **P76** | CFG | `ip_D1HygienizationMaxDays` | días | 7 | 3 | 14 | Días máx sin alcanzar T mínima en D1 |
| **P77** | CFG | `ip_D1HygienizationMinTemp` | °C | 60 | 55 | 65 | T mínima objetivo en TT2 (D1 fondo) |

---

## Bloque P80 · Prioridades BDC (CFG)

| Código | Nombre programa | Unidad | Defecto | Mín | Máx | Descripción |
|---|---|---|---|---|---|---|
| **P80** | `ip_BDCPriority` | — | 0 | 0 | 1 | 0=ACS>CLIM>PISC · 1=ACS>PISC>CLIM |

---

## Bloque P90–P97 · Sistema, Modbus y HMI (CFG)

| Código | Nombre programa | Unidad | Defecto | Mín | Máx | Descripción |
|---|---|---|---|---|---|---|
| **P90** | `ip_ModbusSlaveAddr` | — | 1 | 1 | 247 | Dirección esclavo Modbus FREE Smart |
| **P91** | `ip_ModbusBaudrate` | — | 1 | 0 | 2 | 0=9600 · 1=19200 · 2=38400 |
| **P92** | `ip_ModbusPollPeriod` | s | 5 | 2 | 30 | Periodo polling maestro FREE Evolution |
| **P93** | `ip_ModbusTimeout` | s | 15 | 5 | 60 | Timeout comunicación → alarma |
| **P94** | `ip_PIN_L1` | — | 1234 | 0 | 9999 | PIN acceso nivel L1 (operador) |
| **P95** | `ip_PIN_CFG` | — | 9999 | 0 | 9999 | PIN acceso nivel CFG (técnico) |
| **P96** | `ip_PIN_MaxAttempts` | — | 3 | 2 | 5 | Intentos fallidos antes de bloqueo |
| **P97** | `ip_SessionTimeout` | min | 10 | 2 | 60 | Timeout inactividad sesión |

---

## Offsets de sondas OS00–OS13 (CFG)

Corrección: `valor_corregido = valor_medido + offset`

| Código | Nombre programa | Unidad | Defecto | Rango | Sonda |
|---|---|---|---|---|---|
| **OS00** | `ip_Offset_TT1` | K | 0,0 | ±5,0 | Salida colector |
| **OS01** | `ip_Offset_TT2` | K | 0,0 | ±5,0 | D1 fondo |
| **OS02** | `ip_Offset_TT3` | K | 0,0 | ±5,0 | D1 cabeza |
| **OS03** | `ip_Offset_TT4` | K | 0,0 | ±5,0 | D2 fondo |
| **OS04** | `ip_Offset_TT5` | K | 0,0 | ±5,0 | D2 cabeza |
| **OS05** | `ip_Offset_TT6` | K | 0,0 | ±5,0 | D3 cabeza |
| **OS06** | `ip_Offset_TT7` | K | 0,0 | ±5,0 | D3 fondo |
| **OS07** | `ip_Offset_TT8` | K | 0,0 | ±5,0 | Ida primario BDC |
| **OS08** | `ip_Offset_TT9` | K | 0,0 | ±5,0 | Retorno primario BDC |
| **OS09** | `ip_Offset_TT10` | K | 0,0 | ±5,0 | Ida HTR |
| **OS10** | `ip_Offset_TT11` | K | 0,0 | ±5,0 | Piscina |
| **OS11** | `ip_Offset_TT12` | K | 0,0 | ±5,0 | Exterior |
| **OS12** | `ip_Offset_TT13` | K | 0,0 | ±5,0 | Retorno fancoils |
| **OS13** | `ip_Offset_TT14` | K | 0,0 | ±5,0 | Mini bucle intermedio |

---

## Resumen

| Bloque | Subsistema | Nivel | Nº |
|---|---|---|---|
| P00–P09 | Límites de equipo | CFG | 10 |
| P10–P19 | Solar operativo | L1 | 10 |
| P20–P21 | Solar PI | CFG | 2 |
| P30–P35 | ACS | L1 | 6 |
| P40–P46 | ACS apartamentos | L1 | 7 |
| P50–P53 | Climatización | L1 | 4 |
| P60–P64 | Piscina | L1 | 5 |
| P70–P77 | Higienización | L1/CFG | 8 |
| P80 | Prioridades BDC | CFG | 1 |
| P90–P97 | Sistema/Modbus/HMI | CFG | 8 |
| OS00–OS13 | Offsets sondas | CFG | 14 |
| **Total** | | | **75** |

---

*Fusela House · Instalación térmica integrada · Jerez de la Frontera*
