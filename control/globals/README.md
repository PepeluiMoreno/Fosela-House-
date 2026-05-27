# `globals/` — Variables y parámetros globales (GVL)

Contenido previsto:
- `Parameters.st` — todos los `Pxx` (constructivos), `SPxx` (setpoints), `HYxx` (histéresis), `OFxx` (offsets). Cada parámetro como registro `{default, min, max, unidad}`.
- `States.st` — instancias y referencias a enums `ST_*`.
- `IO_Map.st` — mapeo de variables del programa a los bornes físicos del M241 (coherente con M12). Aislar el cableado físico del resto del código.
