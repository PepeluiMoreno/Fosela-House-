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

## Bombas — estándar de intercambiabilidad

- **Longitud entre roscas: 180 mm en TODAS las circuladoras.** Conexión común **DN25, rosca G1½" (tuerca loca), racor Rp1".** Cualquier bomba entra en cualquier puesto de su clase.
- **Dos clases:**
  - **Suave (~3-4 m):** P-SOL, P-ACS, P-POOL.
  - **Media-fuerte (~6-8 m):** P1, P2. DN25, 180 mm, presión constante. Intercambiables en emergencia (misma conexión); el repuesto UPM3 25-70 cubre P2 y P1 si el serpentín ≤7 m.

| Bomba | Función | Caudal | Altura | Control | Modelo |
|---|---|---|---|---|---|
| **P-SOL** | Lazo solar (glicol) | 1,85 m³/h nom. | 7,5 m máx | PWM perfil C (M02) | **Grundfos Alpha Solar 25-75 180** ✅ adquirida |
| **P-ACS** | Primario ACS instantáneo | ~1.080 L/h | ~3-4 m | PWM (M04) | A comprar, variante PWM |
| **P1** | Trasvase D2 → buffer | ~2.400 L/h | ~5-8 m | On/off | **Stiebel Eltron UP 25/7.5 PCV** (8,4 m, 180) |
| **P2** | Buffer → fancoils | normal ~1,8 · pico ~3,5 m³/h | ~7 m | Presión constante | **Grundfos UPM3 Auto/Hybrid 25-70 180** |
| **P-POOL** | Primario HX piscina | ~900-1.075 L/h | ~3-4 m | On/off | **Grundfos ALPHA2 25-40 180** |

Todas DN25, **180 mm**. Modulantes (P-SOL, P-ACS) por PWM desde la CPU (M12); on/off por relé de interposición.

### P-SOL — Grundfos Alpha Solar 25-75 180 (adquirida)

Lazo solar primario (con glicol). En el retorno frío (boca inferior del serpentín D1). Especificaciones confirmadas en ficha:
- **Glicol:** compatible con mezclas hasta **50%**. ✅
- **Temperatura del fluido:** servicio 2-110 °C, soporta hasta **130 °C** con ambiente 60 °C. ✅
- **Control:** **PWM perfil C** (el solar, desde el controlador/CPU, M02) o curvas constantes en modo autónomo.
- **Prestaciones:** caudal nom. 1,85 m³/h, altura máx 7,5 m, motor ECM, EEI ≤0,20, 230 V, 10 bar. DN25, G1½", 180 mm.

### P1 — Stiebel Eltron UP 25/7.5 PCV (8,4 m, 180 mm)

Trasvase D2 → buffer a través del **doble serpentín de D2** (~2,4 m³/h). La pérdida del doble serpentín es incierta hasta tener el dato del fabricante (puede llegar a ~8 m); la Stiebel de **8,4 m** la cubre con margen sin depender de ese dato. PCV = presión constante variable. DN25, 180 mm, 230 V.
- Verificar al montar: que el modo PCV mantenga presión de forma autónoma y la curva a 2,4 m³/h.

### P2 — Grundfos UPM3 Auto/Hybrid 25-70 180

Buffer → fancoils. Caudal pico ~3,5 m³/h, altura ~7 m. DN25, 180 mm, **presión constante autónoma** (modos Δp-c/Δp-v en la bomba, sin señal externa — idóneo para el arranque por Zelio, M10). La 25-70 encaja (holgada en uso normal ~1,8 m³/h, justa en el pico de 12 zonas).
- **Al comprar:**
  - **Sufijo de control:** **ZZZ (Auto)** o **ACA (Hybrid)** válidos. **AZA (solo-PWM) NO** sirve.
  - **Longitud 180 mm** (no la versión 130).
  - Ref. Auto: 93370517 / 59C93603. Ref. Hybrid: 59C93103.
  - Ajustar a presión constante ~7 m al montar.
- Más margen de caudal en el pico, si se quisiera: UPM3 25-75 o MAGNA3 25-80 (180).

> **Intercambiabilidad P1↔P2:** distinta marca pero mismo estándar (DN25, 180 mm, presión constante) → intercambiables en emergencia. Un repuesto **UPM3 25-70** en stock cubre P2 al 100% y P1 mientras el doble serpentín no pida >7 m.

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
- **P-SOL: Grundfos Alpha Solar 25-75 180** ✅ adquirida (glicol 50%, 110-130 °C, PWM perfil C — confirmado).
- **P1: Stiebel Eltron UP 25/7.5 PCV** (8,4 m, 180) — comprada/en compra. Verificar modo PCV autónomo y curva a 2,4 m³/h.
- **Comprar P2: Grundfos UPM3 Auto/Hybrid 25-70 180** (sufijo ZZZ/Auto o ACA/Hybrid; 180 mm; no AZA). Ajustar presión constante ~7 m.
- Comprar P-ACS (PWM).
- ALPHA2 25-40 180 → P-POOL.
