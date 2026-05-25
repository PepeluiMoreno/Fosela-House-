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

**Tomas para el lazo de agua técnica**: bocas de 1¼" del ánodo (parte alta) y la resistencia (parte baja) de cada depósito, las de mayor diámetro del cuerpo.

---

## 8. PRODUCCIÓN DE ACS INSTANTÁNEA — ESTACIÓN DE AGUA FRESCA

El ACS se produce de forma instantánea, sin acumulación de agua potable, mediante una estación de agua fresca: un intercambiador de placas de acero inoxidable AISI 316L apto para agua potable.

```
Reservorio (D2 cabeza) ──► [Primario placa AISI 316L] ──► D1 fondo
                                      │
                                      │ (intercambio de calor)
                                      │
         AFS entrada ──► [Secundario placa] ──► ACS salida 55°C ──► distribución
```

**Control de la estación**:
- Circuladora Wilo modulante PWM1 (perfil calefacción — se para ante pérdida de señal; **nunca** perfil solar, que va a máxima velocidad ante pérdida de señal).
- Caudalímetro de efecto Hall en el secundario: detecta apertura del grifo y sube la bomba antes de que la temperatura caiga (anticipación).
- Lazo PID sobre sonda rápida de salida.
- Válvula mezcladora termostática VMT1 final: seguro mecánico independiente de la electrónica.
- Corte térmico independiente en la línea de ACS (protección adicional ante fallo de bomba o señal).

**Dimensionado pendiente**: placa a 40-50 kW con la temperatura de reservorio prevista + caudalímetro hasta 20 L/min.

**Ventajas frente a acumulación de potable**:
- Riesgo de legionela prácticamente eliminado: no hay acumulación de agua potable.
- Potencia libre: placa dimensionada sin cuello de botella.
- Los depósitos de acero vitrificado se usan correctamente (circuito cerrado técnico).

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
| PWM2 | Solar | Modulante PWM, ΔT constante | Circuito primario de glicol |
| PWM1 | Estación ACS | Modulante PWM (perfil calefacción) | Anticipación por caudal + PID sobre T° de salida |
| Circuladora BC | Aerotérmico | Según equipo | **A verificar suficiencia** (ver sección 6.2) |
| Fancoils | Climatización | Variable EC / ΔP | Caudal variable según zonas activas |
| Depuradora | Piscina | Existente | Circulación piscina + disipación nocturna |

---

## 14. CONTROL — DOS PLC ELIWELL POR MODBUS

```
FREE Evolution (EVD7500)  ──── RS-485 Modbus RTU ────  FREE Smart (SMD5500)
        maestro                                                esclavo
  lógica principal + HMI                             subsistema solar completo
```

### FREE Smart (esclavo, dirección 1) — subsistema solar

- Bomba PWM2 con control de ΔT constante (objetivo 8 K).
- Calorímetro del aporte solar.
- Persianas motorizadas.
- Sondas del circuito de glicol (TT1 ida, TT2 retorno, TT3 D1 cabeza).

### FREE Evolution (maestro) — sistema principal

- Dos V3V aerotérmicas (V3V-1, V3V-2).
- Válvulas de tres vías de los apartamentos (4 uds.).
- Estación de agua fresca: anticipación por caudal + PID.
- Bomba PWM1.
- Ciclo de pasteurización antilegionela.
- HMI local.

**Variables compartidas por Modbus**: el maestro lee del esclavo la potencia solar instantánea, la energía acumulada, el estado de las persianas y las temperaturas del circuito; le envía consignas cuando las necesita.

Programación en Structured Text conforme a IEC 61131-3 mediante FREE Studio.

**Caudalímetros**: efecto Hall con salida de pulsos, compatibles con entradas digitales rápidas de los controladores.

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
| Fail-safe bomba PWM1 | Perfil calefacción (parada ante pérdida de señal, no disparo a máxima velocidad) |

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
