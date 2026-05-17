# Parámetros de equipo — Estructura de límites y dependencias

## Fusela House · Jerez de la Frontera

Documento que identifica qué parámetros físicos de cada equipo
son relevantes para la operación del sistema, y qué setpoints
operativos quedan acotados por cada uno de ellos.

Los valores concretos se extraen de la ficha técnica de cada equipo
y se introducen en el HMI (menú CFG, acceso técnico) durante la
puesta en marcha. No están hardcodeados en el software.

---

## Modelo de dependencias

```
EQUIPO
  └── PARÁMETRO DE EQUIPO (CFG, técnico)
          └── acota el rango de →  SETPOINT OPERATIVO (nivel 1)
                                        └── determina → ACCIÓN DE CONTROL
```

---

## 1. Acumuladores D1 y D2 (Tusol DB2 450)

**Parámetros de equipo relevantes:**

| Código CFG | Descripción |
|---|---|
| `EQ_ACUM_T_MAX` | Temperatura máxima de trabajo del acumulador |
| `EQ_ACUM_PS_ACS` | Presión máxima lado sanitario |
| `EQ_ACUM_PS_SERP` | Presión máxima serpentines |

**Setpoints acotados:**

| Setpoint | Acotado por |
|---|---|
| `SP_TT5` — consigna D2 cabeza | ≤ `EQ_ACUM_T_MAX` − margen |
| `SP_TT2_diss` — cierre persianas | ≤ `EQ_ACUM_T_MAX` − margen |
| `SP_TT3_pool` — desvío a piscina | ≤ `EQ_ACUM_T_MAX` − margen |
| `past_target` — temperatura pasteurización | ≤ `EQ_ACUM_T_MAX` − margen |
| `Z1 / Z2` — termostatos seguridad hardware | ≤ `EQ_ACUM_T_MAX` |
| `VS_serp` — tarado válvulas seguridad serpentines | = `EQ_ACUM_PS_SERP` |

---

## 2. Bomba de calor ecoAIR+ 6-24 PRO

**Parámetros de equipo relevantes:**

| Código CFG | Descripción |
|---|---|
| `EQ_BDC_T_MAX_PRIM` | Temperatura máxima impulsión primario (calefacción) |
| `EQ_BDC_T_MAX_HTR` | Temperatura máxima producción HTR |
| `EQ_BDC_T_MIN_COOL` | Temperatura mínima impulsión primario (refrigeración) |
| `EQ_BDC_PS_PRIM` | Presión máxima circuito primario |

**Setpoints acotados:**

| Setpoint | Acotado por |
|---|---|
| `SP_TT5` — consigna D2 vía BDC | ≤ `EQ_BDC_T_MAX_PRIM` − margen serpentín |
| `SP_TT5_HTR_stop` — inhibición HTR | ≤ `EQ_BDC_T_MAX_HTR` |
| `SP_TT10_max` — alarma ida HTR | ≤ `EQ_BDC_T_MAX_HTR` |
| `SP_cool` — consigna refrigeración D3 | ≥ `EQ_BDC_T_MIN_COOL` |
| `SP_heat` — consigna calefacción D3 | ≤ `EQ_BDC_T_MAX_PRIM` − margen |

---

## 3. Colectores solares

**Parámetros de equipo relevantes:**

| Código CFG | Descripción |
|---|---|
| `EQ_COL_T_ESTANC` | Temperatura de estancamiento |
| `EQ_COL_T_MAX_OPER` | Temperatura máxima de operación continuada |
| `EQ_COL_PS_MAX` | Presión máxima circuito primario |

**Setpoints acotados:**

| Setpoint | Acotado por |
|---|---|
| `VE1_precarga` — vaso expansión solar | Calculada a partir de `EQ_COL_T_ESTANC` |
| `SP_TT1_MAX_ALM` — alarma sobretemperatura colector | ≤ `EQ_COL_T_MAX_OPER` |
| `VS1_tarado` — válvula seguridad solar | ≤ `EQ_COL_PS_MAX` |

---

## 4. Intercambiadores de placas titanio (HX1, HX_BDC, HX_HTR)

**Parámetros de equipo relevantes:**

| Código CFG | Descripción |
|---|---|
| `EQ_HX_T_MAX` | Temperatura máxima admisible en placas |
| `EQ_HX_PS_MAX` | Presión máxima admisible |

**Setpoints acotados:**

| Setpoint | Acotado por |
|---|---|
| `SP_TT10_max` — T máxima HTR | ≤ `EQ_HX_T_MAX` (HX_HTR, lado primario) |
| Presión circuitos primarios | ≤ `EQ_HX_PS_MAX` |

---

## 5. Bomba solar P1 (Teula TEU-III DN20)

**Parámetros de equipo relevantes:**

| Código CFG | Descripción |
|---|---|
| `EQ_P1_T_MAX` | Temperatura máxima del fluido (sello/membrana) |
| `EQ_P1_PS_MAX` | Presión máxima de trabajo |
| `EQ_P1_VEL_MIN` | Velocidad mínima de funcionamiento estable |
| `EQ_P1_VEL_MAX` | Velocidad máxima (100%) |

**Setpoints acotados:**

| Setpoint | Acotado por |
|---|---|
| `P1_vel_min` — velocidad mínima en HMI | ≥ `EQ_P1_VEL_MIN` |
| Temperatura circulante | ≤ `EQ_P1_T_MAX` |

---

## 6. Vaso de expansión solar VE1

**Parámetros de equipo relevantes:**

| Código CFG | Descripción |
|---|---|
| `EQ_VE1_T_MAX_MEMB` | Temperatura máxima de la membrana |
| `EQ_VE1_PS_MAX` | Presión máxima de trabajo |
| `EQ_VE1_PRECARGA` | Presión de precarga de fábrica |

**Setpoints acotados:**

| Setpoint | Acotado por |
|---|---|
| `VS1_tarado` — VS solar | ≤ `EQ_VE1_PS_MAX` |
| Temperatura en punto de conexión | ≤ `EQ_VE1_T_MAX_MEMB` |

---

## 7. Vaso de expansión ACS (VE_AFS)

**Parámetros de equipo relevantes:**

| Código CFG | Descripción |
|---|---|
| `EQ_VEAFS_T_MAX` | Temperatura máxima membrana sanitaria |
| `EQ_VEAFS_PS_MAX` | Presión máxima de trabajo |
| `EQ_VEAFS_PRECARGA` | Presión de precarga de fábrica |

**Setpoints acotados:**

| Setpoint | Acotado por |
|---|---|
| `SP_TT5` — consigna D2 | ≤ `EQ_VEAFS_T_MAX` |
| `VS_ACS_tarado` — VS sanitaria | ≤ `EQ_VEAFS_PS_MAX` |

---

## 8. Válvulas motorizadas (V3V, VP)

**Parámetros de equipo relevantes:**

| Código CFG | Descripción |
|---|---|
| `EQ_V3V_T_MAX` | Temperatura máxima del fluido |
| `EQ_V3V_PS_MAX` | Presión máxima de trabajo |
| `EQ_V3V_TRAVEL` | Tiempo de maniobra del actuador |

**Setpoints acotados:**

| Setpoint | Acotado por |
|---|---|
| `V3V_travel` — tiempo de maniobra en lógica | = `EQ_V3V_TRAVEL` |
| Temperaturas de los circuitos | ≤ `EQ_V3V_T_MAX` |

---

## 9. Mini bucle intermedio (VE_INT, VS_INT)

**Parámetros de equipo relevantes:**

| Código CFG | Descripción |
|---|---|
| `EQ_BUCLE_T_MAX` | Temperatura máxima admisible en el bucle |
| `EQ_BUCLE_PS_MAX` | Presión máxima |
| `EQ_BUCLE_VS_TARADO` | Tarado VS_INT |

**Setpoints acotados:**

| Setpoint | Acotado por |
|---|---|
| `SP_TT3_pool` — desvío a piscina | ≤ `EQ_BUCLE_T_MAX` |
| `VS_INT_tarado` | = `EQ_BUCLE_PS_MAX` |

---

## 10. Tabla de cotas cruzadas

Vista inversa: dado un setpoint, qué parámetros de equipo lo acotan.

| Setpoint operativo | Acotado por (límite superior) | Acotado por (límite inferior) |
|---|---|---|
| `SP_TT5` | `EQ_ACUM_T_MAX`, `EQ_BDC_T_MAX_PRIM`, `EQ_VEAFS_T_MAX` | `past_target` |
| `SP_TT2_diss` | `EQ_ACUM_T_MAX` | `SP_TT5` |
| `SP_TT3_pool` | `EQ_ACUM_T_MAX`, `EQ_BUCLE_T_MAX` | `SP_TT5` |
| `past_target` | `EQ_ACUM_T_MAX`, `SP_TT5` | normativa RD 865/2003 (65°C mín) |
| `SP_TT5_HTR_stop` | `EQ_BDC_T_MAX_HTR` | `SP_TT5` |
| `SP_TT10_max` | `EQ_BDC_T_MAX_HTR`, `EQ_HX_T_MAX` | — |
| `SP_cool` | — | `EQ_BDC_T_MIN_COOL` |
| `SP_heat` | `EQ_BDC_T_MAX_PRIM` | — |
| `SP_TT1_MAX_ALM` | `EQ_COL_T_MAX_OPER` | — |
| `P1_vel_min` | 100% | `EQ_P1_VEL_MIN` |
| `V3V_travel` | `EQ_V3V_TRAVEL` | `EQ_V3V_TRAVEL` |

---

## 11. Consecuencia para el código

En `GVL_HMI_Params.st` los rangos `[min, max]` de cada setpoint editable
**no son constantes fijas** sino que se calculan en tiempo de ejecución
a partir de los parámetros de equipo:

```pascal
(* Ejemplo: rango admisible de SP_TT5 calculado en tiempo real *)
SP_TT5_MAX := EQ_ACUM_T_MAX - MARGEN_ACUM;   (* límite superior *)
SP_TT5_MIN := past_target + 2.0;              (* límite inferior *)

(* El HMI usa SP_TT5_MAX / SP_TT5_MIN como item_max / item_min *)
(* Si el técnico cambia EQ_ACUM_T_MAX, todos los rangos dependientes
   se recalculan automáticamente en el siguiente ciclo *)
```

Esto garantiza **coherencia automática**: cambiar un parámetro de equipo
actualiza en cascada todos los rangos que dependen de él, sin tocar
el código de la lógica de control ni las páginas HMI.

---

*Fusela House · Instalación térmica integrada · Jerez de la Frontera*
