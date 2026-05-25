# Fosela House — Instalación térmica integrada

Repositorio técnico del proyecto de instalación térmica integrada para vivienda principal con 4 apartamentos turísticos y piscina privativa en Jerez de la Frontera.

## Descripción del sistema

- **Solar térmico**: 8 m² (4 colectores planos, Solar Keymark), propilenglicol 15%
- **Aerotermia**: BC monobloc R290, módulo hidráulico integrado en unidad exterior
- **ACS**: producida por inversión de ciclo (BC en modo ACS) o calefacción → reservorio de 800 L agua técnica
- **Reservorio energía**: 2 × Tusol DB2 450 vitrificado (~800 L agua técnica, serpentines en serie)
- **Climatización**: 13 fancoils con PICV 0-10V, buffer D3 150 L
- **Piscina**: ~25 m³, 2 intercambiadores titanio (HX solar + HX aerotérmico)
- **ACS apartamentos**: agua precalentada del reservorio → V3V por apartamento → termo eléctrico existente
- **Control**: Schneider Modicon TM241CE24R + módulos TM3 (EcoStruxure Machine Expert / CoDeSys 3)

## Ramas

| Rama | Descripción |
|---|---|
| `main` | Arquitectura vigente — BC monobloc genérica, sin HTR |
| `arquitectura/ecoforest-htr` | Archivo histórico — Ecoforest ecoAIR+ 6-24 PRO con HTR |
| `version-economica` | Variante de menor coste |

## Estructura del repositorio

```
Fosela-House/
├── docs/
│   ├── BOM.md                           ← Lista de materiales
│   ├── Parameters.md                    ← Tabla de parámetros PLC
│   ├── Equipment_Limits.md              ← Límites de equipo y dependencias
│   └── memoria/
│       ├── memoria_instalacion_termica_jerez.md
│       └── memoria_instalacion_termica_jerez.docx
├── diagramas/
│   └── esquema_hx_piscina.svg
├── control/
│   ├── lib/                             ← Tipos, bloques genéricos reutilizables
│   ├── free_smart/                      ← Código FREE Smart (subsistema solar)
│   └── free_evolution/                  ← Código FREE Evolution (sistema principal)
├── bitacora/
└── docs/
    └── anexo_compras.md          ← Precios reales y fuentes de aprovisionamiento
    └── bitacora_proyecto_fosela.md      ← Registro cronológico de decisiones
```

## Estado del proyecto

| Documento / Código | Estado |
|---|---|
| Memoria técnica | 🔄 En revisión (actualizar a monobloc) |
| BOM | 🔄 En revisión |
| Código Schneider M241 | 🔲 Pendiente migración desde FREE Studio |
| Código FREE Evolution | 🔄 Pendiente adaptar a EcoStruxure Machine Expert |
| Tabla de parámetros | 🔄 En revisión (eliminar P02, P34, P35) |
| P&ID completo | 🔲 Pendiente |
| Bitácora decisiones | ✅ Completa |

## Puntos abiertos

1. **Circuladora BC**: verificar si la integrada vence ~150 mbar (dos serpentines en serie + distribución)
2. **Equilibrado dinámico fancoils**: decidir entre PICV 0-10V / válvulas ΔP / PICV integrada / bomba ΔP cte
3. **Estación ACS**: dimensionar placa AISI 316L (40-50 kW) + circuladora PWM1 + caudalímetro hasta 20 L/min

## Normativa de referencia

RITE · CTE HE-4 · CTE HS-4 · RD 865/2003 · EN 1717 · EN 378-3 · IEC 61131-3

---

*Proyecto Fosela House · Jerez de la Frontera · zona climática B4 · zona solar V*
