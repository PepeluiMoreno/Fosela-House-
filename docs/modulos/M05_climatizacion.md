# M05 — Climatización reversible (origen híbrido solar-aerotermia)

**Estado:** 🔶 topología cerrada · `FB_ClimateReversible.st` pendiente de reescribir a esta topología.
**Depende de:** M01 (tándem), M03 (BC) · **Control:** clima + arbitraje (M09).

## Propósito

Climatizar la vivienda (13 fancoils de 2 kW) en calor y frío, desde un **buffer de inercia de 150 L** (aguja hidráulica de 4 bocas), aprovechando en invierno el calor híbrido solar+aerotérmico acumulado en el tándem.

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

- **13 fancoils de 2 kW.** Caudal por fancoil a ΔT 5 °C: 2000 / (1,16 × 5) ≈ **345 L/h** (~5,75 L/min).
- **Caudal de diseño de clima (simultaneidad 75 %):** suma a pleno caudal de los 13 = ~4.485 L/h; con **factor de simultaneidad 0,75** → **~3.360 L/h** (≈3,36 m³/h). Valor prudente: cubre el escenario de apartamentos turísticos ocupados pidiendo a la vez en temporada alta, sin dimensionar para el 100 % (improbable).
- **Distribución arborescente:** tronco **32 mm** → ramas **25 mm** → bajadas a cada FCU **20 mm** (multicapa). Primario del buffer (P1) también 32.
  - ⚠️ **Velocidad en el tronco de 32 a 3.360 L/h:** ~1,75 m/s (int. ~26 mm), por encima del cómodo ~1,5 m/s. Aceptable pero ya no holgado — vigilar ruido; valorar tronco inicial de 40 mm si molesta.
- **Una PICV por fancoil** (válvula de control independiente de la presión): regula + mantiene caudal constante ante variaciones de presión + controla.
  - **Candidata: Frese 53-1615 compacta, DN15 ½" F/F, PN25, rango 0,44-2,53 GPM (≈100-575 L/h).** El caudal de fancoil (345 L/h) cae **cómodo en el rango**, con margen a ambos lados. DN15 es la talla correcta (no necesita DN20). ~24 €/ud (verificar si incluye actuador o es solo cuerpo). Frese es fabricante de referencia en PICV.
  - **Actuador:** cada PICV necesita su actuador (térmico on/off o motorizado) gobernado por la demanda de zona. Probablemente va aparte del cuerpo a ese precio — sumar al presupuesto.
- **Sin colector de fancoils:** la independencia de presión de las PICV anula la desventaja de la arborescente (los fancoils del final del ramal reciben menos presión, pero su PICV lo compensa). PICV y colector resuelven el mismo problema → poner ambos es redundante. Se elige arborescente + PICV (menos tubería, control superior).
- ⚠️ **P2 a 3.360 L/h:** la ALPHA2 25-40 llega a ~2,5-3 m³/h a baja altura; **a 3,36 m³/h puede quedarse justa** según la pérdida de carga real de la arborescencia. **Verificar la curva de P2 a ese caudal**; si no llega, subir a 25-60 o aceptar leve caída con todos los fancoils a tope (raro).
- **Vaso de expansión** del conjunto buffer+fancoils (misma masa de agua, una aguja): en la aspiración de P2 (ver M08).

## Control

- `FB_ClimateReversible.st` (a reescribir): gestión de V3V1/V3V2 + cortes antitermosifón + P1 supeditada a garantía de ACS + P2 según demanda.
- Enclavamiento: válvulas en posición antes de arrancar P1 / cambiar modo BC.
- Posición de fallo: cortes cierran la vía al tándem por muelle (ver M10).

## Pendientes

- Reescribir `FB_ClimateReversible.st` (topología 2 V3V + P1 trasvase).
- Verificar potencia BC para ACS + clima simultáneos sostenidos.
- Confirmar PICV Frese 53-1615 (rango OK para 345 L/h) y si el precio incluye actuador.
- **Verificar curva de P2 (ALPHA2 25-40) a ~3.360 L/h** (simultaneidad 75 %); subir a 25-60 si se queda corta.
- Valorar tronco inicial de 40 mm si la velocidad a 1,75 m/s en el 32 genera ruido.
