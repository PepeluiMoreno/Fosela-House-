# Tabla de parámetros — Fusela House

Identificador único `Pnn` válido en HMI, código ST, documentación y puesta en marcha.

**Niveles de acceso:**
- **CFG** — parámetros de equipo y sistema, acceso técnico instalador (PIN CFG)
- **L1** — setpoints operativos, acceso operador autorizado (PIN L1)
- **R/O** — solo lectura

**Unidades:** temperaturas en °C · tiempos en segundos salvo indicación  
**Encoding Modbus:** temperaturas × 10 como entero (42,5 °C → 425)

---

## Bloque P00–P06 · Límites de equipo (CFG)

Valores extraídos de las fichas técnicas de los equipos instalados.
Se introducen en la puesta en marcha y solo se modifican si se sustituye un equipo.
El software los usa en tiempo real para calcular los rangos admisibles de los parámetros L1.

| Código | Nombre programa | Función | Si demasiado alto | Si demasiado bajo |
|---|---|---|---|---|
| **P00** | `ip_AccumulatorMaxTemp` | T máx de trabajo de los acumuladores según placa. Techo absoluto del sistema: acota P17 (cierre persianas), P30 (consigna ACS) y P70 (higienización). | El software permite consignas que dañan el acumulador (vitrificado, ánodo). La cadena hardware (Z1/Z2) actuará tarde. | Reduce innecesariamente el rango operativo de ACS e higienización. |
| **P01** | `ip_BDCMaxFlowTemp` | T máx impulsión del primario de la bomba de calor en modo calefacción. Acota P30 (consigna ACS) y P50 (consigna climatización calefacción). | El software ordena temperaturas que la bomba de calor no puede alcanzar → cicleo continuo, desgaste compresor. | Limita innecesariamente la temperatura de ACS y calefacción por debajo de lo que el equipo puede dar. |
| **P02** | `ip_HTRMaxTemp` | T máx que produce el recuperador de calor del compresor (HTR). Acota P34 (inhibición HTR hacia D2). | El software no inhibe el HTR cuando corresponde → riesgo de sobretemperatura en D2. | El software inhibe el HTR demasiado pronto → se desaprovecha energía gratuita del compresor. |
| **P03** | `ip_BDCMinCoolTemp` | T mín impulsión de la bomba de calor en modo refrigeración. Acota P52 (consigna refrigeración D3). | El software permite consignas de frío que la bomba de calor no puede alcanzar → cicleo, pérdida de eficiencia. | El software limita el frío por encima de lo que el equipo puede dar → confort insuficiente en verano. |
| **P04** | `ip_CollectorMaxOperTemp` | T máx de operación continuada de los colectores solares. El software activa alarma TT1 y cierra persianas antes de que TK1 hardware actúe. | El software no actúa antes que TK1 → la protección queda solo en hardware (aceptable pero no óptimo). | El software cierra persianas y lanza alarmas a temperaturas de operación normales → interrupciones innecesarias. |
| **P05** | `ip_HXMaxTemp` | T máx admisible en los intercambiadores de calor. El software corta el primario correspondiente si TT8/TT10 la supera. | El software no protege los intercambiadores por software → solo queda la VS mecánica como protección. | El software corta primarios a temperaturas de operación normales → calentamiento de piscina interrumpido. |
| **P06** | `ip_PumpMaxFluidTemp` | T máx del fluido admisible por la bomba solar (sellos y rodamientos). El software para P1 si TT1 la supera antes de que lo haga Z1 hardware. | El software no para P1 a tiempo → daño a los sellos de la bomba antes de que actúe Z1. | El software para P1 en condiciones de operación normal → pérdida de producción solar innecesaria. |

---

## Bloque P10–P19 · Solar (L1)

| Código | Nombre programa | Función | Si demasiado alto | Si demasiado bajo |
|---|---|---|---|---|
| **P10** | `ip_SolarDeltaTTarget` | ΔT objetivo del lazo PI entre sonda colector (TT1) y fondo D1 (TT2). El PI ajusta la velocidad de P1 para mantener este diferencial. | El fluido circula muy lento → colector muy caliente → pérdidas por temperatura elevada → menor rendimiento óptico. | El fluido circula muy rápido → ΔT real cae → P1 reduce velocidad de nuevo → oscilación. Valor típico 6–10 K. |
| **P11** | `ip_SolarDeltaTStart` | ΔT mínimo para arrancar P1. | P1 arranca con muy poco calor disponible → posible transferencia negativa (D1 calienta el campo). | P1 tarda mucho en arrancar → se pierde producción solar de mañana y tarde. |
| **P12** | `ip_SolarDeltaTStop` | ΔT por debajo del cual P1 para. Debe ser menor que P11 para crear histéresis. | Histéresis insuficiente → P1 cicla continuamente arrancando y parando. | P1 sigue funcionando con ΔT casi cero → riesgo de transferencia inversa (D1 enfría el campo). Siempre < P11. |
| **P13** | `ip_SolarPumpMinSpeed` | Velocidad mínima de P1 mientras está en marcha. Por debajo de este valor el lazo PI no puede bajar. | Flujo mínimo demasiado alto → campo solar no llega a temperatura útil en condiciones de baja irradiancia. | Velocidad tan baja que la bomba entra en zona de cavitación o flujo no estable. |
| **P14** | `ip_SolarPumpMinOnTime` | Tiempo mínimo que P1 permanece en marcha una vez arrancada. Evita cicleo. | Tiempos muy largos → P1 sigue en marcha con ΔT negativo perdiendo energía. | No evita el cicleo → arranques y paradas frecuentes → desgaste de la bomba. |
| **P15** | `ip_SolarPumpMinOffTime` | Tiempo mínimo que P1 permanece parada antes de poder volver a arrancar. | Campo solar espera demasiado para aprovechar un recurso solar disponible. | No evita el cicleo → mismos efectos que P14 bajo. |
| **P16** | `ip_MinTempForPoolSolarHeating` | T mínima en D1 cabeza (TT3) para autorizar desvío solar a piscina vía V3V_SOL. Garantiza que el ACS está suficientemente cargado antes de derivar energía a piscina. | Se desvía a piscina con D1 casi frío → ACS insuficiente. | D1 debe estar muy caliente para derivar a piscina → se desaprovecha energía solar que podría calentar la piscina. Máx = P00 − 7 K. |
| **P17** | `ip_SolarOverheatShutterClose` | T en D1 fondo (TT2) que activa el cierre de persianas. Software actúa antes de TK1 hardware. | Software cierra persianas tarde → TK1 actúa primero → no hay margen software. Máx = P00 − 3 K. | Persianas cierran a temperaturas normales de operación → pérdida de producción solar innecesaria. |
| **P18** | `ip_SolarOverheatShutterHyst` | Histéresis de reapertura de persianas tras el cierre por sobretemperatura. | Persianas reabren demasiado pronto → vuelven a cerrar en poco tiempo → cicleo. | Las persianas tardan demasiado en reabrir tras bajar la temperatura → pérdida de producción solar. |
| **P19** | `ip_SolarMode` | Modo de operación del subsistema solar: 0=AUTO / 1=forzar ACS / 2=forzar piscina / 3=OFF. Solo para mantenimiento o puesta en marcha. En operación normal siempre en AUTO. | — | — |

---

## Bloque P20–P21 · Regulador PI solar (CFG)

| Código | Nombre programa | Función | Si demasiado alto | Si demasiado bajo |
|---|---|---|---|---|
| **P20** | `ip_SolarPI_Kp` | Ganancia proporcional del lazo PI de P1. Determina la rapidez de respuesta ante un error de ΔT. | Respuesta demasiado agresiva → velocidad de P1 oscila continuamente (inestabilidad). | Respuesta lenta → el sistema tarda mucho en ajustarse a cambios de irradiancia. |
| **P21** | `ip_SolarPI_Ki` | Ganancia integral del lazo PI. Elimina el error estacionario de ΔT. | Acción integral excesiva → oscilación de baja frecuencia en la velocidad de P1 (windup). | El lazo no converge al ΔT objetivo → error permanente entre ΔT real y P10. Ajustar junto con P20. |

---

## Bloque P30–P35 · ACS (L1)

| Código | Nombre programa | Función | Si demasiado alto | Si demasiado bajo |
|---|---|---|---|---|
| **P30** | `ip_ACSStorageSetPoint` | Consigna de temperatura en D2 cabeza (TT5). Define la temperatura objetivo del agua sanitaria en el acumulador. | Mayor consumo eléctrico de la bomba de calor. Mayor pérdida estática. Riesgo de sobretemperatura si se acerca a P00. Máx = P01 − 5 K. | Agua sanitaria insuficientemente caliente para garantizar 55 °C en distribución tras VMT1. Mín normativo: suficiente para 55 °C en usuario. |
| **P31** | `ip_ACSStorageHysteresis` | Banda muerta total en TT5. La bomba de calor arranca cuando TT5 < (P30 − P31/2) y para cuando TT5 > (P30 + P31/2). | Poca carga a la bomba de calor → arranques frecuentes → desgaste compresor. | Bomba de calor trabaja casi continuamente → menor rendimiento, mayor consumo. |
| **P32** | `ip_ACSBDCStartTemp` | T en D2 fondo (TT4) que activa la carga de D2 mediante la bomba de calor. Evita cargar D2 desde arriba cuando el fondo ya está caliente. | La bomba de calor no arranca hasta que D2 está muy frío → usuario sin ACS. Siempre < P30 − 3 K. | La bomba de calor carga D2 innecesariamente aunque haya calor solar suficiente. |
| **P33** | `ip_ACSBDCStartHyst` | Histéresis de P32. | Sin histéresis suficiente → cicleo de la bomba de calor. | Rango demasiado estrecho → la bomba de calor arranca y para continuamente. |
| **P34** | `ip_HTRStopTemp` | T en D2 cabeza (TT5) que inhibe el desvío del HTR hacia D2. Cuando D2 está suficientemente caliente el HTR se deriva a piscina. | El HTR sigue calentando D2 cuando ya no es necesario → desaprovecha energía gratuita para piscina. Máx = P02. | El HTR se inhibe demasiado pronto → D2 no alcanza temperatura suficiente solo con HTR. Mín = P30. |
| **P35** | `ip_HTRStopHyst` | Histéresis de P34. | Sin histéresis → V3V3 conmuta continuamente entre D2 y piscina. | Rango tan estrecho que el HTR cambia de destino con cada ciclo. |

---

## Bloque P40–P46 · ACS apartamentos (L1)

| Código | Nombre programa | Función | Si demasiado alto | Si demasiado bajo |
|---|---|---|---|---|
| **P40–P44** | `ip_AptMode_01..05` | Modo de la válvula de cada apartamento: 0=precalentada (normal) / 1=AFS (mantenimiento o vacancia). En modo AFS el calentador del apartamento trabaja desde agua fría de red. | — | — |
| **P45** | `ip_VacancyThreshold` | Días de no-uso de un apartamento tras los cuales la válvula conmuta automáticamente a AFS para evitar agua estancada en el ramal de precalentada a temperatura de riesgo Legionella. | Un apartamento vacío mantiene agua tibia estancada demasiado tiempo en el ramal → riesgo microbiológico. | El sistema conmuta a AFS muy pronto → se pierde el ahorro energético del preheating en apartamentos con rotación frecuente. |
| **P46** | `ip_AptSwitchHour` | Hora nocturna en la que se ejecutan las conmutaciones programadas de válvulas de apartamento. Evita cambios bruscos de temperatura en el grifo durante el uso. | Conmutación en horario de uso → usuario nota cambio de temperatura en el grifo. | Misma consecuencia si se elige hora con posible uso nocturno. Rango recomendado: 2–5 h. |

---

## Bloque P50–P53 · Climatización (L1)

| Código | Nombre programa | Función | Si demasiado alto | Si demasiado bajo |
|---|---|---|---|---|
| **P50** | `ip_HeatingSetPoint` | Consigna de temperatura en D3 cabeza en modo calefacción. Define el agua caliente que circula por los fancoils. | Mayor consumo, menor COP de la bomba de calor. Posible sobreconfort. Máx = P01 − 5 K. | Fancoils no alcanzan la potencia necesaria para climatizar → disconfort en invierno. |
| **P51** | `ip_HeatingHysteresis` | Banda muerta en calefacción. | Arranques frecuentes de la bomba de calor. | D3 oscila mucho de temperatura → confort irregular. |
| **P52** | `ip_CoolingSetPoint` | Consigna de temperatura en D3 fondo en modo refrigeración. | D3 no baja suficientemente → fancoils no refrigeran → disconfort en verano. Mín = P03. | Refrigeración excesiva → mayor consumo, mayor riesgo de condensación si hay suelo radiante. |
| **P53** | `ip_CoolingHysteresis` | Banda muerta en refrigeración. | Cicleo de la bomba de calor en modo frío. | D3 oscila de temperatura → confort irregular. |

---

## Bloque P60–P64 · Piscina (L1)

| Código | Nombre programa | Función | Si demasiado alto | Si demasiado bajo |
|---|---|---|---|---|
| **P60** | `ip_PoolSetPoint` | Consigna de temperatura de la piscina (TT11). | Mayor consumo energético para mantener temperatura. Agua demasiado caliente → incómoda para el baño. | Agua fría → piscina no utilizable en temporadas de baño. |
| **P61** | `ip_PoolHysteresis` | Banda muerta de la temperatura de piscina. | Activaciones frecuentes de los intercambiadores → desgaste de válvulas VP. | Temperatura de piscina estable con poco margen → mayor confort térmico en el agua. |
| **P62** | `ip_PoolMaxTemp` | T máxima de piscina que activa alarma y corte de calentamiento. Protege tanto al usuario como al revestimiento del vaso. | El software no protege contra sobretemperatura de la piscina. Máx razonable: 36 °C. | Alarma demasiado pronta → interrupciones de calentamiento en días de mucho sol. |
| **P63** | `ip_PoolDelay` | Tiempo que la bomba del secundario (lado piscina) permanece en marcha tras parar la bomba del primario. Recupera el calor residual almacenado en las placas del intercambiador. | Se bombea agua fría de piscina por el intercambiador ya sin calor → enfría ligeramente la piscina. | Se pierde el calor residual en las placas → menor eficiencia del intercambiador. Típico: 20–60 s. |
| **P64** | `ip_PoolValveTravelTime` | Tiempo de maniobra de las válvulas VP_HX. El software espera este tiempo antes de confirmar el cambio de posición. | Tiempo correcto según especificación del actuador. Si es muy bajo: el software considera abierta/cerrada una válvula que aún está en tránsito. | El sistema espera innecesariamente → retraso en el inicio del calentamiento. |

---

## Bloque P70–P77 · Higienización térmica (L1 / CFG)

| Código | Nivel | Nombre programa | Función | Si demasiado alto | Si demasiado bajo |
|---|---|---|---|---|---|
| **P70** | L1 | `ip_HygienizationTarget` | T objetivo en D2 durante el ciclo de higienización térmica. Debe ser suficiente para inactivar Legionella en toda la red. | Mayor consumo, mayor tiempo de ciclo, mayor desgaste del acumulador. Máx = 75 °C (margen respecto a P00). | Por debajo de 65 °C el ciclo no garantiza la inactivación microbiológica. Mín normativo: 65 °C. |
| **P71** | L1 | `ip_HygienizationHysteresis` | Banda muerta de mantenimiento durante el ciclo. D2 oscila entre P70 ± P71/2 durante el tiempo P72. | Pocas activaciones de la bomba de calor durante el ciclo → mayor estabilidad térmica. | D2 sube y baja continuamente durante el ciclo → la bomba de calor cicla innecesariamente. |
| **P72** | L1 | `ip_HygienizationHoldTime` | Tiempo de mantenimiento de D2 a temperatura P70. La normativa exige tiempo suficiente para garantizar la higienización en todo el volumen. | Mayor duración del ciclo → consumo adicional. | Tiempo insuficiente → no se garantiza la higienización completa del volumen de D2. Mín normativo: 30 min. |
| **P73** | L1 | `ip_HygienizationFlushTime` | Tiempo de purgado por apartamento: tiempo que permanece abierta la válvula de cada apartamento para que el agua caliente recorra todo el ramal hasta el grifo. | Mayor consumo de energía y agua. | El agua caliente no llega al grifo del apartamento → parte de la red queda sin higienizar. |
| **P74** | L1 | `ip_HygienizationDayOfWeek` | Día de la semana del ciclo automático (1=Lun…7=Dom). Elegir día de menor ocupación para minimizar molestias. | — | — |
| **P75** | L1 | `ip_HygienizationHour` | Hora de inicio del ciclo automático. Elegir madrugada para no afectar al usuario. | Hora demasiado tardía → el ciclo puede solaparse con el uso matinal. Rango recomendado: 2–4 h. | Hora demasiado temprana → poco tiempo para que D2 se recargue antes del uso matinal. |
| **P76** | CFG | `ip_D1HygienizationMaxDays` | Días máximos sin que TT2 (D1 fondo) alcance la temperatura P77. Si se supera, el sistema fuerza un arranque de P1 para mezclar el volumen de D1. Protección antilegionela en D1. | D1 puede acumular riesgo microbiológico durante demasiado tiempo sin tratamiento. | El sistema fuerza arranques de P1 demasiado frecuentes sin necesidad real. |
| **P77** | CFG | `ip_D1HygienizationMinTemp` | T mínima que debe alcanzar TT2 (D1 fondo) para considerar D1 higienizado. Si no se alcanza en P76 días, se fuerza la mezcla del volumen. | Con temperaturas muy altas el criterio se cumple solo en días muy soleados → P1 forzado frecuente en invierno. | Temperatura demasiado baja → criterio de higienización insuficiente para D1. |

---

## Bloque P80 · Prioridades bomba de calor (CFG)

| Código | Nombre programa | Función | Si demasiado alto | Si demasiado bajo |
|---|---|---|---|---|
| **P80** | `ip_BDCPriority` | Orden de prioridad del primario de la bomba de calor: 0 = ACS > climatización > piscina / 1 = ACS > piscina > climatización. El perfil 1 es útil en primavera/otoño cuando la piscina tiene más prioridad que el confort interior. | — | — |

---

## Bloque P90–P97 · Sistema, Modbus y HMI (CFG)

| Código | Nombre programa | Función | Si demasiado alto | Si demasiado bajo |
|---|---|---|---|---|
| **P90** | `ip_ModbusSlaveAddr` | Dirección Modbus del controlador solar en el bus RS485. Debe ser única en el bus. | Conflicto de direcciones si hay otro esclavo con la misma. | — |
| **P91** | `ip_ModbusBaudrate` | Velocidad de comunicación RS485: 0=9600 / 1=19200 / 2=38400 bps. Debe ser igual en ambos controladores. | Velocidad incompatible con el otro controlador → sin comunicación. | Ídem. |
| **P92** | `ip_ModbusPollPeriod` | Cada cuántos segundos el controlador principal interroga al controlador solar. | Las temperaturas solares llegan tarde al controlador principal → reacciones tardías. | Polling muy frecuente → carga innecesaria en el bus RS485. |
| **P93** | `ip_ModbusTimeout` | Tiempo sin respuesta tras el cual se activa la alarma de comunicación. | El sistema tarda demasiado en detectar una pérdida de comunicación. | Falsas alarmas de comunicación por latencias normales del bus. Mín > P92 × 2. |
| **P94** | `ip_PIN_L1` | PIN de acceso al nivel L1 (operador). | — | — |
| **P95** | `ip_PIN_CFG` | PIN de acceso al nivel CFG (técnico). | — | — |
| **P96** | `ip_PIN_MaxAttempts` | Intentos fallidos antes del bloqueo temporal del HMI. | Fácil de forzar por ensayo y error. | Bloqueo por un simple error de tecleo. |
| **P97** | `ip_SessionTimeout` | Minutos de inactividad tras los cuales se cierra la sesión de acceso. | Un operador olvida cerrar sesión → acceso no autorizado prolongado. | Sesión cierra demasiado rápido → incómodo en operaciones largas. |

---

## Offsets de sondas OS00–OS13 (CFG)

`valor_corregido = valor_medido + offset`  
Ajustar durante puesta en marcha comparando con termómetro de referencia calibrado.

| Código | Nombre programa | Sonda | Si positivo | Si negativo |
|---|---|---|---|---|
| **OS00** | `ip_Offset_TT1` | Salida colector | La sonda mide por debajo de la real | La sonda mide por encima de la real |
| **OS01** | `ip_Offset_TT2` | D1 fondo | Ídem | Ídem |
| **OS02** | `ip_Offset_TT3` | D1 cabeza | Ídem | Ídem |
| **OS03** | `ip_Offset_TT4` | D2 fondo | Ídem | Ídem |
| **OS04** | `ip_Offset_TT5` | D2 cabeza | Ídem | Ídem |
| **OS05** | `ip_Offset_TT6` | D3 cabeza | Ídem | Ídem |
| **OS06** | `ip_Offset_TT7` | D3 fondo | Ídem | Ídem |
| **OS07** | `ip_Offset_TT8` | Ida primario bomba calor | Ídem | Ídem |
| **OS08** | `ip_Offset_TT9` | Retorno primario bomba calor | Ídem | Ídem |
| **OS09** | `ip_Offset_TT10` | Ida recuperador HTR | Ídem | Ídem |
| **OS10** | `ip_Offset_TT11` | Piscina | Ídem | Ídem |
| **OS11** | `ip_Offset_TT12` | Exterior | Ídem | Ídem |
| **OS12** | `ip_Offset_TT13` | Retorno fancoils | Ídem | Ídem |
| **OS13** | `ip_Offset_TT14` | Mini bucle intermedio | Ídem | Ídem |

---

## Resumen

| Bloque | Subsistema | Nivel | Nº |
|---|---|---|---|
| P00–P06 | Límites de equipo | CFG | 7 |
| P10–P19 | Solar | L1 | 10 |
| P20–P21 | Solar PI | CFG | 2 |
| P30–P35 | ACS | L1 | 6 |
| P40–P46 | ACS apartamentos | L1 | 7 |
| P50–P53 | Climatización | L1 | 4 |
| P60–P64 | Piscina | L1 | 5 |
| P70–P77 | Higienización | L1/CFG | 8 |
| P80 | Prioridades BDC | CFG | 1 |
| P90–P97 | Sistema/Modbus/HMI | CFG | 8 |
| OS00–OS13 | Offsets sondas | CFG | 14 |
| **Total** | | | **72** |

---

*Fusela House · Instalación térmica integrada · Jerez de la Frontera*
