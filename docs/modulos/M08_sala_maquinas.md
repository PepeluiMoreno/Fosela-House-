# M08 — Sala de máquinas (hidráulica común)

**Estado:** 🔶 colector, bombas, vasos y diámetros definidos · falta confirmar producto.
**Transversal a:** todos los módulos hidráulicos.

## Colector de consumidores (sala)

- **Punto alto común de extracción:** ACS, clima (trasvase P1) y piscina toman de zona alta común del tándem; la prioridad la ejerce el control (M09), no la hidráulica. Retornos al fondo de D1.
- Reparte **agua técnica del tándem** a los consumidores grandes. (Los fancoils NO cuelgan de aquí: van por arborescencia desde el buffer, ver M05.)
- **Colector de latón roscado (sin soldar).** Candidato Wallapop: cuerpo **1" (DN25)**, salidas **3/4"**, encadenable (macho-hembra), 12 €. Es un colector **ajustado, no holgado**: con el cuerpo de 1" y clima+ACS simultáneos (~3.480 L/h) la velocidad interna sube (~1,9 m/s); aceptable porque el clima sale por el extremo y el arbitraje suaviza, pero sin margen. Para holgura: encadenar dos cuerpos o buscar cuerpo de 2".
- Tapón roscado en extremos, **purgador** en alto y **vaciado** en bajo. Sellado cuidadoso de roscas.
- Sin separador hidráulico de marca (Caleffi SEP4/SEPCOLL): innecesario y caro.

### Reparto de bocas

| Boca | Ramal | Caudal |
|---|---|---|
| Extremo 1" | Alimentación desde el tándem (suma de caudales) | ~3.480 L/h |
| Extremo 1" opuesto | **Clima = trasvase P1 al buffer** (el de más caudal) | ~2.400 L/h |
| Salida 3/4" | ACS (primario, P-ACS) | ~1.080 L/h |
| Salida 3/4" | Piscina (P-POOL, ΔT alto) | ~900-1.075 L/h |

> "Clima por el extremo" = el **trasvase P1 al buffer de inercia**, NO los fancoils.

## Posición de las bombas

- Prevalece la **aspiración con presión positiva** (evitar cavitación), con el vaso del lado de aspiración. La "parte fría" es criterio menor.
- Cada bomba en la **impulsión de su ramal** + **válvula de retención aguas abajo** (evita reflujo por el colector con la bomba parada).
- P-ACS en impulsión (por control).

## Vasos de expansión

Regla: cada **masa de agua cerrada e independiente**, su vaso, en el lado frío/aspiración.

| Vaso | Circuito | Notas |
|---|---|---|
| **Solar** | Glicol (M02) | Imprescindible; absorbe vapor de estancamiento. Junto a P-SOL, en el retorno frío (boca inferior serpentín D1) |
| **Fancoils + buffer 150 L** | Clima (M05) | Una sola masa (la aguja los une). En aspiración de P2 |
| **BC (integrado)** | M03 | Trabaja en verano (en invierno comparte agua con el tándem). Verificar que cubre ~812 L o añadir externo |

**Sin vaso propio:** primarios de HX (ramas del agua técnica, los cubre el vaso del tándem/BC); secundarios separados por barrera (ACS → red; piscina → vaso de la piscina).

## Diámetros y racordería

- **Sala de máquinas: todo multicapa 32 mm = rosca 1" (DN25).** Fittings de 32 (rematan en 1", **no** 1¼"). Bombas y válvulas en 1".
- **Primario de ACS en cobre 22 mm** (~0,95 m/s).
- **Distribución fancoils (fuera de sala):** arborescente 32 → 25 → 20 con PICV (M05).
- **Manguito dieléctrico** pegado a cada boca de depósito, luego llave de bola.

## Retención antitermosifón del tándem

- En el enlace serie **tapa de D1 → fondo de D2**, una retención orientada a dejar pasar solo D1→D2; impide que D2 caliente retroceda a D1 y deshaga la estratificación (ver M01).

## Manómetros

- En cada grupo de seguridad (solar, agua técnica), en el circuito de fancoils, y en impulsión/retorno de la BC. Opcional en primario de ACS.

## Parámetros constructivos

Los valores que dependen del componente comercial elegido (caudal nominal de captadores, U y área/placa del HX, potencia pico del campo, volumen del vaso de la BC, Kv de válvulas...) son **parámetros `Pxx`** con valor conocido el día de la instalación. El diseño se expresa en función de ellos; no bloquean el diseño.

## Pendientes

- Confirmar medidas del colector candidato (1" cuerpo / 3/4" salidas) y aptitud para agua caliente de sus llaves.
- Dimensionado definitivo de vasos según volumen real de cada circuito.
