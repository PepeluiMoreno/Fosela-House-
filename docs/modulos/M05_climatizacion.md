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

## Distribución a fancoils — arborescente con PICV

- **13 fancoils de 2 kW (solo vivienda).** Caudal por fancoil a ΔT 5 °C: 2000 / (1,16 × 5) ≈ **345 L/h** (~5,75 L/min).
- **PICV sin actuador (solo cuerpo).** Decisión: se compran **solo los cuerpos** de las PICV, **sin actuador**.
  - **Candidata: Frese 53-1615 compacta, DN15 ½" F/F, PN25, rango 0,44-2,53 GPM (≈100-575 L/h).** El caudal de fancoil (345 L/h) cae **cómodo en el rango**. DN15 correcta (no necesita DN20). ~24 €/ud. Frese es fabricante de referencia en PICV. **Comprada (ayer).**
  - **DN15 + multicapa 20 al fancoil: combinación correcta.** El multicapa 20 mm tiene Ø interior ~15-16 mm = mismo calibre que el paso DN15 de la válvula → sin estrangulamiento ni salto de sección. A 345 L/h la velocidad en DN15 es ~0,48 m/s (muy holgada). Conexión: multicapa 20 → racor a rosca ½" → PICV ½". No se necesita DN20.
  - **Sin actuador, la PICV sigue cumpliendo el EQUILIBRADO** (las dos funciones mecánicas internas): limitación de caudal al valor preajustado + independencia de presión. Eso es justo lo que permite la arborescente sin colector ni válvulas de equilibrado.
  - **El control de temperatura por estancia lo hace el VENTILADOR del fancoil**, gobernado por el termostato de la estancia. No se gobierna el agua por zona. Motivo: no hay termostatos asequibles con salidas analógicas tanto para el ventilador como para un actuador de PICV; meter actuador además del control de ventilador duplicaría el control. El agua circula siempre a caudal equilibrado; cada estancia regula con su ventilador.
- **Distribución arborescente:** tronco **32 mm** → ramas **25 mm** → bajadas a cada FCU **20 mm** (multicapa). Primario del buffer (P1) también 32.
- **Sin colector de fancoils:** la independencia de presión de las PICV anula la desventaja de la arborescente. PICV y colector resuelven el mismo problema → redundante poner ambos. Se elige arborescente + PICV.
- **Vaso de expansión** del conjunto buffer+fancoils (misma masa de agua, una aguja): en la aspiración de P2 (ver M08).

## Simultaneidad: hidráulica ≠ térmica (importante)

Como el agua **circula siempre** por todos los fancoils (no se corta por zona — solo se para el ventilador), hay que distinguir dos simultaneidades:

- **Simultaneidad hidráulica (para P2):** alta. Casi todas las ramas tienen paso de agua a su caudal equilibrado siempre que P2 esté en marcha, independientemente de qué estancias pidan clima. Para dimensionar **la bomba P2** cuenta el caudal con (casi) todas las PICV con paso → próximo a la suma: ~4.485 L/h a pleno, o el caudal que P2 sea capaz de mover contra la red.
- **Simultaneidad térmica (para la BdC):** menor. El fancoil con ventilador parado **casi no intercambia calor** (sin aire forzado el intercambio es mínimo), así que la **demanda térmica real** sobre el buffer/BdC baja con las estancias satisfechas. La BdC se dimensiona por la **demanda térmica del edificio**, NO por la suma de fancoils (ver M03).

> Consecuencia de diseño: P2 mueve caudal por toda la red de continuo (penalización energética asumida por no cortar agua por zona); la BdC NO tiene que cubrir 26 kW de emisión instalada, sino la demanda real de la vivienda amortiguada por el buffer y el tándem.

- ⚠️ **P2 con (casi) toda la red abierta:** caudal alto. La ALPHA2 25-40 llega a ~2,5-3 m³/h a baja altura; con la red cargada **puede quedarse justa**. **Verificar la curva de P2 contra la pérdida de carga real de la arborescencia**; si no llega, subir a 25-60.
- ⚠️ **Velocidad en el tronco de 32:** a caudales altos (>3 m³/h) la velocidad pasa de ~1,5 m/s (cómodo). Vigilar ruido; valorar tronco inicial de 40 mm.

## Control

- `FB_ClimateReversible.st` (a reescribir): gestión de V3V1/V3V2 + cortes antitermosifón + P1 supeditada a garantía de ACS + P2 según demanda global de clima.
- **Los fancoils NO se gobiernan individualmente desde el PLC** (control por ventilador/termostato de estancia, local). El PLC gobierna el lazo del buffer (P2, temperatura del agua, modo calor/frío), no cada FCU.
- Enclavamiento: válvulas en posición antes de arrancar P1 / cambiar modo BC.
- Posición de fallo: cortes cierran la vía al tándem por muelle (ver M10).

## Pendientes

- Reescribir `FB_ClimateReversible.st` (topología 2 V3V + P1 trasvase).
- **Verificar curva de P2 (ALPHA2 25-40)** contra la pérdida de carga real de la arborescencia con la red abierta; subir a 25-60 si se queda corta.
- Valorar tronco inicial de 40 mm si la velocidad genera ruido.
- Dimensionar la BdC por **demanda térmica de la vivienda** (ver M03), no por suma de fancoils.
