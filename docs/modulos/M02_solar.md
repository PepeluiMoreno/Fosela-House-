# M02 — Solar térmico

**Estado:** 🔶 diseño cerrado · falta caudal nominal de captadores.
**Sirve a:** M01 (carga D1) y M06 (excedente a piscina) · **Control:** `FB_Solar.st`.

## Propósito

Campo solar térmico que carga el depósito D1 y, en excedente, calienta la piscina. Circuito cerrado de glicol con bomba modulante.

## Decisiones clave

- **Campo:** 4 colectores planos, 8 m² totales. Solar Keymark.
- **Fluido:** propilenglicol 15 % (mínimas Jerez ~-2 °C). Llenado manual con refractómetro; **sin** llenado automático (diluiría el anticongelante).
- **P-SOL modulante** (PWM), en el retorno frío del serpentín de D1.
- **Arranque por muestreo a bajo caudal**, no por sonda de captador: evita el cable al tejado y reaprovecha bomba + sondas de lazo.
- **Antiestancamiento por persianas** motorizadas (cierre fail-safe), no por circulación nocturna.

## Diseño / conexiones

- Glicol caliente entra por serpentín superior de D1, sale por el inferior.
- **Grupo de seguridad** en el retorno frío junto a P-SOL: vaso de expansión (absorbe vapor de estancamiento), válvula de seguridad 6 bar, manómetro, llaves de llenado/vaciado.
- **Antirretorno antitermosifón** en el lazo.
- **Captadores en Tichelmann** (retorno invertido) para reparto equilibrado.
- **Sondas:** ida y retorno de glicol (NTC en vaina) → modulación PI por ΔT + calorimetría. (Sonda de captador descartada vía muestreo.)

## Control (`FB_Solar.st`)

- Estados `ST_Solar`: SLEEP / SAMPLING / RUNNING / DISSIPATING / OVERHEAT.
- Muestreo: P-SOL a `P13_SolarPumpMinSpeed` durante `P57_SolarSampleDuration` cada `P56_SolarSampleInterval`; si ΔT > `P11` → RUNNING.
- **Disipación encadenada** (ver M06): 1º desvío a piscina (V3V disipación → HX-POOL-SOL si pool < `P62`), 2º persianas.

### ⚠️ Enclavamiento disipación ⇒ depuradora

La disipación a piscina por HX-POOL-SOL **exige circulación en el secundario**, que la da la **depuradora** (M06). Antes de abrir la V3V de disipación a piscina, el control debe **arrancar la depuradora y confirmar marcha/caudal**; sin circulación confirmada no se vuelca calor al HX (no disiparía y podría sobrecalentar el intercambiador). El arranque se hace como **petición de forzado** al `FB_PoolFiltration` (M06), no gobernando la depuradora desde el solar.

## Pendientes

- Caudal nominal de captadores → diámetro del lazo (16-20 mm) y dimensionado del vaso.
- Confirmar pre-vaso según temperatura de estancamiento.
- Implementar el enclavamiento disipación⇒depuradora (DO mando + DI confirmación, ver M12).
