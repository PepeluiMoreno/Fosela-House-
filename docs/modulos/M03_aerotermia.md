# M03 — Aerotermia (bomba de calor monobloc)

**Estado:** ⏳ potencia dimensionada (~12 kW) · pendiente de integración del modelo concreto (punto crítico).
**Alimenta:** M01 (carga D2, invierno) y M05 (buffer frío, verano).

## Propósito

Bomba de calor monobloc R290 con módulo hidráulico integrado. Único productor activo todo el año. Entrega agua técnica caliente (invierno) o fría (verano). Conexión solo hidráulica, sin frigoríficas al interior.

## Dimensionado de potencia

**Potencia objetivo: ~12 kW (rango 12-14 kW).**

Edificio: **220 m², una sola planta climatizada**, muros gruesos de piedra (alta inercia térmica), cubierta bien aislada y renovada, ventanas PVC con doble acristalamiento de calidad. Jerez de la Frontera (zona cálida, refrigeración dominante).

Estimación de cargas (ratios para esta calidad de envolvente):

| Demanda | Ratio | Total |
|---|---|---|
| **Refrigeración (dominante)** | ~50-60 W/m² | **~12 kW** |
| Calefacción | ~40-45 W/m² | ~9-10 kW |

- **Manda la refrigeración** (~12 kW): en Jerez el verano es más exigente que el invierno suave. La cubierta aislada y la inercia de la piedra contienen el pico; sin ellas sería mayor.
- **ACS NO suma a la punta:** la BC carga el **tándem (812 L)**, que amortigua. La BC repone energía al tándem **en diferido**, no cubre la punta instantánea de ACS de vivienda + 4 apartamentos. El tándem desacopla producción y demanda → no hay que sumar ACS a los 12 kW.
- **Piscina:** consumidor sacrificable, se atiende con excedente / horas de baja demanda. **No dimensiona la BC.**
- **NO sobredimensionar a 16 kW:** peor COP a carga parcial, más ciclado, más caro. **NO bajar de 12:** sin margen en el pico de agosto. El óptimo es 12-14 kW.

> **La inercia juega a favor:** muros de piedra + tándem 812 L + buffer 150 L dan mucha inercia térmica. La BC trabaja en **ciclos largos y estables** (mejor COP y vida del compresor) y permite cargar en **tarifa valle**. Una BC ajustada (12 kW) con esta inercia rinde mejor que una sobredimensionada.

> Cuando haya cálculo de cargas formal (transmitancias reales de los muros de piedra, superficie de huecos), reajustar. La estimación por ratios es conservadora y defendible para elegir el modelo.

## Decisiones clave

- **Reparto por V3V de modo** (la propia de la BC): invierno → tándem (D2); verano → buffer de clima frío. **Conmutación estacional**, no continua.
- **En invierno la BC no conmuta destino:** calienta siempre la misma agua técnica (el tándem). El reparto ACS/clima lo hacen aguas abajo P-ACS y P1 (ver M04/M05). El agua técnica de la BC **se funde con el volumen del tándem** → climatización de origen híbrido solar-aerotermia.
- **En verano** el circuito de la BC es independiente (agua fría, no toca el tándem).

## ⚠️ Punto crítico de integración

Las BC de climatización+ACS suelen venir esperando **gobernar su propia V3V de ACS** (traen contacto de relé) y/o una **sonda/orden de demanda de ACS** para entrar en modo ACS. Aquí:
- La orden de ACS **nunca le llega** (ACS al paso, sin sonda de ACS en la BC).
- Su contacto de V3V de ACS queda **huérfano**.

**A resolver con la ficha del modelo:**
1. Configurarla como **generador de agua técnica puro** a consigna fija del tándem / por sonda de tándem, ignorando su lógica de ACS (lo más limpio).
2. O **simular la demanda de ACS** (sonda en tándem / contacto del M241) si la exige.
3. Mapear su regletero: entradas de demanda (ACS/calef/frío), salida V3V externa, habilitación, señal verano/invierno → qué usa el M241, qué se ignora, qué se puentea.

## Pendientes

- **Seleccionar modelo concreto de ~12 kW** (monobloc R290) y leer su manual de esquemas hidráulicos.
- Verificar COP/SCOP y rango de modulación (que module bien a cargas parciales, dada la inercia).
- Verificar suficiencia de la circuladora interna (pérdida de carga serpentines en serie + distribución).
- Verificar vaso de expansión integrado: ¿cubre su circuito o hace falta externo? (el del tándem ya es propio, Ibaiondo 50 L, ver M08).
- Confirmar Modbus RTU para integración con el M241 (estado, consignas, alarmas → libera DI10).
- Cuando exista cálculo de cargas formal, reajustar la potencia.
