# BITÁCORA — PROYECTO CASA FOSELA
## Registro cronológico de decisiones técnicas

**Proyecto:** Sistema integrado de climatización hidrónica, ACS instantánea y climatización de piscina
**Emplazamiento:** Jerez de la Frontera (Cádiz) — Zona climática B4
**Registro elaborado:** 25 de mayo de 2026

---

## FASE 1 — Concepción y primeros datos de partida
### Chat: *"Memoria Proyecto Fosela"* (bloque inicial) · ca. 15 mayo 2026

El proyecto arranca cuando el cliente expone el alcance completo de la instalación a dimensionar:

> **Requisitos iniciales planteados:** climatizar una vivienda de 220 m² con 13 fancoils; producir ACS para la vivienda principal y cuatro apartamentos de 1 dormitorio; usar la piscina como disipador de calor en verano aprovechando el excedente solar térmico; climatizar la piscina (8×4 m, ~40-48 m³); los apartamentos ya disponen de aire acondicionado, solo necesitan ACS.

Se establecen los primeros datos de partida:

| Parámetro | Valor |
|---|---|
| Ubicación inicial | Benalup-Casas Viejas (Cádiz) — refinado luego a Jerez de la Frontera |
| Ocupación | 12-16 personas (vivienda + 4 apartamentos) |
| Demanda ACS | 336 L/día a 60 °C (17,6 kWh/día), CTE HE4 |
| Pico refrigeración | 17,6 kW (80 W/m²) |
| Pico calefacción | 12,1 kW (55 W/m²) |
| Piscina | 8×4 m, ~40-48 m³ |

**Conclusión de la sesión:** la arquitectura inicial propone una bomba de calor Ecoforest ecoAIR+ con HTR (desuperheater), solar térmico de 6 colectores planos (12 m²), dos acumuladores en cascada y buffer de inercia para los fancoils.

---

## FASE 2 — Análisis crítico: se detectan fallos graves en el diseño inicial
### Chat: *"Análisis crítico y mejoras del proyecto"* · 15 mayo 2026 · 05:55h

Se somete la primera propuesta técnica a revisión despiadada. Los principales problemas identificados:

**1. Antihelada solar por circulación nocturna: descartada.**
Se concluye que proteger el campo solar mediante circulación nocturna de la bomba es un punto de fallo inadmisible: un corte de luz o fallo de bomba en una noche de helada (Jerez registra mínimas de -2 °C) destroza el campo. Se decide sustituirla por **propilenglicol** como anticongelante, sacrificando algo de eficiencia pero ganando fiabilidad total.

**2. Sin circuito de recirculación ACS: añadido.**
Con cuatro apartamentos distribuidos por la finca, sin retorno de ACS los usuarios esperan 30-60 segundos y se desperdician cientos de litros/día. Se incorpora al diseño.

**3. Temperatura de distribución ACS a 45 °C: incumple RD 865/2003.**
La distribución de ACS debe mantenerse a ≥50 °C hasta los puntos de uso; la limitación a 45 °C va en los mezcladores de los grifos, no en la red. Se corrige.

**4. Ciclo de pasteurización antilegionela: formalizado.**
El diseño inicial asumía que el HTR «pasivamente» mantenía alta temperatura. Se formaliza un ciclo semanal automático independiente del estado de la BC.

**Decisión clave de la sesión:** se confirma la estrategia de comprar la Ecoforest ecoAIR+ **con HTR** y **mínimo de software propietario** (sin e-manager, sin e-system, sin suscripción cloud), integrando todo el control con PLC propio. Se buscan acumuladores con geometría compatible con módulos PCM futuros («PCM-ready»), de modo que en el futuro solo cambien parámetros del PLC, no la hidráulica.

---

## FASE 3 — Estudio del HTR de Ecoforest y arquitectura con tres fuentes de ACS
### Chat: *"Integración de calor solar y bomba de calor en piscina"* · 23 mayo 2026 · 23:11h

Sesión larga y técnicamente densa en la que se producen dos avances importantes:

### 3.1 Comprensión correcta del HTR

Tras una discusión acalorada, se busca y lee la documentación de Ecoforest sobre el HTR. Conclusión: el HTR no es un recuperador marginal de sobrecalentamiento sino el **condensador principal** cuando hay demanda de ACS, capaz de producir simultáneamente calefacción/refrigeración y ACS a 80 °C. Se establece la jerarquía correcta de fuentes para ACS:

```
1.º HTR (hasta 80°C)    → fuente principal cuando corre el compresor
2.º Solar               → complemento gratuito diurno
3.º BC modo ACS         → apoyo solo si los anteriores insuficientes
```

### 3.2 Arquitectura de la piscina con dos productores

Se resuelve el problema de conectar solar y desuperheater a la misma piscina sin mezclar sus fluidos y con caudales muy dispares. **Decisión:** dos intercambiadores de titanio independientes, uno por cada fuente. El agua de la piscina circula en paralelo por el secundario de ambos accionada por la depuradora. Esta solución elimina la necesidad de colector de mezcla y antirretornos.

### 3.3 Inicio del código PLC

Se comienza a generar el código Structured Text (IEC 61131-3) para el FREE Smart (subsistema solar). Se programan los bloques funcionales `FB_PropSalmuera`, `FB_Solar_PI`, `FB_WiloPWM`, `FB_EnergiaSolar`, `FB_DistribBDC`, `FB_Piscina` y los programas principales `PRG_EVD7500` y `PRG_FreeSmart`.

**Incidencia documentada:** en esta fase los documentos llevan erróneamente el nombre «Intramuros» en lugar de «Casa Fosela». Se detecta y se programa su corrección.

---

## FASE 4 — Definición del hardware de control: autómatas Eliwell
### Chat: *"Características del autómata Eliwell Free Advance"* · 21 mayo 2026 · 10:56h
### Chat: *"Revisión de instalación térmica solar con acumuladores"* · 21 mayo 2026 · 10:54h

Se estudia el hardware de control disponible. Se evalúan los modelos de la familia FREE de Eliwell:

- **FREE Evolution (EVD7500):** maestro, con HMI, lógica principal.
- **FREE Smart (SMD5500):** esclavo, subsistema solar.
- **FREE Advance (AVC6200):** descartado por complejidad y coste innecesario para este proyecto.
- **EVE7500 (módulo de expansión):** incluido inicialmente, luego cuestionado.

**Decisión sobre el EVE7500:** tras contar las salidas necesarias (11 DO, 1-2 AO) se confirma que EVD7500 + SMD5500 pueden cubrir la instalación sin expansión. Sin embargo, cuando se conoce el precio real del EVE7500 (~150 €), se decide mantenerlo por margen de seguridad a un coste justificado.

**Arquitectura de control confirmada:**
```
FREE Evolution (EVD7500) ──── RS-485 Modbus RTU ──── FREE Smart (SMD5500)
        maestro                                              esclavo solar
  lógica principal + HMI                              subsistema solar completo
```

Programación en Structured Text conforme a IEC 61131-3 mediante FREE Studio.

**También en esta fase:**
- Se revisa la memoria técnica del sistema con acumuladores Tusol DB2 de 450 L (luego cambia a 400 L).
- Se define el mapa de señales I/O de ambos controladores.
- Se decide usar caudalímetros de **efecto Hall** (salida de pulsos) para calorimetría solar y para la estación de ACS.

---

## FASE 5 — Estudio de los depósitos adquiridos y primer cambio de arquitectura ACS
### Chat: *"Diseño de climatización hidrónica"* · 25 mayo 2026 · 07:46h

### 5.1 Los depósitos ya están comprados: Tusol, acero vitrificado, 400 L, doble serpentín

Se confirma que los dos acumuladores ya adquiridos son de acero vitrificado (no inox). Esto tiene implicaciones:

- **El acero vitrificado no es apto para agua potable circulante con temperatura variable** con garantía suficiente a largo plazo.
- Por tanto, **el ACS no puede producirse almacenando agua potable en el cuerpo del depósito** mediante el método convencional sin riesgo.

### 5.2 Primer intento: ACS convencional en serie → aprobado, luego descartado

Se diseña una cascada D1 (precalentamiento solar) → D2 (remate aerotérmico) con potable en los cuerpos. El cliente lo aprueba. Pero al ver la solución, el cliente comenta:

> *«Qué lástima, estaba elegantísima la solución [al paso].»*

Esto abre la puerta al rescate de la solución al paso, que había sido descartada por el material de los depósitos.

### 5.3 Decisión transformadora: estación de agua fresca con intercambiador de placas externo

**Solución:** mover la separación hidráulica potable/técnica a un intercambiador de placas externo de acero inoxidable AISI 316L, dejando los depósitos como reservorio de **agua técnica** (no potable). El potable solo toca la placa de inox y nunca se almacena.

**Ventajas que justifican el cambio:**
- Los depósitos de acero vitrificado funcionan correctamente en circuito cerrado de agua técnica (su uso correcto).
- La potencia de ACS es libre: placa dimensionada a 40-50 kW sin cuello de botella.
- Riesgo de legionela prácticamente eliminado: no hay acumulación de agua potable.
- La solución es más elegante, moderna y segura.

**Elementos de la estación de agua fresca:**
- Intercambiador de placas AISI 316L, 40-50 kW
- Circuladora Wilo modulante tipo PWM1 (perfil calefacción, se para ante pérdida de señal)
- Caudalímetro de efecto Hall en el secundario (hasta 20 L/min)
- Control: anticipación por caudal + lazo PID sobre sonda de salida
- Mezcladora termostática final (seguro mecánico independiente)
- Corte térmico independiente en la línea de ACS

**Nota crítica sobre el tipo de bomba:** se señala explícitamente que la PWM1 de la estación debe ser de **perfil calefacción** (que se para ante pérdida de señal) y no de perfil solar (que va a máxima velocidad ante pérdida de señal, lo que en ACS significaría agua hirviendo en el grifo).

---

## FASE 6 — Rediseño del reservorio: serpentines en serie en ambos depósitos
### Chat: *"Diseño de climatización hidrónica"* (continuación) · 25 mayo 2026

Con el ACS al paso resuelto, los serpentines de los depósitos quedan **completamente libres** para los productores. Se decide:

**En ambos depósitos:** conectar el serpentín superior y el inferior **en serie**, duplicando la superficie de intercambio disponible por productor (~3,2 m² por depósito frente a 1,6 m² con un solo serpentín).

**Dirección del flujo del productor:** entra por el serpentín superior, sale por el inferior. Esto construye la zona caliente arriba (donde se extrae el calor para consumos) y devuelve el fluido lo más frío posible (mejor rendimiento del captador solar y mejor COP de la BC).

**Reparto simétrico de productores:**
- El solar carga el depósito izquierdo (serpentines en serie).
- La BC carga el depósito derecho (serpentines en serie).
- Al estar en depósitos distintos, no hace falta colector de antirretornos para separar las fuentes.

**Tomas para los consumos:** se utilizan las bocas de 1¼" del ánodo (parte alta) y la resistencia (parte baja) de cada depósito, que son las bocas de mayor diámetro del cuerpo. El agua técnica entra fría por el fondo del depósito solar, se precalienta, pasa por su cabeza al depósito aerotérmico, donde la BC la remata, y sale caliente por la cabeza de este último.

---

## FASE 7 — Concentración del anticongelante solar: glicol al 15%
### Chat: *"Diseño de climatización hidrónica"* (continuación) · 25 mayo 2026

Se revisa la concentración de propilenglicol en el circuito solar. La decisión inicial (fase 2) había sido usar glicol pero sin especificar concentración.

**Decisión:** propilenglicol al **15%**.

**Justificación:**
- Las mínimas históricas de Jerez rondan los -2 °C. El 15% de PG protege holgadamente frente a esas temperaturas.
- A menor concentración, mayor calor específico (Cp ≈ 4,05 kJ/kg·K al 15%, frente a ~3,7 con concentraciones más altas) y menor viscosidad, lo que mejora tanto la transferencia como el bombeo.
- Permite el cálculo calorimétrico del aporte solar con parámetros configurables en el controlador sin recompilar.
- Sin válvula de llenado automático desde la red: el llenado es manual con premezcla verificada con refractómetro.

---

## FASE 8 — Abandono del HTR y cambio a BC monobloc genérica
### Chat: *"Memoria Proyecto Fosela"* · 25 mayo 2026 · 08:24h

Decisión de gran calado: se **descarta** la BC Ecoforest ecoAIR+ con HTR y se pasa a una **bomba de calor aerotérmica monobloc genérica** con el módulo hidráulico integrado en la unidad exterior.

**Motivo documentado:** la nueva arquitectura con estación de agua fresca hace que el HTR pierda su papel protagonista. Además, con el reservorio de agua técnica como acumulador de energía, el ACS queda cubierto de forma más robusta, independiente y sin depender del compresor de la BC.

**Implicaciones del cambio:**
- La BC entrega directamente agua técnica caliente o fría según el modo, sin tuberías frigoríficas al interior.
- La conexión al sistema es exclusivamente **hidráulica y de comunicación**.
- **Único punto abierto sobre la BC:** verificar si la circuladora integrada en la unidad exterior tiene caudal y altura manométrica suficientes para vencer la pérdida de carga del circuito de carga del reservorio (~150 mbar de los dos serpentines en serie + distribución y válvulas). Si no llega: circuladora de apoyo o desacople por buffer.

---

## FASE 9 — Arquitectura de reparto aerotérmico: dos válvulas de tres vías
### Chat: *"Memoria Proyecto Fosela"* (continuación) · 25 mayo 2026

Sin el HTR, la producción de la BC debe repartirse entre tres destinos con solo dos válvulas de tres vías:

```
Producción BC
     │
   V3V-1
    ├── A → Reservorio (depósito aerotérmico, serpentines en serie)
    └── B → V3V-2
              ├── A → Climatización vivienda (fancoils)
              └── B → Climatización piscina (HX titanio aerotérmico)
```

**Condición crítica documentada:** en modo refrigeración el agua técnica está a 7-12 °C, completamente inservible para cargar el reservorio o calentar la piscina. El PLC nunca dirigirá la producción al reservorio ni a la piscina cuando la BC esté en modo frío.

---

## FASE 10 — Distribución de ACS a los apartamentos
### Chat: *"Memoria Proyecto Fosela"* (continuación) · 25 mayo 2026

Los cuatro apartamentos conservan sus termos eléctricos existentes. Se diseña la alimentación de agua precalentada:

**Solución:** una válvula de tres vías por apartamento, controlada por señal digital del PLC desde un colector central en la sala de máquinas. La válvula conmuta entre agua de red y agua precalentada de la estación.

**Decisión de seguridad:** válvula con **retorno por muelle** — en caso de fallo de tensión conmuta automáticamente a agua de red. La señal de control es 24 V en cable 2×1 mm², completamente independiente del circuito de fuerza.

El termostato de cada termo se sube a 55-60 °C para que la resistencia apenas arranque cuando recibe agua precalentada.

---

## FASE 11 — Definición final del hardware de control: Evolution + Smart por Modbus
### Chat: *"Memoria Proyecto Fosela"* (continuación) · 25 mayo 2026

**Decisión final:** se descarta el módulo de expansión EVE7500 y se trabaja solo con dos controladores comunicados por RS-485:

```
FREE Evolution (EVD7500) ──── RS-485 Modbus RTU ──── FREE Smart (SMD5500/C/S)
        maestro                                               esclavo
  lógica principal + HMI                              subsistema solar completo
```

**Reparto de funciones:**

| Controlador | Función |
|---|---|
| FREE Evolution (maestro) | V3V aerotérmicas, V3V apartamentos, estación agua fresca (anticipación + PID), PWM1, ciclo pasteurización |
| FREE Smart (esclavo) | Bomba PWM2 (ΔT constante), calorímetro solar, persianas motorizadas, sondas glicol |

Las variables se comparten por Modbus: el maestro lee del esclavo la potencia solar instantánea, la energía acumulada, el estado de persianas y temperaturas; le envía consignas cuando las necesita.

---

## FASE 12 — Estudio de la bomba Wilo Para ST 15/7-50/PWM3 y código de control solar
### Chat: *"Bomba de agua Wilo 15/7-50/PWM3"* · 25 mayo 2026 · 08:37h

Se estudia en detalle la bomba Wilo Para ST 15/7-50/PWM3 como candidata para el circuito solar primario (bomba PWM2):

**Características confirmadas:**
- Bomba de rotor húmedo para circuito solar, apta para mezcla agua/glicol hasta 1:1
- Rango de temperatura: -10 °C a +110 °C
- Interfaz iPWM3 (3.ª generación): recibe señal duty cycle 0-100% de la centralita solar
- **Comportamiento ante pérdida de señal:** acelera a velocidad máxima (fail-safe solar)
- Active Stop: 2% PWM mantiene la bomba en reposo controlado sin girarla

**Código PLC generado en esta sesión:**
Se escribe el bloque `FB_Solar_PI` en Structured Text con las siguientes características:
- Arquitectura en dos capas: `FB_PI_AntiWindup` (PI puro reutilizable) + `FB_Solar_PI` (lógica solar específica)
- Anti-windup por back-calculation para evitar disparo del integrador tras períodos parados
- Active Stop (2% PWM en lugar de 0%) para arranque más rápido y sin golpe hidráulico
- Parámetros de ajuste PI documentados: punto de partida Kp=4,0, Ki=0,05

**Mapa de señales confirmado para FREE Smart:**
- AI1, AI2, AI3: sondas NTC del circuito de glicol (ida y retorno del solar + depósito)
- Salida PWM Open Collector a 1000 Hz
- Ciclo de programa OB1: 1000 ms

---

## ESTADO ACTUAL DEL PROYECTO (25 mayo 2026)

### Arquitectura definitiva aprobada:
- BC aerotérmica monobloc R290 con módulo hidráulico en unidad exterior
- Solar térmico 8 m², propilenglicol 15%, bomba PWM2 con ΔT constante
- Reservorio 800 L (2 × 400 L), agua técnica, serpentines en serie en ambos
- ACS instantánea por estación de agua fresca (placa AISI 316L + circuladora PWM1)
- Piscina: 2 HX de titanio independientes (solar + aerotérmico)
- Fancoils: 13 unidades con equilibrado dinámico (pendiente de decidir tipo)
- Control: FREE Evolution (maestro) + FREE Smart (esclavo) por Modbus RS-485
- Apartamentos: V3V + termo eléctrico existente, retorno a red por muelle

### Tres puntos abiertos pendientes de cierre:

| # | Cuestión | Opciones |
|---|---|---|
| 1 | Suficiencia circuladora BC (¿vence ~150 mbar + distribución?) | Circuladora de apoyo / desacople por buffer |
| 2 | Equilibrado dinámico fancoils | PICV 0-10V / válvulas ΔP / PICV integrada fábrica / bomba ΔP constante |
| 3 | Dimensionado estación ACS | Placa + circuladora a 40-50 kW con Tª reservorio prevista; caudalímetro hasta 20 L/min |

### Documentos y código generados hasta la fecha:
- `propuesta_DEFINITIVA_BC_monobloc.md` — Propuesta técnica definitiva
- `propuesta_OPCION_BC_con_HTR.md` — Versión archivada con HTR (por si se reconsidera)
- `FB_PropSalmuera.st`, `FB_Solar_PI.st`, `FB_WiloPWM.st`, `FB_EnergiaSolar.st` — Bloques funcionales FREE Smart
- `FB_DistribBDC.st`, `FB_Piscina.st` — Bloques funcionales FREE Evolution
- `PRG_EVD7500.st`, `PRG_FreeSmart.st` — Programas principales de cada controlador
- `Solar_PI_FreeSmart.st` — Versión actualizada con PI anti-windup y Active Stop

---

*Bitácora elaborada el 25 de mayo de 2026. Próxima actualización al cerrar cualquiera de los tres puntos pendientes.*
