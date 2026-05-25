# MEMORIA TÉCNICA — BORRADOR
## Instalación térmica integrada · Aerotermia monobloc + solar térmico
### Vivienda principal con 4 apartamentos · Piscina · Jerez de la Frontera

> **Estado:** borrador de trabajo. Ver bitácora `bitacora/bitacora_proyecto_fosela.md` para el registro de decisiones.
> **Rama:** `main` — arquitectura BC monobloc genérica sin HTR.

---

## 1. OBJETO Y ALCANCE

La presente memoria describe el sistema integrado de climatización hidrónica, producción de ACS instantánea y climatización de piscina para una vivienda principal de 220 m² con cuatro apartamentos turísticos anexos en Jerez de la Frontera (zona climática B4, zona solar V).

El sistema cubre cuatro demandas térmicas:

- **ACS instantánea** para un máximo de 16 ocupantes simultáneos (336 L/día a 60 °C, CTE HE-4), producida al paso mediante estación de agua fresca sin acumulación de agua potable.
- **Calefacción y refrigeración** de la vivienda principal mediante 13 fancoils.
- **ACS precalentada** para los cuatro apartamentos, que conservan sus termos eléctricos existentes.
- **Climatización de piscina** (8×4 m, ~40 m³): calentamiento en primavera y otoño, disipación pasiva en verano.

---

## 2. CONDICIONANTES

- **Titularidad única**: no aplica la obligación de individualización de consumos (RITE IT 1.2.4.4).
- **Uso turístico de los apartamentos**: obligaciones higiénico-sanitarias del RD 865/2003.
- **Depósitos adquiridos**: dos Tusol DB2 450 vitrificados (acero vitrificado SMALGLASS). No aptos para almacenamiento de agua potable en circuito abierto; se usan como reservorio de **agua técnica** en circuito cerrado.
- **BC monobloc**: equipo con módulo hidráulico integrado en la unidad exterior. Conexión al sistema exclusivamente hidráulica. Sin tuberías frigoríficas al interior.

---

## 3. NORMATIVA

| Referencia | Ámbito |
|---|---|
| RD 1027/2007 (RITE) y modificaciones | Diseño y seguridad de la instalación térmica |
| CTE DB-HE (HE-0, HE-1, HE-4) | Eficiencia energética y aportación solar mínima |
| CTE DB-HS-4 | Suministro de agua y protección de la red potable |
| RD 865/2003 + UNE 100030 | Prevención de legionelosis |
| UNE-EN 378-1/2/3 | Sistemas frigoríficos con R290 |
| UNE-EN 1717 | Protección frente a contaminación de agua potable |
| UNE-EN 12831 | Cálculo de cargas térmicas |
| IEC 61131-3 | Programación de controladores (Structured Text) |

---

## 4. DATOS DE PARTIDA

| Parámetro | Valor |
|---|---|
| Superficie vivienda principal | 220 m² |
| Ocupación | 12-16 personas |
| Potencia pico refrigeración | 12-17 kW |
| Potencia pico calefacción | 12 kW |
| Demanda ACS | 336 L/día a 60 °C (17,6 kWh/día) |
| Caudal punta ACS instantánea | 15-20 L/min (40-50 kW) |
| Producción solar invierno | 12-16 kWh/día |
| Producción solar verano | 38-45 kWh/día |
| Piscina | 8×4 m, ~40 m³ |
| Clima | B4 — mínimas 2-4 °C, veranos >40 °C |

---

## 5. ARQUITECTURA GENERAL

Dos productores cargan un reservorio de energía técnica. Del reservorio se extrae el calor para cuatro consumos. El agua potable nunca se almacena: el ACS se produce al paso en una estación de agua fresca.

```
LADO SOLAR                          LADO AEROTÉRMICO
─────────────────────────────────   ──────────────────────────────────────────
Captadores 8 m²                     BC monobloc R290
Bomba PWM2 (ΔT constante)           Módulo hidráulico integrado
     │                                   │
     │  serpentines en serie             │  2× V3V en cascada:
     ▼  (superior → inferior)            ├──► Reservorio (D2 serpentines en serie)
  Dep. SOLAR (D1)                        ├──► Buffer D3 → 13 fancoils
     │                                   └──► HX titanio BC → piscina
     └──► HX titanio solar → piscina

RESERVORIO (agua técnica):   D1 ──serie──► D2  (~800 L total)
ACS INSTANTÁNEA:  Reservorio ──► Estación agua fresca (HX inox 316L) ──► ACS
APARTAMENTOS:  ACS precalentada ──► V3V por apartamento ──► termo eléctrico existente
```

### Principio de funcionamiento del reservorio

El retorno frío de los consumos entra por el fondo de D1 (depósito solar), se precalienta mediante el serpentín solar, pasa por la cabeza de D1 al fondo de D2 (depósito aerotérmico) donde la BC lo remata, y sale caliente por la cabeza de D2 hacia los consumos.

Los serpentines de ambos depósitos quedan libres y dedicados exclusivamente a sus productores. En cada depósito los dos serpentines (superior e inferior) se conectan en serie, duplicando la superficie de intercambio (~3,2 m² por depósito).

---

## 6. FUENTES DE ENERGÍA

### 6.1 Solar térmico

- **Campo**: 4 colectores planos, 2 m² cada uno, **8 m² totales**. Solar Keymark obligatorio.
- **Fluido**: propilenglicol al **15 %** en agua. Protección hasta ~-8 °C (mínimas históricas Jerez: -2 °C). Cp ≈ 4,05 kJ/kg·K. Sin válvula de llenado automático desde red — llenado manual con premezcla verificada con refractómetro.
- **Protección frente a sobrecalentamiento**: persianas motorizadas sobre los captadores, con posición manual como último recurso. El PLC cierra las persianas cuando el reservorio está saturado. El glicol y el vaso de expansión actúan como respaldo pasivo.
- **Bomba PWM2**: Wilo modulante, ajusta velocidad para mantener ΔT constante entre ida y retorno del circuito de glicol. Con alta radiación aumenta el caudal; con baja lo reduce. Optimiza la captación (el captador trabaja a la temperatura más baja posible) y permite el cálculo calorimétrico del aporte solar.
- **Calorímetro solar**: Q [W] = ṁ [kg/s] × Cp [J/kg·K] × ΔT [K]. Cp y densidad configurables en el controlador según composición y concentración del anticongelante. Dos sondas en el circuito de glicol (ida y retorno).

### 6.2 Bomba de calor aerotérmica monobloc

- Refrigerante R290 (GWP 3), conformidad EN 378.
- Módulo hidráulico integrado en la unidad exterior. Entrega directamente agua técnica caliente o fría. Sin tuberías frigoríficas al interior.
- Conexión al sistema exclusivamente hidráulica y de comunicación.
- **Punto a verificar**: suficiencia de la circuladora integrada para vencer la pérdida de carga del circuito de carga del reservorio (~150 mbar en dos serpentines en serie más distribución y válvulas). Si no llega: circuladora de apoyo o desacople por buffer.

---

## 7. RESERVORIO DE ENERGÍA — DOS ACUMULADORES EN SERIE

Dos acumuladores Tusol DB2 450 (acero vitrificado SMALGLASS, ~406 L cada uno, doble serpentín) forman un reservorio de **~800 L de agua técnica**.

No almacenan agua potable. El cuerpo de cada depósito contiene agua técnica en circuito cerrado, lo que elimina prácticamente el riesgo de legionela en la acumulación y permite usar el acero vitrificado sin problema (su uso correcto).

| Depósito | Productor | Serpentines |
|---|---|---|
| D1 — solar | Solar (glicol 15 %) | Superior + inferior en serie (~3,2 m²) |
| D2 — aerotérmico | BC monobloc | Superior + inferior en serie (~3,2 m²) |

El productor entra por el serpentín superior y sale por el inferior: zona caliente arriba, fluido devuelto lo más frío posible → mejor rendimiento del captador y mejor COP de la BC.

**Tomas para el lazo de agua técnica**: bocas del ánodo (parte alta) y la resistencia (lateral) de cada depósito para el circuito de extracción, las de mayor diámetro del cuerpo. Las bocas AFS (fondo) y ACS (cabeza) quedan para el enlace serie entre depósitos: fondo de D2 → cabeza de D1.

### 7.1 Conexión de los circuitos de extracción — criterio de estratificación

El tándem D1+D2 se comporta como un único depósito de inercia estratificado de ~812 L. Para preservar la estratificación —que es lo que da valor al volumen acumulado— todo circuito que extrae energía debe **tomar de la zona más alta (más caliente) y devolver a la zona más baja (más fría)**. Tomas o retornos a media altura mezclan el depósito y destruyen la estratificación.

**Jerarquía de extracción por grado de temperatura:**

| Consumidor | Toma (impulsión) | Grado requerido | Retorno |
|---|---|---|---|
| DHW (PWM1) | Punto más alto — cabeza de D2 (ánodo) | El más alto (~65°C) | Fondo del tándem (D1) |
| Fancoils (P3) | Zona alta, por debajo de la toma DHW | Medio (~45°C) | Fondo del tándem (D1) |

El DHW (circuladora PWM1 de la estación de producción) toma del punto absolutamente más alto porque es el consumidor de mayor grado. Los fancoils (circuladora P3), que trabajan a temperatura más baja, toman **por debajo** de la toma del DHW: así no degradan la cabeza ni le roban el agua más caliente al DHW. Ambos retornos van lo más abajo posible (fondo de D1), donde el agua fría favorece tanto el rendimiento del captador solar como el COP de la BC durante la carga.

> La asignación exacta de cada boca (ánodo, resistencia, AFS, ACS) a su función definitiva requiere cotejar el plano dimensional del DB2 450 para confirmar la altura real de cada toma.

---

## 8. PRODUCCIÓN DE ACS INSTANTÁNEA — ESTACIÓN DE AGUA FRESCA

### 8.1 Justificación de la solución

La producción de ACS al paso mediante estación de agua fresca se adopta por la concurrencia de varios factores que hacen de esta solución la única técnicamente correcta para esta instalación.

**Condicionante material de los acumuladores adquiridos.** Los dos depósitos Tusol DB2 450 ya adquiridos son de acero vitrificado SMALGLASS. Este material está diseñado para circuito cerrado de agua técnica con química estable y baja renovación de oxígeno. Su uso como acumulador de agua potable en circuito abierto — con agua de red, oxígeno disuelto y variaciones de mineralización — compromete la integridad del esmalte a medio plazo. La estación al paso resuelve este conflicto desde la raíz: los depósitos funcionan como reservorio de agua técnica en circuito cerrado, que es exactamente el uso para el que están diseñados, y el agua potable nunca entra en ellos.

**Eliminación del riesgo de legionela en la acumulación.** El RD 865/2003 regula la proliferación de *Legionella pneumophila* en sistemas de acumulación de agua caliente sanitaria, que prolifera preferentemente en agua estancada entre 25-50°C. Al no existir acumulación de agua potable, ese vector desaparece. No se requieren ciclos de precalentamientoón en los acumuladores, ni tratamientos biocidas, ni auditorías de temperatura en depósitos de potable. El ACS se produce en el instante de la demanda y no reside en ningún volumen caliente.

**Potencia de producción libre.** Con producción por serpentines internos, la superficie del intercambiador interior del depósito limita el pico de potencia transferible. Con una placa exterior dimensionada libremente a 40-50 kW, la estación puede servir 15-20 L/min simultáneamente — caudal suficiente para varias duchas concurrentes — sin cuello de botella. La energía disponible en el reservorio de 800 L a 65°C (~47 kWh almacenados) supera con holgura la demanda diaria estimada de 17,6 kWh.

**Temperatura de reservorio sin restricción sanitaria en el depósito.** Con agua potable acumulada, la temperatura de distribución queda limitada a 60°C en el depósito para evitar riesgos de escaldadura. Con agua técnica, el reservorio puede trabajar a 70-80°C sin restricción, aumentando la densidad energética almacenada y el margen disponible antes de que la temperatura caiga bajo el umbral de confort en ACS.

**Respaldo garantizado sin corte de servicio.** Un eventual fallo de la estación no interrumpe el suministro de ACS. Los cuatro apartamentos conservan sus termos eléctricos existentes, conectados a agua de red mediante válvulas V3V con retorno por muelle. Ante cualquier fallo de tensión o componente, las V3V conmutan automáticamente a agua de red y los termos producen ACS por resistencia eléctrica con total independencia de la estación al paso. La estación es una mejora sobre un sistema que ya funciona de forma autónoma, no un sustituto sin respaldo.

**Separación total entre circuitos conforme a EN 1717.** El agua potable solo toca el intercambiador de placas de AISI 316L — material certificado para agua de consumo humano — y en ningún momento entra en contacto con el agua técnica del reservorio. La barrera es física y permanente.

### 8.2 Construcción de la estación — elementos sueltos

La estación se construye a partir de componentes individuales seleccionados y ensamblados en obra, sin recurrir a una estación comercial prefabricada. Esta decisión responde a criterios de coste, flexibilidad de dimensionado y acceso a repuestos estándar de mercado.

La estación comprende los siguientes elementos:

**Intercambiador de placas AISI 316L** — dimensionado a 40-50 kW con la temperatura de reservorio prevista (~65°C en primario, agua de red ~15°C en secundario, caudal secundario hasta 20 L/min). Fabricantes de referencia: SWEP, Alfa Laval, GEA o equivalente. Las placas deben estar certificadas para agua potable.

**Circuladora modulante PWM1** — del tipo integrado en calderas de condensación, con señal de control PWM y perfil calefacción (se para ante pérdida de señal). Es crítico que sea perfil calefacción y no perfil solar: el perfil solar dispara a velocidad máxima ante pérdida de señal, lo que en una estación de ACS significaría agua del reservorio a 70°C sin control en el grifo. La señal de control proviene de las salidas rápidas TR0/TR1 del M241, a través del módulo buck DC-DC 24V→12V (dentro del rango iPWM3: UiH 4,5-15V).

**Caudalímetro de efecto Hall** — instalado en el secundario (agua potable), rango hasta 20 L/min, salida de pulsos compatible con las entradas digitales rápidas del M241. Su función es detectar la apertura de cualquier grifo y enviar una señal de anticipación al PLC antes de que la temperatura de salida caiga, arrancando la bomba PWM1 con antelación.

**Válvula mezcladora termostática VMT1** — instalada a la salida de la placa, tarada a 55°C. Actúa como seguro mecánico independiente de la electrónica: aunque el PID falle o la bomba entregue agua a temperatura excesiva, la VMT1 limita la temperatura de ACS al consumidor. No sustituye al control electrónico sino que lo respalda.

**Corte térmico independiente** — en la línea de ACS, con rearme manual, calibrado a ~70°C. Actúa por hardware, al margen del PLC, ante cualquier fallo de la bomba o de la señal de control que pudiera producir sobretemperatura en la línea de distribución.

```
Red potable ──► [Caudalímetro Hall] ──► [Secundario placa AISI 316L] ──► [VMT1 55°C] ──► [Corte térmico] ──► ACS distribución

Reservorio D2 (cabeza, ~65°C) ──► [Circuladora PWM1] ──► [Primario placa] ──► D1 (fondo, retorno frío)
```

**Control de la estación**:
- Anticipación por caudal: el caudalímetro detecta apertura del grifo → PLC arranca PWM1 antes de que caiga la temperatura.
- Lazo PID sobre sonda rápida de salida de placa → modula velocidad de PWM1 para mantener temperatura de consigna.
- VMT1: seguro mecánico independiente, tarada a 55°C.
- Corte térmico: seguro hardware independiente, rearme manual, ~70°C.

**Dimensionado pendiente**: verificar la placa seleccionada a 40-50 kW con la temperatura mínima de reservorio prevista en condiciones de demanda máxima, y confirmar el rango del caudalímetro hasta 20 L/min.

### 8.3 Cálculos justificativos del intercambiador de placas

#### 8.3.1 Temperatura del agua de red

No existe dato publicado específico de temperatura del agua de red para Jerez de la Frontera. Aguas de Jerez (Aqualia) publica análisis de calidad pero no de temperatura. El abastecimiento procede del embalse de Guadalcacín y del manantial de Tempul — este último históricamente valorado por su temperatura constante en todas las estaciones.

El referente normativo aplicable es la tabla de temperaturas medias mensuales del agua de red del **CTE DB-HE Anejo B**, que para la provincia de **Cádiz** (zona climática HE4: V) establece:

| Ene | Feb | Mar | Abr | May | Jun | Jul | Ago | Sep | Oct | Nov | Dic |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 10 °C | 10 °C | 11 °C | 13 °C | 15 °C | 17 °C | 19 °C | 20 °C | 19 °C | 17 °C | 14 °C | 11 °C |

El escenario de cálculo punta es **enero/febrero con T_red = 10 °C**, que constituye el caso más desfavorable del año tanto para la potencia del intercambiador como para el rendimiento de producción solar.

#### 8.3.2 Parámetros de diseño del intercambiador

| Parámetro | Valor | Observaciones |
|---|---|---|
| T_red (agua fría entrada secundario) | **10 °C** | Enero/febrero, CTE HE4 Cádiz |
| T_placa (salida secundario antes de VMT1) | **60 °C** | VMT1 mezcla a 55 °C |
| T_res (entrada primario, nominal) | **70 °C** | Temperatura nominal reservorio |
| T_res (entrada primario, mínima) | **65 °C** | Mínima de operación garantizada |
| Caudal secundario diseño | **15 L/min** | Demanda sostenida (varias duchas) |
| Caudal secundario pico | 20 L/min | Demanda punta momentánea |
| Caudal primario estimado (PWM1) | 0,40 kg/s (24 L/min) | Bomba tipo caldera, perfil calefacción |

#### 8.3.3 Cálculo de potencia térmica

**Caso diseño — 15 L/min sostenidos:**

```
Q = ṁ_s × Cp × ΔT_s
Q = (15/60) kg/s × 4,18 kJ/kg·K × (60 − 10) K
Q = 0,250 × 4,18 × 50 = 52,2 kW
```

**Caso pico — 20 L/min momentáneos:**

```
Q_pico = (20/60) × 4,18 × 50 = 69,7 kW
```

El pico de 20 L/min es momentáneo y la masa térmica del circuito primario y del reservorio lo absorbe. El dimensionado del intercambiador se realiza sobre los **52 kW sostenidos**.

**Análisis VMT1 a caudal punta:**

La válvula mezcladora termostática VMT1 mezcla agua de placa con agua de red para entregar 55 °C al usuario. A 20 L/min en grifo:

```
Balance mezcla: F_placa × (60 − 55) = F_fría × (55 − 10)
F_placa + F_fría = 20 L/min
→  F_placa = 18 L/min   F_fría = 2 L/min
```

La placa solo procesa **18 de los 20 L/min** del caudal punta; la VMT1 añade los 2 L/min restantes de agua fría de red directa.

#### 8.3.4 Dimensionado del intercambiador — método LMTD

El intercambiador trabaja en contracorriente. Las temperaturas en cada extremo:

**Caso nominal (reservorio a 70 °C):**

| Extremo | Primario (caliente) | Secundario (frío) | ΔT |
|---|---|---|---|
| Entrada HX | 70 °C (T_h,in) | 60 °C (T_c,out) | **ΔT₁ = 10 °C** |
| Salida HX | 38,8 °C (T_h,out) | 10 °C (T_c,in) | **ΔT₂ = 28,8 °C** |

```
T_h,out = 70 − 52.200 / (0,40 × 4.180) = 70 − 31,2 = 38,8 °C

LMTD = (ΔT₁ − ΔT₂) / ln(ΔT₁/ΔT₂)
LMTD = (10 − 28,8) / ln(10/28,8) = −18,8 / −1,058 = 17,8 °C
```

**Caso desfavorable (reservorio a 65 °C, mínima operación):**

| Extremo | Primario | Secundario | ΔT |
|---|---|---|---|
| Entrada HX | 65 °C | 60 °C | **ΔT₁ = 5 °C** |
| Salida HX | 33,8 °C | 10 °C | **ΔT₂ = 23,8 °C** |

```
LMTD = (5 − 23,8) / ln(5/23,8) = −18,8 / −1,558 = 12,1 °C
```

**Área de intercambio necesaria:**

Para intercambiadores de placas de acero inoxidable con fluidos agua-agua, el coeficiente global de transferencia U oscila entre 4.000 y 7.000 W/m²·K. Se adopta **U = 5.000 W/m²·K** como valor conservador.

| Escenario | LMTD | A necesaria |
|---|---|---|
| Nominal (res. 70 °C) | 17,8 °C | **0,59 m²** |
| Desfavorable (res. 65 °C) | 12,1 °C | **0,86 m²** |

```
A = Q / (U × LMTD)
A_desfavorable = 52.200 W / (5.000 W/m²·K × 12,1 K) = 0,86 m²
```

**Criterio de selección:** se elige un intercambiador con **A ≥ 1,0 m²** para incorporar un margen de seguridad del 15 % sobre el caso desfavorable y cubrir el ensuciamiento progresivo (fouling) característico del agua dura de Cádiz. Una placa de 20-30 canales en formato B25/B35 de los fabricantes habituales (SWEP, Alfa Laval, GEA) cubre esta superficie con holgura.

#### 8.3.5 Temperatura mínima del reservorio — implicación para el control

La temperatura de salida del intercambiador está acotada por la temperatura de entrada del primario menos la diferencia de aproximación (approach temperature), que en placas es típicamente 3-5 °C:

```
T_placa_max = T_res − ΔT_approach ≈ T_res − 5 °C
```

Para que la placa entregue 60 °C (y la VMT1 pueda mezclar a 55 °C):

```
T_res_min = 60 + 5 = 65 °C
```

**Implicación en la lógica del PLC:**
- Setpoint mínimo de carga del reservorio (TT5 en cabeza D2): **65 °C**
- Por debajo de 65 °C en TT5, la estación entrega ACS a temperatura reducida (la VMT1 no puede compensar). El PLC debe generar alarma de «reservorio frío» y priorizar la carga aerotérmica hacia D2.
- El setpoint nominal de operación es **70 °C** en TT5, que garantiza el margen para el caso desfavorable.
- Por encima de **80 °C** en TT5 se activa la protección por sobretemperatura y se suspende la carga.

| TT5 (D2 cabeza) | Estado | Acción PLC |
|---|---|---|
| < 60 °C | Reservorio frío | Alarma + prioridad BC→reservorio |
| 60–65 °C | Reservorio marginal | ACS puede ser < 55 °C en grifo |
| 65–70 °C | Operación normal | ACS garantizada ≥ 55 °C |
| 70–80 °C | Reservorio caliente | BC puede cargar piscina/fancoils |
| > 80 °C | Sobretemperatura | Suspender carga, alarma |


---

## 9. REPARTO DE LA PRODUCCIÓN AEROTÉRMICA

Dos válvulas de tres vías motorizadas en cascada reparten la producción de la BC entre tres destinos:

```
Producción BC
     │
   V3V-1
    ├── FALSE → Reservorio (D2 serpentines en serie)
    └── TRUE  → V3V-2
                  ├── FALSE → Buffer D3 → fancoils
                  └── TRUE  → HX titanio BC → piscina
```

La BC produce alternativamente para uno de los tres destinos, nunca simultáneamente.

**Condición crítica**: en modo refrigeración el agua técnica está a 7-12 °C. El PLC nunca dirige la producción al reservorio ni a la piscina cuando la BC está en modo frío.

---

## 10. CLIMATIZACIÓN DE LA VIVIENDA

Trece fancoils alimentados desde el buffer D3 (150 L). El buffer desacopla el caudal de la BC del caudal variable de los fancoils y evita el ciclado del compresor cuando se cierran zonas.

Cada fancoil incorpora:
- Dos llaves de corte (impulsión y retorno).
- Elemento de equilibrado hidráulico dinámico (tipo pendiente de decidir: PICV 0-10V / válvulas ΔP / PICV integrada de fábrica / control por bomba ΔP constante).
- Bandeja y desagüe de condensados con sifón.

Todo el ramal va aislado con barrera de vapor (operación en modo frío).

---

## 11. CLIMATIZACIÓN DE LA PISCINA

Dos intercambiadores de titanio independientes (uno por fuente), con el agua de la piscina circulando por el secundario de ambos accionada por la depuradora existente.

| Intercambiador | Fuente | Función estacional |
|---|---|---|
| HX solar | Excedente solar | Calentamiento primavera/otoño; gratuito |
| HX aerotérmico | BC en modo calor | Calentamiento primavera/otoño |

**En verano**: BC en modo refrigeración → no aporta a piscina (agua técnica a 7-12 °C). Solo el excedente solar la calienta. La piscina se autorregula: sombra durante horas centrales y depuradora nocturna que aprovecha el diferencial térmico con el aire más fresco (Levante). Balance prácticamente neutro sin gasto eléctrico adicional.

El titanio es obligatorio por la agresividad del agua clorada y constituye la barrera de separación entre el circuito técnico y el agua de baño (categoría 5, EN 1717).

---

## 12. DISTRIBUCIÓN DE ACS A LOS APARTAMENTOS

Los cuatro apartamentos conservan sus termos eléctricos existentes. El agua precalentada de la estación entra por la conexión de agua fría de cada termo con el termostato subido a 55-60 °C para que la resistencia apenas arranque.

**Conmutación**: una válvula de tres vías por apartamento, controlada por señal digital del PLC desde un colector en la sala de máquinas. **Retorno por muelle**: en caso de fallo de tensión, la válvula conmuta automáticamente a agua de red.

Señal de control 24 V en cable 2×1 mm², independiente del circuito de fuerza.

---

## 13. BOMBAS

| Bomba | Lado | Control | Función |
|---|---|---|---|
| PWM2 | Solar | PI sobre ΔT — señal PWM por DO rápida M241 + divisor 24V→10V | Circuito primario de glicol |
| PWM1 | Estación ACS | PI + anticipación caudal — señal PWM por DO rápida M241 + divisor 24V→10V | Circuito primario placa ACS |
| Circuladora BC | Aerotérmico | Según equipo | **A verificar suficiencia** (ver sección 6.2) |
| Fancoils | Climatización | Variable EC / ΔP | Caudal variable según zonas activas |
| Depuradora | Piscina | Existente | Circulación piscina + disipación nocturna |

---

## 14. CONTROL — SCHNEIDER MODICON M241 + MÓDULOS TM3

Un único controlador reemplaza la arquitectura de dos PLC comunicados por Modbus. La separación lógica entre subsistema solar y sistema principal se resuelve con dos tareas de programa de ciclos independientes.

```
Schneider TM241CE24R
├── Ethernet (Modbus TCP + web server HMI)
├── RS-485 × 2 (Modbus RTU hacia BC u otros dispositivos)
├── 14 DI (8 rápidas — caudalímetros + PWM output)
├── 10 DO relé 250VAC — V3V, válvulas, bombas
└── Módulos TM3 en bus local:
    ├── 2× TM3TI8T → 16 canales NTC 10K (13 sondas + 3 spare)
    ├── 2× TM3DQ16R/DO16R → 32 DO relé adicionales (mejoras instalación)
    └── 2× TM3AI4 → 8 AI 0-10V/4-20mA (presión, piranómetro, señal BC)
```

**Programación**: EcoStruxure Machine Expert (CoDeSys 3, IEC 61131-3). Structured Text para lógica de control. Software gratuito sin licencia de pago ni dongle.

**HMI**: web server integrado en el M241. Tablet existente en red WiFi accede a la visualización por navegador. Sin panel HMI físico adicional.

**Control de bombas Wilo iPWM3**: las salidas digitales rápidas Q0 y Q1 del M241 generan señal PWM a 1000 Hz. Un divisor resistivo (R1=1k5, R2=1k0) en una plaquita de carril DIN reduce el nivel de 24VDC a ~9,6VDC, dentro del rango válido de la entrada iPWM3 de Wilo (4,5–15V). El bloque PI en Structured Text implementa el control de ΔT constante en la bomba solar y anticipación + PID en la bomba de ACS.

**Caudalímetros**: efecto Hall con salida de pulsos, conectados a entradas digitales rápidas del M241.

**Sondas de temperatura**: NTC 10K en pozos de inmersión inox, conexión directa a módulos TM3TI8T sin convertidores de señal.

---

## 15. SEGURIDAD Y CUMPLIMIENTO NORMATIVO

| Aspecto | Solución |
|---|---|
| Antihelada solar | Propilenglicol 15 % + persianas; sin circulación nocturna ni llenado automático de red |
| Legionela | Riesgo mínimo: no se acumula agua potable; ACS producida al paso |
| Quemaduras | Mezcladora termostática VMT1 55 °C + antiescaldadura en puntos de uso (RITE IT 1.1.4.3.1) |
| Sobretemperatura ACS | Corte térmico independiente en línea ACS + VMT1 como respaldo mecánico |
| Separación piscina | Intercambiadores de titanio (categoría 5, EN 1717) |
| Refrigerante R290 | Cumplimiento EN 378-3; BC en exterior con zonas de exclusión |
| Sobretemperatura general | Termostatos de seguridad Z1 (D1) y Z2 (D2), rearme manual, hardware independiente |
| Seguridad hidráulica | Válvula de seguridad y vaso de expansión en cada circuito |
| Fail-safe apartamentos | V3V retorno por muelle → agua de red si falla la tensión |
| Fail-safe bombas PWM | Pérdida de señal PWM → bomba a velocidad máxima (comportamiento nativo Wilo iPWM3 en modo solar). Gestionar por software: M241 fuerza duty cycle 0% antes de cualquier parada programada) |

La producción de ACS al paso elimina la acumulación de agua potable y con ella la mayor parte de la problemática de legionela del RD 865/2003.

---

## 16. ESTIMACIONES ENERGÉTICAS (orientativas)

### ACS
- Demanda: 17,6 kWh/día.
- Reservorio: ~800 L × 45 K × 1,16 Wh/L·K ≈ **42 kWh** almacenados (de 15 a 55 °C). Autonomía ~2,4 días sin aporte.
- Fracción solar estimada: 65-75 % anual (a verificar con CHEQ4).

### Piscina
- Energía para elevar 40 m³ de 15 a 26 °C: 40 × 1,163 × 11 ≈ **511 kWh**.
- Potencia pico disponible: HX solar ~5 kW + HX BC ~12 kW = **17 kW**.
- Calentamiento inicial con cobertor isotérmico: 2-4 días.
- Mantenimiento de temporada: aporte BC con bajo recurso solar a coste eléctrico moderado.

### Climatización
- Carga máxima refrigeración estimada: 12-17 kW.
- Carga máxima calefacción estimada: 12 kW.
- Consumo eléctrico anual orientativo BC + bombas: **6.000-9.000 kWh** (a confirmar con simulación).

---

## 17. PUNTOS ABIERTOS

| # | Cuestión | Opciones |
|---|---|---|
| 1 | Suficiencia circuladora BC (~150 mbar serpentines serie + distribución) | Circuladora de apoyo / desacople por buffer |
| 2 | Equilibrado dinámico fancoils | PICV 0-10V / válvulas ΔP / PICV integrada fábrica / bomba ΔP cte |
| 5b | Programación EcoStruxure Machine Expert | Adaptar código ST del repo (escrito para FREE Studio) a EcoStruxure |
| 3 | Dimensionado estación ACS | Placa 40-50 kW + circuladora PWM1 + caudalímetro hasta 20 L/min |
| 4 | Cálculo formal fracción solar | CHEQ4 |
| 5 | Simulación cargas térmicas | CYPETHERM o equivalente |
| 6 | P&ID completo | Pendiente |
| 7 | Zonificación fancoils por planta | Pendiente distribución en planta |

---

## 18. DECISIONES DE DISEÑO DOCUMENTADAS

Para el registro completo de cómo se tomaron estas decisiones ver:
`bitacora/bitacora_proyecto_fosela.md`

1. **ACS al paso en lugar de acumulación de potable**: los depósitos de acero vitrificado adquiridos no son aptos para almacenamiento de agua potable en circuito abierto. Se opta por estación de agua fresca con placa AISI 316L, que además elimina el riesgo de legionela y libera potencia de ACS sin cuello de botella.

2. **Serpentines en serie en ambos depósitos**: duplica la superficie de intercambio por productor (~3,2 m² por depósito), el productor entra por el serpentín superior y sale por el inferior (zona caliente arriba, retorno frío más frío).

3. **Glicol al 15 % en lugar de 35 %**: las mínimas históricas de Jerez rondan -2 °C; el 15 % protege con holgura. A menor concentración, mayor Cp y menor viscosidad → mejor transferencia y bombeo → mayor rendimiento del captador.

4. **Abandono del HTR**: la arquitectura con estación de agua fresca hace innecesario el HTR. El reservorio de agua técnica cubre el ACS de forma más robusta e independiente. Ver rama `arquitectura/ecoforest-htr` para la versión con Ecoforest + HTR.

5. **Persianas motorizadas frente a circulación nocturna antihelada**: la circulación nocturna requiere electricidad y bomba disponibles exactamente cuando ocurre la helada; un corte de luz en esa noche destroza el campo. Las persianas actúan pasivamente sin corriente.

6. **No se instala válvula de llenado automático en el circuito de glicol**: diluiría progresivamente el anticongelante sin aviso. Llenado manual con premezcla verificada con refractómetro.

7. **V3V con retorno por muelle en apartamentos**: ante fallo de tensión la válvula conmuta a agua de red garantizando ACS por el termo eléctrico existente.

---

## APÉNDICE A — Mejoras posibles en la instrumentación

Los dos módulos **TM3AI4** incluidos en el lote de Manresa proporcionan 8 canales de entrada analógica (0-10V / 4-20mA) disponibles para futuras ampliaciones de instrumentación. A continuación se relacionan las mejoras que podrían incorporarse sin modificar el hardware de control ya adquirido.

| # | Instrumento | Señal | Canales | Utilidad |
|---|---|---|---|---|
| 1 | Transductor de presión — circuito solar primario | 4-20 mA | 1 | Detección de pérdidas de glicol, necesidad de purga, caída de presión progresiva |
| 2 | Transductor de presión — lazo agua técnica (D1-D2) | 4-20 mA | 1 | Vigilancia de la integridad del circuito cerrado, alarma por pérdida de presión |
| 3 | Piranómetro — radiación solar global horizontal | 0-10 V | 1 | Correlación producción real vs. radiación disponible; detección de suciedad en captadores |
| 4 | Señal analógica BC — potencia o estado | 0-10 V / 4-20 mA | 1 | Calorimetría aerotérmica si el equipo ofrece salida analógica de potencia o COP |

> Ninguna de estas mejoras ha sido objeto de decisión. Se listan como posibilidades que el hardware ya adquirido puede asumir sin coste adicional de control.
> La disponibilidad de la señal analógica de la BC depende del modelo concreto que se instale — verificar ficha técnica antes de planificar su uso.
