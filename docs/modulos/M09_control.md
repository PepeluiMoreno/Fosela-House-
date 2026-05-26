# M09 — Control (PLC Modicon M241)

**Estado:** 🔶 hardware y FBs base escritos · falta integración de I/O y reescritura del árbitro/clima.

## Hardware

```
Schneider TM241CE24R (Ethernet integrado)
├── DI (8 rápidas) — caudalímetros + entradas PWM
├── DO relé 250VAC — V3V, válvulas, bombas
├── RS-485 ×2 (Modbus RTU hacia BC)
└── Bus TM3:
    ├── 2× TM3TI8T → 16 NTC 10K (13 sondas + spare)
    ├── TM3DQ/DO16R → DO adicionales
    └── 2× TM3AI4 → 8 AI 0-10V/4-20mA (presión, etc.)
```

- **Programación:** EcoStruxure Machine Expert (CoDeSys 3, IEC 61131-3, Structured Text). Versión Free sin licencia de pago; el límite es la memoria del M241 (640 KB RAM / 2 MB Flash), que sobra. *(Obsoleto: "FREE Studio".)*
- **Bombas Wilo iPWM3:** DO rápidas a 1000 Hz + divisor resistivo 24V→~9,6V.
- **HMI:** servidor web embebido (ver M11). Estados con nombre legible.

## Taxonomía de constantes (ver `nomenclatura.md`)

`SP` setpoints · `P` parámetros de control · `HY` histéresis intrínsecas del reservorio · `OF` offsets de instrumentación · `ST_` estados (enum con nombre).

## Bloques de función (estado)

| FB | Función | Estado |
|---|---|---|
| `FB_DHW_Station` | Estación ACS (M04) | escrito |
| `FB_Solar` | Solar + muestreo + disipación (M02) | escrito |
| `FB_ClimateReversible` | Clima (M05) | **reescribir** a topología 2 V3V + P1 |
| `FB_BDC_Arbiter` | Arbitraje | **reescribir** (ver abajo) |
| `FB_PoolReversible` | Piscina (M06) | pendiente |
| lib | PI, Pump, Valve2Way, Valve3Way, Hysteresis, Alarm | escritos |

## Arbitraje ACS / clima / piscina (a reescribir)

- **ACS y clima NO son excluyentes.** Se simultanean como modo normal (el tándem absorbe; ver M01).
- **Condición por temperatura del tándem:** tándem frío → solo ACS; tándem caliente (sobre umbral) → ACS + clima a la vez. La conmutación la gobierna la **histéresis intrínseca del tándem (HY)**, no un margen artificial.
- **El clima nunca se sacrifica por ACS.** Único sacrificable bajo contención: **piscina**.

## Pendientes

- Mapa de I/O del M241 (DI/DO/AI/HSC/TR), conteo de canales vs hardware.
- Integrar FBs en `PLC_PRG_Evolution`.
- Migración de nomenclatura existente a SP/P/HY/OF/ST (decisión: completa vs incremental).
- 2º TM3TI8T para 16 NTC.
