# M10 — Cadenas de Seguridad (operación sin PLC)

**Estado:** ⏳ principio rector fijado · falta **diseño de la lógica cableada** y el esquema eléctrico detallado (prioritario).
**Transversal a:** todos los módulos.

## Principio rector

La instalación se diseña en **dos capas independientes**:

1. **Control (M241):** optimiza.
2. **Cadenas de Seguridad (cableadas):** garantizan. Elementos pasivos —termostatos, relés, conmutadores, válvulas con retorno por muelle, termostatos de rearme manual— que mantienen ACS, agua técnica y seguridad **aunque el PLC esté averiado o sin tensión**.

> *El PLC optimiza; las Cadenas de Seguridad garantizan.* Quitar el PLC degrada prestaciones, nunca compromete lo esencial.

## Funciones que deben sobrevivir al fallo del PLC

| Función | Cadena de seguridad |
|---|---|
| **ACS** | V3V de apartamentos caen por muelle a agua de red → termos eléctricos siguen dando ACS (M07) |
| **Agua técnica** | Termostato pasivo gobierna la carga de la BC en modo local, manteniendo T útil en el tándem |
| **Disipación solar** | Termostatos físicos Z1/Z2 (~90 °C) y TK1 (~88 °C) cortan P-SOL y cierran persianas por hardware |
| **Seguridad BC** | Protecciones internas del equipo + termostato/presostato externos |
| **Ocultación paneles** | Persianas con cierre fail-safe ante sobretemperatura o corte de tensión |
| **Sobretemperatura ACS** | Corte térmico bimetálico NC 70 °C en serie con P-ACS por hardware (M04) |
| **No mezcla verano** | Cortes antitermosifón del serpentín D2 cierran por muelle la vía al tándem ante fallo (M05) |

## Lógica cableada de resiliencia (a diseñar)

Parte de la resiliencia al fallo de la electrónica **no puede vivir en el PLC**: tiene que ser **lógica cableada** (relés, termostatos, enclavamientos físicos) que opere con el PLC muerto. Pendiente de bajar a esquema. Candidatos identificados:

- **Corte térmico ACS → P-ACS:** contacto NC del termostato en **serie con la alimentación** de P-ACS. Independiente del PLC.
- **Z1/Z2/TK1 → P-SOL + persianas:** cortan P-SOL y fuerzan cierre de persianas por hardware, sin pasar por el PLC.
- **Enclavamiento disipación ⇒ depuradora:** si se quiere resiliente, garantizar que no se abra la disipación a piscina sin circulación; valorar enclavar por relé (la V3V de disipación solo se energiza con la depuradora en marcha) además de en software.
- **Posición de fallo de actuadores:** V3V apartamentos → red; cortes D2 → cierran vía tándem; persianas → cierran. Por muelle, sin depender del PLC.
- **Conmutador manual/0/auto por actuador:** permite operar bombas/válvulas a mano con el PLC fuera.

## Dispositivo autónomo de cierre de persianas (sobretemperatura del captador)

Primer dispositivo de lógica cableada concretado. Objetivo: **cerrar las persianas que ocultan los captadores cuando se dispara un termostato de sobretemperatura, aunque el PLC no funcione**, evitando el estancamiento del campo solar.

**Concepto:** la orden de cierre por seguridad debe poder actuar con independencia del PLC y, cuando lo haga, **tener prioridad sobre el mando del PLC** (no sumarse a él, para no enfrentar dos órdenes opuestas sobre el mismo motor). Es una OR cableada con prioridad de la seguridad, no un simple paralelo.

Dos arquitecturas según el tipo de actuador de persiana:

### Opción A — Persiana fail-safe por muelle (RECOMENDADA)

Actuador con **retorno por muelle a posición cerrada** (igual que una compuerta cortafuegos). El PLC la mantiene **abierta** dándole tensión; al perder tensión, cae a **cerrada** por muelle.

- El **termostato de sobretemperatura (NC)** se cablea **en serie con la alimentación** del actuador (la que viene comandada por el PLC).
- Disparo del termostato → corta la tensión → la persiana **cae a cerrada por muelle**.
- Fallo del PLC o corte general → misma consecuencia: cerrada.

Ventajas: eléctricamente trivial (un contacto en serie), sin órdenes opuestas, sin finales de carrera, **fail-safe puro**. No depende de que el motor responda activamente. Es la opción robusta.

```
+V ──[contacto NC termostato sobretemp.]──[mando PLC: mantener abierta]── actuador muelle ── 0V
        (abre el circuito al disparar)        (energiza = abierta)        (sin tensión = cerrada)
```

### Opción B — Persiana con motor reversible (subir/bajar)

Si el actuador ya es un motor reversible con finales de carrera, no se puede "dejar caer": hay que **mandarle activamente bajar**. Aquí el termostato no se pone en paralelo directo (enfrentaría órdenes), sino que gobierna un **relé de seguridad conmutador**:

- **Reposo** (termostato frío): el relé deja pasar el **mando del PLC** al motor → operación normal (sube/baja según el PLC).
- **Disparo** (sobretemperatura): el relé **desconecta el mando del PLC y conecta directamente la orden de BAJAR** al motor → la persiana cierra con prioridad, ignore lo que diga el PLC.

```
                    ┌─ reposo: ── mando PLC (subir/bajar) ─┐
motor persiana ──[relé de seguridad]                       ├─→ motor
                    └─ disparo: ── orden fija BAJAR ────────┘
                          ↑
              bobina gobernada por termostato sobretemp.
```

Requiere relé de seguridad, contemplar finales de carrera y tiempo de maniobra. Válido, pero más componentes y casuística que la opción A.

### Requisitos comunes a ambas

- **Alimentación independiente del PLC:** el circuito termostato + actuador debe tomar energía de una línea que **no dependa de la fuente de control 24V ni de una salida del PLC**; así sigue operando con el PLC colgado mientras haya tensión.
- **Termostato de rearme manual:** una vez disparado, no rearma solo (evita ciclos); se revisa la causa antes de reabrir.
- **Aviso al PLC:** el contacto del termostato lleva también una señal al M241 (DI) para registro/alarma, pero **el corte/cierre no pasa por el PLC**.
- **Coherencia con Z1/Z2/TK1:** este dispositivo es el actuador físico del cierre que la disipación solar (M02) invoca como 2.º escalón; el mismo termostato (o TK1) puede gobernarlo.

**Recomendación:** elegir actuador de persiana **fail-safe por muelle (Opción A)**. Simplifica la seguridad a un contacto en serie y es intrínsecamente seguro ante cualquier fallo (electrónica o tensión). Reservar la Opción B solo si el actuador disponible es de motor reversible no sustituible.

## Reglas de diseño

- Cada actuador con **conmutador manual/0/auto**.
- Cada actuador con **posición de fallo** definida (la segura) ante pérdida de tensión.
- Las seguridades térmicas cortan **por hardware, en serie con la potencia**; el M241 solo recibe el aviso.

## Pendientes

- **Diseño de la lógica cableada** del resto de cadenas (relés, enclavamientos hardware, esquema eléctrico).
- Tabla de posición de fallo por actuador (bombas, V3V1/V3V2, cortes D2, V3V de modo BC, V3V disipación, V3V apartamentos, persianas, depuradora).
- Decidir qué enclavamientos van **solo en software**, cuáles **solo cableados** y cuáles **en ambas capas** (redundantes).
- Elegir tipo de actuador de persiana (muelle vs motor reversible) → fija la arquitectura A o B.
