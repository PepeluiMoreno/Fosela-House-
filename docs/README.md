# Casa Fosela — Proyecto técnico

Instalación térmica integrada (aerotermia monobloc R290 + solar térmico) para vivienda de 220 m² + 4 apartamentos turísticos + piscina, en Jerez de la Frontera. Control con un único PLC programable; **dos opciones de autómata mantenidas en paralelo: Eliwell FREE Evolution/Smart y Schneider Modicon M241** (ver M12).

> **Enfoque modular:** cada funcionalidad de la instalación se trata como un **subproyecto autocontenido**. Este índice es el mapa; cada módulo vive en `docs/modulos/Mnn_*.md` con su propósito, decisiones, diseño, montaje, control y pendientes.

## Arquitectura en una imagen

Dos productores (solar + BC) cargan un **reservorio de agua técnica** (tándem D1+D2, ~812 L). Del reservorio se sirve todo: ACS al paso, climatización y piscina. El agua potable nunca se almacena.

```
SOLAR (glicol 15%) ──serpentín──> D1 (frío) ──serie──> D2 (caliente) <──serpentín── BC monobloc R290
                                      │ tándem agua técnica (~812 L)
        ┌─────────────────────────────┼─────────────────────────────┐
        ▼                             ▼                             ▼
   ACS al paso                  Climatización                    Piscina
  (HX-ACS placas)          (buffer 150 L + fancoils)        (HX titanio x2)
```

## Mapa de módulos

| Módulo | Subproyecto | Estado |
|---|---|---|
| [M01](modulos/M01_reservorio.md) | Reservorio de agua técnica (tándem D1+D2) | 🔶 diseño cerrado, falta plano DB2 |
| [M02](modulos/M02_solar.md) | Solar térmico | 🔶 diseño cerrado, falta caudal captadores |
| [M03](modulos/M03_aerotermia.md) | Aerotermia — BC monobloc | ⏳ pendiente integración del modelo concreto |
| [M04](modulos/M04_acs.md) | ACS instantánea (estación agua fresca) | 🔶 cálculos hechos, falta selección placa |
| [M05](modulos/M05_climatizacion.md) | Climatización reversible (origen híbrido) | 🔶 topología cerrada, falta FB |
| [M06](modulos/M06_piscina.md) | Climatización de piscina | 🔶 diseño cerrado, falta FB |
| [M07](modulos/M07_acs_apartamentos.md) | Distribución ACS a apartamentos | ✅ definido |
| [M08](modulos/M08_sala_maquinas.md) | Sala de máquinas (hidráulica común) | 🔶 colector/bombas/vasos definidos |
| [M09](modulos/M09_control.md) | Control — lógica y FBs | 🔶 FBs base, falta integración |
| [M10](modulos/M10_cadenas_seguridad.md) | Cadenas de Seguridad (operación sin PLC) | ⏳ principio fijado, falta esquema eléctrico |
| [M11](modulos/M11_supervision.md) | Supervisión remota | ⏳ fase posterior |
| [M12](modulos/M12_mapa_es.md) | Mapa de E/S y configuraciones de autómata | 🔶 censo cerrado, falta catálogo Eliwell |

Leyenda: ✅ definido · 🔶 parcial · ⏳ pendiente

## Dos autómatas, un mismo diseño

El proyecto mantiene **dos opciones de controlador** (ver M12): **Eliwell FREE Evolution** (con módulo Ethernet) o **FREE Smart**, y **Schneider Modicon M241**. El diseño hidráulico, la lógica de control y las Cadenas de Seguridad son idénticos; solo cambia el mapeo de E/S a bornes. El código ST es portable a nivel conceptual (ambos IEC 61131-3), reintroduciéndolo en el IDE de cada plataforma.

## Documentos transversales

- [`nomenclatura.md`](nomenclatura.md) — convención de equipos y taxonomía de constantes (SP/P/HY/OF/ST).
- [`PENDIENTES.md`](PENDIENTES.md) — lista viva de tareas por módulo.
- [`manual_montaje.md`](manual_montaje.md) — secuencia ejecutable para el instalador.
- `memoria/memoria_instalacion_termica_jerez.md` — **memoria histórica monolítica**. En proceso de modularización; ante discrepancia, **prevalecen los módulos** de `docs/modulos/`.

## Principios rectores del proyecto

1. **Nada hardcoded:** todo umbral/consigna/característica va a parámetro nombrado (ver taxonomía SP/P/HY/OF/ST).
2. **El PLC optimiza; las Cadenas de Seguridad garantizan** (M10): la instalación sigue dando ACS, agua técnica y seguridad con el PLC averiado.
3. **El agua potable nunca se almacena:** ACS siempre al paso (M04).
4. **Estratificación del reservorio** como activo a preservar (M01).
5. **Autómata intercambiable** (M12): Eliwell o Modicon, mismo diseño, distinto mapeo de E/S.
