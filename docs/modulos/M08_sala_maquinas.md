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

Todas las bombas de la sala son **circuladoras domésticas DN25 (rosca exterior 1½" con tuerca loca)**, que encajan en la línea de **1" de la sala** mediante racorería estándar. Las dos modulantes (P-SOL, P-ACS) se gobiernan por **PWM** desde las salidas rápidas de la CPU (M12); las tres on/off (P1, P2, P-POOL) se arrancan/paran por **relé de interposición** y trabajan a **velocidad fija seleccionada manualmente** al montar.

| Bomba | Función | Caudal nom. | Altura req. | Tipo control | Modelo |
|---|---|---|---|---|---|
| **P-SOL** | Lazo solar (glicol) | según captadores | ~3-4 m | PWM modulante (M02) | Wilo iPWM3 o equivalente, **apta glicol/alta temp.** |
| **P-ACS** | Primario ACS instantáneo | ~1.080 L/h | ~3-4 m | PWM modulante (M04) | Wilo iPWM3 o equivalente |
| **P1** | Trasvase D2 → buffer clima | ~2.400 L/h | **6-8 m** (doble serpentín en serie) | On/off velocidad fija | **Grundfos UPS 25-80** (8 m, candidata principal); alternativa **ALPHA1/2 25-60** (6 m, si la curva confirma) |
| **P2** | Buffer → fancoils | ~2.400 L/h | ~4 m (arborescencia PICV) | On/off velocidad fija | **Grundfos ALPHA1 25-40 130** (en posesión, Wallapop) |
| **P-POOL** | Primario HX piscina | ~900-1.075 L/h | ~3-4 m | On/off velocidad fija | cualquier circuladora doméstica DN25 (no exigente) |

**Notas:**
- **P1 es la más exigente:** mueve el agua técnica en circuito cerrado a través de **dos serpentines en serie** (D2 + buffer), con pérdida de carga sumada. Por eso 6-8 m de altura; la **UPS 25-80** da holgura sin electrónica que falle. Verificar curva a 2.400 L/h.
- **P2 (ALPHA1 25-40):** 3 velocidades por botón, alta eficiencia, ideal para el circuito de fancoils (el que más horas trabaja). Seleccionar curva al montar según pérdida real.
- **P-SOL en glicol:** elegir variante apta para glicol y temperatura de circuito solar. NO sirve la ALPHA1 (no apta para glicol).
- **P-ACS:** circulación de agua técnica (no agua sanitaria), por lo que valen circuladoras de calefacción estándar en variante PWM.

## Vasos de expansión

Regla: cada **masa de agua cerrada e independiente**, su vaso, en el lado frío/aspiración. **Tres vasos a montar** + el integrado de la BC. Litrajes con asunciones de volumen conservadoras (a afinar con volúmenes reales).

| Vaso | Circuito (volumen est.) | Tipo | Litraje | Precarga | Ubicación |
|---|---|---|---|---|---|
| **Solar** | Glicol (~25 L) | **Solar específico** (membrana alta temp. HNBR, apto glicol, 10 bar) | **25 L** | ~1,2 bar | Retorno frío, junto a P-SOL (boca inferior serpentín D1) |
| **Clima** | Fancoils + buffer 150 L (~230 L) | Calefacción (membrana EPDM) | **18 L** (24 si se quiere holgura) | ~1,0 bar | Aspiración de P2 |
| **Agua técnica tándem** | Tándem (812 L) | Calefacción | **50 L** | ~0,5-1 bar | Lado frío del agua técnica (fondo D1) |
| BC (integrado) | Circuito BC | — | no se compra | — | Verificar que cubre su propio circuito en verano |

**Notas de dimensionado:**
- **Tándem 50 L:** el integrado de la BC (~8-10 L) **NO cubre** los 812 L del tándem. El tándem necesita vaso propio: 812 L que se calientan a 60 °C (y hasta ~90 °C antes de Z1/Z2) dilatan ~14-28 L → con factor de presión, ~35 L a temperatura de servicio, **50 L con margen** por el escenario de 90 °C. Este vaso cubre el tándem en invierno y en verano; el integrado de la BC queda solo para el circuito de la BC cuando va independiente (verano).
- **Solar 25 L:** lo dominante es el vapor de estancamiento, no la dilatación. Al ir en el retorno frío, la membrana no recibe el fluido a máxima temperatura. Si el punto del vaso superara ~70 °C en estancamiento, añadir **vaso intermedio (pre-vaso)** — a verificar; al estar en retorno frío, probablemente innecesario.
- **Clima 18 L:** circuito dominado por el buffer de 150 L; válvula de seguridad 3 bar.

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
- Afinar litraje de vasos con volúmenes reales (tubería de clima ~60 L y circuito solar ~25 L son los más estimados).
- Verificar litraje del vaso integrado de la BC (para su circuito en verano).
- **Comprar P1**: candidata Grundfos UPS 25-80 (verificar curva a 2.400 L/h con doble serpentín).
- Seleccionar P-SOL (PWM, apta glicol) y P-ACS (PWM); P-POOL cualquier DN25 doméstica.
