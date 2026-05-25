# MEMORIA TÉCNICA — BORRADOR
## Instalación térmica integrada · BC monobloc + solar térmico
### Vivienda principal con 4 apartamentos turísticos y piscina · Jerez de la Frontera
### Arquitectura: aerotermia monobloc R290 (sin HTR) + solar térmico + control PLC

> **Estado:** borrador de trabajo. Ver rama `arquitectura/ecoforest-htr` para la versión con Ecoforest ecoAIR+ 6-24 PRO HTR.

---

## 1. OBJETO Y ALCANCE

La presente memoria describe una instalación térmica integrada que da servicio a una vivienda principal de 220 m² con cuatro apartamentos de uso turístico anexos, bajo titularidad única, en Jerez de la Frontera (zona climática B4 según CTE DB-HE; zona V de radiación solar según CTE HE-4).

La instalación cubre cuatro demandas térmicas:

- **ACS instantánea** para 16 ocupantes máximos (336–448 L/día a 60 °C, CTE HE-4), producida al paso sin acumulación de agua potable.
- **Calefacción y refrigeración** de la vivienda principal mediante 13 fancoils (≈12 kW calor / 17 kW frío).
- **Climatización de piscina** exterior 8×4 m (~25 m³): calentamiento en primavera/otoño, disipación pasiva en verano.
- **Precalentamiento de ACS** a los cuatro apartamentos, que conservan sus termos eléctricos existentes.

## 2. CONDICIONANTES DEL PROYECTO

- **Titularidad única**: no aplica la obligación de individualización de consumos del RITE IT 1.2.4.4.
- **Uso turístico de los apartamentos**: obligaciones higiénico-sanitarias del RD 865/2003.
- **Piscina privativa**: uso exclusivo del propietario. Clasificación EN 1717 categoría 4/5 según la ruta.
- **Depósitos ya adquiridos**: 2 × Tusol DB2 450 vitrificado (406 L, doble serpentín). Funcionan como reservorio de agua técnica, no de agua potable.
- **ACS al paso**: consecuencia directa del punto anterior. El acero vitrificado es correcto para agua técnica en circuito cerrado, no para almacenar agua potable con temperatura variable. La separación se resuelve con intercambiador de placas externo AISI 316L.

## 3. NORMATIVA DE APLICACIÓN

| Referencia | Ámbito |
|---|---|
| RD 1027/2007 (RITE) y modificaciones | Diseño y seguridad de la instalación térmica |
| CTE DB-HE (HE-0, HE-1, HE-4) | Eficiencia energética y aportación solar mínima |
| CTE DB-HS-4 | Suministro de agua y protección de la red potable |
| RD 865/2003 | Prevención de legionelosis en agua sanitaria |
| UNE-EN 378-1/2/3 | Sistemas frigoríficos con R290 |
| UNE 100030 | Prevención de legionelosis en instalaciones |
| UNE-EN 1717 | Protección frente a contaminación de agua potable |
| UNE-EN 12831 | Cálculo de cargas térmicas |
| RD 115/2017 | Gases fluorados / refrigerantes |
| IEC 61131-3 | Programación del controlador (Structured Text) |

## 4. DATOS DE PARTIDA

| Parámetro | Valor |
|---|---|
| Potencia pico refrigeración | 12–17 kW |
| Potencia pico calefacción | 12 kW |
| Demanda ACS | 336 L/día a 60 °C (17,6 kWh/día) |
| Caudal punta ACS instantáneo | 15–20 L/min (~40–50 kW) |
| Producción solar invierno | 12–16 kWh/día |
| Producción solar verano | 38–45 kWh/día |
| Piscina | 8×4 m, ~25 m³ |
| Clima | B4, mínimas 2–4 °C, veranos > 40 °C |

## 5. ARQUITECTURA GENERAL

El sistema se organiza en torno a dos productores —solar y aerotérmico— que cargan un **reservorio de energía** de ~800 L de agua técnica, del que se extrae calor para cuatro consumos: ACS instantánea, climatización de la vivienda, climatización de piscina y precalentamiento de ACS a los apartamentos.

```
LADO SOLAR                           LADO AEROTÉRMICO
Captadores 8 m²                      BC monobloc R290
Bomba PWM2 (ΔT cte)                  Módulo hidráulico integrado
  │                                    │
  │  serpentines en serie              │  V3V-1: reservorio / →V3V-2
  ▼  (serp.sup → serp.inf)            │  V3V-2: fancoils / piscina
Dep. SOLAR (D1)                       ▼
  │                         Dep. AEROTÉRMICO (D2) ──► HX placas ──► ACS
  ▼                                    │
HX titanio SOLAR ──► piscina          HX titanio BC ──► piscina

RESERVORIO: D1 ──(tomas 1¼")──► D2
ACS: Reservorio ──► Estación agua fresca ──► grifos
```

**Principio fundamental**: agua técnica en los depósitos (circuito cerrado, no potable); agua potable solo en la placa de inox de la estación de agua fresca, sin acumularse.

## 6. BOMBA DE CALOR AEROTÉRMICA MONOBLOC

- BC aerotérmica monobloc R290, módulo hidráulico integrado en unidad exterior.
- La conexión al sistema es exclusivamente **hidráulica y de comunicación** — sin tuberías frigoríficas al interior.
- La unidad entrega directamente agua técnica caliente o fría según el modo.
- Incorpora circuladora de agua técnica interna. **Punto abierto**: verificar que vence la pérdida de carga del circuito de carga del reservorio (~150 mbar de los dos serpentines en serie de D2 + distribución + válvulas). Si no llega: circuladora de apoyo o desacople por buffer.
- Refrigerante R290 (GWP 3), conformidad EN 378-3.
- Instalación obligatoriamente exterior con zonas de exclusión dimensionadas según EN 378-3.

## 7. CAMPO SOLAR TÉRMICO

- **4 colectores planos**, 2 m² apertura cada uno, **8 m² totales**. Solar Keymark.
- Fluido caloportador: **propilenglicol 15 %** en agua (protección ≥ −5 °C, Cp ≈ 4,05 kJ/kg·K).
  - Concentración deliberadamente baja: mantiene alto Cp y baja viscosidad, mejorando captación y bombeo.
  - Protege holgadamente frente a las mínimas históricas de Jerez (≈ −2 °C).
  - Llenado manual con premezcla; sin válvula de llenado automático desde red (evita dilución inadvertida). Control periódico de concentración con refractómetro.
- **Protección frente a sobrecalentamiento**: persianas motorizadas con posición manual sobre los captadores. El PLC cierra las persianas cuando el reservorio está saturado. El glicol y el vaso de expansión actúan como respaldo pasivo.
- **Bomba PWM2** (Wilo Para ST 15/7-50/PWM3 o equiv.): modulante con señal PWM, control de salto térmico constante (ΔT objetivo 8 K). Optimiza la captación manteniendo el circuito a la temperatura más baja posible.
- El solar carga D1 a través de sus dos serpentines conectados en serie (serp. sup → serp. inf). El productor entra por el serpentín superior y sale por el inferior: zona caliente arriba, fluido devuelto lo más frío posible.
- El excedente solar (D1 en setpoint) se desvía al intercambiador de titanio solar hacia la piscina.

## 8. RESERVORIO DE ENERGÍA — DOS ACUMULADORES EN SERIE

### 8.1 Descripción

Dos acumuladores Tusol DB2 450 de **406 L** vitrificado SMALGLASS, doble serpentín, ya adquiridos, funcionan como un único reservorio de **~800 L de agua técnica**. No almacenan agua potable.

- **D1** (depósito solar): cargado por el campo solar a través de sus dos serpentines en serie.
- **D2** (depósito aerotérmico): cargado por la BC a través de sus dos serpentines en serie.
- Los dos cuerpos se encadenan en serie: el retorno frío de los consumos entra por el fondo de D1, se precalienta, pasa por la cabeza de D1 al fondo de D2, donde la BC lo remata, y sale caliente por la cabeza de D2.

### 8.2 Serpentines en serie en cada depósito

En cada depósito, el serpentín superior e inferior se conectan **en serie**, duplicando la superficie de intercambio disponible para el productor (~3,2 m² por depósito). El productor entra por el serpentín superior y sale por el inferior.

Ventajas:
- Mayor superficie → mayor transferencia → el productor trabaja con menor salto térmico → mejor COP (BC) y mayor rendimiento óptico (captadores).
- Zona caliente arriba (donde se extrae el calor para consumos).
- Fluido del productor devuelto lo más frío posible.

**Nota**: dos serpentines en serie duplican la pérdida de carga del lado del productor (~150 mbar en D2). Verificar suficiencia de la circuladora integrada de la BC (ver §6).

### 8.3 Tomas para los consumos

Las tomas de **1¼"** del ánodo (parte alta) y la resistencia (parte baja) de cada depósito — las únicas bocas de gran diámetro del cuerpo — se usan para mover el agua técnica entre productores y consumos. Los serpentines quedan así íntegramente dedicados a los productores.

### 8.4 Reparto simétrico de productores

- Solar → D1 (serpentines en serie).
- BC → D2 (serpentines en serie).
- Al estar en depósitos distintos, no se necesita colector de antirretornos para separarlos.

## 9. PRODUCCIÓN DE ACS INSTANTÁNEA — ESTACIÓN DE AGUA FRESCA

### 9.1 Principio

ACS producida al paso, sin acumulación de agua potable, mediante una **estación de agua fresca**: intercambiador de placas AISI 316L apto para agua potable, alimentado en su primario por el agua técnica caliente del reservorio.

```
Red AFS ──► [secundario placa AISI 316L] ──► ACS a grifos
                    │
Reservorio (D2) ──► [primario placa] ──► retorno frío a D1
```

### 9.2 Control

- **Circuladora PWM1** (perfil calefacción — se para ante pérdida de señal, nunca a máxima velocidad): acelera o frena el caudal del primario para mantener la temperatura de ACS en consigna.
- **Anticipación por caudal**: caudalímetro de efecto Hall detecta apertura del grifo y sube la bomba antes de que la temperatura caiga.
- **Lazo PID** sobre sonda rápida de salida para ajuste fino.
- **Válvula mezcladora termostática** final: seguro mecánico independiente de la electrónica (45 °C punto de uso, RITE IT 1.1.4.3.1).
- **Corte térmico independiente** en la línea de ACS: protección hardware ante fallo de bomba o señal.

### 9.3 Dimensionado

- Potencia objetivo: **40–50 kW** (caudal de ducha holgado a 15–20 L/min).
- Placa AISI 316L: a dimensionar con temperatura de reservorio prevista y caudal punta.
- Caudalímetro: rango hasta 20 L/min.
- **Pendiente de cierre**: dimensionado definitivo de placa + circuladora.

### 9.4 Conexiones

- Agua caliente del primario: toma ánodo (parte alta) de D2.
- Retorno frío del primario: toma resistencia (parte baja) de D1.

### 9.5 Ventajas frente a la acumulación convencional

- Riesgo de legionela prácticamente eliminado (no hay volumen de agua potable acumulado).
- Potencia de ACS libre (no limitada por bocas de ½" de los serpentines).
- Los depósitos vitrificados funcionan en su uso correcto (agua técnica en circuito cerrado).

## 10. REPARTO DE LA PRODUCCIÓN AEROTÉRMICA — DOS VÁLVULAS DE TRES VÍAS

```
Producción BC
     │
   V3V-1
    ├── A → Reservorio (D2, serpentines en serie)
    └── B → V3V-2
              ├── A → Climatización vivienda (buffer D3 → 13 fancoils)
              └── B → Piscina (HX titanio aerotérmico)
```

Con dos válvulas se cubren los tres destinos. La BC produce alternativamente para uno de ellos según la prioridad del PLC, nunca simultáneamente, garantizando que cada consumo recibe agua a la temperatura adecuada.

**Condición crítica — incompatibilidad de temperaturas**: en modo refrigeración el agua técnica está a 7–12 °C, inservible para cargar el reservorio o calentar la piscina. El PLC solo dirige la producción al reservorio o a la piscina cuando la BC está en modo calefacción o modo ACS. En verano, mientras la BC enfría la vivienda:
- El ACS lo cubre el solar a través del reservorio solar.
- La piscina recibe únicamente el excedente solar vía su HX de titanio solar.

## 11. CLIMATIZACIÓN DE LA VIVIENDA

- **13 fancoils** distribuidos por la vivienda principal, alimentados desde el buffer D3 (150 L).
- El buffer desacopla el caudal fijo de la BC del caudal variable de los fancoils, evitando el ciclado del compresor cuando se cierran zonas.
- Cada fancoil: dos llaves de corte + elemento de equilibrado hidráulico dinámico + bandeja y desagüe de condensados con sifón.
- **Equilibrado dinámico** — pendiente de decidir entre:
  - PICV con entrada 0-10V junto al fancoil
  - Válvulas de presión diferencial puras
  - Fancoils con PICV integrada de fábrica
  - Control por bomba de presión diferencial constante
- Todo el ramal va aislado con barrera de vapor (operación en modo frío).

## 12. CLIMATIZACIÓN DE LA PISCINA — DOS INTERCAMBIADORES DE TITANIO

La piscina (~25 m³, 8×4 m) cumple doble función estacional:
- **Primavera/otoño**: calentamiento (solar + BC en modo calefacción).
- **Verano**: actúa como disipador pasivo del excedente solar; la depuradora nocturna aprovecha el diferencial térmico con el aire exterior (Levante) para disipar el pequeño excedente. Balance prácticamente neutro sin gasto eléctrico adicional.

**Dos intercambiadores de titanio independientes**:
- **HX solar**: recibe en su primario el excedente solar (vía V3V_SOL).
- **HX aerotérmico**: recibe en su primario la producción de la BC (vía V3V-2B).

El agua de piscina, impulsada por la depuradora existente, circula por el secundario de ambos. Cada fuente tiene su propio HX y nunca interfieren.

El titanio es obligatorio por la agresividad del agua clorada y constituye la barrera de separación entre circuito técnico y agua de baño (EN 1717, categoría 5).

## 13. DISTRIBUCIÓN DE ACS A LOS APARTAMENTOS

Los cuatro apartamentos conservan sus termos eléctricos existentes. La instalación les suministra agua precalentada de la estación de agua fresca:

- Una **válvula de tres vías** por apartamento, controlada por señal digital del PLC desde un colector en sala de máquinas.
- Válvula con **retorno por muelle**: conmuta a agua de red si falla la tensión.
- Señal de control: 24 Vdc, cableada en 2×1 mm² por apartamento en tubo independiente.
- Termostato de cada termo subido a 55–60 °C para que la resistencia apenas arranque.

## 14. BOMBAS

| Bomba | Lado | Control | Función |
|---|---|---|---|
| PWM2 | Solar | Modulante PWM, ΔT constante | Circuito solar primario |
| PWM1 | Estación ACS | Modulante PWM, perfil calefacción | Primario estación agua fresca |
| Integrada BC | Aerotérmico | Según equipo | A verificar suficiencia (§6) |
| P3 fancoils | Climatización | Variable EC / presión diferencial | Caudal variable fancoils |
| Depuradora | Piscina | Existente | Filtración + lado secundario HX |

**Nota crítica PWM1**: debe ser de perfil calefacción (para ante pérdida de señal) y no de perfil solar (que va a máxima velocidad ante pérdida de señal — en ACS significaría agua hirviendo en el grifo).

## 15. CONTROL — DOS PLC ELIWELL POR MODBUS

```
FREE Evolution (EVD7500) ──── RS-485 Modbus RTU ──── FREE Smart (SMD5500)
        maestro                                              esclavo
  lógica principal + HMI                              subsistema solar completo
```

**FREE Evolution (maestro)**: V3V-1 y V3V-2 aerotérmicas, válvulas de tres vías de apartamentos, control de la estación de agua fresca (anticipación por caudal + PID), bomba PWM1, ciclo de pasteurización antilegionela.

**FREE Smart (esclavo)**: bomba modulante PWM2 con control de salto térmico constante, calorímetro del aporte solar, persianas motorizadas, sondas del circuito de glicol.

**Comunicación Modbus**: el maestro lee del esclavo potencia solar instantánea, energía acumulada, estado de persianas y temperaturas; le envía las consignas necesarias.

Programación en **Structured Text** conforme a IEC 61131-3 mediante FREE Studio.

Los caudalímetros (calorimetría solar y estación ACS) son de efecto Hall con salida de pulsos, compatibles con entradas digitales rápidas de los controladores.

## 16. SEGURIDAD Y CUMPLIMIENTO NORMATIVO

| Aspecto | Solución |
|---|---|
| Antihelada solar | Propilenglicol 15% + persianas; sin circulación nocturna |
| Legionela | Riesgo mínimo: ACS producida al paso, sin acumulación de potable |
| Quemaduras | Mezcladora termostática 45 °C en estación ACS + antiescaldadura en puntos de uso (RITE IT 1.1.4.3.1) |
| Sobretemperatura ACS | Corte térmico independiente en línea de ACS |
| Separación piscina | HX titanio (EN 1717 cat. 5) |
| Refrigerante R290 | Cumplimiento EN 378-3, instalación exterior |
| Sobretemperatura general | Termostato de seguridad rearme manual, hardware independiente |
| Seguridad hidráulica | Válvula de seguridad y vaso de expansión en cada circuito |
| Pasteurización | Ciclo semanal automático ≥ 70 °C en D2, registrado |

La producción de ACS al paso elimina la acumulación de agua potable y con ella la mayor parte de la problemática de legionela del RD 865/2003, al no existir volumen de potable acumulado donde pueda proliferar.

## 17. ESTIMACIONES ENERGÉTICAS (ORIENTATIVAS)

| Concepto | Valor estimado |
|---|---|
| Fracción solar ACS en verano | ~100% |
| Fracción solar ACS anual | 60–75% (verificar con CHEQ4) |
| Excedente solar a piscina en verano | 35–45 kWh/día |
| Calentamiento inicial piscina 15→26 °C | ~320 kWh (2–4 días con BC + solar) |
| COP BC calefacción estimado (+6 °C ext) | 3,0–3,5 |
| COP BC refrigeración estimado (+35 °C ext) | 2,5–3,0 |

## 18. PUNTOS ABIERTOS — PENDIENTES DE CIERRE

| # | Cuestión | Opciones / Acción |
|---|---|---|
| 1 | **Circuladora BC**: ¿vence ~150 mbar + distribución? | Comparar curva circuladora integrada con pérdida de carga calculada. Si no llega: circuladora de apoyo o desacople por buffer |
| 2 | **Equilibrado dinámico fancoils** | PICV 0-10V / válvulas ΔP / PICV integrada fábrica / bomba ΔP constante |
| 3 | **Estación ACS**: dimensionado definitivo | Placa AISI 316L (40-50 kW) + circuladora PWM1 con Tª reservorio prevista + caudalímetro hasta 20 L/min |
| 4 | **Agrupación fancoils por zonas** | Distribución en planta de la vivienda |
| 5 | **Fracción solar** | Verificar con CHEQ4 con 8 m² y demanda real |

## 19. DECISIONES DE DISEÑO DOCUMENTADAS

Ver bitácora completa: `bitacora/bitacora_proyecto_fosela.md`

Decisiones principales:
1. **ACS al paso** (no acumulación): consecuencia de los depósitos vitrificados adquiridos + ventaja sanitaria.
2. **Glicol 15%** (no 35%): protección suficiente en Jerez, mejor Cp y viscosidad.
3. **Serpentines en serie en ambos depósitos**: ganancia de superficie libre al no acumular potable.
4. **BC monobloc genérica** (no Ecoforest HTR): la estación de agua fresca cubre el ACS de forma más robusta e independiente del compresor.
5. **Dos HX titanio** (no tres): sin HTR, no hay tercera fuente de calor a piscina.
6. **Dos V3V** (no tres): dos válvulas cubren tres destinos en cascada.
7. **Persianas** (no circulación nocturna): antihelada más fiable ante cortes de suministro.

---

*Proyecto Fosela House · Jerez de la Frontera · zona climática B4 · zona solar V*
*Borrador — pendiente de completar con P&ID, cálculo de cargas y verificación CHEQ4*
