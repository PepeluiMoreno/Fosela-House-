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

## Reglas de diseño

- Cada actuador con **conmutador manual/0/auto**.
- Cada actuador con **posición de fallo** definida (la segura) ante pérdida de tensión.
- Las seguridades térmicas cortan **por hardware, en serie con la potencia**; el M241 solo recibe el aviso.

## Pendientes

- **Diseño de la lógica cableada** de cada cadena (relés, enclavamientos hardware, esquema eléctrico).
- Tabla de posición de fallo por actuador (bombas, V3V1/V3V2, cortes D2, V3V de modo BC, V3V disipación, V3V apartamentos, persianas, depuradora).
- Decidir qué enclavamientos van **solo en software**, cuáles **solo cableados** y cuáles **en ambas capas** (redundantes).
