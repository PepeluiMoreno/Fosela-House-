# M09 — Control (lógica y FBs)

**Estado:** 🔶 hardware fijado · FBs base escritos · falta integración de I/O y reescritura del árbitro/clima.
**Autómata:** ver M12 (dos opciones: Modicon M241 / Eliwell FREE Evolution). La lógica y los FBs son comunes; solo cambia el mapeo de E/S.

## Hardware (opción Modicon fijada, ver M12 para Eliwell)

```
Schneider TM241CE24T (CPU a transistor, Ethernet integrado)
├── 14 DI integradas (incl. rápidas para Hall y PWM)
├── 10 DO transistor (2 en modo PWM rápido para bombas; resto → relés interp.)
├── RS-485 + línea serie (Modbus RTU hacia BC)
└── Bus TM3:
    ├── 2× TM3TI8T → 16 entradas de temperatura (PT1000)
    └── 1× TM3DQ16T → 16 DO transistor adicionales (→ relés interp.)
```

- **CPU a transistor** (no relé) porque el PWM de las bombas exige salidas rápidas (ver abajo). Todas las cargas se conmutan con **relés de interposición** (M13); las salidas del PLC son señal de mando.
- **Sondas PT1000** (los TM3TI8T leen termopar/RTD, no NTC 10K; la rama Eliwell usaría NTC 10K — ver M12).
- **Programación:** EcoStruxure Machine Expert (CODESYS 3.5, IEC 61131-3, Structured Text). Sin licencia de pago para el M241; el límite es la memoria del PLC, que sobra. *(Obsoleto: "FREE Studio", IDE de la opción Eliwell — CODESYS 2.3.)*
- **HMI:** servidor web embebido (ver M11). Estados con nombre legible.

### Bombas modulantes: PWM por hardware (no por software)

P-SOL y P-ACS son **Wilo iPWM3**, cuya entrada de control es **PWM** (no 0-10V). El PWM **no se genera escribiendo una salida en el ciclo de scan** (inviable a 1 kHz): se usa el **generador de pulsos por hardware** de la CPU a transistor — se configura la salida rápida en modo **PWM (función PTO/PWM del expert I/O del M241)** y el silicio produce la onda a la frecuencia fija y al ciclo de trabajo que el código le indica. Desde ST solo se escribe el **duty cycle** (0-100%); la onda la hace el hardware. Nivel adaptado con **divisor 24V→~9,6V** al rango de la Wilo.

### Salidas analógicas: no hay (deliberado)

El proyecto **no lleva salidas analógicas (0-10V/4-20mA)**. Las únicas señales moduladas son las dos bombas, y van por **PWM** por exigencia de la entrada Wilo iPWM3. El resto de actuadores (P1/P2/P-POOL, V3V, cortes, persianas, apartamentos) son **on/off o por muelle**. 
- Solo haría falta un módulo de salida analógica (**TM3AQ2/AQ4**) si se cambiara a bombas con entrada **0-10V** en vez de PWM, o si se introdujera una válvula mezcladora proporcional 0-10V. Ninguno está en el diseño actual.
- Para **leer presiones** (transductores) haría falta un **TM3AI4** (entrada analógica) — tampoco previsto: los manómetros son de lectura visual (M08).

## Ocupación de E/S (censo M12 vs hardware)

| Recurso | Disponible | Usado | Libre | Notas |
|---|---|---|---|---|
| **Temperatura** | 16 (2×TM3TI8T) | 13 sondas | 3 spare | ~9-10 imprescindibles + ~3-4 de mejora/calorimetría (AI4, AI10, AI11, AI13). El 2.º módulo es holgura, no necesidad estricta |
| **DI** | 14 (CPU) | 11 | 3 | Ajustado. DI10 (alarma BC) puede sobrar si va por Modbus. Riesgo de quedarse corto si se llevan al PLC los conmutadores manual/auto o más confirmaciones de bomba → expansión TM3DI |
| **DO** | 26 (10 CPU + 16 TM3DQ16T) | 20 | 6 | 2 DO son PWM (CPU). Resto on/off vía relé interp. |

**Imprescindibles vs mejora (temperatura):** imprescindibles = ida/retorno glicol, salida placa ACS, tapa D2, D1, buffer clima, piscina, impulsión fancoils, exterior. Mejora/vigilancia = retorno primario ACS (AI4), retorno fancoils (AI10), ACS distribución (AI11), estratificación D2 (AI13).

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
| `FB_PoolFiltration` | Depuradora desvinculada del HVAC (M06) | pendiente |
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

- Mapa de I/O del M241 (asignación señal↔borne), coherente con M12 y el clemero (M13).
- Verificar referencias/canales del hardware en el catálogo de EcoStruxure antes de comprar.
- Integrar FBs en `PLC_PRG_Evolution`.
- Decidir si los conmutadores manual/auto se realimentan al PLC (DI) → puede exigir expansión TM3DI.
- Migración de nomenclatura existente a SP/P/HY/OF/ST (decisión: completa vs incremental).
- Definir el registro {default, min, max, unidad} de cada parámetro.
