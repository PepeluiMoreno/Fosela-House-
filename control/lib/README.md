# `lib/` — FBs genéricos reutilizables

Bibliotecas de FBs no específicos del proyecto, reutilizables en cualquier instalación. Sin dependencias del dominio (no saben qué es "solar" ni "ACS").

Contenido previsto:
- `FB_PI` — controlador PI con anti-windup.
- `FB_Pump` — bomba modulante con `PumpProfile` parametrizado (ver M09 §FB_Pump).
- `FB_Valve2Way`, `FB_Valve3Way` — válvulas todo/nada y desviadoras.
- `FB_Hysteresis` — comparador con histéresis.
- `FB_Alarm` — alarma con rearme y enclavamiento.
