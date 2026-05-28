# M08 — Sala de máquinas (hidráulica común)

**Estado:** 🔶 colector, bombas, vasos y diámetros definidos · falta confirmar producto.
**Transversal a:** todos los módulos hidráulicos.

## Colector de consumidores (sala)

- **Punto alto común de extracción:** ACS, clima (trasvase P1) y piscina toman de zona alta común del tándem; la prioridad la ejerce el control (M09), no la hidráulica. Retornos al fondo de D1.
- Reparte **agua técnica del tándem** a los consumidores grandes. (Los fancoils NO cuelgan de aquí: van por arborescencia desde el buffer, ver M05.)
- **Colector de latón roscado (sin soldar).** Candidato Wallapop: cuerpo **1" (DN25)**, salidas **3/4"**, encadenable (macho-hembra), 12 €. Es un colector **ajustado, no holgado**: con el cuerpo de 1" y clima+ACS simultáneos (~3.480 L/h) la velocidad interna sube (~1,9 m/s); aceptable porque el clima sale por el extremo y el arbitraje suaviza, pero sin margen. Para holgura: encadenar dos cuerpos o buscar cuerpo de 2".
- Tapón roscado en extremos, **purgador** en alto y **vaciado** en bajo. Sellado cuidadoso de roscas.
- Sin separador hidráulico de marca (Caleffi SEP4/SEPCOLL): innecesario y caro.

### Reparto de bocas

| Boca | Ramal | Caudal |
|---|---|---|
| Extremo 1" | Alimentación desde el tándem (suma de caudales) | ~3.480 L/h |
| Extremo 1" opuesto | **Clima = trasvase P1 al buffer** (el de más caudal) | ~2.400 L/h |
| Salida 3/4" | ACS (primario, P-ACS) | ~1.080 L/h |
| Salida 3/4" | Piscina (P-POOL, ΔT alto) | ~900-1.075 L/h |

> "Clima por el extremo" = el **trasvase P1 al buffer de inercia**, NO los fancoils.

## Posición de las bombas

- Prevalece la **aspiración con presión positiva** (evitar cavitación), con el vaso del lado de aspiración. La "parte fría" es criterio menor.
- Cada bomba en la **impulsión de su ramal** + **válvula de retención aguas abajo** (evita reflujo por el colector con la bomba parada).
- P-ACS en impulsión (por control).

## Criterio de intercambiabilidad de bombas (ESTÁNDAR)

Para que las bombas sean **intercambiables** y un repuesto sirva sin tocar la tubería:

- **Longitud entre roscas: 180 mm en TODAS las circuladoras** (estándar del proyecto). Las de 130 mm (típicas de caldera) **quedan descartadas** aunque cumplan prestaciones — romperían la intercambiabilidad. Montar todos los huecos a 180 mm.
- **Conexión común: DN25, rosca G1½" (tuerca loca), racor Rp1".** Cualquier bomba entra en cualquier puesto de su clase.
- **Dos clases de bomba por exigencia de altura:**
  - **Clase suave (~3-4 m):** P-SOL, P-ACS, P-POOL. Un repuesto de esta clase las cubre.
  - **Clase fuerte (~7-8 m):** P1, P2. **Mismo modelo entre sí** (UPM3 Auto 25-70 180) → un repuesto común cubre las dos.

## Selección de bombas

Bombas DN25 (rosca 1½" tuerca loca), **180 mm**, que encajan en la línea de 1" de la sala. Las modulantes (P-SOL, P-ACS) por **PWM** desde la CPU (M12); las on/off por **relé de interposición**.

| Bomba | Función | Caudal | Altura req. | Long. | Control | Modelo |
|---|---|---|---|---|---|---|
| **P-SOL** | Lazo solar (glicol) | según captadores | ~3-4 m | 180 | PWM modulante (M02) | Grundfos Alpha Solar 25-75 / Wilo iPWM3, **apta glicol** |
| **P-ACS** | Primario ACS instantáneo | ~1.080 L/h | ~3-4 m | 180 | PWM modulante (M04) | A comprar, **variante PWM** |
| **P1** | Trasvase D2 → buffer | ~2.400 L/h | **~7-8 m** (doble serpentín en serie) | 180 | On/off | **Grundfos UPM3 Auto 25-70 180** (igual que P2; verificar curva a 2.400 L/h) |
| **P2** | Buffer → fancoils | **normal ~1,8 m³/h · pico ~3,5 m³/h** | **~7-8 m** (red + Δp PICV) | **180** | Presión constante | **Grundfos UPM3 Auto 25-70 180** (ver abajo) |
| **P-POOL** | Primario HX piscina | ~900-1.075 L/h | ~3-4 m | 180 | On/off | **Grundfos ALPHA2 25-40 180** (reubicada aquí) |

### P1 y P2 = mismo modelo (UPM3 Auto 25-70 180)

**Intención: P1 y P2 idénticas — Grundfos UPM3 Auto 25-70 180** — para repuesto común de clase fuerte. Ambas DN25, 180 mm, 7 m, presión constante autónoma.
- **P2 (fancoils):** ~7 m, pico 3,5 m³/h → la 25-70 encaja (justa en pico, holgada en normal).
- **P1 (trasvase D2→buffer, doble serpentín):** ~2,4 m³/h. ⚠️ **Verificar que la 25-70 (7 m) cubre la pérdida del doble serpentín en serie** a 2.400 L/h. Si P1 necesitara >7 m, decidir entre subir ambas a 25-80 (repuesto común a más altura) o asumir modelos distintos. *Pendiente: pérdida real del doble serpentín.*
- En modo on/off (P1) la UPM3 Auto se fija a velocidad/curva constante; en P2 trabaja en presión constante.

### P2 — dimensionado y bomba

**Fancoils mayoritariamente de 1,5 kW** (259 L/h c/u; ver M05), con 1-2 excepciones de 2 kW a lo sumo. Con corte por zona (actuador en cada PICV), P2 mueve el caudal de las zonas que pidan:
- **Escenario normal (~7 zonas):** ~7 × 259 ≈ **1,8 m³/h** (pérdida ~7 m).
- **Pico (12 zonas, todas):** ≈ **~3,4-3,5 m³/h** (pérdida pesimista ~7,5-8 m; real ~6-7 m).

Pérdida pesimista a ~3,5 m³/h: Δp mínimo PICV ~2,5 m (ineludible) + batería fancoil ~2 m + tubería ~2 m + sala ~1 m = **~7,5 m**.

P2 debe ser **bomba de distribución DN25, 180 mm, caudal ≥3,5 m³/h, altura ~7-8 m, presión constante** (modula al cerrarse zonas — encaja con el arranque por Zelio contra red parcialmente cerrada, M10).

**P2 = Grundfos UPM3 Auto 25-70 180** (ref. 93370517 / 59C93603). Alt.: **UPM3 Hybrid 25-70 180** (ref. 59C93103, autónoma + PWM).
- **DN25, 180 mm** (cumple el estándar de intercambiabilidad), **7 m**, **presión constante autónoma** (modos Δp-c/Δp-v seleccionables en la bomba — no necesita señal externa, ideal para el arranque por Zelio).
- **Auto** = autónoma (presión constante interna). **Hybrid** = autónoma **+** gobierno PWM opcional (5 modos, 18 curvas, AUTOADAPT).
- ⚠️ **Sufijo de control (CRÍTICO):** **ZZZ = Auto** ✅ · **ACA = Hybrid** ✅ · **AZA = básica solo-PWM** ❌ (no tiene presión constante autónoma; no sirve para el arranque por Zelio salvo gobernarla siempre por PWM). Comprobar el sufijo en la etiqueta.
- ⚠️ **OJO con la longitud:** existe la misma en **130 mm**, que **NO cumple el estándar de 180** → comprar **explícitamente la 180**.
- ⚠️ **Caudal:** la 25-70 da ~3,5-4 m³/h de tope → en el **pico (3,5 m³/h) va justa**, en **uso normal (1,8 m³/h) holgada**. Aceptable por la inercia. Si se quiere margen en el pico: **UPM3 25-75** o **MAGNA3 25-80** (180).
- **Producto localizado:** UPM3 Auto 25-70 180 ZZZ — usada ~100 € (o mejor oferta) en eBay (vendedor Eternitec); también vista **nueva a ~165 €**. Decisión nueva/usada pendiente.

> **Nota Yonos MAXO 25/0,5-7:** técnicamente ideal (caudal 7 m³/h, 180 mm), pero **nueva ~700 €** → descartada por precio.

> **Historial de descarte por CAUDAL** (no reconsiderar): DN15 de caldera (UPM3/Viessmann 15-75, Wilo RS 15/7, Yonos PICO STG 15/1-13 = 1,9 m³/h, Yonos PARA 15) y DN25 de poco caudal (UPMGEO 25-85 ~2,8; Yonos PICO 1.0 25/1-8 ~3,3). Además, **descarte por longitud 130 mm** (estándar = 180) y por **sufijo AZA** (solo-PWM, sin presión constante autónoma).

**Alternativas equivalentes** (gama distribución, 180 mm, presión constante): Grundfos **MAGNA3 25-80**, **UPM3 25-75 180**, Wilo **Stratos 25/1-8**.

**ALPHA2 25-40 180 → P-POOL** (cumple 180).

## Vasos de expansión

Regla: cada **masa de agua cerrada e independiente**, su vaso, en el lado frío/aspiración. Litrajes con asunciones de volumen conservadoras (a afinar con volúmenes reales).

| Vaso | Circuito (volumen est.) | Tipo | Litraje | Precarga | Ubicación | Producto |
|---|---|---|---|---|---|---|
| **Solar** | Glicol (~25 L) | **Solar específico** (membrana alta temp. HNBR, apto glicol, 10 bar) | **25 L** | ~1,2 bar | Retorno frío, junto a P-SOL (boca inferior serpentín D1) | pendiente |
| **Clima** | Fancoils + buffer ~50 L | Calefacción (membrana EPDM) | **18 L** | ~1,0 bar | Aspiración de P2 | a comprar nuevo (~30 €) |
| **Agua técnica tándem** | Tándem (812 L) | Calefacción (vale uno solar reaprovechado) | **50 L** | ~0,5-1 bar | Lado frío del agua técnica (fondo D1) | **Ibaiondo 50 SMR P** (50 L, solar, -10/+130 °C; 70 € Wallapop). Reajustar precarga de fábrica (~2,5 bar) a ~0,5-1 bar |
| Buffer clima | ~50 L | — | **incluido con la BC** | — | — | viene con la bomba de calor (M05) |
| BC (integrado) | Circuito BC | — | no se compra | — | Verificar que cubre su propio circuito en verano | — |

**Notas de dimensionado:**
- **Tándem 50 L (Ibaiondo 50 SMR P):** el integrado de la BC (~8-10 L) **NO cubre** los 812 L del tándem. El tándem necesita vaso propio: 812 L que se calientan a 60 °C (y hasta ~90 °C antes de Z1/Z2) dilatan ~14-28 L → con factor de presión, ~35 L a temperatura de servicio, **50 L con margen** por el escenario de 90 °C. El **Ibaiondo 50 SMR P** es vaso solar (membrana 130 °C / glicol), pero un vaso solar sirve de sobra para agua técnica de calefacción (al revés no). **Reajustar la precarga** de fábrica (~2,5 bar) a la del tándem (~0,5-1 bar) antes de montar.
- **Solar 25 L:** lo dominante es el vapor de estancamiento, no la dilatación. Al ir en el retorno frío, la membrana no recibe el fluido a máxima temperatura. Si el punto del vaso superara ~70 °C en estancamiento, añadir **vaso intermedio (pre-vaso)** — a verificar; al estar en retorno frío, probablemente innecesario.
- **Clima 18 L:** circuito dominado por el buffer; válvula de seguridad 3 bar. Comprar nuevo (~30 €, no compensa usado).

**Sin vaso propio:** primarios de HX (ramas del agua técnica, los cubre el vaso del tándem); secundarios separados por barrera (ACS → red; piscina → vaso de la piscina).

## Diámetros y racordería

- **Sala de máquinas: todo multicapa 32 mm = rosca 1" (DN25).** Fittings de 32 (rematan en 1", **no** 1¼"). Bombas y válvulas en 1".
- **Primario de ACS en cobre 22 mm** (~0,95 m/s).
- **Distribución fancoils (fuera de sala):** arborescente 32 → 25 → 20 con PICV (M05).
- **Manguito dieléctrico** pegado a cada boca de depósito, luego llave de bola.

## Retención antitermosifón del tándem

- En el enlace serie **tapa de D1 → fondo de D2**, una retención orientada a dejar pasar solo D1→D2; impide que D2 caliente retroceda a D1 y deshaga la estratificación (ver M01).

## Manómetros

- En cada grupo de seguridad (solar, agua técnica), en el circuito de fancoils, y en impulsión/retorno de la BC. Opcional en primario de ACS.

## Parámetros constructivos

Los valores que dependen del componente comercial elegido (caudal nominal de captadores, U y área/placa del HX, potencia pico del campo, volumen del vaso de la BC, Kv de válvulas...) son **parámetros `Pxx`** con valor conocido el día de la instalación. El diseño se expresa en función de ellos; no bloquean el diseño.

## Pendientes

- Confirmar medidas del colector candidato (1" cuerpo / 3/4" salidas) y aptitud para agua caliente de sus llaves.
- Afinar litraje de vasos con volúmenes reales (circuito solar ~25 L es el más estimado).
- Verificar litraje del vaso integrado de la BC (para su circuito en verano).
- Reajustar precarga del Ibaiondo 50 SMR P (tándem) a ~0,5-1 bar antes de montar.
- Comprar vaso solar 25 L y vaso clima 18 L nuevo (~30 €). El del tándem ya resuelto (Ibaiondo); el buffer viene con la BC.
- **P1 = P2 = Grundfos UPM3 Auto 25-70 180** (repuesto común). Verificar que la 25-70 (7 m) cubre la pérdida del doble serpentín de P1 a 2.400 L/h; si no, subir ambas a 25-80.
- **Comprar P2: Grundfos UPM3 Auto 25-70 180** (sufijo ZZZ/Auto o ACA/Hybrid; ¡180, no 130; no AZA!). Ajustar presión constante ~7-8 m. Decisión nueva (~165 €) vs usada (~100 €) pendiente.
- Comprar P-SOL (PWM, glicol, 180) y P-ACS (PWM, 180).
- **Todas las bombas en 180 mm** (estándar de intercambiabilidad). ALPHA2 25-40 180 → P-POOL.
