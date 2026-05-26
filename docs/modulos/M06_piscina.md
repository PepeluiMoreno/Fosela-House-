# M06 — Climatización de piscina

**Estado:** 🔶 diseño cerrado · `FB_PoolReversible` pendiente.
**Toma de:** M01 (tándem, vía BC) y M02 (excedente solar) · **Control:** árbitro (M09) + disipación (M02).

## Propósito

Calentar la piscina (8×4 m, ~40 m³) en primavera/otoño y servir de **sumidero del excedente solar** en verano. Consumidor de menor prioridad.

## Decisiones clave

- **Dos intercambiadores tubulares de titanio**, uno por fuente:
  - **HX-POOL-SOL** ← excedente solar (camino directo glicol→piscina, esquiva el tándem).
  - **HX-POOL-BC** ← BC en modo calor.
- Titanio obligatorio (agua clorada; barrera categoría 5 EN 1717).
- Secundario de ambos: agua de piscina movida por la **depuradora existente** (sin circuladora propia).
- **P-POOL** en el retorno frío del primario.

## Lógica estacional / disipación

- Primavera/otoño: calentamiento por solar y/o BC.
- Verano: la BC no aporta (produce frío). Solo excedente solar. La piscina es el **1er escalón de disipación** (ver M02): si pool < `P62_PoolMaxTemp`, traga excedente; si lo alcanza, deja de ser sumidero → persianas.
- Autorregulación verano: sombra + depuradora nocturna; balance casi neutro.

## Pendientes

- Potencia de calentamiento → diámetros del primario y caudal de P-POOL.
- `FB_PoolReversible`: selección de fuente (SOL/BC) + P-POOL + límite `P62`.
