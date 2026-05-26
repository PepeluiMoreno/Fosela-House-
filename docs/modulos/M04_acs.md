# M04 — ACS instantánea (estación de agua fresca)

**Estado:** 🔶 cálculos hechos · falta selección de placa y caudalímetro.
**Toma de:** M01 (tándem) · **Control:** `FB_DHW_Station.st`.

## Propósito

Producción de ACS **al paso**, sin acumular agua potable, mediante intercambiador de placas alimentado por el agua técnica del tándem.

## Decisiones clave

- **Estación de agua fresca con HX-ACS de placas AISI 316L**, ensamblada con componentes sueltos (no prefabricada).
- Motivos: los depósitos vitrificados no son aptos para potable en abierto; se elimina la legionela de acumulación; potencia de ACS sin cuello de botella; reservorio a 70-80 °C sin restricción sanitaria.
- **P-ACS modulante en la impulsión** (perfil calefacción, no solar) — el control por anticipación y PI lo requieren.

## Diseño / conexiones

```
Red potable → [caudalímetro Hall] → [secundario HX-ACS] → [VMT1 55°C] → [corte térmico] → ACS
Tándem (tapa D2, ~65°C) → [P-ACS] → [primario HX-ACS] → retorno → fondo D1
```

- **VMT1** mezcladora termostática a 55 °C: seguro mecánico independiente.
- **Corte térmico** bimetálico NC, rearme manual, ~70 °C, de inmersión: corta P-ACS por **hardware** + avisa al M241 (ver M10).
- **Caudalímetro Hall** en el secundario: detecta apertura de grifo → anticipación.

## Cálculos (resumen)

- Caso diseño 15 L/min, T_red 10 °C, salida 60 °C → **52 kW**; pico 20 L/min → 70 kW (lo absorbe la inercia).
- HX por LMTD: A ≥ **1,0 m²** (margen sobre caso desfavorable reservorio a 65 °C + fouling agua dura).
- **T_res mínima 65 °C** para entregar 60 °C en placa; nominal 70 °C. (Detalle completo en memoria histórica §8.3.)

## Control (`FB_DHW_Station.st`)

- Estados `ST_DHW`: IDLE / ANTICIPATION / ACTIVE / COOLDOWN / PREHEATING / ALARM / INHIBITED.
- Lazo PI sobre temperatura de salida de placa; anticipación por caudalímetro; cooldown; vigilancia de reservorio.

## Pendientes

- Selección de placa (≥1 m², 40-50 kW) y caudalímetro (hasta 20 L/min); factor K → `P36`.
- Reclasificar consigna de placa como **SP** (no P).
