# Nomenclatura del proyecto Casa Fosela

Convención única para todo el proyecto (esquema de principio, memoria, manual de montaje, código ST).

## Depósitos

| Etiqueta | Descripción |
|---|---|
| **D2** | Acumulador aerotérmico (caliente). Cargado por la BC. Tapa = punto más caliente del tándem. |
| **D1** | Acumulador solar (frío). Cargado por solar. Fondo = punto más frío del tándem. |
| **Tándem D1+D2** | Depósito de inercia único de agua técnica (~812 L), estratificado, en serie (tapa D1 → fondo D2, con retención antitermosifón). |
| **Buffer inercia** | Aguja hidráulica de 150 L, 4 bocas, del circuito de clima. |

## Bombas / circuladoras

| Etiqueta | Circuito | Posición | Modula |
|---|---|---|---|
| **P-SOL** | Primario solar (glicol), carga D1 | Retorno frío del serpentín | Sí (PWM, muestreo + ΔT) |
| **P-ACS** | Primario placa ACS | Impulsión (control por anticipación) | Sí (PWM, lazo PI) |
| **P-POOL** | Primario HX titanio piscina | Retorno frío | — |
| **P1** | Trasvase D2 → buffer de inercia (antes "PC") | Sale de un colector de D2, vuelve al otro; supeditada a ACS garantizada | — |
| **P2** | Secundario buffer clima → fancoils (antes "P3") | Impulsión a fancoils (aspira arriba, retorna abajo) | — |
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
| **V3V estacional** | 3 vías motorizada | Impulsión BC: D2/tándem (invierno) / buffer clima frío (verano) |
| **V3V disipación** | 3 vías motorizada | Glicol solar: carga D1 / desvío a HX-POOL-SOL (excedente) |
| **V3V1** | 3 vías desviadora | Impulsión del lazo del buffer: caudal de P1 → buffer **o** → colector de D2 |
| **V3V2** | 3 vías desviadora | Retorno del lazo del buffer; reconecta según modo, coordinada con V3V1 |
| **Corte-D2-imp** | 2 vías motorizada | Antitermosifón del serpentín de D2: entre la entrada superior del serpentín y la V3V1 |
| **Corte-D2-ret** | 2 vías motorizada | Antitermosifón del serpentín de D2: aguas abajo de la T (subida a BC / bajada a toma inferior), en la rama que baja a la toma inferior |
| **PICV** | Control independiente de presión | Una por fancoil: regula + mantiene caudal constante ante variaciones de presión + controla (distribución arborescente, M05) |
| **VMT1** | Mezcladora termostática mecánica | Limita la salida de ACS (autónoma, no PLC) |
| **AFS / FS** | 3 vías por apartamento | Precalentada / agua de red (distribución apartamentos, retorno por muelle a red) |

> **V3V1 + V3V2** (desviadoras) reconfiguran el lazo del buffer (verano: BC directa al buffer frío; invierno: clima de origen híbrido desde el tándem). **Corte-D2-imp + Corte-D2-ret** clausuran el serpentín de D2 por sus dos bocas (antitermosifón). Esta topología **sustituye** el esquema anterior de dos VZ (VZ-INV/VZ-VER), que queda obsoleto.

## Sondas / seguridad

| Etiqueta | Descripción |
|---|---|
| Corte térmico ACS | Termostato bimetálico NC, rearme manual, ~70 °C, de inmersión. Corta P-ACS por hardware + avisa al M241. |
| Z1, Z2 | Termostatos seguridad D1/D2, ~90 °C, NC, rearme manual, hardware independiente. |
| TK1 | Termostato de contacto ~88 °C rearme manual (cadena de seguridad solar). |

---

## Taxonomía de constantes y estados (convención del proyecto)

Cada constante del proyecto se clasifica por su **naturaleza** mediante un prefijo. Cualquiera que abra el proyecto sabe qué es una constante solo por su prefijo. Convención a aplicar de aquí en adelante (migración de lo existente: pendiente, ver PENDIENTES.md).

| Prefijo | Familia | Naturaleza | Ejemplo |
|---|---|---|---|
| **SPxx** | Setpoints | Lo que el sistema quiere conseguir: confort / punto de funcionamiento de los receptores de agua técnica | `SP_ACS_salida`, impulsión a fancoils, temperatura piscina |
| **Pxx** | Parámetros de control **y parámetros constructivos** | (a) Lo que se decide que debe pasar: umbrales, tiempos, velocidades. (b) Valores del **componente comercial elegido**, conocidos el día de la instalación; el diseño se expresa en función de ellos y no quedan bloqueados | Umbral de simultaneidad clima, intervalo de muestreo solar · `Pxx_pinch_HX_DHW`, caudal nominal de captadores, U y área/placa del HX, potencia pico del campo, vaso de la BC, Kv de válvulas |
| **HYxx** | Histéresis intrínsecas | **Solo histéresis.** Cómo responde físicamente cada reservorio en cada situación térmica (inercia). **No es un margen elegido**, es propiedad del reservorio en esa situación. Hay tantas HY como situaciones reservorio-transición existan | Inercia del tándem enfriándose por extracción de ACS; calentándose por BC; por solar; piscina (inercia lentísima) |
| **OFxx** | Offsets de instrumentación | Corrección de la desviación de cada sonda (calibración sin tocar hardware) | Error de calibración de una NTC/PT1000 |
| **ST_** | Estados | Estados de las máquinas de estado de cada FB. Enum **con nombre** (HMI es servidor web, hay sitio para texto legible) | `ST_DHW.ACTIVO`, `ST_Solar.MUESTREO`, `ST_Clima.INVIERNO` |

**Criterio de fondo:** SP = el deseo · P = la regla **o** el dato del componente · HY = la física del reservorio · OF = el error del sensor · ST = la situación del autómata.

**Parámetros constructivos (Pxx):** no son una familia aparte. Son `Pxx` cuyo valor se conoce al elegir el componente. No bloquean el diseño: se arrastran como variable nombrada y se rellenan el día de la instalación.

**Estados con nombre (no numerados)** porque el HMI será **servidor web**: hay espacio para mostrar texto legible. (Si el HMI fuera un display limitado, se usarían estados numerados + tabla de equivalencia en la documentación.)
