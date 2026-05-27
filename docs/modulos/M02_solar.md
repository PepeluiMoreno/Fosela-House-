# M02 — Solar térmico

**Estado:** 🔶 diseño cerrado · falta caudal nominal de captadores.
**Sirve a:** M01 (carga D1) y M06 (excedente a piscina) · **Control:** `FB_Solar.st`.

## Propósito

Campo solar térmico que carga el depósito D1 y, en excedente, calienta la piscina. Circuito cerrado de glicol con bomba modulante.

## Decisiones clave

- **Campo:** 4 colectores planos, 8 m² totales. Solar Keymark.
- **Fluido:** propilenglicol 15 % (mínimas Jerez ~-2 °C). Llenado manual con refractómetro; **sin** llenado automático (diluiría el anticongelante).
- **P-SOL modulante** (PWM perfil solar), en el retorno frío del serpentín de D1.
- **Arranque por muestreo a bajo caudal**, no por sonda de captador: evita el cable al tejado y reaprovecha bomba + sondas de lazo.
- **Antiestancamiento por persianas** motorizadas (cierre fail-safe), no por circulación nocturna.

## P-SOL — selección de bomba

Las dos alternativas son **funcionalmente equivalentes** desde el PLC (mismo perfil PWM solar, lógica invertida); cambian la marca y el nivel de tensión PWM que exigen al divisor.

| Alternativa | Modelo | Altura | PWM | Tensión PWM | Notas |
|---|---|---|---|---|---|
| **Grundfos** | **Alpha Solar 25-75 130** | 7,5 m (4 curvas: 4,5/5,5/6,5/7,5) | **Perfil C (solar)** | Low-voltage (no especificado en datasheet, **probablemente 5V** — verificar con multímetro al recibir) | Apta agua/glicol hasta 50 %. T líquido hasta 110 °C (con T amb 70 °C). G 1½". 4 modos constantes + PWM. Conector potencia **Superseal**, señal **Mini Superseal 3 vías** (input/output/reference, cable máx. 3 m, accesorio Grundfos de 1 m disponible). Pinout y nivel exacto NO publicados — Grundfos los facilita bajo petición |
| **Wilo** | **iPWM3** (variante solar de la familia Para/Yonos) | según modelo | **PWM señal 2 (solar)** — equivalente al perfil C Grundfos | ~9,6V | Lógica invertida también (failsafe ante cable roto). Apta glicol/alta temperatura. La que estaba prevista originalmente con divisor 24V→9,6V |

**Sobre el perfil PWM:** ambos fabricantes usan PWM con **lógica invertida en variante solar** (0% → velocidad máxima, 100% → parada). Esto es **failsafe**: si se rompe el cable de señal, la bomba va a tope y disipa el calor al circuito, en vez de pararse y dejar el captador estancando. Grundfos lo llama "perfil C" y Wilo "señal PWM 2 (solar)", pero el comportamiento es el mismo.

**Divisor de tensión:** la CPU TM241CE24T saca PWM a 24V. Para Grundfos hay que ajustar a ~5V (a confirmar); para Wilo a 9,6V. **Solo el divisor cambia** — el código ST en el PLC es idéntico.

## Diseño / conexiones

- Glicol caliente entra por serpentín superior de D1, sale por el inferior.
- **Grupo de seguridad** en el retorno frío junto a P-SOL: vaso de expansión (absorbe vapor de estancamiento), válvula de seguridad 6 bar, manómetro, llaves de llenado/vaciado.
- **Antirretorno antitermosifón** en el lazo.
- **Captadores en Tichelmann** (retorno invertido) para reparto equilibrado.
- **Sondas:** ida y retorno de glicol (PT1000 en vaina, rama Schneider) → modulación PI por ΔT + calorimetría. (Sonda de captador descartada vía muestreo.)

## Control (`FB_Solar.st`)

- Estados `ST_Solar`: SLEEP / SAMPLING / RUNNING / DISSIPATING / OVERHEAT.
- Muestreo: P-SOL a `P13_SolarPumpMinSpeed` durante `P57_SolarSampleDuration` cada `P56_SolarSampleInterval`; si ΔT > `P11` → RUNNING.
- **Disipación encadenada** (ver M06): 1º desvío a piscina (V3V disipación → HX-POOL-SOL si pool < `P62`), 2º persianas.
- **Atención a la lógica invertida PWM:** la consigna de velocidad en el código ST se transforma a duty cycle invertido al escribirla en la salida (100% velocidad ↔ 0% PWM y viceversa). Encapsular en una función `PWMSolarInvert()` para que el resto del FB trabaje con velocidad "natural" (0-100%).

### ⚠️ Enclavamiento disipación ⇒ depuradora

La disipación a piscina por HX-POOL-SOL **exige circulación en el secundario**, que la da la **depuradora** (M06). Antes de abrir la V3V de disipación a piscina, el control debe **arrancar la depuradora y confirmar marcha/caudal**; sin circulación confirmada no se vuelca calor al HX (no disiparía y podría sobrecalentar el intercambiador). El arranque se hace como **petición de forzado** al `FB_PoolFiltration` (M06), no gobernando la depuradora desde el solar.

## Pendientes

- Caudal nominal de captadores → diámetro del lazo (16-20 mm) y dimensionado del vaso.
- Confirmar pre-vaso según temperatura de estancamiento.
- Implementar el enclavamiento disipación⇒depuradora (DO mando + DI confirmación, ver M12).
- **Elegir P-SOL** entre Grundfos Alpha Solar 25-75 130 (95 € hallazgo Wallapop) o Wilo iPWM3 solar.
- Verificar nivel de tensión PWM del modelo elegido y ajustar el divisor (~5V Grundfos / ~9,6V Wilo).
- Conseguir cable de potencia Superseal y cable de señal Mini Superseal (si Grundfos sin cables).
