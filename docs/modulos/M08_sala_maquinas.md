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

## Selección de bombas

Bombas DN25 (rosca 1½" tuerca loca) que encajan en la línea de 1" de la sala. Las modulantes (P-SOL, P-ACS) por **PWM** desde la CPU (M12); las on/off por **relé de interposición**.

| Bomba | Función | Caudal | Altura req. | Control | Modelo |
|---|---|---|---|---|---|
| **P-SOL** | Lazo solar (glicol) | según captadores | ~3-4 m | PWM modulante (M02) | Grundfos Alpha Solar 25-75 / Wilo iPWM3, **apta glicol** |
| **P-ACS** | Primario ACS instantáneo | ~1.080 L/h | ~3-4 m | PWM modulante (M04) | A comprar, **variante PWM** |
| **P1** | Trasvase D2 → buffer | ~2.400 L/h | **~8 m** (doble serpentín en serie) | On/off | Grundfos UPS 25-80 / Wilo Star-RS 25/8 (verificar curva a 2.400 L/h) |
| **P2** | Buffer → fancoils | **normal ~1,8 m³/h · pico ~3,5 m³/h** | **~7-8 m** (red + Δp PICV) | Presión constante | **Wilo Yonos MAXO 25 (0,5-7 vale; 8/10/12 holgada)** |
| **P-POOL** | Primario HX piscina | ~900-1.075 L/h | ~3-4 m | On/off | **Grundfos ALPHA2 25-40 180** (reubicada aquí) |
| *spare* | repuesto | — | — | — | **Grundfos ALPHA1 25-40 130** (Wallapop, queda de repuesto) |

### P2 — dimensionado y bomba

**Fancoils mayoritariamente de 1,5 kW** (259 L/h c/u; ver M05), con 1-2 excepciones de 2 kW a lo sumo. Con corte por zona (actuador en cada PICV), P2 mueve el caudal de las zonas que pidan:
- **Escenario normal (~7 zonas):** ~7 × 259 ≈ **1,8 m³/h** (pérdida ~7 m).
- **Pico (12 zonas, todas):** 12 zonas × 259 (+ alguna de 2 kW) ≈ **~3,4-3,5 m³/h** (pérdida pesimista ~7,5-8 m; real ~6-7 m).

Pérdida pesimista a ~3,5 m³/h:

| Componente | Δp pesimista |
|---|---|
| **Δp mínimo de trabajo de la PICV** (ineludible, su regulador lo exige) | ~2,5 m (25 kPa) |
| Batería del fancoil + conexiones | ~2 m |
| Tubería (tronco 32 + ramas 25 + bajadas 20, recorrido desfavorable) | ~2 m |
| Buffer/aguja + accesorios de sala | ~1 m |
| **TOTAL** | **~7,5 m a ~3,5 m³/h** |

P2 debe ser **bomba de distribución DN25, caudal ≥3,5 m³/h, altura ~7-8 m, presión constante** (modula al cerrarse zonas — encaja con el arranque por Zelio contra red parcialmente cerrada, M10).

> **Cambio respecto al cálculo anterior:** al pasar los fancoils a 1,5 kW dominante, el **caudal pico baja de 4,5 a ~3,5 m³/h**. Esto **relaja P2**: la **Wilo Yonos MAXO 25/0,5-7** (más fácil de encontrar y más barata que la -12) ahora **cubre el pico** (a 3,5 m³/h da ~5 m, y la pérdida real ronda 6-7 m → en el límite alto pero aceptable; la -8/-10/-12 dan holgura si aparecen a buen precio). La barrera sigue siendo el **caudal** → gama de distribución (MAXO/Stratos/MAGNA3); las circuladoras pequeñas DN15/DN25 de poco caudal siguen sin servir.

**P2 = Wilo Yonos MAXO 25, altura 0,5-7 (suficiente) o superior (holgada).** Ajustar a presión constante ~7-8 m al montar. **Punto crítico de aprovisionamiento** (difícil a precio asequible de 2ª mano).

> **Historial de descarte** (no reconsiderar): DN15 de caldera (UPM3/Viessmann 15-75, Wilo RS 15/7, Yonos PICO STG 15/1-13 = 1,9 m³/h, Yonos PARA 15) y DN25 de poco caudal (UPMGEO 25-85 ~2,8 m³/h; Yonos PICO 1.0 25/1-8 ~3,3 m³/h). *Nota: con el pico reducido a 3,5 m³/h, la Yonos PICO 1.0 25/1-8 (~3,3 m³/h) queda muy al límite — jugable solo si no aparece una MAXO y se acepta trabajar al borde de su curva.*

**Alternativas equivalentes** (gama distribución): Wilo **Stratos 25/1-8**, Grundfos **MAGNA3 25-80**, Grundfos **UPM3 25-70/75** (esta última, más pequeña, ahora entra por el pico reducido).

**Reasignación de las ALPHA 25-40:** la ALPHA2 25-40 180 → **P-POOL**; la ALPHA1 25-40 130 → **repuesto** (ambas equivalentes en piscina).

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
- **Comprar P1** (~8 m a 2.400 L/h): Grundfos UPS 25-80 / Wilo Star-RS 25/8.
- **Comprar P2: Wilo Yonos MAXO 25/0,5-7** (suficiente con el pico reducido a 3,5 m³/h) o superior si aparece a buen precio. Ajustar presión constante ~7-8 m al montar. Punto crítico de aprovisionamiento.
- Comprar P-SOL (PWM, glicol) y P-ACS (PWM).
- ALPHA2 25-40 180 → P-POOL; ALPHA1 25-40 130 → repuesto.
