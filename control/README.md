# `control/` — Código ST del proyecto

Código del PLC en **Structured Text (IEC 61131-3)**, CODESYS 3.5 (Schneider Machine Expert para el M241; portable a CODESYS 2.3 / FREE Studio para la rama Eliwell con reintroducción manual de los POU).

## Fuente de verdad

**Los archivos `.st` de este árbol son la fuente de verdad.** El proyecto binario de Machine Expert (`.smbp` / `.project`) NO se versiona aquí — Git no lo diferencia útilmente y los merges son inviables.

## Flujo de trabajo (VS Code ↔ Machine Expert)

```
  Claude (edita .st en GitHub)
         │
         ▼  git pull
  VS Code (revisas/editas .st)
         │
         ▼  git commit / push
  GitHub (fuente de verdad)
         │
         ▼  copia-pega manual (o import PLCopen XML)
  Machine Expert (compilas, simulas, cargas al PLC)
         │
         ▼  si Machine Expert te obliga a ajustar algo (errores, warnings)
  vuelves al .st en VS Code y haces commit  ← disciplina importante
```

**Regla de oro:** si modificas código dentro de Machine Expert para probar algo, **vuelca el cambio al `.st` correspondiente** antes de seguir. Nunca dejes que las dos versiones diverjan.

## Importar al Machine Expert

**Opción A — copia-pega (rápido, ideal para iteración):**
1. Abres el `.st` en VS Code, seleccionas todo el contenido del POU, copias.
2. En Machine Expert, sobre el POU correspondiente, pegas en el editor ST. Si el POU no existe, lo creas vacío con el mismo nombre primero.

**Opción B — import PLCopen XML (para cambios masivos):**
1. En Machine Expert: `Project → Export → PLCopen XML`. Versiona el XML si quieres.
2. Edición externa en el repo / VS Code.
3. `Project → Import → PLCopen XML` de vuelta.

## Estructura

```
control/
├── types/         Definiciones de TYPE (PumpProfile, enums ST_*)
├── lib/           FBs genéricos reutilizables (PI, Pump, Valve, Hysteresis, Alarm)
├── fb/            FBs específicos del proyecto (Solar, DHW, Climate, Pool, Arbiter, Filtration)
├── globals/       GVLs (Parameters Pxx/SPxx/HYxx/OFxx, States, IO_Map)
└── pou/           Programa principal (PLC_PRG)
```

El orden de importación al Machine Expert es: `types/` → `globals/` → `lib/` → `fb/` → `pou/` (las dependencias van de arriba abajo).

## Convenciones

- Indentación: 4 espacios, sin tabs.
- Comentarios doc encima de cada POU: propósito, entradas, salidas, módulo del proyecto al que pertenece (M02, M04, etc.).
- Nomenclatura: ver `docs/nomenclatura.md` (SP / P / HY / OF / ST).
- Cada `.st` contiene un único POU (FB / FUN / PROGRAM) o un único TYPE/GVL. Excepción: `types/` puede agrupar varios TYPE relacionados en un mismo fichero.

## Estado

Estructura vacía, pendiente de rellenar a partir de la próxima sesión (ver `docs/PENDIENTES.md` §Próxima sesión).
