# M05 — Climatización reversible (origen híbrido solar-aerotermia)

**Estado:** 🔶 topología cerrada · `FB_ClimateReversible.st` pendiente de reescribir a esta topología.
**Depende de:** M01 (tándem), M03 (BC) · **Control:** clima + arbitraje (M09).

## Propósito

Climatizar **la vivienda** (220 m², 13 fancoils de 2 kW) en calor y frío, desde un **buffer de inercia de 150 L** (aguja hidráulica de 4 bocas), aprovechando en invierno el calor híbrido solar+aerotérmico acumulado en el tándem.

> **Los apartamentos turísticos NO se climatizan** — solo reciben ACS (M07). La climatización es exclusiva de la vivienda.

## Decisiones clave

- **Buffer 150 L como aguja.** Secundario fijo: **P2 → fancoils** (conexión cruzada: aspira arriba, retorna abajo).
- **Origen híbrido en invierno:** el agua técnica de la BC se funde con el tándem; el clima se nutre indistintamente de solar (vía D1) y aerotermia (BC).
- **Verano independiente:** la BC alimenta el buffer en frío, aislado del tándem (no mezclar 10 °C con 50 °C).
- **P1 = bomba de trasvase D2 → buffer**, solo cuando D2 está bien cargado y la **ACS al paso queda garantizada**. Sale de un colector de D2 y vuelve al otro.

## Topología del lazo del buffer

- **V3V1** (desviadora, impulsión): caudal de P1 → buffer **o** → colector de D2.
- **V3V2** (desviadora, retorno): reconecta el retorno del buffer según el modo, coordinada con V3V1.
- **Dos válvulas de corte de 2 vías sobre el serpentín de D2** (antitermosifón), que clausuran el serpentín por sus dos bocas:
  - Impulsión: entre la entrada superior del serpentín de D2 y la V3V1.
  - Retorno: aguas abajo de la T (subida a BC / bajada a la toma inferior del serpentín), en la rama que baja a la toma inferior. **No en serie.**

> Esta topología **sustituye** el planteamiento anterior de válvulas de zona (VZ) y el antiguo buffer "D3". Queda obsoleto.

## Distribución a fancoils — arborescente con PICV y corte por zona

- **13 fancoils de 2 kW (solo vivienda).** Caudal por fancoil a ΔT 5 °C: 2000 / (1,16 × 5) ≈ **345 L/h** (~5,75 L/min).
- **Distribución arborescente:** tronco **32 mm** → ramas **25 mm** → bajadas a cada FCU **20 mm** (multicapa). Primario del buffer (P1) también 32. **Sin colector de fancoils** (la independencia de presión de las PICV lo hace innecesario).
- **PICV Frese 53-1615 (OPTIMA Compact) + actuador electrotérmico** (una por fancoil):
  - **Cuerpo: Frese 53-1615 compacta, DN15 ½" F/F, PN25, rango "alto" 100-575 L/h (carrera 5,0 mm).** El caudal de fancoil (345 L/h) cae **cómodo en el rango**. ~24 €/ud. **Comprada.** DN15 correcta (no necesita DN20). Cuerpo latón DZR, diafragma HNBR, juntas EPDM, -10/+120 °C, admite glicol hasta 50%.
  - **DN15 + multicapa 20 al fancoil:** mismo calibre (Ø interior multicapa 20 ≈ 15-16 mm = paso DN15), sin estrangulamiento. A 345 L/h, velocidad ~0,48 m/s (holgada). Conexión: multicapa 20 → racor ½" → PICV ½". Accesorio de conexión opcional Frese **43-2330** (racores + acoplamientos DN15, G¾"-R½").
  - **Actuador electrotérmico todo/nada NC** (corte por zona): cierra el agua del fancoil cuya estancia está satisfecha. **Requisitos Frese (ineludibles): rosca M30×1,5, fuerza mínima 100N, NC.** Frese declina responsabilidad con actuadores no especificados.
    - **Referencia (original Frese): 48-5528** (230 V CA) — electrotérmico todo/nada NC, carrera 5,0 mm. Variante 24V: **48-5527** (24 V CA/CC). *(Las 48-5525/5526 son carrera 2,5 mm, NO aplican aquí.)*
    - **Equivalencia (alternativa compatible): Watts 22CX 230V NC 4 hilos** (M30×1,5, electrotérmico todo/nada NC, 230V, 1,8W, IP54). Cumple rosca y NC; los 4 hilos aportan contacto auxiliar de fin de carrera opcional. Verificar fuerza ≥100N. Distribuidor Polarstock.
    - ⚠️ **NO sirven los actuadores de suelo radiante genéricos**: suelen ser M28×1,5 o clip propietario. La Frese exige **M30×1,5**.
  - **Funciones que cubre la PICV:** equilibrado (limitación de caudal preajustado + independencia de presión, mecánicas) **y** corte por zona (vía actuador). Una sola pieza por fancoil hace ambas; no hacen falta válvulas de zona aparte ni colector de equilibrado.
  - **Corte manual de servicio (gratis):** la Frese OPTIMA Compact (DN10-DN32) admite **tapón roscado** que la convierte en **válvula de corte total hasta 10 bar**. Permite **aislar/anular un fancoil** para mantenimiento sin vaciar el circuito, sin llaves de corte adicionales. Cierre **manual de servicio**, distinto del corte por zona automático (actuador).
- **Preselección de caudal:** girar el anillo de preajuste de cada PICV a la posición que da **345 L/h** → en rango alto carrera 5,0 mm, preajuste **~3,0** (334 L/h) o **3,2** (352 L/h). Igual en las 13 (fancoils idénticos). ⚠️ **La escala de preselección NO es accesible una vez montado el actuador** → **preseleccionar el caudal primero, montar el actuador después.** Respetar la flecha de sentido de flujo.

## Control de los fancoils y gobierno del actuador

- **El ventilador del fancoil es 0-10V** (no on/off), gobernado por el termostato de estancia según temperatura.
- **El actuador de la PICV es on/off**, gobernado por el **contacto de demanda del termostato** (señal "pide / no pide"), no por la señal 0-10V del ventilador. El desfase térmico que descartaba modular la PICV con la curva 0-10V **no aplica al corte on/off** (solo interesa abrir cuando trabaja / cerrar cuando para).
- **Cableado — manguera de 4 hilos por termostato** entre estancia y sala de máquinas:
  - 2 hilos: **contacto de demanda** on/off del termostato (informa "este fancoil pide").
  - 2 hilos: **change-over** (modo calor/frío) desde el control al termostato.
- **El actuador de la PICV se gobierna localmente en cada fancoil** (con el contacto del termostato de su estancia). No puede centralizarse en la sala porque la distribución es **arborescente** (no hay colector central donde agrupar válvulas).
- **En la sala**, los 13 contactos de demanda permiten una **lógica OR**: si ningún fancoil pide → **parar P2** (no bombear sin consumidores); en cuanto uno pida → arrancar P2. Esta OR se resuelve en relé programable o en el PLC (ver M12).

## Simultaneidad y dimensionado de P2

- **La simultaneidad de fancoils puede ser ALTA** (toda la vivienda pidiendo a la vez en un día extremo). Aun con corte por zona, el caso de dimensionado de P2 asume **caudal alto** (próximo a la suma): ~4.485 L/h ≈ **4,5 m³/h**.
- **P2 es una bomba grande**, no una circuladora doméstica pequeña. Pérdida de carga pesimista a 4,5 m³/h: Δp mínimo PICV ~2,5 m (ineludible) + batería fancoil ~2 m + tubería arborescente ~3 m + buffer/sala ~1 m = **~8,5 m**. → **P2 ~8-9 m a 4,5 m³/h** (ver M08): MAGNA3/Stratos 25-80 o 32-80, posible DN32. **A comprar.**
- El corte por zona aporta **ahorro energético** (no bombea por fancoils satisfechos) y, con una P2 modulante/electrónica de presión constante, evita sobrepresión cuando cierran zonas. No reduce el caso de dimensionado porque la simultaneidad puede ser alta.
- ⚠️ **Velocidad en el tronco de 32 a caudal alto** (~1,75 m/s a 3,36 m³/h, más a 4,5): por encima del cómodo ~1,5 m/s. Vigilar ruido; valorar tronco inicial de 40 mm.
- **Vaso de expansión** del conjunto buffer+fancoils: en la aspiración de P2 (ver M08).

## Control (FB)

- `FB_ClimateReversible.st` (a reescribir): gestión de V3V1/V3V2 + cortes antitermosifón + P1 supeditada a garantía de ACS + arranque/paro de P2 según la **OR de demandas** de los termostatos + modo calor/frío (change-over).
- **Los fancoils NO se gobiernan individualmente desde el PLC** en cuanto a temperatura (eso lo hace el termostato local sobre su ventilador y su actuador de PICV). El PLC/relé gobierna el lazo del buffer (P2, temperatura del agua, modo) y recibe la demanda agregada.
- Enclavamiento: válvulas en posición antes de arrancar P1 / cambiar modo BC.
- Posición de fallo: cortes cierran la vía al tándem por muelle (ver M10). Los actuadores de PICV son **NC** → sin tensión cierran (fancoil aislado).

## Pendientes

- **Comprar actuadores electrotérmicos** Frese 48-5528 (230V) — equivalente Watts 22CX 230V NC —, uno por fancoil. Verificar fuerza ≥100N si se opta por el equivalente.
- Definir el gobierno de la OR de demandas y la parada de P2: relé programable independiente vs entradas al PLC (ver M12, decisión de tarjeta).
- Confirmar que los termostatos de estancia tienen **contacto de demanda** (relé libre) **y** entrada de **change-over**.
- Reescribir `FB_ClimateReversible.st` (topología 2 V3V + P1 + OR de demandas + change-over).
- **Comprar P2** (~8-9 m a 4,5 m³/h, ver M08).
- Valorar tronco inicial de 40 mm si la velocidad genera ruido.
- Dimensionar la BdC por **demanda térmica de la vivienda** (ver M03), no por suma de fancoils.
