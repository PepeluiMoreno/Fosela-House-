# M07 — Distribución de ACS a apartamentos

**Estado:** ✅ definido.
**Toma de:** M04 (ACS precalentada).

## Propósito

Llevar ACS precalentada de la estación a los 4 apartamentos turísticos, que **conservan sus termos eléctricos** existentes como respaldo.

## Decisiones clave

- El agua precalentada entra por la conexión de agua fría de cada termo, con el termostato del termo a 55-60 °C (la resistencia apenas arranca).
- **Una V3V por apartamento con retorno por muelle:** ante fallo de tensión conmuta a **agua de red** → el termo eléctrico sigue dando ACS con total independencia (fail-safe, ver M10).
- Señal de control 24 V en cable 2×1 mm², independiente de la fuerza.

## Interfaz

- Es la principal **Cadena de Seguridad de ACS** (M10): el respaldo del ACS no depende del PLC ni de la estación.
