# M08 — Sala de máquinas (hidráulica común)

**Estado:** 🔶 colector, bombas, vasos y diámetros definidos · falta confirmar producto.
**Transversal a:** todos los módulos hidráulicos.

## Colector de consumidores

- **Punto alto común de extracción:** ACS, clima y piscina toman de zona alta común del tándem; la prioridad la ejerce el control (M09), no la hidráulica. Retornos al fondo de D1.
- **Colector casero de latón roscado (sin soldar):** cuerpo **2" (DN50)**, salidas reducidas a **1" (DN25)** con manguitos. A 2", velocidad ~0,5 m/s incluso con ACS+clima simultáneos (~3.480 L/h) → punto de presión estable, ninguno ahoga al otro.
- Tapón roscado en extremos, **purgador** en alto y **vaciado** en bajo. Sellado cuidadoso de roscas.
- Sin separador hidráulico de marca (Caleffi SEP4/SEPCOLL): innecesario con colector sobredimensionado + arbitraje por software.

## Posición de las bombas

- Prevalece la **aspiración con presión positiva** (evitar cavitación), con el vaso del lado de aspiración. La "parte fría" es criterio menor.
- Cada bomba en la **impulsión de su ramal** + **válvula de retención aguas abajo** (evita reflujo por el colector con la bomba parada).
- P-ACS en impulsión (por control).

## Vasos de expansión

Regla: cada **masa de agua cerrada e independiente**, su vaso, en el lado frío/aspiración.

| Vaso | Circuito | Notas |
|---|---|---|
| **Solar** | Glicol (M02) | Imprescindible; absorbe vapor de estancamiento. Junto a P-SOL |
| **Fancoils + buffer 150 L** | Clima (M05) | Una sola masa (la aguja los une). En aspiración de P2 |
| **BC (integrado)** | M03 | Trabaja en verano (en invierno comparte agua con el tándem). Verificar que cubre ~812 L o añadir externo |

**Sin vaso propio:** primarios de HX (ramas del agua técnica, los cubre el vaso del tándem/BC); secundarios separados por barrera (ACS → red; piscina → vaso de la piscina).

## Diámetros y racordería

- **Sala de máquinas: todo multicapa 32 mm = rosca 1" (DN25).** Fittings de 32 (rematan en 1", **no** 1¼"). Bombas y válvulas en 1".
- **Primario de ACS en cobre 22 mm** (~0,95 m/s).
- **Distribución fancoils:** tronco 32 → ramas 25 → bajadas 20 (fuera de sala).
- **Manguito dieléctrico** pegado a cada boca de depósito, luego llave de bola.

## Manómetros

- En cada grupo de seguridad (solar, agua técnica), en el circuito de fancoils, y en impulsión/retorno de la BC. Opcional en primario de ACS.

## Pendientes

- Confirmar tamaño de los colectores candidatos (Wallapop) y aptitud para agua caliente de las llaves integradas.
- Dimensionado definitivo de vasos según volumen real de cada circuito.
