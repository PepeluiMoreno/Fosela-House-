# M07 — Distribución de ACS a apartamentos

**Estado:** ✅ definido.
**Toma de:** M04 (ACS precalentada).

## Propósito

Llevar ACS precalentada (~55 °C) de la estación a los 4 apartamentos turísticos, que **conservan sus termos eléctricos** existentes como respaldo.

## Decisiones clave

- El agua precalentada entra por la conexión de agua fría de cada termo, con el termostato del termo a 55-60 °C (la resistencia apenas arranca).
- **Una V3V por apartamento con retorno por muelle:** ante fallo de tensión conmuta a **agua de red** → el termo eléctrico sigue dando ACS con total independencia (fail-safe, ver M10).
- Señal de control 24 V en cable 2×1 mm², independiente de la fuerza.

## Reparto de la salida de ACS — colector de detentores

- La estación produce **una** salida de ACS que se reparte a los 4 apartamentos mediante un **colector de detentores** (latón roscado, encadenable).
- **Detentores al máximo (abiertos):** en ACS no se equilibra caudal (cada apartamento toma el que demande); el colector hace solo de **reparto**. Equilibrar estrangularía a un apartamento en favor de otro.
- El ACS no es circuito cerrado (agua de consumo); una pequeña descompensación no es crítica porque el **termo de cada apartamento remata** si llega algo justo.
- ⚠️ **Verificar latón apto para agua sanitaria** (los colectores de calefacción a veces no lo son).

## Interfaz

- Es la principal **Cadena de Seguridad de ACS** (M10): el respaldo del ACS no depende del PLC ni de la estación.
