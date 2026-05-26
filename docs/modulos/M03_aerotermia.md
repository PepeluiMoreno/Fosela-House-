# M03 — Aerotermia (bomba de calor monobloc)

**Estado:** ⏳ pendiente de integración del modelo concreto (punto crítico).
**Alimenta:** M01 (carga D2, invierno) y M05 (buffer frío, verano).

## Propósito

Bomba de calor monobloc R290 con módulo hidráulico integrado. Único productor activo todo el año. Entrega agua técnica caliente (invierno) o fría (verano). Conexión solo hidráulica, sin frigoríficas al interior.

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

- Verificar suficiencia de la circuladora interna (pérdida de carga serpentines en serie + distribución).
- Verificar vaso de expansión integrado: ¿cubre los ~812 L del tándem en invierno o hace falta externo? (ver M08).
- Selección del modelo concreto y lectura de su manual de esquemas hidráulicos.
