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

1. **`FB_Pump` refactorizado con `PumpProfile`** (M09 §FB_Pump parametrizado). Trabaja con velocidad lógica 0-100% y traduce a duty cycle físico aplicando el perfil. Dos perfiles iniciales: `PROFILE_GRUNDFOS_ALPHA_SOLAR` y `PROFILE_WILO_IPWM3_SOLAR`. Base de las dos bombas modulantes (P-SOL, P-ACS).

2. **`FB_Solar`** (M02). Ya escrito en versión antigua — revisar y adaptar al nuevo `FB_Pump`. Estados SLEEP/SAMPLING/RUNNING/DISSIPATING/OVERHEAT. Cuidado con la **lógica invertida PWM** (encapsular en `PWMSolarInvert()`).

3. **`FB_DHW_Station`** (M04). Ya escrito — revisar y adaptar al nuevo `FB_Pump`.

4. **`FB_ClimateReversible`** (M05). **Reescribir** a la topología actual: 2 V3V (V3V1 impulsión, V3V2 retorno) + P1 trasvase + buffer 150 L. Modo invierno/verano por V3V estacional.

5. **`FB_PoolReversible`** (M06). Selección de fuente (SOL/BC), P-POOL, límite `P62_PoolMaxTemp`, integración con la disipación solar.

6. **`FB_PoolFiltration`** (M06). Ciclos propios de filtrado (calendario/horas/día) + entrada de **forzado** desde HVAC + salida de **confirmación de marcha** (necesaria para el enclavamiento de disipación, M02).

7. **`FB_BDC_Arbiter`** (M09). **Reescribir**: simultaneidad ACS+clima condicionada por T del tándem (HY intrínseca, no margen artificial). Clima nunca sacrificado por ACS; único sacrificable: piscina.

8. **Integración** de todos los FBs en `PLC_PRG_Evolution` con wiring de I/O reales (mapeo señal↔borne, ver M12).

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
- [ ] **Conmutadores manual/0/auto por actuador.**
- [ ] **Tabla de posiciones de fallo** por actuador (V3V apartamentos → red; cortes D2 → cerrados; persianas → cerradas; etc.).

> El PLC OPTIMIZA; las Cadenas de Seguridad GARANTIZAN.

---

## 📦 Estado actual del proyecto (cerrado)

**Hardware Schneider:** TM241CE24T + 2× TM3TI8T (PT1000) + TM3DQ16T (~440 €).

**Bombas asignadas:**
- **P2** (fancoils): Grundfos ALPHA2 25-40 180 (modulante autoadaptativa por presión).
- **P-POOL** (primario HX piscina): Grundfos ALPHA1 25-40 130 (la de Wallapop, 3 velocidades fijas).
- **P1** (trasvase D2→buffer): **pendiente** — Grundfos UPS 25-80 / Wilo Star-RS 25/8 (6-8 m por doble serpentín en serie, ~2.400 L/h).
- **P-SOL** (lazo solar): **pendiente** — Grundfos Alpha Solar 25-75 130 (95 € Wallapop) o Wilo iPWM3. Ambas PWM perfil solar invertido (failsafe).
- **P-ACS** (primario ACS): **pendiente** — variante PWM, agua técnica.

**Depuradora piscina:** DepuraPool Indoor, filtro 600 + selectora Star manual + bomba 0,75 kW + bypass, **sin cuadro** (~1.180 €). Gobernada por PLC vía contactor + DI confirmación de marcha.

**Colector PVC HX piscina:** dos HX de titanio en paralelo entre sí (cada rama con llave + tuercas de enlace), el conjunto en serie con la filtración vía bypass.

**Vasos de expansión:** tres a montar — solar 25 L (específico HNBR para glicol), clima 18 L (calefacción EPDM), tándem 50 L (calefacción). + integrado BC para su propio circuito en verano.

**Instrumentación local (M14):** manómetros y termómetros en puntos clave + protocolo de chequeo periódico. Frontera clara con el PLC (al PLC solo lo imprescindible para el control).

**Cadenas de seguridad (M10):** principio rector "nada de electrónica" fijado. Dispositivo autónomo de persianas por klixon bimetálico mecánico diseñado (Opción A muelle / Opción B motor reversible con klixon SPDT). Pendiente bajar a esquema el resto.

---

## 🛒 Pendientes de compra

- [ ] **Bomba P1** (Grundfos UPS 25-80 o Wilo Star-RS 25/8).
- [ ] **Bomba P-SOL** (decidir Grundfos Alpha Solar 25-75 130 a 95 € o Wilo iPWM3).
- [ ] **Bomba P-ACS** (variante PWM).
- [ ] **Cables Grundfos** (si Alpha Solar): Superseal (potencia) + Mini Superseal 3 vías (señal PWM).
- [ ] **CPU TM241CE24T** + **TM3DQ16T** (nuevos).
- [ ] **Confirmar 2ª TM3TI8T usada** (oferta eBay alemán enviada).
- [ ] **DepuraPool Indoor sin cuadro:** confirmar a fabricante el bypass para DOS HX.
- [ ] **Sondas PT1000** (~9 imprescindibles + spare) con vainas inox: cortas ~50 mm tubería / largas ~200 mm depósito (M14).
- [ ] **Klixon bimetálico** rearme manual para persianas y corte térmico ACS.
- [ ] **Tres vasos de expansión** (litrajes en M08).
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

---

## 🧠 Decisiones de software pendientes

- [ ] **Verificar nivel de tensión PWM Grundfos** (probablemente 5V) con multímetro al recibir la bomba, para ajustar el divisor (vs 9,6V Wilo).
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

---

## 🌐 Supervisión remota (fase posterior, M11)

- [ ] Arquitectura: M241 cliente MQTT/HTTP → servidor externo. Solo conexiones salientes.
- [ ] Plataforma: IoT gestionada vs VPS + broker MQTT propio.

---

## 📄 Documentación pendiente

- [ ] **BOM por módulo** (lo hará el usuario).
- [ ] **Esquema de principio final** dibujado en QElectroTech (lo hará el usuario).
- [ ] **Cuadro eléctrico M13:** esquema y calibres — **al final**, cuando todos los elementos estén definidos.
- [ ] **Hoja de ronda M14:** rangos esperados (a rellenar tras puesta en marcha).
- [ ] **Esquema eléctrico de las cadenas de seguridad** (M10) con klixones, conmutadores y posiciones de fallo.
