# M06 — Climatización de piscina

**Estado:** 🔶 diseño cerrado · `FB_PoolReversible` y `FB_PoolFiltration` pendientes.
**Toma de:** M01 (tándem, vía BC) y M02 (excedente solar) · **Control:** árbitro (M09) + disipación (M02).

## Propósito

Climatizar la piscina (~25 m³) con el objetivo de **extender la temporada de baño de abril a octubre**, y servir de **sumidero del excedente solar** en verano. Consumidor de menor prioridad.

## Decisiones clave

- **Dos intercambiadores tubulares de titanio**, uno por fuente:
  - **HX-POOL-SOL** ← excedente solar (camino directo glicol→piscina, esquiva el tándem).
  - **HX-POOL-BC** ← BC en modo calor.
- Titanio obligatorio (agua clorada; barrera categoría 5 EN 1717).
- Secundario de ambos: agua de piscina movida por la **depuradora existente** (sin circuladora propia).
- **P-POOL** en el retorno frío del primario.
- **Manta térmica / cubierta:** parte del diseño, no accesorio. Sin ella el objetivo abril-octubre no es realista con aerotermia a coste razonable (la evaporación nocturna dispara las pérdidas).

## Potencias de los intercambiadores

| HX | Dimensionado por | Potencia |
|---|---|---|
| **HX-POOL-BC** | Mantenimiento de temporada (cubrir pérdidas abril/oct con manta) | **~8-10 kW** |
| **HX-POOL-SOL** | Capacidad de disipar el excedente solar pico (1er escalón de disipación) | ≥ potencia pico del campo (Pxx constructivo, pdte. caudal captadores M02). Sobredimensionar por el bajo ΔT en disipación |

- Caudal del primario de piscina: con ~10 kW y **ΔT alto (8-10 °C)** → ~860-1.075 L/h → entra holgado por una salida de **3/4"** del colector (M08). No necesita el extremo de 1".

## Depuradora — `FB_PoolFiltration` (desvinculado del HVAC)

La depuradora la **gobierna el PLC** (bomba mayor → **contactor**, ver M13), pero su lógica de filtrado es **independiente de la climatización**:

- `FB_PoolFiltration` corre los **ciclos de filtrado propios** (horas/día, calendario), ajenos al HVAC.
- El HVAC (disipación solar M02, o calentamiento) puede **forzar la marcha** de la depuradora mediante una **petición de forzado** al FB: si ya está en marcha por ciclo, se aprovecha; si no, arranca por petición.
- El FB arbitra ciclo propio vs forzado y devuelve **confirmación de marcha/caudal** (necesaria para el enclavamiento de disipación, M02).

Esto desacopla filtrado y climatización: la depuración no depende del HVAC, y el HVAC solo le pide circulación cuando la necesita.

## Lógica estacional / disipación

- Primavera/otoño (extremos de temporada): el grueso del aporte lo pone la **BC** (el sol ya no basta). Por eso HX-POOL-BC se dimensiona por mantenimiento, no por calentón inicial.
- Verano: la BC no aporta (produce frío). Solo excedente solar. La piscina es el **1er escalón de disipación** (ver M02): si pool < `P62_PoolMaxTemp`, traga excedente; si lo alcanza → persianas.
- **Enclavamiento:** disipación a piscina ⇒ depuradora en marcha confirmada (ver M02).

## Pendientes

- Potencia pico del campo solar (Pxx, pdte. caudal captadores M02) → cierra HX-POOL-SOL.
- `FB_PoolReversible`: selección de fuente (SOL/BC) + P-POOL + límite `P62`.
- `FB_PoolFiltration`: ciclos propios + entrada de forzado + salida de confirmación de marcha.
