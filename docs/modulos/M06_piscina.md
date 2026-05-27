# M06 — Climatización de piscina

**Estado:** 🔶 diseño cerrado · equipo de depuración especificado · `FB_PoolReversible` y `FB_PoolFiltration` pendientes.
**Toma de:** M01 (tándem, vía BC) y M02 (excedente solar) · **Control:** árbitro (M09) + disipación (M02).

## Propósito

Climatizar la piscina (~25 m³) con el objetivo de **extender la temporada de baño de abril a octubre**, y servir de **sumidero del excedente solar** en verano. Consumidor de menor prioridad.

## Decisiones clave

- **Dos intercambiadores tubulares de titanio**, uno por fuente:
  - **HX-POOL-SOL** ← excedente solar (camino directo glicol→piscina, esquiva el tándem).
  - **HX-POOL-BC** ← BC en modo calor.
- Titanio obligatorio (agua clorada; barrera categoría 5 EN 1717).
- Secundario de ambos: agua de piscina movida por la **bomba de filtración** (la del equipo de depuración, sin circuladora propia).
- **P-POOL** en el retorno frío del primario.
- **Manta térmica / cubierta:** parte del diseño, no accesorio. Sin ella el objetivo abril-octubre no es realista con aerotermia a coste razonable (la evaporación nocturna dispara las pérdidas).

## Potencias de los intercambiadores

| HX | Dimensionado por | Potencia |
|---|---|---|
| **HX-POOL-BC** | Mantenimiento de temporada (cubrir pérdidas abril/oct con manta) | **~8-10 kW** |
| **HX-POOL-SOL** | Capacidad de disipar el excedente solar pico (1er escalón de disipación) | ≥ potencia pico del campo (Pxx constructivo, pdte. caudal captadores M02). Sobredimensionar por el bajo ΔT en disipación |

- Caudal del primario de piscina: con ~10 kW y **ΔT alto (8-10 °C)** → ~860-1.075 L/h → entra holgado por una salida de **3/4"** del colector (M08). No necesita el extremo de 1".

## Equipo de depuración — especificado

**DepuraPool INDOOR (depuradora de interior), configuración:**
- **Filtro 600** + **válvula selectora Star** (6 vías, **manual**) + **bomba de filtración 0,75 kW** + **bypass** (de serie, para intercalar equipos como la bomba de calor).
- **Sin cuadro eléctrico** (opción elegida): el mando lo pone el PLC del proyecto, no el cuadro del fabricante. Coherente con la filosofía de control único + resiliencia (bomba = motor asíncrono sin electrónica).
- Precio de referencia: **~1.180 € IVA incl.** (filtro 600, bomba 0,75 kW, sin cuadro).
- Equipo de interior → va en la sala técnica.

Razones de la elección:
- **Sin cuadro** = sin electrónica del fabricante que estorbe; la gobierna el PLC vía contactor (M13), confirmación por presostato/caudalímetro (DI11, M12).
- Bomba **0,75 kW** suficiente para 25 m³ (la de 1 kW iría sobrada y consume más).
- **Bypass de serie**, con opción de bypass específico para bomba de calor (el fabricante lo ofrece): encaja con los dos HX-POOL.

Pendiente de confirmar con el fabricante (su teleasistencia, gratis 1 año):
- Que el **bypass admita intercalar los DOS HX de titanio** (HX-POOL-SOL y HX-POOL-BC) en el circuito de filtración.
- Caudal nominal de la bomba 0,75 kW → verificar que el secundario de los HX trabaja bien con él.

> Nota: la **válvula selectora es manual** — el PLC arranca/para la bomba, pero el contralavado del filtro (cambio de modo de la selectora) se hace a mano. Automatizarlo exigiría selectora motorizada (introduce electrónica; no se hace).

## Colector de PVC de los HX de piscina (secundario)

Los dos HX de titanio se montan en un **colector de PVC de presión**, encolado, con **racorería desmontable** (tuercas de enlace) y **llaves de corte**:

- **Entre ellos: en paralelo.** Cada HX cuelga del colector en su propia rama, con **llave de corte + tuercas de enlace** (3 piezas/uniones desmontables para poder desmontar cada HX sin cortar tubería). Mismo agua de entrada para ambos.
- **El conjunto: en serie con la filtración.** Ese bloque en paralelo se **intercala en serie en el retorno de la depuradora a la piscina**, a través del **bypass** del equipo (tras filtro y selectora). Todo el caudal de retorno atraviesa el bloque de HX.
- **Llaves de corte por rama:** permiten aislar el HX que no trabaja (los dos son estacionalmente casi excluyentes: BC en primavera/otoño, SOL en verano) y desmontar para mantenimiento sin vaciar el circuito.
- **El propio bypass** del equipo permite además derivar todo el caudal directo a piscina (sin pasar por los HX) para filtrado sin climatización.

Material y montaje: **PVC de presión** (encolado), apto para agua clorada del secundario; uniones a los HX de titanio con **tuercas de enlace / racor desmontable** (no encolado fijo contra el HX, para poder retirarlo). Llaves de bola de PVC.

> Geometría: **paralelo entre los dos HX**, ese paralelo **en serie** dentro del circuito de filtración (vía bypass). No es serie entre los HX.

## Depuradora — `FB_PoolFiltration` (desvinculado del HVAC)

La depuradora la **gobierna el PLC** (bomba 0,75 kW → **contactor**, ver M13), pero su lógica de filtrado es **independiente de la climatización**:

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
- Confirmar con DepuraPool: bypass para los dos HX y caudal de la bomba 0,75 kW.
- Diámetro del colector de PVC y de las ramas (según caudal de la bomba de filtración).
- `FB_PoolReversible`: selección de fuente (SOL/BC) + P-POOL + límite `P62`.
- `FB_PoolFiltration`: ciclos propios + entrada de forzado + salida de confirmación de marcha.
