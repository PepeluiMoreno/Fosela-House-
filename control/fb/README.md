# `fb/` — FBs específicos del proyecto

FBs que implementan la lógica de la instalación. Usan los genéricos de `lib/` y los TYPE de `types/`.

Contenido previsto (en orden de desarrollo, ver `docs/PENDIENTES.md`):
1. `FB_Solar` — solar + muestreo + disipación (M02).
2. `FB_DHW_Station` — estación ACS al paso (M04).
3. `FB_ClimateReversible` — clima reversible 2 V3V + P1 + buffer (M05).
4. `FB_PoolReversible` — climatización piscina, dos HX (M06).
5. `FB_PoolFiltration` — depuradora con ciclos propios + forzado HVAC (M06).
6. `FB_BDC_Arbiter` — árbitro ACS+clima simultáneos, sacrificable piscina (M09).
