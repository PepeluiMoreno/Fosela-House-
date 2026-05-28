# M08 — Sala de máquinas (hidráulica común)

**Estado:** 🔶 colector, bombas, vasos y diámetros definidos · falta confirmar producto.
**Transversal a:** todos los módulos hidráulicos.

## Colector de consumidores (sala)

- **Punto alto común de extracción:** ACS, clima (trasvase P1) y piscina toman de zona alta común del tándem; la prioridad la ejerce el control (M09), no la hidráulica. Retornos al fondo de D1.
- Reparte **agua técnica del tándem** a los consumidores grandes. (Los fancoils NO cuelgan de aquí: van por arborescencia desde el buffer, ver M05.)
- **Colector de latón roscado (sin soldar):** cuerpo **1" (DN25)**, salidas **3/4"**, encadenable. Con clima+ACS simultáneos (~3.480 L/h) la velocidad interna sube (~1,9 m/s): aceptable, sin margen. Para holgura, encadenar dos cuerpos.
- Tapón roscado en extremos, **purgador** en alto y **vaciado** en bajo.
- Sin separador hidráulico de marca: innecesario.

### Reparto de bocas

| Boca | Ramal | Caudal |
|---|---|---|
| Extremo 1" | Alimentación desde el tándem (suma de caudales) | ~3.480 L/h |
| Extremo 1" opuesto | **Clima = trasvase P1 al buffer** (el de más caudal) | ~2.400 L/h |
| Salida 3/4" | ACS (primario, P-ACS) | ~1.080 L/h |
| Salida 3/4" | Piscina (P-POOL, ΔT alto) | ~900-1.075 L/h |

> "Clima por el extremo" = el **trasvase P1 al buffer de inercia**, NO los fancoils.

## Posición de las bombas

- **Aspiración con presión positiva** (evitar cavitación), con el vaso del lado de aspiración.
- Cada bomba en la **impulsión de su ramal** + **válvula de retención aguas abajo**.
- P-ACS en impulsión.

## Bombas — criterio de longitud e intercambiabilidad

- **Conexión común:** DN25, rosca G1½" (tuerca loca), racor Rp1" en todas.
- **Longitud 130 mm en casi todas** (P-SOL, P-ACS, P2, P-POOL, repuesto). **Única excepción: P1 (Stiebel) es 180 mm**, dada por su modelo (8,4 m para el doble serpentín).
- **Pareja P-ACS / P2 = Grundfos UPM3 25-70 130** (mismo cuerpo): P-ACS en Hybrid (ACA, por el PWM de ACS), P2 en Auto (ZZZ, presión constante). Intercambiables y con repuesto común (mismo cuerpo UPM3 25-70 130).
- ⚠️ **P1 a 180:** su hueco de tubería se monta a 180; el resto a 130. No intercambiar a ciegas P1 con las demás sin adaptador.

### Cuadro de bombas

| ID | Marca y modelo | Plataforma | Precio s/portes | Estado |
|---|---|---|---|---|
| **P-SOL** | Grundfos Alpha Solar 25-75 130 | Wallapop (Paco) | 85 € (oferta; PVP 95) | en compra |
| **P-ACS** | Grundfos UPM3 Hybrid 25-70 130 (ACA) | Wallapop (Daniel) | 150 € (nueva) | compra propuesta (pdte. confirmar cables) |
| **P1** | Stiebel Eltron UP 25/7.5 PCV (8,4 m, 180) | eBay | 135 € (oferta pdte. de aceptar; PVP 159) | compra propuesta |
| **P2** | Grundfos UPM3 Auto 25-70 130 (ZZZ) | Wallapop (Daniel) | 100 € (nueva) | compra propuesta |
| **P-POOL** | Grundfos ALPHA1 25-40 130 | Wallapop | 59 € | ✅ comprada |
| **Repuesto** | Grundfos ALPHA 25-40 130 | Wallapop | 60 € | ✅ comprada |

> **P-ACS y P2 = mismo cuerpo** (UPM3 25-70 130): P-ACS Hybrid (ACA), P2 Auto (ZZZ). Distinto sufijo de control pero idéntico cuerpo → intercambiables y repuesto común.

Funciones, caudales y alturas: P-SOL lazo solar (1,85 m³/h, 7,5 m, PWM perfil C, glicol); P-ACS primario ACS (~1.080 L/h, ~3-4 m, PWM); P1 trasvase D2→buffer (~2.400 L/h, ~5-8 m, on/off); P2 buffer→fancoils (normal ~1,8 / pico ~3,5 m³/h, ~7 m, presión constante); P-POOL primario piscina (~900-1.075 L/h, ~3-4 m, on/off). Modulantes (P-SOL, P-ACS) por PWM desde la CPU (M12); on/off por relé de interposición.

### Resumen de gasto en bombas

- **Ya comprado** (en posesión): P-POOL 59 € + Repuesto 60 € = **119 €**.
- **En compra:** P-SOL 85 €.
- **Compra propuesta:** P1 135 € + P-ACS 150 € + P2 100 € = **385 €**.
- **Total previsto del aprovisionamiento de bombas:** **~589 €** (+ portes).

### P-SOL — Grundfos Alpha Solar 25-75 130

Lazo solar primario (con glicol). En el retorno frío (boca inferior del serpentín D1). Confirmado en ficha: glicol hasta **50%**, fluido 2-110 °C (hasta 130 °C con ambiente 60 °C), **PWM perfil C** o curvas constantes autónomas, caudal nom. 1,85 m³/h, altura máx 7,5 m, motor ECM, EEI ≤0,20, 230 V, 10 bar, DN25 G1½", 130 mm. Wallapop (Paco), 85 € (oferta; PVP 95), nueva.

### P-ACS y P2 — Grundfos UPM3 25-70 130 (mismo cuerpo, repuesto común)

Mismo cuerpo UPM3 25-70 130 (DN25, 130 mm). Distinto sufijo de control según puesto.
- **P-ACS — Hybrid (ACA):** primario del HX de ACS instantánea (~1.080 L/h, ~3-4 m). Modula por **PWM desde el M241** (M04) para temperatura de ACS estable al paso — por eso Hybrid, que tiene entrada PWM. La curva de 7 m sobra; modula a la baja. Localizada en Wallapop (Daniel), 150 € nueva — confirmar que incluye los cables (alimentación + señal PWM) y hacer oferta.
- **P2 — Auto (ZZZ):** buffer → fancoils (pico ~3,5 m³/h, ~7 m). Presión constante autónoma (arranque por Zelio, M10); no necesita PWM, por eso vale la Auto. La 25-70 encaja (holgada en normal ~1,8 m³/h, justa en el pico de 12 zonas). Wallapop (Daniel), UPM3 Auto L 25-70 130 ZZZ, 100 € nueva.
- Sufijos válidos: **ACA (Hybrid)** y **ZZZ (Auto)**; **AZA (solo-PWM) NO**. Longitud **130 mm**. Ref. Hybrid 130: 59C93102; Auto 130: 59C93602.

### P1 — Stiebel Eltron UP 25/7.5 PCV (8,4 m, 180 mm)

Trasvase D2 → buffer a través del **doble serpentín de D2** (~2,4 m³/h). La pérdida del doble serpentín es incierta (puede llegar a ~8 m); la Stiebel de **8,4 m** la cubre con margen. PCV = presión constante variable. DN25, 180 mm, 230 V. **Única bomba de 180** de la instalación.
- Verificar al montar: que el modo PCV mantenga presión de forma autónoma y la curva a 2,4 m³/h.

## Vasos de expansión

Cada masa de agua cerrada e independiente, su vaso, en el lado frío/aspiración.

| Vaso | Circuito | Tipo | Litraje | Precarga | Ubicación | Producto |
|---|---|---|---|---|---|---|
| **Solar** | Glicol (~25 L) | Solar específico (HNBR, glicol, 10 bar) | 25 L | ~1,2 bar | Retorno frío, junto a P-SOL | pendiente |
| **Clima** | Fancoils + buffer ~50 L | Calefacción (EPDM) | 18 L | ~1,0 bar | Aspiración de P2 | a comprar nuevo |
| **Agua técnica tándem** | Tándem (812 L) | Calefacción (vale solar) | 50 L | ~0,5-1 bar | Lado frío (fondo D1) | **Ibaiondo 50 SMR P** (reajustar precarga a ~0,5-1 bar) |
| Buffer clima | ~50 L | — | incluido con la BC | — | — | viene con la bomba de calor (M05) |
| BC (integrado) | Circuito BC | — | no se compra | — | verificar cobertura en verano | — |

**Notas:**
- **Tándem (50 L):** el integrado de la BC no cubre los 812 L del tándem. 812 L hasta ~90 °C (antes de Z1/Z2) requieren ~50 L con margen. El **Ibaiondo 50 SMR P** (solar) sirve para agua técnica; reajustar precarga de fábrica (~2,5 bar) a ~0,5-1 bar antes de montar.
- **Solar (25 L):** dominante el vapor de estancamiento. Al ir en retorno frío, la membrana no recibe el fluido a máxima temperatura; pre-vaso solo si el punto superara ~70 °C (improbable).
- **Clima (18 L):** dominado por el buffer; válvula de seguridad 3 bar.

**Sin vaso propio:** primarios de HX (los cubre el vaso del tándem); secundarios separados por barrera (ACS → red; piscina → su vaso).

## Diámetros y racordería

- **Sala: todo multicapa 32 mm = rosca 1" (DN25).** Bombas y válvulas en 1".
- **Primario de ACS en cobre 22 mm.**
- **Distribución fancoils (fuera de sala):** arborescente 32 → 25 → 20 con PICV (M05).
- **Manguito dieléctrico** en cada boca de depósito, luego llave de bola.

## Retención antitermosifón del tándem

- En el enlace serie **tapa de D1 → fondo de D2**, retención que deja pasar solo D1→D2; impide que D2 caliente retroceda a D1 (M01).

## Manómetros

- En cada grupo de seguridad (solar, agua técnica), en el circuito de fancoils, y en impulsión/retorno de la BC.

## Parámetros constructivos

Los valores que dependen del componente comercial (caudal nominal de captadores, U y área/placa del HX, potencia pico del campo, volumen del vaso de la BC, Kv de válvulas, **pérdida del serpentín a caudal nominal**...) son **parámetros `Pxx`** con valor conocido el día de la instalación. El diseño se expresa en función de ellos.

## Pendientes

- Confirmar medidas del colector (1" cuerpo / 3/4" salidas) y aptitud de sus llaves para agua caliente.
- Afinar litraje de vasos con volúmenes reales.
- Verificar litraje del vaso integrado de la BC (circuito en verano).
- Reajustar precarga del Ibaiondo 50 SMR P a ~0,5-1 bar.
- Comprar vaso solar 25 L y vaso clima 18 L. Tándem ya resuelto; buffer viene con la BC.
- **P-SOL: Grundfos Alpha Solar 25-75 130** — en compra (Wallapop Paco, 85 €).
- **P-ACS: Grundfos UPM3 Hybrid 25-70 130** — localizada (Wallapop Daniel, 150 € nueva); confirmar cables y hacer oferta.
- **P2: Grundfos UPM3 Auto 25-70 130 ZZZ** — localizada (Wallapop Daniel, 100 € nueva); hacer oferta.
- **P1: Stiebel Eltron UP 25/7.5 PCV** (180, única de 180) — compra propuesta (eBay, oferta 135 € pendiente). Verificar modo PCV autónomo y curva a 2,4 m³/h.
- **P-POOL: Grundfos ALPHA1 25-40 130** — comprada (59 €, Wallapop).
- **Repuesto: Grundfos ALPHA 25-40 130** — comprado (60 €, Wallapop).
- Montaje: todas a 130 salvo P1 (180).
