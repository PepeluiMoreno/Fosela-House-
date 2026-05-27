# M09 — Control (lógica y FBs)

**Estado:** 🔶 hardware y FBs base escritos · falta integración de I/O y reescritura del árbitro/clima.
**Autómata:** ver M12 (dos opciones: Modicon M241 / Eliwell FREE Evolution). La lógica y los FBs son comunes; solo cambia el mapeo de E/S.

## Hardware (opción Modicon, ver M12 para Eliwell)

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

- **Programación:** EcoStruxure Machine Expert (CODESYS 3.5, IEC 61131-3, Structured Text). Sin licencia de pago para el M241; el límite es la memoria del PLC, que sobra para este proyecto. *(Obsoleto: "FREE Studio", que es el IDE de la opción Eliwell — CODESYS 2.3.)*
- **Bombas Wilo iPWM3:** DO rápidas a 1000 Hz + divisor resistivo 24V→~9,6V.
- **HMI:** servidor web embebido (ver M11). Estados con nombre legible.

## Taxonomía de constantes (ver `nomenclatura.md`)

`SP` setpoints · `P` parámetros de control **y constructivos** · `HY` histéresis intrínsecas del reservorio (solo histéresis) · `OF` offsets de instrumentación · `ST_` estados (enum con nombre).

Cada parámetro `SP`/`P` se define como registro **{default, min, max, unidad}**, no solo un valor. El min/max acota el rango editable (seguridad ante valores absurdos por HMI + topes de los campos). Cómo se transcribe a cada autómata: ver M12.

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

## Flujo de trabajo (toolchain) y control de versiones

Objetivo: trabajar el software del PLC con Git/GitHub de forma análoga a VS Code, y poder simular antes de tener hardware.

**Fuente de verdad = el código ST en texto del repo** (`control/*.st`). No el proyecto binario del IDE. Razón: los proyectos de Machine Expert/CODESYS se guardan en **formato binario** (`.project`), que Git versiona como blob (sin diffs legibles ni merge línea a línea). El código en texto sí da diffs y merges reales, y además es lo que comparten las dos opciones de autómata.

**Regla:** se edita/versiona el `.st` de texto; el proyecto del IDE se **genera importando** esos POU. No editar en los dos sitios sin disciplina (se desincroniza).

Flujo:
1. Código ST en texto en `Casa-Fosela` → control de versiones con diffs (como en VS Code).
2. Importar los POU en el IDE del autómata elegido:
   - Modicon: Machine Expert importa PLCopen XML / `.exp` (texto).
   - Eliwell: FREE Studio, reintroducir POU (ver M12, no hay transferencia automática entre IDEs).
3. **Simular en el PC** sin hardware: Machine Expert lleva simulador CODESYS integrado. Permite forzar entradas (sondas, pulsos de caudalímetro) y observar salidas; depurar máquinas de estado, PI, árbitro y transiciones estacionales. **Para simular sí hacen falta valores numéricos de los `Pxx`** (para operar en el PLC real, no).
4. **Probar Modbus con la BC** en banco con la *Modbus Communication DTM Library* (Schneider, gratuita; FDT2 + Modbus DTM). Herramienta de depuración de la comunicación, opcional: la comunicación de producción se puede resolver por código ST (funciones Modbus de la librería del M241).
5. Volcar al M241 por Ethernet cuando el hardware esté.
6. Commit/push a GitHub: desde VS Code/terminal sobre los `.st`, o desde la integración Git del propio Machine Expert (mejor sobre el código exportado a texto que sobre el binario).

## Pendientes

- Mapa de I/O del M241 (DI/DO/AI/HSC/TR), conteo de canales vs hardware (M12).
- Integrar FBs en `PLC_PRG_Evolution`.
- Migración de nomenclatura existente a SP/P/HY/OF/ST (decisión: completa vs incremental).
- 2º TM3TI8T para 16 NTC.
- Definir el registro {default, min, max, unidad} de cada parámetro.
