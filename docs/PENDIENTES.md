# Pendientes — Casa Fosela

Lista viva. Actualizar al cierre de cada sesión.

---

## 🎯 PRÓXIMA SESIÓN — Desarrollo de los Bloques de Función (FBs)

**Objetivo:** escribir/completar los FBs del control en `control/*.st` (texto, fuente de verdad — ver M09 §toolchain). El hardware y la hidráulica están cerrados; toca el software.

**Antes de tocar código, releer:**
- `docs/README.md` (mapa general).
- `docs/modulos/M09_control.md` (control, toolchain, taxonomía SP/P/HY/OF/ST, hardware Schneider, **patrón `PumpProfile`**).
- `docs/modulos/M12_mapa_es.md` (censo de E/S y bornes).
- `docs/nomenclatura.md` (convención de variables).
- El módulo del FB concreto que se vaya a escribir (M02/M04/M05/M06).

**Orden propuesto (de menos a más dependencias):**

1. **`FB_Pump` refactorizado con `PumpProfile`** (M09 §FB_Pump parametrizado). Trabaja con velocidad lógica 0-100% y traduce a duty cycle físico aplicando el perfil. Dos perfiles iniciales: `PROFILE_GRUNDFOS_ALPHA_SOLAR` (P-SOL) y `PROFILE_GRUNDFOS_UPM3_HYBRID` (P-ACS). Base de las dos bombas modulantes (P-SOL, P-ACS).

2. **`FB_Solar`** (M02). Ya escrito en versión antigua — revisar y adaptar al nuevo `FB_Pump`. Estados SLEEP/SAMPLING/RUNNING/DISSIPATING/OVERHEAT. Cuidado con la **lógica invertida PWM** (encapsular en `PWMSolarInvert()`).

3. **`FB_DHW_Station`** (M04). Ya escrito — revisar y adaptar al nuevo `FB_Pump`. P-ACS modulada por PWM (UPM3 Hybrid) para temperatura de ACS estable al paso.

4. **`FB_ClimateReversible`** (M05). **Reescribir** a la topología actual: 2 V3V (V3V1 impulsión, V3V2 retorno) + P1 trasvase + buffer ~50 L (incluido con la BC). Modo invierno/verano por V3V estacional. P2 (UPM3 Auto, sin PWM) gobernada por presión constante + arranque por Zelio (M10).

5. **`FB_PoolReversible`** (M06). Selección de fuente (SOL/BC), P-POOL, límite `P62_PoolMaxTemp`, integración con la disipación solar.

6. **`FB_PoolFiltration`** (M06). Ciclos propios de filtrado (calendario/horas/día) + entrada de **forzado** desde HVAC + salida de **confirmación de marcha** (necesaria para el enclavamiento de disipación, M02).

7. **`FB_BDC_Arbiter`** (M09). **Reescribir**: simultaneidad ACS+clima condicionada por T del tándem (HY intrínseca, no margen artificial). Clima nunca sacrificado por ACS; único sacrificable: piscina.

8. **Integración** de todos los FBs en `PLC_PRG` con wiring de I/O reales (mapeo señal↔borne, ver M12).

---

## ⚠️ PRINCIPIO RECTOR — OPERACIÓN MANUAL SIN PLC (Cadenas de Seguridad)

**Todo el diseño basado en PLC debe poder degradarse a operación manual.** Cada función crítica necesita su cadena de seguridad **pasiva** (klixon bimetálico, muelle, contacto mecánico) que opere con el PLC averiado. Ver M10.

**Criterio rector:** nada de electrónica en la capa de seguridad. Primero corte mecánico directo; el relé solo si es inevitable; la electrónica nunca.

Funciones a cubrir (cada una con esquema cableado pendiente):

- [ ] **Continuidad de ACS:** V3V de apartamentos caen por muelle a agua de red → termos eléctricos siguen funcionando.
- [ ] **Continuidad de agua técnica:** termostato pasivo gobernando la BC en modo local.
- [ ] **Disipación solar sin PLC:** Z1/Z2/TK1 cortan P-SOL y cierran persianas por hardware.
- [ ] **Persianas:** klixon NC rearme manual en serie con la alimentación (Opción A, M10). Pendiente elegir actuador fail-safe muelle vs motor reversible.
- [ ] **Corte térmico ACS:** klixon NC en serie con P-ACS.
- [ ] **Climatización (P2):** demanda agregada del Zelio arranca P2 por hardware aunque el M241 esté caído (M10). P2 sin PWM (presión constante autónoma) precisamente para esto.
- [ ] **Conmutadores manual/0/auto por actuador.**
- [ ] **Tabla de posiciones de fallo** por actuador (V3V apartamentos → red; cortes D2 → cerrados; persianas → cerradas; etc.).

> El PLC OPTIMIZA; las Cadenas de Seguridad GARANTIZAN.

---

## 📦 Estado actual del proyecto (cerrado)

**Hardware Schneider:** TM241CE24T + 2× TM3TI8T (PT1000) + TM3DQ16T (~440 €).

**Bombas asignadas (cuadro cerrado, ver M08):** todas DN25 (G1½", racor Rp1"), longitud 130 mm salvo P1 (180).

| ID | Modelo | Control | Long. | Estado |
|---|---|---|---|---|
| **P-SOL** | Grundfos Alpha Solar 25-75 130 | PWM (perfil solar, M02) | 130 | en compra (Wallapop Paco, 85 €) |
| **P-ACS** | Grundfos UPM3 Hybrid 25-70 130 (ACA) | PWM (M04) | 130 | compra propuesta (Wallapop Daniel, 150 €; confirmar cables) |
| **P1** | Stiebel Eltron UP 25/7.5 PCV (8,4 m) | on/off | 180 | compra propuesta (eBay, oferta 135 €) |
| **P2** | Grundfos UPM3 Auto 25-70 130 (ZZZ) | presión constante, sin PWM (arranque Zelio) | 130 | compra propuesta (Wallapop Daniel m. Calahorra, 100 €) |
| **P-POOL** | Grundfos ALPHA1 25-40 130 | on/off | 130 | ✅ comprada (59 €) |
| **Repuesto** | Grundfos ALPHA 25-40 130 | on/off | 130 | ✅ comprada (60 €) |

- **P-ACS y P2** comparten cuerpo (UPM3 25-70 130) → repuesto común; distinto sufijo (ACA Hybrid con PWM para ACS / ZZZ Auto sin PWM para que el Zelio arranque P2).
- **Gasto total bombas:** ~589 € sin portes (119 € ya comprado + 470 € por comprar).

**Buffer de inercia clima:** **~50 L, incluido con la BC** (no se aprovisiona aparte).

**Depuradora piscina:** DepuraPool Indoor, filtro 600 + selectora Star manual + bomba 0,75 kW + bypass, **sin cuadro** (~1.180 €). Gobernada por PLC vía contactor + DI confirmación de marcha.

**Colector PVC HX piscina:** dos HX de titanio en paralelo entre sí (cada rama con llave + tuercas de enlace), el conjunto en serie con la filtración vía bypass.

**Vasos de expansión:** tres a montar — solar 25 L (específico HNBR para glicol), clima 18 L (calefacción EPDM), tándem 50 L (Ibaiondo 50 SMR P, reajustar precarga). + integrado BC para su propio circuito en verano. Buffer clima ~50 L viene con la BC.

**Instrumentación local (M14):** manómetros y termómetros en puntos clave + protocolo de chequeo periódico. Frontera clara con el PLC (al PLC solo lo imprescindible para el control).

**Cadenas de seguridad (M10):** principio rector "nada de electrónica" fijado. Dispositivo autónomo de persianas por klixon bimetálico mecánico diseñado (Opción A muelle / Opción B motor reversible con klixon SPDT). Resiliencia clima→P2 vía Zelio cerrada. Pendiente bajar a esquema el resto.

---

## 🛒 Pendientes de compra

- [ ] **P-SOL** (Grundfos Alpha Solar 25-75 130) — en compra, Wallapop Paco 85 €.
- [ ] **P-ACS** (Grundfos UPM3 Hybrid 25-70 130 ACA) — Wallapop Daniel 150 €; **confirmar que incluye cables** (alimentación + señal PWM) y hacer oferta.
- [ ] **P1** (Stiebel Eltron UP 25/7.5 PCV 180) — eBay, oferta 135 € pendiente de aceptar.
- [ ] **P2** (Grundfos UPM3 Auto 25-70 130 ZZZ) — Wallapop Daniel m. Calahorra 100 €; hacer oferta.
- [ ] **Cables Grundfos PWM** (si no vienen con P-ACS): Superseal (potencia) + Mini Superseal 3 vías (señal PWM).
- [ ] **CPU TM241CE24T** + **TM3DQ16T** (nuevos).
- [ ] **Confirmar 2ª TM3TI8T usada** (oferta eBay alemán enviada).
- [ ] **DepuraPool Indoor sin cuadro:** confirmar a fabricante el bypass para DOS HX.
- [ ] **Sondas PT1000** (~9 imprescindibles + spare) con vainas inox: cortas ~50 mm tubería / largas ~200 mm depósito (M14).
- [ ] **Klixon bimetálico** rearme manual para persianas y corte térmico ACS.
- [ ] **Vasos de expansión:** solar 25 L + clima 18 L (nuevos). Tándem ya resuelto (Ibaiondo 50 SMR P); buffer viene con la BC.
- [ ] **Colector latón** Wallapop (cuerpo 1" / salidas 3/4") — confirmar y comprar.
- [ ] **Caudalímetro YF-B6** (factor K en pendiente).

---

## 🔧 Pendientes de montaje / detalles fontanería (M08 / manual_montaje)

- [ ] **Ubicación de sondas PT1000** en cada circuito (vainas, alturas).
- [ ] **Purgadores y llaves de llenado/vaciado** por circuito.
- [ ] **Manguitos dieléctricos** en cada boca de depósito.
- [ ] **Diámetros y roscas concretos** por tramo en cada módulo.
- [ ] **Antirretornos** por rama (criterio documentado, ubicación exacta pendiente).
- [ ] **Plano dimensional del DB2 450**: confirmar bocas reales para asignar a cada función.
- [ ] **Longitud de bombas en el montaje:** todas a 130 salvo P1 (180). No intercambiar a ciegas P1 con las demás sin adaptador.

---

## 🧠 Decisiones de software pendientes

- [ ] **Verificar nivel de tensión PWM Grundfos** (probablemente 5V) con multímetro al recibir la bomba, para ajustar el divisor. Ambas modulantes son Grundfos (Alpha Solar y UPM3 Hybrid) → mismo orden de tensión PWM, un solo divisor de referencia.
- [ ] **Migración de nomenclatura** a SP/P/HY/OF/ST: ¿completa o incremental?
- [ ] Crear tabla **HYxx** (histéresis por transición del tándem).
- [ ] Crear tabla **OFxx** (offsets de calibración por sonda).
- [ ] Renombrar enums `E_*` → `ST_*` (legibles en HMI web).
- [ ] Definir el registro `{default, min, max, unidad}` de cada parámetro.
- [ ] **Factor K caudalímetro** YF-B6 → actualizar `P36_DHWFlowMeterK`.

---

## 🏗️ Integración con la BC (pendiente del modelo concreto)

- [ ] **Leer manual de la BC** elegida (esquemas hidráulicos, gestión de ACS, V3V).
- [ ] Configurarla como **generador de agua técnica puro**, sin que espere demanda de ACS interna.
- [ ] Mapear regletero (demanda, V3V externa, habilitación, verano/invierno).
- [ ] **Modbus RTU** con la BC desde el PLC (estado, consignas) — DI10 alarma BC se libera si va por bus.
- [ ] Verificar **potencia BC** para ACS medio + clima sostenidos en hora punta.
- [ ] **Vaso integrado BC**: verificar litraje para su circuito en verano.
- [ ] **Buffer ~50 L incluido con la BC:** confirmar volumen real al elegir modelo (valida el dimensionado del circuito de clima).

---

## 🌐 Supervisión remota (fase posterior, M11)

- [ ] Arquitectura: M241 cliente MQTT/HTTP → servidor externo. Solo conexiones salientes.
- [ ] Plataforma: IoT gestionada vs VPS + broker MQTT propio.
- [ ] HMI gráfico = web server del M241 (M09/M11), sin pantallas físicas; en el cuadro solo panel de mando manual (M13).

---

## 📄 Documentación pendiente

- [ ] **BOM por módulo** (lo hará el usuario).
- [ ] **Esquema de principio final** dibujado en QElectroTech (lo hará el usuario).
- [ ] **Cuadro eléctrico M13:** esquema y calibres — **al final**, cuando todos los elementos estén definidos.
- [ ] **Hoja de ronda M14:** rangos esperados (a rellenar tras puesta en marcha).
- [ ] **Esquema eléctrico de las cadenas de seguridad** (M10) con klixones, conmutadores y posiciones de fallo.

---

## 📜 Código legacy

- El código ST de la arquitectura antigua (dos controladores Eliwell, FREE Studio: maestro `Evolution` + esclavo solar `Smart`, Modbus) queda archivado en la rama **`legacy-eliwell`** (carpetas `control/free_evolution` y `control/free_smart`). **No es el objetivo**; sirve como referencia de lógica (estados solar, disipación, arbitraje). El desarrollo actual es para **un único M241** en `control/{types,globals,lib,fb,pou}`.
