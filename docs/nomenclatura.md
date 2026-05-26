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
| **VZ-INV** | 2 vías zona | Vía de invierno: primario buffer ↔ tándem (toma del punto alto común, retorno a fondo D1). Abierta en invierno |
| **VZ-VER** | 2 vías zona | Vía de verano: primario buffer ↔ BC fría (salida V3V estacional). Abierta en verano |
| **VMT1** | Mezcladora termostática mecánica | Limita ACS a 55 °C (autónoma, no PLC) |
| **AFS / FS** | 3 vías por apartamento | Precalentada / agua de red (distribución apartamentos) |

> Dos VZ enclavadas: VZ-INV y VZ-VER nunca abiertas a la vez. Cada una con su retención. (Simplificación de las 4 VZ iniciales al adoptar punto alto común de extracción.)

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
| **SPxx** | Setpoints | Lo que el sistema quiere conseguir: confort / punto de funcionamiento de los receptores de agua técnica | Consigna ACS, impulsión a fancoils, temperatura piscina |
| **Pxx** | Parámetros de control | Lo que se decide que debe pasar: umbrales, tiempos, velocidades | Umbral de simultaneidad clima, intervalo de muestreo solar |
| **HYxx** | Histéresis intrínsecas | Cómo responde físicamente cada reservorio en cada situación térmica (inercia). **No es un margen elegido**, es propiedad del reservorio en esa situación. Hay tantas HY como situaciones reservorio-transición existan | Inercia del tándem enfriándose por extracción de ACS; tándem calentándose por BC; tándem por solar; piscina (inercia lentísima) |
| **OFxx** | Offsets de instrumentación | Corrección de la desviación de cada sonda (calibración sin tocar hardware) | Error de calibración de una NTC/PT1000 |
| **ST_** | Estados | Estados de las máquinas de estado de cada FB. Enum **con nombre** (HMI es servidor web, hay sitio para texto legible) | `ST_DHW.ACTIVO`, `ST_Solar.MUESTREO`, `ST_Clima.INVIERNO` |

**Criterio de fondo:** SP = el deseo · P = la regla · HY = la física del reservorio · OF = el error del sensor · ST = la situación del autómata.

**Estados con nombre (no numerados)** porque el HMI será **servidor web**: hay espacio para mostrar texto legible. (Si el HMI fuera un display limitado, se usarían estados numerados + tabla de equivalencia en la documentación.)
