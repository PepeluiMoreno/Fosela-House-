# M01 — Reservorio de agua técnica (tándem D1+D2)

**Estado:** 🔶 diseño cerrado · falta plano dimensional del DB2 450 para asignar bocas.
**Depende de:** — · **Alimentado por:** M02 (solar), M03 (BC) · **Sirve a:** M04 (ACS), M05 (clima invierno), M06 (piscina).

## Propósito

Reservorio único de **agua técnica** (~812 L) en circuito cerrado, formado por dos acumuladores Tusol DB2 450 (acero vitrificado, doble serpentín) **en serie**, que desacopla producción y consumo y da inercia al sistema. No almacena agua potable.

## Decisiones clave

- **D1 = solar (frío), D2 = aerotérmico (caliente).** El tándem se comporta como un único depósito estratificado.
- **Flujo en columna:** retorno frío → fondo de D1 → (precalienta solar) → tapa D1 → fondo D2 → (remata BC) → tapa D2 → consumos.
- **Serpentines en serie** en cada depósito (~3,2 m² por depósito); productor entra por el superior, sale por el inferior (contracorriente).
- **Agua técnica, no potable:** elimina el riesgo de legionela en la acumulación y respeta el uso del acero vitrificado.

## Diseño / conexiones

- **Enlace serie entre depósitos:** tapa de D1 → fondo de D2.
- **Retención antitermosifón** en ese enlace (tapa D1 → fondo D2), orientada a dejar pasar solo D1→D2; impide que D2 caliente retroceda a D1 por convección y deshaga la estratificación.
- **Extracción por prioridad de grado** (criterio de altura): a mayor grado/prioridad, más alta la toma. ACS lo más alto (tapa D2); piscina por debajo; clima en invierno también desde zona alta (ver M05). Retornos al fondo de D1.
- **Bocas (criterio):** ánodo (alta) y resistencia (lateral) para extracción; AFS (fondo)/ACS (tapa) para el enlace serie. Asignación física definitiva pendiente del plano DB2 450.

## Seguridad (ver M10)

- Termostatos Z1 (D1) y Z2 (D2), ~90 °C, NC, rearme manual, hardware independiente.
- Vaso de expansión y válvula de seguridad del agua técnica (ver M08).

## Pendientes

- Plano dimensional DB2 450 → asignar cada boca a su función.
- Confirmar dimensión del vaso del agua técnica (¿basta el integrado de la BC para los ~812 L? ver M03/M08).
