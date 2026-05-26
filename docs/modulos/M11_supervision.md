# M11 — Supervisión remota

**Estado:** ⏳ fase posterior (tras control + cadenas de seguridad).

## Propósito

Ver y vigilar la instalación desde cualquier lugar (4 apartamentos turísticos), sin exponer el PLC.

## Arquitectura

- **HMI local:** servidor web embebido en el M241 (Ethernet). Solo red local. **No abrir puertos del router hacia el PLC.**
- **Remota:** el M241 actúa como **cliente que publica** (MQTT o HTTP POST) hacia un **servidor externo** (VPS o servicio gestionado) — solo conexiones salientes. El servidor almacena histórico y sirve la web con autenticación. Avisos al móvil ante alarmas.

## Principio

- **Capa de supervisión, NO de control.** Si internet o el servidor caen, el M241 sigue controlando y las Cadenas de Seguridad (M10) siguen protegiendo.
- **Comandos de vuelta** (si se implementan) limitados a **SP de confort**; nunca Cadenas de Seguridad ni parámetros críticos.

## Valor

- Histórico: rendimiento solar real, consumo ACS por apartamento, detección de averías.
- Avisos: alarma, corte térmico, sobretemperatura.

## Pendientes

- Decidir plataforma: IoT gestionada vs propia (VPS + broker MQTT + frontend).
- Definir el set de variables publicadas y la política de comandos de vuelta.
