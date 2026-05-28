# M13 — Cuadro eléctrico (distribución y montaje)

**Estado:** ⏳ inventario y criterios de distribución fijados · falta esquema en QElectroTech y selección de calibres.
**Depende de:** M09 (PLC y E/S), M10 (Cadenas de Seguridad), M12 (mapa de E/S).

## Propósito

Alojar control y potencia de la instalación en un cuadro único, con una distribución que separe potencia/control/señal, facilite el montaje y el mantenimiento, y respete las Cadenas de Seguridad (que deben seguir operando con el PLC averiado, ver M10).

> **No hay "sistema experto" comercial que diseñe la distribución.** La distribución se rige por reglas de buena práctica deterministas (separación por naturaleza, flujo de la energía, disipación térmica, accesibilidad). Este módulo las aplica al inventario concreto del proyecto. El dibujo se hace en QElectroTech.

## Inventario de aparamenta (dentro del cuadro)

### Potencia / alimentación
- Interruptor general + protección de acometida (magnetotérmico + diferencial).
- Protecciones por circuito: bombas (P-SOL, P-ACS, P1, P2, P-POOL), persianas, auxiliares.
- **Línea protegida dedicada para la BC** (monobloc R290): magnetotérmico propio; la BC gestiona internamente su compresor. En el cuadro: **habilitación por contacto** (DO19) + Modbus, **sin contactor de motor**.
- **Un contactor:** para la **bomba de la depuradora** (motor mayor, arranque con punta), mandado por relé desde DO20.
- **Fuente de alimentación 24 Vdc** (PLC, sensores, relés, válvulas motorizadas).
- **Sin resistencias en el cuadro** (las únicas del sistema son las de los termos de apartamentos, M07, con circuito propio).

### Control
- **PLC M241** (TM241CE24T) + módulos TM3: **2× TM3TI8T** (temperatura PT1000) + **1× TM3DQ16T** (DO transistor) — ver M09/M12. (En la opción Eliwell, el FREE Evolution + expansiones ocupa este espacio, con sondas NTC 10K.)
- **Relés de interposición entre cada DO del PLC y su carga** (buena práctica: no usar los relés internos del PLC). Separan la lógica de la potencia y son sustituibles.
- **Zelio Logic** (OR de demandas de fancoils, M12) — relé programable, gobierna el arranque de P2 como cadena de seguridad de clima (M10). Su línea de alimentación es **independiente de la fuente de control del M241**.
- Relés/temporizadores de las **Cadenas de Seguridad** (cableadas, independientes del PLC).

### Señal
- **Clemero de sondas:** 16 canales PT1000 (13 + 3 spare) — bornas de paso, apantalladas. (NTC 10K en la rama Eliwell.)
- **Comunicaciones:** RS-485 (Modbus a BC), Ethernet (HMI web / supervisión).
- Bornas de entradas digitales (caudalímetro Hall, avisos de seguridades, confirmación depuradora, demanda agregada del Zelio) y de las salidas a actuadores.

### Seguridad (hardware, ver M10)
- Termostatos bimetálicos de rearme manual (corte ACS, Z1, Z2, TK1) — cuerpo en depósito/captador, contacto al cuadro.
- Klixon de persianas (sobretemperatura captador).
- **Panel de mando manual en la puerta** (ver sección siguiente).
- Sirena/baliza de alarma (AV1).

## Panel de mando manual en la puerta del cuadro (HMI físico)

Conjunto de **manetas, pulsadores y pilotos** en el frontal/puerta del cuadro para **operar la instalación a mano en caso de fallo del PLC o para pruebas/puesta en marcha**, sin depender del automáta ni del web server. Es la materialización del "conmutador manual/0/auto por actuador" de M10. **No es una pantalla** — el HMI gráfico es el web server del M241 (M09/M11); esto es mando electromecánico.

### Selectores Manual / 0 / Auto (uno por actuador gobernable)

En **Auto** manda el M241; en **0** parado/aislado; en **Manual** el operario fuerza desde el cuadro saltando al PLC. Actuadores con selector M/0/A:

| Selector | Actuador | Notas |
|---|---|---|
| P-SOL | Bomba solar | en manual, marcha fija (sin PWM) |
| P-ACS | Bomba primario ACS | en manual, marcha fija |
| P1 | Bomba trasvase D2→buffer | |
| P2 | Bomba fancoils | en auto, gobernada por Zelio/PLC |
| P-POOL | Bomba primario piscina | |
| Depuradora | Contactor depuradora | |
| V3V modo BC | Conmutación estacional invierno/verano | |
| Persianas | Subir/bajar (respeta el klixon de seguridad, que tiene prioridad) | |

> Las **V3V de proceso** (V3V1, V3V2, disipación, apartamentos) y los **cortes antitermosifón** se mueven con el PLC o caen a su posición de fallo por muelle; se valora añadir selector manual solo donde aporte para pruebas (pendiente, ver tabla de posición de fallo en M10).

### Pulsadores
- **Marcha/paro** puntuales donde el modo Manual lo requiera.
- **Rearme** de las seguridades de rearme manual (o se rearma en el propio termostato, a decidir).
- **Seta de emergencia** general (corte de potencia de bombas/actuadores).

### Pilotos (LED) de estado
- Marcha/paro de cada bomba (P-SOL, P-ACS, P1, P2, P-POOL, depuradora).
- Alarmas activas: Z1, Z2, TK1, corte térmico ACS, fallo BC.
- "Hay demanda de clima" (salida del Zelio).
- Presencia de tensión de control 24V / fallo de fuente.

> Detalle fino (cuántos pilotos, agrupación, colores según norma) a cerrar con el esquema en QElectroTech. Coordinar el cableado del panel con los relés de interposición (los selectores M/0/A actúan sobre el mando de cada relé/contactor, no sobre la potencia directamente, salvo la seta).

## Criterios de distribución (las reglas aplicadas)

1. **Separación por naturaleza — tres zonas que no se mezclan:**
   - **Potencia** (acometida, protecciones, contactor depuradora, fuente): una zona.
   - **Control** (PLC, relés de interposición, Zelio): otra zona.
   - **Señal** (clemero de PT1000, RS-485): separada de la potencia para no inducir ruido en las sondas y el bus. **Las sondas y el RS-485 nunca en paralelo con cables de potencia**; si se cruzan, a 90°.
2. **Flujo de la energía de arriba abajo:** acometida y general arriba → distribución y protecciones → fuente 24V → consumos. Cableado corto y ordenado.
3. **Disipación térmica:** la fuente 24V y lo que caliente, en la parte alta o donde ventile; el PLC y lo sensible, lejos del foco de calor.
4. **Clemero abajo**, alineado con las entradas de cable (prensaestopas), agrupado por tipo: bornas de potencia / 24V / señales analógicas (PT1000, apantalladas) / comunicaciones. Numeración correlativa coherente con M12.
5. **Accesibilidad:** PLC, protecciones a rearmar, panel de mando manual de la puerta y bornas de prueba, accesibles. Lo que no se toca, detrás/arriba.
6. **Margen de relleno** de canaletas y carriles (~30 % libre) para mantenimiento y futuras ampliaciones (spare ya previsto en sondas y en el hueco para la 2ª TM3TI8T si se amplía).

## Disposición orientativa por zonas (carriles DIN)

```
┌─────────────────────────────────────────────┐
│ Carril 1 (alto):  General + diferencial +     │  POTENCIA
│                   magnetotérmicos + Línea BC   │
│ Carril 2:         Fuente 24Vdc + protección 24V│
│ Carril 3:         Contactor depuradora +       │
│                   relés de bombas y persianas  │
├──────────────────────────────────────────┤
│ Carril 4:         PLC (M241) + módulos TM3     │  CONTROL
│ Carril 5:         Relés de interposición DO    │
│ Carril 6:         Zelio + relés/temporizadores │
│                   de las Cadenas de Seguridad  │
├──────────────────────────────────────────┤
│ Carril 7 (bajo):  Clemero — potencia | 24V |   │  SEÑAL
│                   PT1000 (apantalladas) |      │
│                   RS-485 | Ethernet (RJ45)     │
└─────────────────────────────────────────────┘
        (prensaestopas en la parte inferior)
```

**Panel de mando manual (selectores M/0/A, pulsadores, pilotos, seta): en la PUERTA del cuadro.**

## Convención de marcado (para EPLAN / clemero, ver carpeta `cuadro/`)

- **Bornas:** correlativas por regletero — `X1` potencia, `X2` 24V, `X3` PT1000 (apantalladas), `X4` comunicaciones. Formato `X1:1, X1:2…`
- **Cables:** etiqueta única `Wnnn` en el cable; **origen/destino/tipo solo en la tabla de cables** (`cuadro/cables.csv`), no rotulados en el cable.
- **Aparatos:** notación `-Kn` (relés/contactores), `-Qn` (protecciones), `-Xn` (regleteros), `-Tn` (fuente), `-A1` (PLC), `-A2` (Zelio), `-Sn` (selectores/pulsadores del panel).

## Pendientes

- Inventario fino con referencias y calibres (magnetotérmicos, diferencial, sección de cables, contactor depuradora) — apoyar en Ecodial / EcoStruxure Power Design.
- **Cerrar el panel de mando manual:** lista definitiva de selectores M/0/A, pulsadores y pilotos; cableado sobre los relés de interposición; norma de colores.
- Dimensionar la envolvente (nº de módulos DIN + holgura) según el inventario cerrado, contando el Zelio y el panel de puerta.
- Esquema eléctrico y plano de clemero en **QElectroTech**; tablas de input para EPLAN en `cuadro/`.
- Coordinar el clemero con la numeración de E/S de M12 y las Cadenas de Seguridad de M10.
