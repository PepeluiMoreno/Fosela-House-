# MEMORIA TÉCNICA
## Instalación térmica integrada solar térmica + aerotermia
### Vivienda principal con 4 apartamentos turísticos y piscina · Jerez de la Frontera

---

## 1. OBJETO Y ALCANCE

La presente memoria describe una instalación térmica integrada que da servicio a una vivienda principal con cuatro apartamentos de uso turístico anexos, todos bajo titularidad única del mismo propietario, situados en Jerez de la Frontera (zona climática B4 según CTE DB-HE; zona V de radiación solar según CTE HE-4).

La instalación cubre simultáneamente cuatro demandas térmicas:

- **Producción de ACS** para 16 ocupantes simultáneos máximos: 448 L/día a temperatura de referencia 60 °C (CTE HE-4).
- **Calefacción y refrigeración** de todas las estancias mediante 13 fancoils, potencia máxima 24 kW.
- **Climatización de piscina privativa exterior** de 36 m³ (8 × 3 × 1,5 m), con aporte combinado de campo solar, primario de la BDC y HTR.

## 2. CONDICIONANTES DEL PROYECTO

- **Titularidad única**: la instalación no tiene carácter colectivo aunque sirva a varias unidades habitacionales. No aplica la obligación de individualización de consumos del RITE IT 1.2.4.4.
- **Uso turístico de los apartamentos**: rotación de ocupantes y obligaciones higiénico-sanitarias específicas (RD 865/2003) sobre el agua sanitaria.
- **Piscina privativa**: uso exclusivo del propietario, no accesible a huéspedes. Clasificación EN 1717 categoría 4 (separación simple suficiente regulatoriamente respecto a ACS).
- **El agua sanitaria es común a las cinco viviendas**: la seguridad de ACS frente a contaminación es prioridad de diseño superior al cumplimiento mínimo de la piscina.

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

## 4. ARQUITECTURA GENERAL

Tres fuentes de aporte energético, tres acumuladores con funciones diferenciadas, y un mini bucle intermedio dedicado exclusivamente a la transferencia solar→piscina (que es la ruta de mayor exposición potencial al ACS y por eso conserva la doble separación).

**Fuentes:**

1. Campo solar térmico (12 m²): calor de baja-media temperatura, prioridad ACS y aporte a piscina vía D1.
2. Bomba de calor aerotérmica modulante con HTR: calor y frío para climatización, apoyo ACS y aporte directo a piscina.
3. Calentadores eléctricos individuales por vivienda: respaldo final ACS y soporte del ciclo de pasteurización.

**Acumuladores:**

- **D1** (406 L vitrificado SMALGLASS, 2 serpentines): preacumulación solar de ACS y transferencia a piscina vía mini bucle intermedio. **Tusol DB2 450** (Año 2015, Mat. M15370446). Serp. inf 2,2 m²/52 kW/2200 L/h (solar); serp. sup 1,0 m²/26 kW/1100 L/h (mini bucle intermedio). PS sanitaria 10 bar; PS serpentines 6 bar; T máx 95 °C.
- **D2** (406 L vitrificado SMALGLASS, 2 serpentines): acumulación final de ACS calentada por BDC (inferior) y HTR (superior). **Tusol DB2 450** (mismo modelo). Serp. inf 2,2 m²/52 kW/2200 L/h (BDC primario); serp. sup 1,0 m²/26 kW/1100 L/h (HTR). PS y T máx ídem D1.
- **D3** (150 L cerrado): buffer hidráulico doble uso calor/frío para fancoils.

**Intercambiadores de placas a piscina:**

- **HX1** (titanio, 5 kW nominal): mini bucle intermedio ↔ piscina (vía solar).
- **HX_BDC** (titanio, 12 kW nominal): primario BDC ↔ piscina (directo).
- **HX_HTR** (titanio, 3 kW nominal): HTR ↔ piscina (directo).

**Topología de aportes a piscina:**

```
Solar primario glicol ──► serp.inf D1 ──► ACS (modo por defecto)
                      │
                      └► V3V_SOL ──► serp.sup D1 ──► mini bucle intermedio ──► HX1 ──► PISCINA
                                                       (P2, VE_INT, etc.)

BDC primario ──► V3V1 ──► serp.inf D2 (ACS)
                      │
                      └► V3V2 ──► D3 (climatización)
                              │
                              └► HX_BDC ──► PISCINA

HTR ──► V3V3 ──► serp.sup D2 (ACS, por defecto)
              │
              └► HX_HTR ──► PISCINA
```

## 5. FUENTES DE ENERGÍA

### 5.1 Campo solar térmico

- 6 colectores planos S-01 a S-06, 2 m² de apertura cada uno, **12 m² totales**.
- Rendimiento óptico η₀ ≥ 0,78; coeficiente de pérdidas a₁ ≤ 3,8 W/m²·K.
- Certificación Solar Keymark exigida.
- Fluido caloportador: propilenglicol 35 % en agua (protección −15 °C, compatible alimentario).
- Producción estimada en Jerez (a verificar con CHEQ4): 55–65 kWh/día verano, 25–35 kWh/día invierno.
- Fracción solar HE-4 zona V mínima: 70 %. Fracción estimada del proyecto: 70–80 % anual ACS, con descarga del excedente a piscina vía D1.

### 5.2 Bomba de calor aerotérmica

- Ecoforest ecoAIR+ 6-24 PRO.
- Refrigerante R290 (GWP 3), conformidad EN 378.
- Modulación 6–24 kW, alimentación trifásica 400 V.
- Tecnología HTR (superheater) integrada: recuperación del calor de descarga del compresor con producción de agua a 70–80 °C sin consumo eléctrico adicional, simultáneo con calefacción o refrigeración activas.
- COP estimado: 3,0–3,5 calefacción a +6 °C; 2,5–3,0 refrigeración a +35 °C.
- **Salidas hidráulicas y destinos:**
  - Primario principal (6–24 kW modulante): mediante cascada V3V1 + V3V2 puede dirigirse a serp.inf de D2 (ACS), a D3 (climatización), o a HX_BDC (piscina).
  - HTR (2–3 kW continuos cuando el compresor está activo, 70–80 °C): mediante V3V3 puede dirigirse a serp.sup de D2 (ACS) o a HX_HTR (piscina).
- Instalación obligatoriamente exterior con zonas de exclusión EN 378-3 (ver Sec. 10).

### 5.3 Calentadores eléctricos individuales

- 5 calentadores **CE-01 a CE-05**, uno por vivienda.
- Función: respaldo final cuando la cascada solar+BDC entregue agua por debajo de consigna, y soporte del ciclo de pasteurización antilegionela en el punto terminal.
- Alimentación fría seleccionable mediante **V3V_APT_01 a V3V_APT_05 motorizadas** ubicadas inmediatamente aguas arriba de cada CE. Cada V3V_APT escoge entre agua precalentada (salida común de VMT1) o AFS directa.
- **Seguridad sanitaria del ramal interior por diseño**: el CE actúa como barrera térmica entre el ramal de precalentada y el punto de uso. El agua del ramal entre V3V_APT y el CE puede estar tibia durante la vacancia del apartamento, pero nunca llega al grifo sin pasar por el CE, que la mantiene a temperatura de seguridad de forma continua. El volumen de ese ramal es mínimo y se integra en el volumen del CE en el primer uso. La seguridad sanitaria queda garantizada por construcción.
- Ánodo de sacrificio y válvula de seguridad sanitaria 8 bar con desagüe visible. **No se instala vaso de expansión individual**: la propia V3V_APT proporciona aislamiento direccional respecto al ramal alternativo, y la expansión del CE se transmite por su entrada de fluido seleccionada hasta el VE_AFS centralizado.

## 6. ARQUITECTURA HIDRÁULICA

### 6.1 Producción de ACS — cascada de dos etapas

1. Entrada AFS: agua fría de red por el fondo de D1.
2. D1 — preacumulación solar (30–50 °C) por serp.inf alimentado por el primario solar.
3. Tránsito D1 → D2: agua precalentada sale del tope de D1 y entra por el fondo de D2.
4. D2 — calentamiento final: BDC carga serp.inf (15–55 % altura), HTR carga serp.sup (60–95 % altura), agua a 65–80 °C.
5. Salida ACS: del tope de D2 a VMT1 (mezcladora termostática 55 °C, distribución ≥ 50 °C RD 865/2003).
6. Distribución del agua precalentada hacia las viviendas en paralelo con la red AFS hasta el conjunto V3V_APT_XX + CE-XX de cada apartamento.
7. **V3V_APT_XX** selecciona la entrada fría del CE (precalentada por defecto, AFS bajo comando del controlador).
8. CE-XX boostea hasta consigna si la entrada está por debajo, o pasa el agua sin calentar si ya cumple.
9. Punto de uso: antiescaldadura individual en grifos y duchas, 45 °C (RITE IT 1.1.4.3.1).

### 6.2 Acumulador solar D1 — Tusol DB2 450

- **406 L** vitrificado SMALGLASS, ánodo de magnesio accesible (rosca 32 mm, longitud 400 mm). Año fabricación 2015.
- Serpentín **inferior** (2,2 m² / 52 kW / 2200 L/h): primario solar glicol. Superficie suficiente para el campo de 12 m² (caudal nominal P1 0,1–1,2 m³/h según modulación).
- Serpentín **superior** (1,0 m² / 26 kW / 1100 L/h): mini bucle intermedio cerrado para transferencia a piscina (primera barrera entre ACS y agua de piscina).
- Boca de inspección DN125 (RD 865/2003), vaina sonda, termómetro de cabecera.
- Válvula de seguridad sanitaria (8 bar) y vaso de expansión sanitario en lado AFS.

### 6.3 Acumulador aerotérmico D2 — Tusol DB2 450

- **406 L** vitrificado SMALGLASS, ánodo de magnesio. Mismo modelo que D1 (intercambiables físicamente según conveniencia del tendido).
- Serpentín **superior** (1,0 m² / 26 kW / 1100 L/h): HTR, alimentado por P4 cuando V3V3 está en posición D2.
- Serpentín **inferior** (2,2 m² / 52 kW / 2200 L/h): primario BDC en modo ACS (V3V1 en posición D2).
- Boca de inspección DN125, vaina sonda, válvula de seguridad sanitaria y vaso de expansión sanitario.
- Termostato de seguridad Z2 (rearme manual, 95 °C, hardware independiente).

### 6.4 Buffer de climatización D3 — decisión de diseño

- 150 L cerrado, aislamiento Armaflex 32 mm con barrera de vapor.
- Doble uso calor/frío, alimentando 13 fancoils desde una bomba P3 de velocidad variable.

Volumen por debajo del estándar habitual (15–25 L/kW para BDC modulante de 24 kW); decisión deliberada para evitar la complejidad de un segundo buffer y una válvula adicional de selección de modo. Mitigado por la modulación 6–24 kW de la BDC y la inercia de los 13 fancoils en paralelo. Sin solapamiento estacional calor/frío significativo en el clima de Jerez.

### 6.5 Climatización — fancoils

- 13 fancoils **FC-01 a FC-13** alimentados desde D3 por la bomba P3 (velocidad variable).
- Cada fancoil incorpora:
  - 2 llaves de corte (impulsión y retorno).
  - Válvula de equilibrado dinámico (PICV).
  - Bandeja y desagüe de condensados con sifón antiolores; en unidades elevadas, bandeja secundaria con sensor de inundación.
- Ramal D3 ↔ fancoils aislado con Armaflex con barrera de vapor (incluidos accesorios y soportes).

### 6.6 Climatización de piscina — tres fuentes, topología por ruta

#### 6.6.1 Ruta solar → piscina (con doble separación)

El primario solar nunca contacta agua de piscina directamente. El mini bucle intermedio actúa como zona neutra entre el ACS de D1 y el agua de piscina:

```
[Solar primario glicol]
    │
    └─► serp.inf D1 ──── pared serpentín ────► ACS en D1
                                                  │
                                                  │ ◄── pared serp.sup D1 (1ª barrera)
                                                  ▼
                          [MINI BUCLE INTERMEDIO — agua tratada cerrada]
                          ├─ P2 circuladora pequeña
                          ├─ VE_INT vaso expansión
                          ├─ VS_INT válvula seguridad
                          ├─ MAN1 manómetro
                          ├─ TT_INT termómetro
                          ├─ Filtro Y
                          ├─ Purgador automático
                          └─ Llaves de llenado y vaciado
                                                  │
                                                  │ ◄── placas titanio HX1 (2ª barrera)
                                                  ▼
                                          AGUA DE PISCINA
```

Doble separación garantizada en la ruta más sensible (la única que parte de un acumulador en contacto con ACS).

#### 6.6.2 Ruta BDC primario → piscina (separación simple)

```
[BDC primario] ──► V3V1 ──► V3V2 ──► HX_BDC (titanio) ──► PISCINA
```

Doble fallo encadenado para llegar a ACS (placa HX_BDC + serpentín inferior D2). El primario BDC no contacta con D1 en ningún momento.

#### 6.6.3 Ruta HTR → piscina (separación simple)

```
[HTR] ──► V3V3 ──► HX_HTR (titanio) ──► PISCINA
```

Doble fallo encadenado para llegar a ACS (placa HX_HTR + serpentín superior D2). El HTR no contacta con D1 en ningún momento.

#### 6.6.4 Conexión común al circuito secundario de piscina

Las tres ramas convergen en un colector después del HX y antes del retorno a piscina. El bombeo del lado piscina lo proporciona la bomba de filtración existente, distribuyendo el caudal entre los tres HX en paralelo más una rama de bypass de filtración pura (ver Sec. 7.6.5).

### 6.7 Válvulas motorizadas — distribución de las fuentes

| Válvula | Tipo | Rama | Posiciones |
|---|---|---|---|
| **V3V_SOL** | 3 vías 230 VAC, DN20 | Primario solar | a) serp.inf D1 (ACS); b) serp.sup D1 (piscina) |
| **V3V1** | 3 vías 230 VAC, DN25 | Primario BDC | a) serp.inf D2 (ACS); b) hacia V3V2 |
| **V3V2** | 3 vías 230 VAC, DN25 | Salida "no-D2" de V3V1 | a) D3 (climatización); b) HX_BDC (piscina) |
| **V3V3** | 3 vías 230 VAC, DN20 | Salida HTR | a) serp.sup D2 (ACS); b) HX_HTR (piscina) |

**Modos del primario BDC:**

| V3V1 | V3V2 | Modo |
|---|---|---|
| D2 | — | Carga ACS |
| no-D2 | D3 | Climatización |
| no-D2 | HX_BDC | Piscina dedicado |

**Modos del HTR (independiente de V3V1/V3V2):**

| V3V3 | Modo |
|---|---|
| D2 sup | Boost ACS (por defecto) |
| HX_HTR | Recuperación HTR a piscina |

**Modos del solar (independiente del resto):**

| V3V_SOL | Modo |
|---|---|
| serp.inf D1 | Calentamiento ACS (por defecto) |
| serp.sup D1 | Aporte a piscina vía mini bucle intermedio |

## 7. ELEMENTOS Y CANTIDADES

### 7.1 Equipos principales

| Código | Equipo | Cantidad |
|---|---|---|
| BDC | Ecoforest ecoAIR+ 6-24 PRO | 1 |
| S-01…S-06 | Colectores solares planos 2 m² | 6 |
| D1 | Acumulador solar vitrificado **Tusol DB2 450** (406 L), 2 serpentines: inf 2,2 m²/solar, sup 1,0 m²/intermedio piscina | 1 |
| D2 | Acumulador aerotermia vitrificado **Tusol DB2 450** (406 L), 2 serpentines: inf 2,2 m²/BDC, sup 1,0 m²/HTR | 1 |
| D3 | Buffer climatización cerrado 150 L | 1 |
| **HX1** | Intercambiador placas titanio 5 kW | 1 |
| **HX_BDC** | Intercambiador placas titanio 12 kW | 1 |
| **HX_HTR** | Intercambiador placas titanio 3 kW | 1 |
| VMT1 | Válvula mezcladora termostática DN20, 55 °C | 1 |
| V3V1, V3V2 | Válvulas 3 vías motorizadas DN25 230 VAC | 2 |
| V3V3, V3V_SOL | Válvulas 3 vías motorizadas DN20 230 VAC | 2 |
| VP_HX1, VP_HX_HTR | Válvulas motorizadas 2 vías **DN20** 230 VAC (lado piscina, ramas solar y HTR) | 2 |
| VP_HX_BDC | Válvula motorizada 2 vías **DN25** 230 VAC (lado piscina, rama BDC) | 1 |
| **EV_BYPASS** | Electroválvula 2 vías **NC** DN25, 230 VAC (bypass piscina, cableada en paralelo con VP_HX) | 1 |
| **IF_PISC** | Interruptor de flujo paleta **DN25**, contacto **NA** 230 VAC (cadena de seguridad hardware en serie con VP_HX1, VP_HX_BDC, VP_HX_HTR) | 1 |
| **V3V_APT_01…V3V_APT_05** | Válvulas motorizadas 3 vías DN20 230 VAC (selección AFS / precalentada) | 5 |
| CE-01…CE-05 | Calentadores eléctricos individuales | 5 |
| FC-01…FC-13 | Fancoils con bandeja de condensados | 13 |

### 7.2 Bombas

| Código | Función | Características indicativas |
|---|---|---|
| **P1** | Solar primario modulante | **Teula TEU-III DN20 / 6 m / 130 mm**, motor EC, señal PWM, 5–42 W, rango 0,1–1,2 m³/h. Señal de control vía **convertidor 0-10 V → PWM** (~20–25 €) interpuesto entre la salida analógica del Eliwell y el conector Molex de la bomba. |
| P2 | Mini bucle intermedio piscina | Wilo Yonos PICO 15/1-4 o Grundfos Alpha 1L, 5–15 W |
| P3 | Fancoils | Velocidad variable, alta eficiencia, DN32 |
| P4 | HTR | Circuladora dedicada, integrada o externa según ecoAIR+ |
| P_BDC_PRIM | Primario BDC | Integrada en la BDC (no se suministra externa) |
| P_PISC | Filtración piscina | Existente, ~5–6 m³/h |

### 7.3 Seguridad y regulación hidráulica

**Válvulas de seguridad:**

- VS1 solar 6 bar / 105 °C.
- VS sanitaria en D1 (8 bar) con desagüe visible.
- VS sanitaria en D2 (8 bar) con desagüe visible.
- VS sanitaria en cada CE-01…CE-05 (8 bar).
- VS_INT mini bucle intermedio piscina (3 bar).
- VS circuito fancoils (3 bar).

**Vasos de expansión:**

- VE1 solar: 30–40 L (dimensionado para condición de estancamiento, no solo para expansión normal).
- VE2 fancoils: 12–18 L.
- **VE_AFS sanitario centralizado: 30–35 L** (dimensionado para absorber la expansión combinada de D1 + D2 + distribución: 812 L × 2,5 % ≈ 20 L de expansión hasta consigna de pasteurización 70 °C, factor de utilización de membrana 0,69 → VE nominal 30 L). Membrana sanitaria certificada para contacto alimentario (Reflex Refix DD, Zilmet Hydro-Pro Inox o equivalente), precarga 2,5 bar, conexión DN20. No se instalan VE individuales en los CE-01…CE-05 al estar todos hidráulicamente conectados al VE_AFS centralizado vía las V3V_APT.
- VE_INT mini bucle intermedio piscina: 3–5 L.

**Detección y diagnóstico:**

- MAN1 manómetro permanente en mini bucle intermedio.
- Manómetros en cabecera de circuitos solar, fancoils, primario BDC y HTR.
- Termómetros analógicos en D1, D2, D3 y mini bucle intermedio.

**Antirretornos:**

- **AR_GENERAL**: en la acometida de la red AFS, antes del reductor de presión y del VE_AFS centralizado (obligatorio CTE HS-4 para protección de la red pública). Es el único AR de la línea sanitaria.
- AR de circuitos cerrados: solar primario, primario BDC, HTR, mini bucle intermedio piscina, circuito fancoils (un AR por circuito).
- No se instalan AR individuales en cada CE: la V3V_APT_XX aporta la función de aislamiento direccional entre AFS y precalentada por construcción (posición de selección bloquea físicamente el ramal alternativo).

**Termostatos de seguridad con rearme manual (hardware independiente):**

- Z1 en D1 a 105–110 °C (sobretemperatura solar).
- Z2 en D2 a 95 °C (sobretemperatura combinada HTR+BDC).

**Antiescaldadura**: válvula termostática individual en cada grifo y ducha de las 5 viviendas (45 °C punto de uso).

**Otros:**

- Reductor de presión AFS si presión de red > 4 bar.
- Separador de aire / desaireador en punto alto del solar.
- Purgadores automáticos con válvula de corte en todos los puntos altos.
- Filtros Y en aspiración de cada bomba (P1, P2, P3, P4).
- Disipador térmico solar como respaldo del modo descarga.

### 7.4 Llaves de corte

| Tipo | Cantidad |
|---|---|
| Llaves principales VC01–VC39 | 39 |
| Llaves individuales fancoils (2 por unidad) | 26 |
| Llaves HX1, HX_BDC, HX_HTR (2 por intercambiador) | 6 |
| Llaves V3V_APT_XX (2 por apartamento: AFS y precalentada) | 10 |
| Llave maestra AFS | 1 |
| **Total** | **82** |

### 7.5 Sistema de control — arquitectura de dos controladores

La instalación se controla mediante dos autómatas programables Eliwell de la familia FREE, comunicados por **RS485 Modbus RTU**:

- **FREE Smart SMD4500C** (esclavo Modbus, dirección 1): subsistema solar.
- **FREE Evolution EVD/EVC** (maestro Modbus): resto de subsistemas.

Ambos se programan en Structured Text (IEC 61131-3) con **FREE Studio Plus**. La comunicación RS485 utiliza cable apantallado de 2 pares trenzados con resistencias de terminación de 120 Ω en cada extremo, velocidad 19.200 baudios, polling cada 5–10 s.

```
FREE Smart (esclavo:1)                    FREE Evolution (maestro)
    │                                           │
    │◄──── RS485 · 2 hilos A/B + GND ─────────►│
    │                                           │
    │  registros 100-110: datos → maestro       │
    │  registros 200-205: órdenes ← maestro     │
```

---

#### 7.5.1 FREE Smart SMD4500C — subsistema solar

**I/O físicas:**

| Recurso | Señal | Función |
|---|---|---|
| AI 1 (NTC/Pt1000) | **TT1** | Temperatura salida colector |
| AI 2 (NTC/Pt1000) | **TT2** | D1 fondo |
| AI 3 (NTC/Pt1000) | **TT3** | D1 cabeza |
| AO 0-10 V | **P1** | Señal → convertidor 0-10 V → PWM → TEU-III |
| DO relé 1 | **V3V_SOL** | Solar hacia ACS (serp.inf D1) o piscina (serp.sup D1) |
| DO relé 2 | **PERS_SOL** | Persianas colectores (todo-nada) |
| DO relé 3 | **P2** | Mini bucle intermedio piscina |
| DO relé 4 | **ALM_SOLAR** | Alarma local solar (óptica/sonora en cuadro) |

**Especificaciones del FREE Smart SMD4500C (ficha técnica Eliwell):**
- Alimentación: 100–240 Vac
- Entradas analógicas: 5 (3× NTC/Pt1000/DI + 2× NTC/DI/0-10V/4-20mA)
- Salidas analógicas: 5 (2× OC/PWM + **2× 0-10V** + 1× 4-20mA)
- Salidas digitales: 4 relés × 2A 250Vac
- Conectividad: RS485, LAN, TTL
- Expansión: módulo SME si se necesitan más I/O

**Lógica autónoma del FREE Smart:**

El FREE Smart implementa íntegramente el control solar sin depender del FRE para su funcionamiento básico:
- Lazo PI de ΔT constante para P1 (objetivo 8 K, configurable vía registro Modbus desde FRE).
- Arbitraje V3V_SOL (ACS vs piscina) según TT3 y setpoint recibido del FRE.
- Control PERS_SOL (cierre cuando TT2 > umbral configurable).
- Control P2 sincronizado con V3V_SOL en posición piscina.
- Alarma local si TT1 > 95 °C.

Si el FRE está en mantenimiento o reprogramación, el solar continúa operando de forma autónoma con los últimos setpoints recibidos.

**Registros Modbus exportados al FRE (lectura maestro):**

| Registro | Variable | Tipo | Descripción |
|---|---|---|---|
| 100 | TT1 | INT (×10) | Temperatura colector (°C × 10) |
| 101 | TT2 | INT (×10) | D1 fondo (°C × 10) |
| 102 | TT3 | INT (×10) | D1 cabeza (°C × 10) |
| 103 | vel_P1 | UINT (0-1000) | Velocidad P1 (‰) |
| 104 | est_V3V_SOL | BOOL | 0=ACS, 1=piscina |
| 105 | est_PERS | BOOL | 0=abiertas, 1=cerradas |
| 106 | est_P2 | BOOL | 0=parado, 1=activo |
| 107 | alarma_solar | UINT | Código alarma (0=OK) |
| 108 | DT_solar | INT (×10) | ΔT medido TT1−TT2 |

**Registros Modbus recibidos del FRE (escritura maestro):**

| Registro | Variable | Tipo | Descripción |
|---|---|---|---|
| 200 | SP_DT_solar | UINT | Setpoint ΔT objetivo P1 (K, por defecto 8) |
| 201 | modo_solar | UINT | 0=auto, 1=forzar ACS, 2=forzar piscina, 3=off |
| 202 | orden_persianas | BOOL | 0=auto, 1=forzar cierre |
| 203 | SP_TT3_piscina | UINT | Umbral TT3 para desvío a piscina (°C) |

---

#### 7.5.2 FREE Evolution — subsistema principal

Gestiona ACS, climatización, piscina, apartamentos y coordina el sistema completo.

**Sondas de temperatura locales (11):**

| Sonda | Ubicación | Función |
|---|---|---|
| TT4 | D2 fondo | Demanda BDC modo ACS |
| TT5 | D2 cabeza | Setpoint final ACS, arbitraje V3V3 |
| TT6 | D3 cabeza | Control buffer modo calor |
| TT7 | D3 fondo | Control buffer modo frío |
| TT8 | Ida primario BDC | Supervisión BDC |
| TT9 | Retorno primario BDC | Supervisión BDC |
| TT10 | Ida HTR | Control P4 y arbitraje V3V3 |
| TT11 | Piscina | Demanda piscina, parada por setpoint |
| TT12 | Exterior | Curvas climáticas |
| TT13 | Retorno común fancoils | Diagnóstico |
| TT14 | Mini bucle intermedio piscina | Confirmación aporte solar |

**Variables recibidas del FREE Smart vía Modbus (registros 100-108):**
TT1, TT2, TT3, vel_P1, est_V3V_SOL, est_PERS, est_P2, alarma_solar, DT_solar — disponibles como variables locales del FRE para toda la lógica de sistema.

**Entradas digitales:**
- Z1, Z2 (termostatos hardware, lectura informativa).
- Sensores de inundación de bandejas secundarias de fancoils.

**Salidas digitales (13):**

| Salida | Señal | Función |
|---|---|---|
| DO 1 | V3V1 | Primario BDC → D2 / hacia V3V2 |
| DO 2 | V3V2 | Primario BDC → D3 / HX_BDC |
| DO 3 | V3V3 | HTR → D2 sup / HX_HTR |
| DO 4 | VP_HX1 | Lado piscina HX1 |
| DO 5 | VP_HX_BDC | Lado piscina HX_BDC |
| DO 6 | VP_HX_HTR | Lado piscina HX_HTR |
| DO 7 | V3V_APT_01 | Apartamento 1: AFS/precalentada |
| DO 8 | V3V_APT_02 | Apartamento 2 |
| DO 9 | V3V_APT_03 | Apartamento 3 |
| DO 10 | V3V_APT_04 | Apartamento 4 |
| DO 11 | V3V_APT_05 | Apartamento 5 |
| DO 12 | P3 | Fancoils (arranque/paro) |
| DO 13 | P4 | HTR (arranque/paro) |

**Salida analógica (1):**
- AO 0-10V: modulación P3 velocidad variable (si se opta por velocidad variable en fancoils).

**Necesidades de expansión del FRE:**
- Base FRE Evolution: ~6 AI y ~8-10 DO.
- Para cubrir 11 AI + 13 DO: se prevé **1 módulo de expansión EVE** (hasta 12 módulos admitidos por el FRE).

**Especificaciones FREE Evolution base (ficha técnica Eliwell):**
- 27 I/O totales: 6 AI + 5 AO + 16 DI/DO configurables.
- Conectividad: RS485, LAN (TCP/IP), USB.
- Expansión: hasta 12 módulos EVE vía CANopen o RS485.

---

#### 7.5.3 Cableado RS485 entre controladores

```
FREE Smart SMD4500C          FREE Evolution EVD/EVC
    borne A+ ─────────────────── borne A+
    borne B- ─────────────────── borne B-
    borne GND ────────────────── borne GND
    [120 Ω entre A y B]          [120 Ω entre A y B]
```

- Cable: apantallado 2 pares trenzados, sección 0,22–0,5 mm², pantalla a tierra en un solo extremo.
- Velocidad: 19.200 baudios, 8N1.
- FREE Smart: esclavo dirección **1**.
- FREE Evolution: maestro, polling cada **5 s**.
- En caso de fallo de comunicación (timeout): FRE activa alarma y el FREE Smart mantiene el último modo conocido.

### 7.6 Dimensionamiento de intercambiadores y circuladoras

Coeficiente de transferencia global U adoptado para PHE titanio agua–agua en condiciones de piscina: **U ≈ 3.500 W/m²·K** (valor conservador; típico catálogo Bowman/Pahlén/Onda 3.000–5.000). Factor de margen de seguridad sobre área calculada: **1,5**.

#### 7.6.1 HX1 — solar (mini bucle intermedio) → piscina

**Condiciones nominales de operación:**

| Lado | Fluido | T entrada | T salida | Caudal |
|---|---|---|---|---|
| Primario | Agua tratada (bucle intermedio) | 42 °C | 35 °C | 0,65 m³/h |
| Secundario | Agua de piscina | 26 °C | 30 °C | 1,1 m³/h |

- Potencia nominal: **5 kW**.
- LMTD ≈ ((42−30) − (35−26)) / ln(12/9) ≈ **10,4 K**.
- Área necesaria: 5.000 / (3.500 × 10,4) ≈ 0,14 m². Con margen 1,5×: **0,21 m²**.
- Configuración: PHE brazed titanio, **~15 placas**, conexiones **DN20 (3/4")**, modelo de referencia Bowman 3.4, Pahlén Hi-Flow 13 o equivalente.
- Pérdida de carga estimada: 3–5 kPa primario, 5–10 kPa secundario.

#### 7.6.2 HX_BDC — primario BDC → piscina

**Condiciones nominales de operación:**

| Lado | Fluido | T entrada | T salida | Caudal |
|---|---|---|---|---|
| Primario | Agua + inhibidor (primario BDC) | 42 °C | 35 °C | 1,5 m³/h |
| Secundario | Agua de piscina | 26 °C | 30 °C | 2,5 m³/h |

- Potencia nominal: **12 kW**.
- LMTD ≈ **10,4 K** (mismas T que HX1, mayor caudal).
- Área necesaria: 12.000 / (3.500 × 10,4) ≈ 0,33 m². Con margen 1,5×: **0,50 m²**.
- Configuración: PHE brazed titanio, **~30 placas**, conexiones **DN25 (1")**, modelo de referencia Bowman 5.5, Pahlén Hi-Flow 25 o equivalente.
- Pérdida de carga estimada: 8–15 kPa primario, 10–20 kPa secundario.

#### 7.6.3 HX_HTR — HTR → piscina

**Condiciones nominales de operación:**

| Lado | Fluido | T entrada | T salida | Caudal |
|---|---|---|---|---|
| Primario | Agua + inhibidor (lazo HTR) | 75 °C | 65 °C | 0,26 m³/h |
| Secundario | Agua de piscina | 26 °C | 28 °C | 1,3 m³/h |

- Potencia nominal: **3 kW** (continua mientras la BDC está activa).
- LMTD ≈ ((75−28) − (65−26)) / ln(47/39) ≈ **43 K** (gran salto térmico por agua del HTR a 70–80 °C).
- Área necesaria: 3.000 / (3.500 × 43) ≈ 0,02 m². Con margen amplio: **0,10 m²**.
- Configuración: PHE brazed titanio, **~10 placas** (mínimo comercial habitual), conexiones **DN20 (3/4")**, modelo de referencia Bowman 0.8, Pahlén Aqua-Mex F11 o equivalente.
- Pérdida de carga estimada: 2–4 kPa primario, 5–10 kPa secundario.

#### 7.6.4 Circuladoras dedicadas

**P2 — mini bucle intermedio piscina:**

- Caudal nominal: **0,65 m³/h**.
- Pérdida de carga del lazo:
  - Serpentín superior D1: 10–15 kPa
  - HX1 primario: 3–5 kPa
  - Filtro Y, accesorios y tubería: 8–15 kPa
  - **Total: 25–35 kPa ≈ 2,5–3,5 m.c.a.**
- Selección: **Wilo Yonos PICO 15/1-4** o **Grundfos Alpha 1L 15-40**, conexión DN15-20, **consumo 5–15 W**.
- Funcionamiento intermitente (solo cuando V3V_SOL está en posición piscina).

**P4 — HTR:**

- Caudal nominal: **0,26 m³/h**.
- Pérdida de carga: HX_HTR primario + serp.sup D2 + accesorios ≈ 15–25 kPa.
- Confirmar con ficha técnica Ecoforest si P4 viene integrada en la ecoAIR+ PRO o se suministra externa.
- Si externa: circuladora pequeña de alta eficiencia, **5–10 W**.

**Otras circuladoras:**

- **P1 (solar)**: caudal 50 L/h·m² × 12 m² = 0,6 m³/h a 20–25 kPa. Selección Grundfos Solar PM2 15-35, **15–30 W**.
- **P3 (fancoils)**: a calcular con suma de caudales nominales de los 13 fancoils y pérdida de carga del circuito; típicamente 1,5–2,5 m³/h a 40–60 kPa, alta eficiencia, **40–80 W**.
- **P_BDC_PRIM**: integrada en la ecoAIR+; caudal regulado por la BDC en función de modulación.
- **P_PISC**: bomba de filtración existente; típicamente 5–6 m³/h para recirculación completa de 36 m³ en 6–8 h.

#### 7.6.5 Distribución del caudal en el lado piscina

La bomba de filtración P_PISC opera de forma continua para la propia filtración. Después del filtro, el caudal entra a un **colector con cuatro ramas en paralelo**:

```
P_PISC ──► Filtro ──► COLECTOR ──┬──► VP_HX1     ──► HX1     ──► retorno piscina
                                  ├──► VP_HX_BDC ──► HX_BDC  ──► retorno piscina
                                  ├──► VP_HX_HTR ──► HX_HTR  ──► retorno piscina
                                  └──► EV_BYPASS (NC) ─────────── retorno piscina
```

- **IF_PISC**: interruptor de flujo paleta DN25, contacto **normalmente abierto (NA)**, instalado en la tubería de salida del filtro antes del colector. Cableado **en serie** con la alimentación 230 VAC de VP_HX1, VP_HX_BDC y VP_HX_HTR:

```
230V ──► IF_PISC (NA) ──► VP_HX1
                     ──► VP_HX_BDC
                     ──► VP_HX_HTR
```

Cadena de seguridad puramente hardware: si la bomba de filtración para o el flujo es insuficiente, IF_PISC abre → las tres VP quedan sin tensión → cierran físicamente → al cortar tensión a VP, el relé auxiliar de EV_BYPASS también se desenergiza → EV_BYPASS abre → protección completa del PVC de la instalación de piscina sin intervención del Eliwell, sin software, sin posibilidad de fallo por bug. Coste: ~15–25 €.

- **VP_HX1, VP_HX_HTR**: válvulas motorizadas 2 vías **DN20**, 230 VAC.
- **VP_HX_BDC**: válvula motorizada 2 vías **DN25**, 230 VAC (mayor caudal: 2,5 m³/h).
- **EV_BYPASS**: electroválvula **normalmente cerrada (NC)** DN25, 230 VAC. **Cableada en paralelo eléctrico con las tres VP**: recibe tensión cuando cualquiera de las VP está energizada → cierra el bypass → todo el caudal va al HX activo. Cuando todas las VP están sin tensión (ningún HX activo) → EV_BYPASS abre → la bomba P_PISC filtra normalmente por el bypass. **No consume ninguna salida digital del Eliwell**: la lógica es puramente cableada mediante un relé auxiliar de 230 VAC (~5 €) cuya bobina se alimenta en paralelo con las VP.
- Caudales de diseño en cada rama: HX1 ~1,1 m³/h, HX_BDC ~2,5 m³/h, HX_HTR ~1,3 m³/h. Suma máxima si los tres activos: 4,9 m³/h, compatible con P_PISC 5–6 m³/h.

## 8. LÓGICAS DE CONTROL

### 8.1 Solar — bomba modulante por ΔT constante

La bomba P1 opera con señal analógica 0-10 V desde el Eliwell. El objetivo es mantener un **ΔT objetivo configurable** (por defecto 8 K) entre la sonda de salida del captador (TT1) y el fondo de D1 (TT2), maximizando la temperatura de entrega al serpentín inferior de D1 independientemente de la irradiancia disponible.

**Arranque:**

- P1 arranca al mínimo (señal 1–2 V, caudal ~0,1 m³/h) cuando TT1 − TT2 > **6 K** (umbral de arranque).
- La señal sube progresivamente hasta alcanzar el ΔT_objetivo.

**Regulación en marcha (lazo proporcional-integral):**

```
error = ΔT_medido − ΔT_objetivo
           = (TT1 − TT2) − 8 K

Si error > 0  →  aumentar señal P1 (más caudal, el fluido se enfría más → ΔT baja)
Si error < 0  →  reducir señal P1 (menos caudal, el fluido sube de temperatura → ΔT sube)

Señal P1 (V) = clamp(señal_anterior + Kp × error + Ki × integral_error, 1, 10)
Kp y Ki ajustables en comisionado (típico Kp 0,3–0,8, Ki 0,05–0,15)
```

Efecto a baja irradiancia (amanecer, nublado): P1 reduce caudal hasta el mínimo → el fluido recorre el campo despacio, se calienta más por unidad de tiempo → TT1 sube → captador trabaja a mayor rendimiento óptico (menor pérdida por convección). El fluido llega más caliente a D1 y favorece la estratificación.

**Parada:**

- P1 para cuando TT1 − TT2 < **3 K** durante 60 s (histéresis anti-cicleo).
- Protección antilegionela: si TT2 < 45 °C durante más de 7 días, el controlador fuerza un arranque de 15 min aunque el diferencial no llegue al umbral (mezcla del volumen de D1 y activa el intercambio con cualquier calor residual).

**Limitaciones de temperatura:**

- Si TT1 > 95 °C: P1 a máxima velocidad (caudal máximo para evacuar el calor y proteger el glicol).
- Si TT2 > 85 °C con todas las cargas satisfechas: activar disipación solar (disipador de excedente).

**Arbitraje V3V_SOL:**

- **V3V_SOL en serp.inf D1 (ACS)**: posición por defecto.
- **V3V_SOL en serp.sup D1 (piscina)**: si TT3 ≥ 75 °C **y** TT11 < setpoint piscina **y** D2 en setpoint (ACS satisfecho). La modulación de P1 continúa activa en esta posición con el mismo algoritmo (TT1 vs TT_INT del mini bucle en lugar de TT2).

### 8.2 ACS

- **HTR pasivo**: V3V3 en D2 sup mientras TT5 < setpoint (65 °C).
- **Modo dedicado ACS**: V3V1 a D2 si TT4 < 50 °C; vuelve a "no-D2" cuando TT5 alcanza 65 °C.
- **Setpoint pasteurización D2**: 70 °C.

### 8.3 Climatización

- V3V1 en "no-D2", V3V2 en D3.
- **Calor**: TT6 entre 45 °C (arranque) y 50 °C (parada).
- **Frío**: TT7 entre 9 °C (arranque) y 7 °C (parada).
- P3 modula caudal según número de fancoils activos.

### 8.4 Piscina — tres modos coexistentes

**Modo solar autónomo** (sin coste eléctrico añadido salvo P2):

- Condición: TT3 ≥ 75 °C y TT11 < setpoint piscina.
- Acción: V3V_SOL → serp.sup D1, P2 ON, **VP_HX1 abierta**.

**Modo BDC primario dedicado a piscina:**

- Condición: TT11 < setpoint − 1 K, no hay demanda ACS prioritaria, y (no hay demanda de climatización o se ha invertido la prioridad).
- Acción: V3V1 → "no-D2", V3V2 → HX_BDC, **VP_HX_BDC abierta**, BDC en modo calefacción modulada.

**Modo HTR a piscina (recuperación oportunista):**

- Condición: BDC activa por cualquier motivo + TT5 ≥ 65 °C (D2 satisfecho) + TT11 < setpoint piscina.
- Acción: V3V3 → HX_HTR, **VP_HX_HTR abierta**, P4 ON.
- **Particularmente valioso en verano** con BDC en refrigeración para fancoils: el HTR se produce siempre que el compresor funciona y de otra manera se desperdiciaría con D2 en setpoint. La recuperación efectiva eleva el COP estacional combinado del sistema.

**Coexistencia simultánea**: las tres rutas pueden estar activas al mismo tiempo. Aporte combinado máximo al lado piscina: ~20 kW (5 + 12 + 3).

### 8.5 Prioridad de la BDC — gestión configurable

Prioridad por defecto:

1. **ACS** (TT4 < 50 °C o ciclo de pasteurización): siempre primero.
2. **Climatización** (demanda activa de fancoils): segundo.
3. **Piscina** (TT11 < setpoint): tercero.

**Perfil "uso intensivo piscina"** (configurable): ACS > Piscina > Climatización. Útil cuando el propietario quiere asegurar temperatura de baño confortable y la demanda de climatización es flexible.

### 8.6 V3V_APT_XX — selección de fuente fría por apartamento

- **Posición por defecto**: precalentada. Cada V3V_APT alimenta su CE desde la salida común de VMT1, aprovechando el preheating del sistema central. El CE solo dispara su resistencia si el agua entrante está por debajo de la consigna del termo.
- **Posición AFS**: por comando explícito del controlador. Casos:
  - **Mantenimiento del sistema central** (D1, D2, VMT1, mini bucle intermedio, BDC): el apartamento sigue teniendo ACS local funcional desde AFS + CE.
  - **Mantenimiento del propio CE** (cambio de ánodo, limpieza): el ramal puede aislarse cerrando las llaves de servicio aguas arriba.
  - **Vacancia prolongada del apartamento** (> 2 semanas): selección AFS para evitar dejar agua tibia estancada en el ramal de precalentada local, reduciendo riesgo Legionella.
- **Coordinación con pasteurización**: durante el ciclo, todas las V3V_APT_XX deben estar **forzadas a posición precalentada** para que el agua a temperatura de pasteurización (≥ 60 °C) recorra también el ramal de precalentada hasta los CE y, a través de éstos, hasta los grifos abiertos del programa.
- **Conmutación**: cambios programados en franja horaria de bajo consumo (madrugada) para evitar saltos térmicos bruscos en el grifo del usuario.

### 8.7 Pasteurización antilegionela

- Frecuencia programable, recomendada semanal en horario nocturno.
- Procedimiento:
  1. Todas las V3V_APT_XX en posición precalentada (fuerza al inicio del ciclo).
  2. BDC sube D2 a 70 °C (V3V1 → D2, V3V3 → D2 sup), mantiene 60 min.
  3. Apertura programada de CE-01…CE-05 para circular agua > 60 °C por la red de distribución 30 min (rotación de viviendas para no saturar la potencia eléctrica).
  4. Registro de evento, temperaturas y duración.
- Pasteurización D1: por radiación solar natural en jornadas de alta irradiancia; complemento programado con carga BDC al fondo de D1 vía bypass si tras 7 días no se ha alcanzado > 60 °C en TT2.

### 8.8 Seguridades hardware

- Z1, Z2 cortan alimentación de las circuladoras correspondientes con rearme manual, independientemente del controlador.
- Detector de fuga R290 en el alojamiento de la BDC (recomendado), con alarma local y al controlador.
- Sensores de inundación de bandejas secundarias de fancoils elevados cortan la unidad correspondiente.

## 9. ESTIMACIONES ENERGÉTICAS

### 9.1 ACS

- Capacidad total ACS (D1 + D2): **812 L** (2 × Tusol DB2 450 de 406 L sanitaria). Autonomía con depósitos a plena carga: ~34 kWh térmicos almacenados (15 → 60 °C), equivalente a ~1,4 días de demanda sin aporte.
- Fracción solar estimada: 70–80 % anual (CHEQ4).

### 9.2 Piscina

- Energía para elevar 36 m³ de 15 °C a 26 °C: 36 × 1,163 × 11 ≈ **460 kWh**.
- Calentamiento inicial con aporte combinado (solar 5 kW + BDC primario 12 kW + HTR 3 kW ≈ **20 kW pico**): **1–3 días** dependiendo de hipótesis de funcionamiento y radiación, con cobertor isotérmico.
- Mantenimiento de temporada extendida (primavera/otoño): aporte BDC permite operación con bajo recurso solar a coste eléctrico moderado (1–3 kWh/día).
- Aprovechamiento HTR en refrigeración estival: 2–3 kW × 6–8 h/día ≈ **15–25 kWh/día gratuitos** a piscina (sin consumo eléctrico adicional, mejora notable del COP estacional del sistema).

### 9.3 Climatización

- Carga máxima refrigeración (estimada): 18–22 kW.
- Carga máxima calefacción (estimada): 14–18 kW.
- Consumo eléctrico anual orientativo BDC + bombas: **7.000–11.000 kWh** (a confirmar con simulación CYPETHERM o EnergyPlus).

### 9.4 Bombas auxiliares

- Consumo anual estimado P1+P2+P3+P4: **900–1.400 kWh**.

## 10. SEGURIDAD R290 — EN 378

- BDC instalada en exterior, sin recintos cerrados próximos.
- Distancias mínimas a aberturas, ventanas, rejillas de ventilación y desagües bajo cota.
- Zonas de exclusión dimensionadas conforme a EN 378-3, según carga real de refrigerante.
- Documentación in situ: placa de identificación, procedimiento de emergencia.
- Mantenimiento por empresa habilitada (RD 115/2017 y EN 13313).

## 11. CUMPLIMIENTO NORMATIVO — SÍNTESIS

| Requisito | Solución adoptada |
|---|---|
| CTE HE-4 aportación solar mínima zona V (70 %) | 12 m² captadores, 70–80 % anual (CHEQ4) |
| CTE HE-4 límites sobrecalentamiento | Disipación a piscina vía mini bucle intermedio y disipador térmico de respaldo |
| CTE HS-4 protección red potable | Doble separación en la ruta solar→piscina (la más crítica); separación simple en BDC y HTR (piscina cat. 4, EN 1717) |
| RD 865/2003 distribución ≥ 50 °C | VMT1 a 55 °C |
| RD 865/2003 pasteurización | Ciclo semanal D2 a 70 °C 60 min, registrado |
| RD 865/2003 limpieza/desinfección | Bocas DN125 en D1, D2; ánodos accesibles |
| RITE IT 1.1.4.3.1 quemaduras | Antiescaldadura individual en grifos y duchas |
| RITE IT 1.3.4.2 sobretemperatura | Z1, Z2 hardware con rearme manual |
| EN 1717 separación cat. 4 (piscina privativa) | Una pared de titanio entre cada fluido y agua piscina; presiones favorables al sentido "fluido técnico → piscina" en caso de fuga |
| EN 378 R290 A3 | Ubicación exterior, zonas de exclusión, ventilación natural |

## 12. PLAN DE MANTENIMIENTO MÍNIMO

| Frecuencia | Actuación |
|---|---|
| **Mensual** | Eventos de pasteurización; presiones de circuitos (solar, fancoils, primario BDC, MAN1 mini bucle intermedio); modo activo de cada V3V y VP |
| **Trimestral** | Limpieza de filtros Y; bandejas de condensados; inspección visual campo solar y bomba de filtración piscina |
| **Semestral** | Verificación de glicol solar (concentración y pH); presiones de vasos de expansión (incluido VE_INT); ánodos accesibles; ensayo funcional de los tres modos de piscina; control pH/conductividad del agua de piscina (indicador indirecto de fuga en cualquier HX) |
| **Anual** | Limpieza y desinfección D1, D2 (RD 865/2003); sustitución preventiva de ánodos; mantenimiento BDC por empresa habilitada (RD 115/2017); revisión completa de seguridades; prueba de estanqueidad de HX1, HX_BDC, HX_HTR y serpentines de D1 y D2 |

## 13. DECISIONES DE DISEÑO DOCUMENTADAS

1. **Buffer D3 único de 150 L para frío y calor**: opción consciente frente a la alternativa de doble buffer con válvula de selección de modo. Se asume menor estratificación y mayor frecuencia de ciclos a baja carga; mitigado por la modulación 6–24 kW de la BDC y la inercia de los 13 fancoils en paralelo.

2. **Topología asimétrica de aportes a piscina**: doble separación únicamente en la ruta solar (vía sup serp D1 + mini bucle intermedio + HX1), separación simple en las rutas BDC y HTR (HX titanio directo). Razón: el agua sanitaria de D1 está en contacto directo con el primario solar; un fallo único en esa ruta sería crítico. Las rutas BDC y HTR no contactan con D1 y requerirían un doble fallo (placa HX + serpentín de D2) para alcanzar ACS, lo que constituye doble separación efectiva por encadenamiento.

3. **No individualización de consumos por vivienda**: titularidad única, no aplica IT 1.2.4.4. Se prescinde de calorímetros individuales y contadores ACS por vivienda. Se conserva contador de aporte solar útil y registro de horas/energía BDC por modo (ACS, climatización, piscina) en el controlador.

4. **Calentadores CE-01…CE-05 como respaldo final, alimentados por V3V_APT motorizada**: dimensionado y lógica orientados a minimizar su uso. La V3V_APT delante de cada CE sustituye al AR individual (por aislamiento direccional de construcción) y al VE individual (la expansión local del CE se transmite por su entrada de fluido seleccionada hasta el VE_AFS centralizado de 30–35 L). El conjunto reduce componentes sanitarios redundantes (-5 AR y -5 VE individuales) a cambio de 5 V3V motorizadas, con ventaja operativa de aislamiento por vivienda sin cortar suministro AFS general.

5. **Cobertor isotérmico de piscina recomendado**: con aporte BDC ya no es condición de viabilidad pero sigue reduciendo el consumo eléctrico de mantenimiento en 50–70 %.

6. **Bomba solar P1 modulante TEU-III DN20 con convertidor 0-10 V → PWM**: se adopta la circuladora PWM Teula TEU-III DN20 / 6 m / 130 mm (motor EC, 5–42 W, desde 102,86 € + IVA), específica para instalaciones solares y circuitos cerrados. Acepta señal PWM; la interfaz con la salida analógica 0-10 V del Eliwell FRE Evolution se resuelve mediante un módulo convertidor 0-10 V → PWM (~20–25 €). El lazo proporcional-integral de ΔT constante (objetivo 8 K) se implementa íntegramente en el Eliwell, que genera la señal 0-10 V; el convertidor la transforma en duty cycle PWM para la TEU-III. Coste total P1 + convertidor ~145–150 € IVA incluido, frente a los 200–350 € de alternativas con entrada 0-10 V directa (Wilo Stratos PICO, Grundfos MAGNA1).

## 14. CONCLUSIONES

La instalación integra solar térmica, aerotermia modulante con HTR y respaldo eléctrico distribuido en una arquitectura coherente para vivienda con apartamentos turísticos en clima mediterráneo-atlántico. El aporte aerotérmico a piscina (primario vía HX_BDC y HTR vía HX_HTR) convierte la piscina privativa en un servicio plenamente operativo en temporada extendida, conservando la seguridad del agua sanitaria común a los apartamentos mediante doble separación en la única ruta de contacto potencial (solar↔ACS↔piscina).

Las decisiones de diseño han priorizado:

- **Cumplimiento normativo**: HE-4, HS-4, RITE, RD 865/2003, EN 1717, EN 378.
- **Seguridad sanitaria**: doble barrera en la ruta solar a piscina; doble fallo encadenado en las rutas BDC y HTR; antiescaldadura terminal.
- **Eficiencia y aprovechamiento**: 70–80 % de fracción solar ACS; recuperación HTR a piscina elevando el COP combinado en verano; modulación amplia de BDC; jerarquía de prioridades configurable.
- **Simplicidad relativa**: buffer único de climatización; sin individualización de consumos; bucle intermedio reducido a la ruta solar; HX titanio directos en las rutas BDC y HTR.

Puntos abiertos a verificación durante ejecución:

- Cálculo formal de fracción solar con CHEQ4.
- Simulación de cargas térmicas con CYPETHERM o equivalente, incluyendo aporte BDC a piscina en escenarios de ocupación variable.
- Confirmación de superficies de serpentín en D1 y D2 con el fabricante (Lapesa, ACV, Ferroli u otro).
- Verificación de modelo concreto de HX titanio con el suministrador (Bowman, Pahlén, Onda, GHE) y ajuste fino de número de placas según ficha técnica real.
- Confirmación de P4 (HTR) como integrada o externa en la ecoAIR+ 6-24 PRO suministrada.
- Cálculo definitivo de zonas de exclusión R290 según carga real de refrigerante.
- Plano de implantación de equipos exteriores con verificación de distancias normativas.
- Diagrama P&ID completo con las cuatro válvulas motorizadas principales (V3V_SOL, V3V1, V3V2, V3V3), las tres válvulas motorizadas de piscina (VP_HX1, VP_HX_BDC, VP_HX_HTR) y los tres intercambiadores HX.
