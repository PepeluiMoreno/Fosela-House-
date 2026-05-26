# Nomenclatura del proyecto Casa Fosela

Convención única para todo el proyecto (esquema de principio, memoria, manual de montaje, código ST).

## Depósitos

| Etiqueta | Descripción |
|---|---|
| **D2** | Acumulador aerotérmico (caliente). Cargado por la BC. Tapa = punto más caliente del tándem. |
| **D1** | Acumulador solar (frío). Cargado por solar. Fondo = punto más frío del tándem. |
| **Tándem D1+D2** | Depósito de inercia único de agua técnica (~812 L), estratificado, en serie. |
| **Buffer inercia** | Aguja hidráulica de 150 L, 4 bocas, del circuito de clima. |

## Bombas / circuladoras

| Etiqueta | Circuito | Posición | Modula |
|---|---|---|---|
| **P-SOL** | Primario solar (glicol), carga D1 | Retorno frío del serpentín | Sí (PWM, muestreo + ΔT) |
| **P-ACS** | Primario placa ACS | Impulsión (control por anticipación) | Sí (PWM, lazo PI) |
| **P-POOL** | Primario HX titanio piscina | Retorno frío | — |
| **P1** | Primario buffer clima (antes "PC") | Rama de invierno | — |
| **P2** | Secundario buffer clima → fancoils (antes "P3") | Impulsión a fancoils | — |
| (interna BC) | Primario de la BC | Integrada en el equipo | — |

> Nota: en el esquema de principio el secundario de clima estaba rotulado **P3** → renombrar a **P2**; la **PC** → **P1**.

## Intercambiadores

| Etiqueta | Tipo | Circuitos |
|---|---|---|
| **HX-ACS** | Placas AISI 316L | Primario agua técnica / secundario agua sanitaria |
| **HX-POOL-SOL** | Tubular de titanio | Excedente solar / agua de piscina |
| **HX-POOL-BC** | Tubular de titanio | BC (modo calor) / agua de piscina |
| **SERP-D1** | Serpentines en serie de D1 | Carga solar |
| **SERP-D2** | Serpentines en serie de D2 | Carga aerotérmica (BC) |

## Válvulas

| Etiqueta | Tipo | Función |
|---|---|---|
| **V3V estacional** | 3 vías motorizada | Impulsión BC: D2 (invierno) / buffer clima frío (verano) |
| **V3V disipación** | 3 vías motorizada | Glicol solar: carga D1 / desvío a HX-POOL-SOL (excedente) |
| **VZ1** | 2 vías zona | Verano-impulsión (BC → buffer clima) |
| **VZ2** | 2 vías zona | Verano-retorno (buffer clima → BC) |
| **VZ3** | 2 vías zona | Invierno-impulsión (D2 → P1 → buffer clima) |
| **VZ4** | 2 vías zona | Invierno-retorno (buffer clima → fondo D1) |
| **VMT1** | Mezcladora termostática mecánica | Limita ACS a 55 °C (autónoma, no PLC) |
| **AFS / FS** | 3 vías por apartamento | Precalentada / agua de red (distribución apartamentos) |

> VZ por parejas de estación: VZ1+VZ2 (verano) y VZ3+VZ4 (invierno) abren y cierran juntas. Nunca cruzadas.

## Sondas / seguridad

| Etiqueta | Descripción |
|---|---|
| Corte térmico ACS | Termostato bimetálico NC, rearme manual, ~70 °C, de inmersión. Corta P-ACS por hardware + avisa al M241. |
| Z1, Z2 | Termostatos seguridad D1/D2, ~90 °C, NC, rearme manual, hardware independiente. |
| TK1 | Termostato de contacto ~88 °C rearme manual (cadena de seguridad solar). |
