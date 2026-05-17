# Fosela House — Instalación térmica integrada

Repositorio técnico del proyecto de instalación térmica integrada para vivienda principal con 3 apartamentos turísticos y piscina privativa en Jerez de la Frontera.

## Descripción del sistema

- **Solar térmico**: 12 m² (6 colectores planos, Solar Keymark)
- **Aerotermia**: Ecoforest ecoAIR+ 6-24 PRO (R290, modulante 6-24 kW, con HTR)
- **Acumulación ACS**: 2 × Tusol DB2 450 (812 L total vitrificado)
- **Climatización**: 13 fancoils, buffer D3 150 L
- **Piscina**: 36 m³, 3 intercambiadores titanio (HX1 5 kW, HX_BDC 12 kW, HX_HTR 3 kW)
- **ACS apartamentos**: cascada D1→D2→VMT1→CE-01…05, con V3V_APT motorizadas
- **Control**: FREE Smart SMD4500C (solar) + FREE Evolution (sistema principal), RS485 Modbus RTU

## Estructura del repositorio

```
Fusela-House/
├── docs/
│   └── memoria/
│       ├── memoria_instalacion_termica_jerez.md   ← Fuente Markdown
│       └── memoria_instalacion_termica_jerez.docx ← Documento Word maquetado
├── diagramas/
│   └── esquema_hx_piscina.svg   ← Esquema HX piscina (vectorial)
├── control/
│   ├── free_smart/              ← Código FREE Smart (subsistema solar)
│   └── free_evolution/          ← Código FREE Evolution (sistema principal)
└── listas/                      ← Lista de materiales y equipos
```

## Estado del proyecto

| Documento | Estado |
|---|---|
| Memoria técnica | ✅ Redactada |
| Esquema HX piscina | ✅ Generado |
| Código FREE Smart | 🔲 Pendiente |
| Código FREE Evolution | 🔲 Pendiente |
| P&ID completo | 🔲 Pendiente |
| Lista de materiales | 🔲 Pendiente |

## Normativa de referencia

RITE · CTE HE-4 · CTE HS-4 · RD 865/2003 · EN 1717 · EN 378 · IEC 61131-3

---

*Proyecto Fosela House · Jerez de la Frontera · zona climática B4 · zona solar V*
