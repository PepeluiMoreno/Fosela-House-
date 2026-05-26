# Manual de montaje — Casa Fosela

Instrucciones ejecutables para el instalador, módulo a módulo. Complementa la memoria técnica (justificación de diseño). Aquí está el *cómo*; el *porqué* está en la memoria.

> **Estado:** este manual recoge la secuencia de los bucles. Faltan los detalles finos de fontanería (ubicación exacta de sondas, clixons, purgadores, llaves de llenado/vaciado, racorería, diámetros) — ver `PENDIENTES.md`.

## Principio común a todas las bocas del depósito

`Boca del depósito → manguito dieléctrico (pegado a la boca) → llave de bola → resto del circuito`

El manguito dieléctrico corta el par galvánico acero vitrificado/cobre y va pegado a la boca, sin metal intermedio. La llave de bola después, para aislar sin vaciar. Cada circuito cerrado lleva su purgador en el punto alto y su vaso de expansión + válvula de seguridad propios.

## Carga de los depósitos (serpentines)

Productor entra por el **serpentín superior** y sale por el **inferior** (contracorriente): cede calor de arriba abajo y vuelve lo más frío posible. Circuladora en el retorno frío.
- **SERP-D1** ← solar (P-SOL). **SERP-D2** ← BC (vía V3V estacional, posición invierno).

## Extracción del tándem (criterio de altura por prioridad)

La altura de la toma la dicta la prioridad/grado del consumidor: a mayor prioridad, más alta la toma.
- **ACS (P-ACS):** boca más alta de D2 (lo más caliente).
- **Piscina (P-POOL):** por debajo de la de ACS.
- Retornos: al fondo de D1.

(Asignación física definitiva pendiente del plano dimensional del DB2 450.)

## MÓDULO CLIMA — circuito reversible con buffer de 150 L

Orientación de referencia (esquema de principio): D2 izquierda, buffer centro, D1 derecha. Buffer: primario a la izquierda (bocas arriba/abajo), secundario a la derecha.

### Secundario (fancoils) — fijo, ambos modos
1. Boca **arriba-izquierda secundario** → **P2** (aspira del buffer, empuja a fancoils) → impulsión fancoils.
2. Retorno fancoils → boca **abajo-secundario**.

### Primario — entrada (boca arriba-izquierda)
3. **Rama invierno:** toma alta de D2 → **VZ3** → **P1** → antirretorno (hacia la T) → T.
4. **Rama verano:** salida de frío de la V3V estacional → **VZ1** → antirretorno (hacia la T) → T.
5. Las dos ramas confluyen en la **T**; de la T, tubo único → boca arriba-izquierda del buffer.

> P1 va en la rama de invierno (paso 3), NO en el tubo común, para que en verano no quede en serie con la bomba de la BC.

### Primario — retorno (boca abajo-izquierda)
6. Boca **abajo-izquierda primario** → segunda **T** (reparte).
7. **Rama invierno:** T → **VZ4** → antirretorno (saliendo de la T) → fondo de D1.
8. **Rama verano:** T → **VZ2** → antirretorno (saliendo de la T) → retorno de la BC.

### Conmutación estacional
| | Invierno (BC calor) | Verano (BC frío) |
|---|---|---|
| VZ3, VZ4 (invierno) | Abiertas | Cerradas |
| VZ1, VZ2 (verano) | Cerradas | Abiertas |
| P1 | En marcha | Parada |
| Empuja el primario | P1 | Bomba interna BC |
| V3V estacional | → D2 | → buffer frío |

### Enclavamiento y pruebas
9. Las VZ deben estar en posición antes de arrancar P1 o cambiar el modo de la BC (tiempo de maniobra + retardo de seguridad).
10. Forzar invierno: VZ3/VZ4 abren, VZ1/VZ2 cierran, P1 arranca, llega caliente del tándem a fancoils.
11. Forzar verano: VZ1/VZ2 abren, VZ3/VZ4 cierran, P1 para, llega frío de la BC sin contaminar el tándem.
12. Verificar que ningún antirretorno deja paso a la rama cerrada.

## MÓDULO ACS — estación de agua fresca
Ver memoria §8 (estación HX-ACS + P-ACS + caudalímetro YF-B6 + VMT1 + corte térmico). P-ACS en impulsión (toma alta D2 → placa → fondo D1).

## MÓDULO PISCINA
Dos intercambiadores tubulares de titanio: **HX-POOL-SOL** (excedente solar, vía V3V disipación) y **HX-POOL-BC** (BC en modo calor). Secundario de ambos por la depuradora existente. P-POOL en retorno frío. Titanio obligatorio (cloro, EN 1717 cat. 5).

## MÓDULO SOLAR
Ver memoria §13 y Apéndice B.1. Arranque por muestreo a bajo caudal. Tres sondas: ida y retorno de glicol (NTC en vaina). Grupo de seguridad (vaso, válvula seguridad 6 bar, manómetro, llenado/vaciado), antirretorno antitermosifón, captadores en Tichelmann.

## CADENA DE SEGURIDAD (K02)
Termostatos Z1 (D1) y Z2 (D2) ~90 °C NC rearme manual + TK1 ~88 °C, en serie por hardware: si cualquiera dispara, cortan P-SOL y cierran persianas independientemente del PLC, que solo recibe el aviso. Corte térmico ACS (~70 °C, bimetálico NC, rearme manual) en serie con P-ACS por hardware.
