# ANEXO DE COMPRAS — Fosela House
## Registro de aprovisionamiento real · precios negociados

> Este documento recoge las compras realizadas o en curso, con precios reales negociados,
> fuentes y estado de cada partida. Es el complemento con precios del BOM técnico (`docs/BOM.md`).

---

## ESTADO RESUMEN

| Kit | Estado | Coste real |
|---|---|---|
| K07 Control — CPU + módulos TM3 | ✅ Negociado | 250 € |
| K07 HMI | ✅ Cerrado | 0 € (tablet + web server M241) |
| Resto kits K01–K06, K08–K13 | 🔲 Pendiente | — |

---

## K07 · Control y automatización — COMPRADO

### Lote Manresa · Wallapop · 250 € (2 lotes negociados juntos)

Vendedor particular, Manresa (Barcelona). Precio negociado desde 2 × 140 € = 280 € hasta 250 € ambos lotes.

**Lote 1** (wallapop.com/item/plc-schneider-1112668075):
- 1x TM241CE24R — CPU M241, 14DI + 10DO relé, Ethernet, 2xRS485
- 1x TM3TI8T — 8 AI temperatura NTC/PTC/termopar
- 1x TM3DQ16R — 16 DO relé 250VAC
- 1x TM3AI4 — 4 AI 0-10V / 4-20mA

**Lote 2** (wallapop.com/item/lote-modulos-plc-schneider-1266057067):
- 1x TM3TI8T — 8 AI temperatura NTC/PTC/termopar (segundo módulo)
- 1x TM3DO16R — 16 DO relé adicional
- 1x TM3AI4 — 4 AI adicional

**Resultado hardware de control:**
- 1x TM241CE24R (CPU) con CoDeSys 3 (EcoStruxure Machine Expert)
- 2x TM3TI8T = 16 canales NTC para 13 sondas + 3 spare
- 2x módulos DO relé (32 salidas relay en total, 10 planificadas + 22 disponibles para mejoras)
- 2x módulos AI analógico (8 canales para transductores presión, piranómetro, señal BC)

### Plaquita divisor PWM · ~2 €

4x resistencias (2x 1k5 ¼W + 2x 1k0 ¼W), perfboard FR4 50x30mm, clip carril DIN.
Reduce señal PWM 24VDC del M241 a ~9,6VDC para entrada iPWM3 de las bombas Wilo.
Ver esquema en docs/plaquita_divisor_pwm.svg

### HMI · 0 €

Web server integrado en TM241CE24R + tablet existente.

---

## K03 · Instrumentación — PENDIENTE

Sondas NTC 10K: los módulos TM3TI8T aceptan NTC 10K directamente.
Referencia: iOVEO 035HP05202 o equivalente. 13 unidades en pozos inmersión inox DN8 G1/2.

---

## PRECIOS ORIENTATIVOS KITS PENDIENTES

| Kit | Descripción | Estimación |
|---|---|---|
| K01 | 2 HX titanio + válvulas + colectores piscina | ~1.700 € |
| K02 | Persianas + cadena seguridad | ~285 € |
| K03 | 13 sondas NTC + pozos inox | ~320 € |
| K04 | 2x Tusol DB2 450 (adquiridos) | 2.000 € |
| K04b | Placa AISI 316L + circuladora + caudalímetro | ~700 € |
| K05 | Circuito solar primario + glicol 15% | ~700 € |
| K06 | Buffer D3 + circuladora fancoils | ~660 € |
| K07 | Control completo (negociado) | 252 € |
| K08 | V3V apartamentos + cableado | ~235 € |
| K09 | Depuración piscina (parcial existente) | ~1.260 € |
| K10 | 4 colectores solares 2m2 + estructura | ~1.500 € |
| K11 | 13 fancoils + PICV 0-10V | ~9.500 € |
| K12 | BC monobloc R290 ~14kW | ~5.000 € |
| K13 | Tubería multicapa + aislamiento | ~985 € |
| **TOTAL estimado** | | **~25.100 €** |

Precios IVA incluido salvo indicación. No incluye mano de obra ni obra civil.

---

## HISTORIAL DE NEGOCIACIONES

| Fecha | Vendedor | Artículo | Precio inicial | Precio final | Estado |
|---|---|---|---|---|---|
| 25 may 2026 | Wallapop Manresa | Lote 1 TM241+módulos | 180 € | 140 € | Comprado |
| 25 may 2026 | Wallapop Manresa | Lote 2 módulos TM3 | 140 € | 110 € | Comprado |
| 25 may 2026 | Wallapop Manresa | Ambos lotes negociados | 280 € | 250 € | Comprado |
| 25 may 2026 | eBay sps-4-you | TM3AQ2 | 99 € | — | Descartado |
| 25 may 2026 | eBay gianeri_0 | TM3TI4 x2 | 112 € | — | Descartado |
