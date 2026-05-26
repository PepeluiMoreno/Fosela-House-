# Pendientes — Casa Fosela

Lista viva de lo que queda por cerrar. Actualizar al cierre de cada sesión.

## Manual de montaje — detalles de instalación que faltan

El manual de montaje describe los bucles y su lógica, pero le faltan los **detalles finos de fontanería** que un instalador necesita pieza a pieza:

- [ ] **Ubicación de sondas** en cada circuito: qué boca/vaina, a qué altura, sonda de superficie vs inmersión. Sondas de ida/retorno solar (NTC en vaina), TT_DHW_out (rápida), TT_DHW_ret, TT5 tapa D2, sondas de buffer clima, etc.
- [ ] **Ubicación de clixons / termostatos de seguridad**: corte térmico ACS, Z1/Z2, TK1 — punto de montaje exacto y cableado en serie con la potencia.
- [ ] **Purgadores**: punto alto de cada circuito cerrado (solar, clima primario, etc.).
- [ ] **Llaves de llenado y vaciado**: posición en cada circuito.
- [ ] **Racorería y conexiones**: tipo de racor en cada unión, "racores locos", latiguillos, etc.
- [ ] **Manguitos dieléctricos**: confirmados en todas las bocas de depósito (criterio ya documentado).
- [ ] **Diámetros y roscas concretos** de cada tramo (DN, rosca M/H) por módulo.
- [ ] **Antirretornos**: orientación y posición exacta en cada rama (criterio ya documentado).

## Arquitectura / decisiones

- [ ] **Plano dimensional del DB2 450**: confirmar número y altura real de bocas para asignar cada toma a su función (criterio de altura por prioridad ya fijado: ACS arriba > clima medio > piscina abajo).
- [ ] **Factor K del caudalímetro YF-B6**: el anuncio no traía specs. Confirmar ficha y actualizar P36_DHWFlowMeterK.
- [ ] **Coordinación de bombas en verano** (clima): confirmar que el antirretorno de la rama de invierno aísla P1 cuando empuja la BC. Resuelto en diseño (P1 en rama de invierno), validar en montaje.
- [ ] **Jerarquía de prioridad invierno**: al colgar clima del tándem, compite con ACS. Fijar en el árbitro (ACS prioritario).
- [ ] **Segundo TM3TI8T** (Coeva/Sonepar Vic) para completar 16 canales NTC.
- [ ] **Confirmar compras**: lote 1 Manresa (140 €), YF-B6 (18,70 €), buck LM2596.

## Código ST — bloques por escribir o completar

- [ ] **Integrar** FB_DHW_Station, FB_Solar, FB_ClimateReversible en PLC_PRG_Evolution (wiring de I/O reales).
- [ ] **FB_SeasonMode**: gestor central de modo estacional (coordina V3V estacional + VZ1-4 + arranque BC), si se separa de FB_ClimateReversible.
- [ ] **FB_PoolReversible**: dos HX (HX-POOL-SOL excedente, HX-POOL-BC modo calor) + lógica estacional + P-POOL.
- [ ] **FB_Dissipation**: cadena de disipación (1º piscina vía V3V disipación, 2º persianas) — parcialmente en FB_Solar, extraer si conviene.
- [ ] **Mapa de I/O del M241**: asignar cada señal a su terminal (DI/DO/AI/HSC/TR), contar canales, validar contra hardware adquirido.
- [ ] **Revisar FB_Climate.st antiguo**: superado por FB_ClimateReversible; decidir si se elimina o se reutiliza.

## Documentación

- [ ] **BOM por módulo** y **esquema de principio**: los hace el usuario (mejor dibujante que Claude).
- [ ] Volcar el esquema de principio final a la memoria una vez dibujado.
