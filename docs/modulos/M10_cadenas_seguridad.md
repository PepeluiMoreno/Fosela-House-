# M10 — Cadenas de Seguridad (operación sin PLC)

**Estado:** ⏳ principio rector fijado · falta **diseño de la lógica cableada** y el esquema eléctrico detallado (prioritario).
**Transversal a:** todos los módulos.

## Principio rector

La instalación se diseña en **dos capas independientes**:

1. **Control (M241):** optimiza.
2. **Cadenas de Seguridad (cableadas):** garantizan. Elementos **pasivos** —termostatos bimetálicos, válvulas con retorno por muelle, contactos mecánicos, conmutadores manuales— que mantienen ACS, agua técnica y seguridad **aunque el PLC esté averiado o sin tensión**.

> *El PLC optimiza; las Cadenas de Seguridad garantizan.* Quitar el PLC degrada prestaciones, nunca compromete lo esencial.

> **Criterio rector de la capa de seguridad: nada de electrónica.** Para protegerse del fallo de la electrónica, la cadena de seguridad no puede depender de electrónica. Se construye con elementos **físicos de acción directa** (bimetálicos, muelles, contactos mecánicos). Donde sea posible se evita incluso el relé (componente activo con bobina); la primera opción es siempre el corte/conmutación mecánica directa.

## Funciones que deben sobrevivir al fallo del PLC

| Función | Cadena de seguridad |
|---|---|
| **ACS** | V3V de apartamentos caen por muelle a agua de red → termos eléctricos siguen dando ACS (M07) |
| **Agua técnica** | Termostato pasivo gobierna la carga de la BC en modo local, manteniendo T útil en el tándem |
| **Climatización (P2)** | La demanda agregada de los fancoils (OR del Zelio) arranca **P2 directamente** por hardware, sin pasar por el M241 → con el PLC averiado, sigue habiendo circulación de clima cuando la vivienda lo pide (ver abajo) |
| **Disipación solar** | Termostatos físicos Z1/Z2 (~90 °C) y TK1 (~88 °C) cortan P-SOL y cierran persianas por hardware |
| **Seguridad BC** | Protecciones internas del equipo + termostato/presostato externos |
| **Ocultación paneles** | Persianas con cierre fail-safe ante sobretemperatura o corte de tensión |
| **Sobretemperatura ACS** | Corte térmico bimetálico NC 70 °C en serie con P-ACS por hardware (M04) |
| **No mezcla verano** | Cortes antitermosifón del serpentín D2 cierran por muelle la vía al tándem ante fallo (M05) |

## Cadena de seguridad de climatización: demanda → P2 directa

El **Zelio** que agrega las 12 zonas de demanda de fancoils (M12) **gobierna P2 directamente por hardware**, no a través del M241. Esto convierte la circulación de clima en una **función resiliente al fallo del PLC**:

- **Con PLC sano:** el M241 gobierna P2 con su lógica fina (modo calor/frío, temperatura del buffer, coordinación con P1, enclavamientos). El Zelio aporta la condición de demanda.
- **Con PLC averiado / sin tensión de control:** la cadena **Zelio → relé/contactor de P2** sigue operando. Si hay demanda en fancoils, P2 arranca; si no, para. **El clima básico sobrevive al fallo del PLC.**

**Articulación eléctrica (OR cableada en el arranque de P2):**

```
                 ┌─ contacto "hay demanda" del Zelio (cadena de seguridad) ─┐
relé/contactor P2 ┤                                                          ├─ (OR cableada)
                 └─ DO4 del M241 (optimización, cuando el PLC está sano) ────┘
        gobernado por conmutador manual/0/auto
```

- El **contacto del Zelio** (alimentado por línea independiente del M241) puede arrancar P2 por sí solo en modo degradado.
- El **M241 (DO4)** añade la inteligencia cuando está operativo.
- **Conmutador manual/0/auto** decide la vía (o se cablean en paralelo, con la del Zelio como respaldo).

> ⚠️ **A verificar:** arrancar P2 por la vía Zelio significa que la bomba puede ponerse en marcha **con el resto del circuito no necesariamente dispuesto** (V3V sin posicionar, P1 parada, buffer sin carga). En modo degradado es aceptable (circulación básica), pero **P2 debe tolerar trabajar contra una red parcialmente cerrada** (PICV de zonas satisfechas cerradas) sin daño → refuerza la elección de P2 **electrónica de presión constante** (reduce velocidad al cerrarse zonas) y/o bypass por el buffer/aguja. Verificar al seleccionar P2 (M08).

> **Alimentación del Zelio:** para que esta cadena sea resiliente, el Zelio y el circuito de mando de P2 deben tomar energía de una **línea independiente de la fuente de control del M241**; así la demanda→P2 sobrevive a un fallo del PLC. (Coherente con el criterio de líneas independientes del resto de seguridades.)

> *Matiz:* el Zelio es un componente **activo** (lógica programable), no un bimetálico. No es \"capa de seguridad pura\" como los klixones, pero sí una **redundancia de control independiente del M241** que mejora la resiliencia de la climatización (función no crítica para la seguridad, sí para el confort). Las funciones **críticas** (ACS, disipación solar, sobretemperaturas) siguen en bimetálico puro.

## Lógica cableada de resiliencia (a diseñar)

Parte de la resiliencia al fallo de la electrónica **no puede vivir en el PLC**: tiene que ser **lógica pasiva** (termostatos bimetálicos, muelles, contactos mecánicos) que opere con el PLC muerto. Pendiente de bajar a esquema. Candidatos identificados:

- **Corte térmico ACS → P-ACS:** contacto NC bimetálico en **serie con la alimentación** de P-ACS. Independiente del PLC.
- **Z1/Z2/TK1 → P-SOL + persianas:** cortan P-SOL y fuerzan cierre de persianas por hardware, sin pasar por el PLC.
- **Demanda fancoils → P2:** contacto del Zelio sobre el mando de P2, línea independiente del M241 (ver arriba).
- **Enclavamiento disipación ⇒ depuradora:** garantizar que no se abra la disipación a piscina sin circulación (además de en software).
- **Posición de fallo de actuadores:** V3V apartamentos → red; cortes D2 → cierran vía tándem; persianas → cierran. Por muelle, sin depender del PLC.
- **Conmutador manual/0/auto por actuador:** permite operar bombas/válvulas a mano con el PLC fuera.

## Dispositivo autónomo de cierre de persianas (sobretemperatura del captador)

Primer dispositivo de lógica de seguridad concretado. Objetivo: **cerrar las persianas que ocultan los captadores al dispararse una sobretemperatura, aunque el PLC no funcione**, evitando el estancamiento del campo solar.

**Elemento de actuación: termostato bimetálico mecánico (klixon).** Es física pura: una lámina bimetálica que, al alcanzar el tarado, se deforma y **abre o cierra un contacto mecánicamente**. **Sin electroimán, sin bobina, sin electrónica** — no hay nada que falle electrónicamente. Es lo más robusto posible para esta función.

**Concepto:** la orden de cierre por seguridad actúa con independencia del PLC y, cuando lo hace, tiene **prioridad sobre el mando del PLC** (no se suma a él; el propio klixon hace de conmutador físico). OR cableada con prioridad de la seguridad, **sin relé**.

Tipos de klixon según uso:
- **NC (abre al calentar):** en reposo conduce; al superar el tarado, abre. Va **en serie** para cortar.
- **NA (cierra al calentar):** en reposo abierto; al calentar cierra. Para *activar* algo con la sobretemperatura.
- **Conmutado SPDT mecánico (común + NA + NC):** conmuta el común de una vía a otra mecánicamente. Permite la conmutación PLC↔seguridad **sin relé**.

Dos arquitecturas según el tipo de actuador de persiana:

### Opción A — Persiana fail-safe por muelle (RECOMENDADA)

Actuador con **retorno por muelle a cerrada** (como una compuerta cortafuegos). El PLC la mantiene **abierta** dándole tensión; sin tensión, cae a **cerrada** por muelle.

- **Klixon NC** (rearme manual) **en serie con la alimentación** del actuador.
- Disparo por sobretemperatura → el bimetálico abre → corta la tensión → la persiana **cae a cerrada por muelle**.
- Fallo del PLC o corte general → misma consecuencia: cerrada.

Un solo componente pasivo (klixon NC) y dos terminales. Sin electrónica, sin relé, sin finales de carrera. **Fail-safe puro.**

```
+V ──[klixon NC sobretemp.]──[mando PLC: mantener abierta]── actuador muelle ── 0V
       (abre al calentar)        (energiza = abierta)        (sin tensión = cerrada)
```

### Opción B — Persiana con motor reversible (subir/bajar), también sin electrónica

Si el actuador es un motor reversible (no se puede "dejar caer"), se usa un **klixon conmutado SPDT mecánico** — la conmutación la hace la lámina bimetálica, **sin relé**:

- **Reposo** (frío): común → **mando del PLC** (sube/baja según el PLC).
- **Disparo** (sobretemperatura): el bimetálico conmuta el común → **orden fija de BAJAR** → la persiana cierra con prioridad, ignore lo que diga el PLC.

```
                    ┌─ reposo (frío):   común → mando PLC (subir/bajar) ─┐
motor persiana ──[klixon SPDT mecánico]                                  ├─→ motor
                    └─ disparo (calor):  común → orden fija BAJAR ────────┘
```

Verificar que el contacto del klixon **aguanta la corriente del motor** de la persiana (los motores de persiana son cargas pequeñas; suele bastar). Solo si el motor pidiera más de lo que aguanta el klixon, este gobernaría un contactor — pero entonces se introduce un componente activo, a evitar salvo necesidad.

### Requisitos comunes a ambas

- **Alimentación independiente del PLC:** el circuito klixon + actuador toma energía de una línea que **no depende de la fuente de control 24V ni de una salida del PLC**; sigue operando con el PLC colgado mientras haya tensión.
- **Klixon de rearme manual:** una vez disparado, no rearma solo (evita reabrir las persianas al enfriar un poco); obliga a revisar la causa. Mismo criterio que Z1/Z2/TK1 y el corte de ACS.
- **Aviso al PLC:** un contacto auxiliar lleva la señal al M241 (DI) para registro/alarma, pero **el cierre no pasa por el PLC**.
- **Coherencia con Z1/Z2/TK1:** este es el actuador físico del cierre que la disipación solar (M02) invoca como 2.º escalón; el mismo TK1 (o un klixon dedicado en el captador) puede gobernarlo.

**Recomendación:** actuador de persiana **fail-safe por muelle (Opción A)** + **klixon NC de rearme manual en serie**. Toda la seguridad se reduce a un bimetálico en serie con la alimentación: intrínsecamente seguro ante cualquier fallo (electrónica, PLC o tensión) y sin un solo componente activo.

## Reglas de diseño

- Cada actuador con **conmutador manual/0/auto**.
- Cada actuador con **posición de fallo** definida (la segura) ante pérdida de tensión.
- Las seguridades térmicas cortan **por hardware (bimetálico mecánico), en serie con la potencia**; el M241 solo recibe el aviso.
- **Primero el corte/conmutación mecánica directa; el relé solo si es inevitable; la electrónica nunca** en la capa de seguridad.
- Las **funciones de confort resilientes** (clima vía Zelio→P2) pueden usar lógica activa independiente del PLC (Zelio), pero **no sustituyen** a las seguridades pasivas críticas, que siguen en bimetálico.

## Pendientes

- **Diseño de la lógica cableada** del resto de cadenas (esquema eléctrico con bimetálicos).
- Tabla de posición de fallo por actuador (bombas, V3V1/V3V2, cortes D2, V3V de modo BC, V3V disipación, V3V apartamentos, persianas, depuradora).
- Decidir qué enclavamientos van **solo en software**, cuáles **solo cableados (pasivos)** y cuáles **en ambas capas** (redundantes).
- Elegir tipo de actuador de persiana (muelle vs motor reversible) → fija la arquitectura A o B.
- Tarado y referencia del klixon de persianas (temperatura, NC/SPDT, rearme manual, capacidad de contacto).
- **Cablear demanda Zelio → P2** con línea independiente del M241 + conmutador manual/0/auto; verificar que P2 tolera arrancar contra red parcialmente cerrada (ver M08).
