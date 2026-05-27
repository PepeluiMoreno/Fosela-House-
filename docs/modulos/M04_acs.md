# M04 — ACS instantánea (estación de agua fresca)

**Estado:** 🔶 diseño cerrado · nº de placas a despejar con U y área/placa del HX elegido.
**Toma de:** M01 (tándem) · **Control:** `FB_DHW_Station.st`.

## Propósito

Producción de ACS **al paso**, sin acumular agua potable, mediante intercambiador de placas alimentado por el agua técnica del tándem. La salida es ACS **precalentada** que entra a los termos de los apartamentos (M07).

## Decisiones clave

- **Estación de agua fresca con HX-ACS de placas AISI 316L**, ensamblada con componentes sueltos.
- Motivos: depósitos vitrificados no aptos para potable en abierto; sin legionela de acumulación; potencia de ACS sin cuello de botella.
- **P-ACS modulante en la impulsión** (el control por anticipación y PI lo requieren).
- **HX sobredimensionado** para conseguir un pinch pequeño (~5 °C) **a caudal pico** → permite tener el tándem más frío → **mejor COP de la BC y más aporte solar aprovechado**. El nº de placas es la variable de diseño.

## Objetivo de diseño y parametrización (nada hardcoded)

De los tres valores relacionados, solo **dos son independientes**; el tercero se calcula:

```
SP_ACS_salida        (lo eliges: confort. Objetivo 55 °C, agua precalentada a termos)
Pxx_pinch_HX_DHW     (característica del HX, objetivo ~5 °C)
→ consigna_tándem = SP_ACS_salida + Pxx_pinch_HX_DHW   (CALCULADA por el control ≈ 60 °C)
```

La temperatura del tándem **no es un parámetro libre**: la calcula el control a partir de la salida de ACS deseada y el pinch del HX. Cambiar el HX (otro pinch) o la consigna de ACS recalcula sola la del tándem.

## Diseño / conexiones

```
Red potable → [caudalímetro Hall] → [secundario HX-ACS] → [VMT1] → [corte térmico] → ACS (~55°C)
Tándem (tapa D2, ~60°C) → [P-ACS] → [primario HX-ACS] → retorno → fondo D1
```

- **VMT1** mezcladora termostática: seguro mecánico independiente.
- **Corte térmico** bimetálico NC, rearme manual, ~70 °C, de inmersión: corta P-ACS por **hardware** + avisa al M241 (ver M10).
- **Caudalímetro Hall** en el secundario: detecta apertura de grifo → anticipación.

## Cálculos (resumen, objetivo tándem 60 / ACS 55)

- Caso diseño 15 L/min, T_red 10 °C → 55 °C (ΔT 45) → **~47 kW**; pico 20 L/min → **~63 kW** (lo absorbe la inercia).
- **Nº de placas = variable de diseño** que se despeja para cumplir `Pxx_pinch_HX_DHW` (~5 °C) al **caudal pico** (20 L/min). Más placas → menor pinch viable → tándem más frío.
- Del fabricante solo se necesitan dos **parámetros constructivos (Pxx)**: coeficiente U y área por placa, para convertir el área necesaria en nº de placas exacto.

## Control (`FB_DHW_Station.st`)

- Estados `ST_DHW`: IDLE / ANTICIPATION / ACTIVE / COOLDOWN / PREHEATING / ALARM / INHIBITED.
- Lazo PI sobre temperatura de salida de placa; anticipación por caudalímetro; cooldown; vigilancia de reservorio.

## Pendientes

- Elegir HX → conocer U y área/placa (Pxx) → despejar nº de placas para pinch 5 °C a 20 L/min.
- Caudalímetro (hasta 20 L/min); factor K → `P36`.
- Definir `SP_ACS_salida` y `Pxx_pinch_HX_DHW` en GVL.
