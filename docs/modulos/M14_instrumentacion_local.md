# M14 — Instrumentación local y protocolo de chequeo

**Estado:** 🔶 criterio fijado · falta ubicar cada punto en el plano y redactar la hoja de ronda.
**Transversal a:** todos los módulos hidráulicos. **Relacionado con:** M08 (sala), M12 (lo que SÍ va al PLC), M10 (seguridades).

## Propósito y criterio

La instalación se verifica con **instrumentación local de lectura visual** (manómetros y termómetros) repartida en puntos clave, y un **protocolo de chequeo periódico** de esas lecturas. **No** se llevan sensores al PLC para vigilancia/diagnóstico/calorimetría.

> **Frontera con el PLC (M12):** al PLC solo llegan las sondas **imprescindibles para el control** (PT1000) y las señales de seguridad por contacto. Todo lo demás —comprobar presiones, rendimiento, ΔT, que una bomba mueve fluido— se hace **a ojo** sobre instrumentación local, no con canales del autómata. Esto evita sobre-instrumentar: menos cableado, menos canales, menos puntos de fallo.

> **Por qué local y no al PLC:** la calorimetría y el diagnóstico fino no controlan nada — informan. Un termómetro de esfera de pocos euros da esa información cuando se necesita, sin ocupar un canal ni añadir una sonda que mantener. El valor de tenerlo en continuo en el PLC no justifica su coste en este proyecto.

## Puntos de medida (a ubicar en plano)

### Manómetros (presión, lectura visual)

| Id | Ubicación | Para qué se chequea |
|---|---|---|
| PI-SOL | Grupo de seguridad solar (retorno frío, junto a P-SOL y vaso) | Presión del circuito de glicol: caída = fuga o vaporización; subida anormal = estancamiento |
| PI-TND | Circuito de agua técnica del tándem (grupo de seguridad) | Presión del circuito principal: caída = fuga |
| PI-CLI | Circuito de clima (buffer + fancoils) | Presión del circuito de climatización |
| PI-POOL-F | Filtro de la depuradora (entrada/salida del filtro) | Colmatación del filtro: subida de presión = toca contralavado (manual) |

### Termómetros (temperatura, lectura visual)

| Id | Ubicación | Para qué se chequea | Vaina (orient.) |
|---|---|---|---|
| TI-SOL-I | Ida de glicol (salida hacia captadores) | ΔT solar (con TI-SOL-R) → rendimiento del campo | corta ~50 mm (tubería) |
| TI-SOL-R | Retorno de glicol (desde captadores) | ΔT solar | corta ~50 mm (tubería) |
| TI-ACS-P | Retorno del primario de ACS (HX) | Que el primario retorna frío → el HX cede bien; calorimetría ACS | corta ~50 mm (tubería) |
| TI-ACS-D | Distribución de ACS tras la mezcladora VMT1 | Que llega ~55 °C a apartamentos; verifica la VMT mecánica | corta ~50 mm (tubería) |
| TI-CLI-I | Impulsión a fancoils | Temperatura de impulsión de clima | corta ~50 mm (tubería) |
| TI-CLI-R | Retorno de fancoils | ΔT de clima (con TI-CLI-I) → que los fancoils intercambian | corta ~50 mm (tubería) |
| TI-D1 | D1 (zona solar del tándem) | Estado térmico del tándem (apoyo visual a la sonda PT1000 de control) | larga ~200 mm (depósito) |
| TI-D2 | D2 (zona caliente / tapa) | Ídem | larga ~200 mm (depósito) |
| TI-POOL | Agua de piscina (lado técnico) | Temperatura de baño | corta ~50 mm (tubería) |

## Longitud de vaina (Tauchhülse) — criterio

La vaina (*Tauchhülse*, inox para solar/glicol y tándem) se pide según dónde mida:

- **En depósito (D1, D2, buffer):** vaina **larga**, que la punta llegue al **centro de la masa de agua** (no a la pared, mediría el acero). Tándem D1/D2 ~**200-250 mm**; buffer 150 L ~**100-150 mm**. **Si el depósito trae dedos/vainas de fábrica, usarlos** y no comprar vaina.
- **En tubería (glicol, fancoils, ACS, piscina):** vaina **corta** ~**50 mm**, montada en T o codo, con la punta en la **vena del fluido** (centro del tubo), sin frenar el caudal. Montaje a contracorriente o en codo para que el fluido bañe la punta.
- **Captador solar:** se usa la vaina del propio captador (de fábrica). En este proyecto, además, el arranque solar es por **muestreo a bajo caudal** (M02), no por sonda de captador → probablemente no se necesita.

Detalles de compra: **diámetro interior** acorde a la sonda (PT1000 solares ~6 mm) + **pasta térmica** (*Wärmeleitpaste*) para buen contacto; **rosca** según toma (depósito **G½"**; T en tubería **G½"** o **G¼"**); material **Edelstahl** (inox) en solar y tándem.

> Las mismas longitudes aplican a las **sondas PT1000 de control** (M12) que van a depósito o tubería, no solo a los termómetros locales.

## Tipo de instrumento

- **Manómetros:** esfera glicerina (amortigua vibración), rango adecuado a cada circuito (solar/tándem/clima ~0-6 bar; filtro piscina según equipo). Con llave/pulsador donde convenga aislarlos.
- **Termómetros:** bimetálicos de esfera con vaina, o de contacto/superficie sobre tubería. En el solar, aptos para la temperatura del punto.
- Montaje sobre toma roscada o vaina; en tubería, donde la lectura sea representativa y visible sin desmontar nada.

## Protocolo de chequeo (a programar)

Ronda periódica de lectura y registro — la «programación» aquí es un **calendario de inspección humana**, no código del PLC.

- **Frecuencia (a fijar):** p.ej. semanal en marcha normal; diaria los primeros días tras arranque y en olas de calor (vigilancia de estancamiento solar).
- **Qué se anota:** lectura de cada manómetro y termómetro, fecha/hora, y comparación con el **rango esperado** de cada punto.
- **Rangos esperados:** definir un valor/intervalo normal por punto (se rellena tras la puesta en marcha, cuando se conozcan los valores reales de régimen).
- **Disparadores de acción:** qué hacer si una lectura sale de rango (p.ej. presión solar baja → revisar fuga/purga; ΔT solar ~0 con sol → bomba parada o aire; presión filtro alta → contralavado).
- **Soporte:** hoja de ronda en papel plastificado junto al cuadro, o registro en hoja de cálculo. (No requiere el HMI; es verificación independiente del PLC, en línea con M10.)

## Pendientes

- Ubicar cada punto (PI-*/TI-*) en el plano hidráulico y en el manual de montaje (M08 / manual_montaje).
- Redactar la **hoja de ronda** con los rangos esperados (tras puesta en marcha).
- Fijar la frecuencia de chequeo por temporada (normal / arranque / ola de calor).
- Decidir el set mínimo real de instrumentos (no sobre-instrumentar: poner donde el chequeo aporte, no en todos los puntos posibles).
