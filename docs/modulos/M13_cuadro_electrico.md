# M13 — Cuadro eléctrico (distribución y montaje)

**Estado:** ⏳ inventario y criterios de distribución fijados · falta esquema en QElectroTech y selección de calibres.
**Depende de:** M09 (PLC y E/S), M10 (Cadenas de Seguridad), M12 (mapa de E/S).

## Propósito

Alojar control y potencia de la instalación en un cuadro único, con una distribución que separe potencia/control/señal, facilite el montaje y el mantenimiento, y respete las Cadenas de Seguridad (que deben seguir operando con el PLC averiado, ver M10).

> **No hay "sistema experto" comercial que diseñe la distribución.** La distribución se rige por reglas de buena práctica deterministas (separación por naturaleza, flujo de la energía, disipación térmica, accesibilidad). Este módulo las aplica al inventario concreto del proyecto. El dibujo se hace en QElectroTech.

## Inventario de aparamenta (dentro del cuadro)

### Potencia / alimentación
- Interruptor general + protección de acometida (magnetotérmico + diferencial).
- Protecciones por circuito: bombas (P-SOL, P-ACS, P1, P2, P-POOL), BC (suele tener su propia línea/protección), persianas, auxiliares.
- **Fuente de alimentación 24 Vdc** (para PLC, sensores, relés, válvulas motorizadas).
- Contactores/relés de mando de bombas (las de on/off: P1, P2, P-POOL) y de persianas.

### Control
- **PLC** (M241 + módulos TM3: 2×TM3TI8T, TM3DQ/DO, 2×TM3AI4) — ver M09/M12. (En la opción Eliwell, el FREE Evolution + expansiones ocupa este espacio.)
- Relés de interposición entre DO del PLC y cargas (separan la lógica de la potencia).
- Relés/temporizadores de las **Cadenas de Seguridad** (cableadas, independientes del PLC).

### Señal
- **Clemero de sondas:** 16 NTC (13 + 3 spare) — bornas de paso, apantalladas.
- **Comunicaciones:** RS-485 (Modbus a BC), Ethernet (HMI/supervisión).
- Bornas de entradas digitales (caudalímetro Hall, avisos de seguridades) y de las salidas a actuadores.

### Seguridad (hardware, ver M10)
- Termostatos de rearme manual (corte ACS, Z1, Z2, TK1) — cuerpo en depósito, contacto al cuadro.
- Conmutadores manual/0/auto por actuador.
- Sirena/baliza de alarma (AV1).

## Criterios de distribución (las reglas aplicadas)

1. **Separación por naturaleza — tres zonas que no se mezclan:**
   - **Potencia** (acometida, protecciones, contactores, fuente): una zona.
   - **Control** (PLC, relés de interposición): otra zona.
   - **Señal** (clemero de NTC, RS-485): separada de la potencia para no inducir ruido en las sondas y el bus. **Las NTC y el RS-485 nunca en paralelo con cables de potencia**; si se cruzan, a 90°.
2. **Flujo de la energía de arriba abajo:** acometida y general arriba → distribución y protecciones → fuente 24V → consumos. Cableado corto y ordenado.
3. **Disipación térmica:** la fuente 24V y lo que caliente, en la parte alta o donde ventile; el PLC y lo sensible, lejos del foco de calor.
4. **Clemero abajo**, alineado con las entradas de cable (prensaestopas), agrupado por tipo: bornas de potencia / 24V / señales analógicas (NTC, apantalladas) / comunicaciones. Numeración correlativa coherente con M12.
5. **Accesibilidad:** PLC, protecciones a rearmar, conmutadores manual/auto y bornas de prueba, accesibles al abrir. Lo que no se toca, detrás/arriba.
6. **Margen de relleno** de canaletas y carriles (~30 % libre) para mantenimiento y futuras ampliaciones (spare ya previsto en sondas).

## Disposición orientativa por zonas (carriles DIN)

```
┌──────────────────────────────────────────────┐
│ Carril 1 (alto):  General + diferencial +     │  POTENCIA
│                   magnetotérmicos por circuito │
│ Carril 2:         Fuente 24Vdc + protección 24V│
│ Carril 3:         Contactores/relés de bombas  │
│                   y persianas                  │
├──────────────────────────────────────────────┤
│ Carril 4:         PLC (M241) + módulos TM3     │  CONTROL
│ Carril 5:         Relés de interposición DO    │
│ Carril 6:         Relés/temporizadores de las  │
│                   Cadenas de Seguridad         │
├──────────────────────────────────────────────┤
│ Carril 7 (bajo):  Clemero — potencia | 24V |   │  SEÑAL
│                   NTC (apantalladas) | RS-485  │
│                   | Ethernet (RJ45)            │
└──────────────────────────────────────────────┘
        (prensaestopas en la parte inferior)
```

Conmutadores manual/0/auto y baliza: en la **puerta** o frontal accesible.

## Pendientes

- Inventario fino con referencias y calibres (magnetotérmicos, diferencial, sección de cables) — apoyar en Ecodial / EcoStruxure Power Design para justificar protecciones.
- Dimensionar la envolvente (nº de módulos DIN + holgura) según el inventario cerrado.
- Esquema eléctrico y plano de clemero en **QElectroTech**.
- Coordinar el clemero con la numeración de E/S de M12 y las Cadenas de Seguridad de M10.
- Definir alimentación de la BC (línea propia / desde este cuadro) y su protección.
