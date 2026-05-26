(* ============================================================
   FB_ClimateReversible.st
   Climatización reversible con buffer de inercia de 150 L como
   aguja hidráulica de 4 bocas.

   ARQUITECTURA:
   - Invierno (BC en calor): el primario del buffer se alimenta del
     TÁNDEM (D2). La bomba P1 (rama de invierno) circula el agua del
     tándem por el buffer. Así la SOLAR contribuye a calefacción.
   - Verano (BC en frío): el primario del buffer se alimenta de la BC
     en frío vía la V3V estacional. P1 parada (empuja la BC).
   - P2 (secundario) mueve el agua del buffer a los fancoils SIEMPRE.

   Conmutación de fuente con 4 válvulas de zona de 2 vías, por parejas
   de estación (lo fija el dibujo del esquema de principio):
     VZ1 = verano-impulsión   VZ2 = verano-retorno
     VZ3 = invierno-impulsión VZ4 = invierno-retorno

   ENCLAVAMIENTO: las válvulas deben estar en posición ANTES de que
   arranque P1 o cambie el modo de la BC. Se respeta tiempo de maniobra
   + retardo de seguridad.

   NADA HARDCODED: tiempos y consignas en GVL_Params.
   ============================================================ *)

FUNCTION_BLOCK FB_ClimateReversible

VAR_INPUT
    eBC_Mode        : E_BDC_Mode;   (* Modo actual de la BC: HEAT / COOL / OFF *)
    bClimateDemand  : BOOL;         (* Hay demanda de clima (termostatos zona) *)
    rTT_buffer      : REAL;         (* Temperatura buffer clima [°C] *)
    bEnable         : BOOL := TRUE;
END_VAR

VAR_OUTPUT
    bVZ1_open       : BOOL;     (* verano-impulsión *)
    bVZ2_open       : BOOL;     (* verano-retorno *)
    bVZ3_open       : BOOL;     (* invierno-impulsión *)
    bVZ4_open       : BOOL;     (* invierno-retorno *)
    bP1_run         : BOOL;     (* circuladora primario clima (invierno) *)
    bP2_run         : BOOL;     (* circuladora secundario → fancoils *)
    bV3V_Seasonal_B : BOOL;     (* V3V estacional: FALSE=D2(calor) / TRUE=buffer(frío) *)
    eSeason         : E_Season;
    bInterlockOK    : BOOL;     (* Válvulas en posición, seguro para arrancar *)
END_VAR

VAR
    eSeasonTarget   : E_Season;
    timer_interlock : TON;
    VZ1, VZ2, VZ3, VZ4 : FB_Valve2Way;
    P1, P2          : FB_Pump;
END_VAR

(* ---------- Determinar estación objetivo según modo BC ---------- *)
IF eBC_Mode = E_BDC_Mode.COOL THEN
    eSeasonTarget := E_Season.SUMMER;
ELSE
    eSeasonTarget := E_Season.WINTER; (* HEAT y OFF → configuración de invierno *)
END_IF

(* ---------- Mando de válvulas de zona por parejas de estación ---------- *)
(* Verano: VZ1+VZ2 abiertas, VZ3+VZ4 cerradas. Invierno: al revés. *)
VZ1(cmd_open := (eSeasonTarget = E_Season.SUMMER) AND bEnable,
    travel_time := GVL_Params.P64_PoolValveTravelTime);
VZ2(cmd_open := (eSeasonTarget = E_Season.SUMMER) AND bEnable,
    travel_time := GVL_Params.P64_PoolValveTravelTime);
VZ3(cmd_open := (eSeasonTarget = E_Season.WINTER) AND bEnable,
    travel_time := GVL_Params.P64_PoolValveTravelTime);
VZ4(cmd_open := (eSeasonTarget = E_Season.WINTER) AND bEnable,
    travel_time := GVL_Params.P64_PoolValveTravelTime);

bVZ1_open := VZ1.is_open;
bVZ2_open := VZ2.is_open;
bVZ3_open := VZ3.is_open;
bVZ4_open := VZ4.is_open;

(* ---------- Enclavamiento: confirmar pareja correcta en posición ---------- *)
IF eSeasonTarget = E_Season.SUMMER THEN
    bInterlockOK := VZ1.is_open AND VZ2.is_open
                    AND NOT VZ3.in_transit AND NOT VZ4.in_transit;
ELSE
    bInterlockOK := VZ3.is_open AND VZ4.is_open
                    AND NOT VZ1.in_transit AND NOT VZ2.in_transit;
END_IF

(* Retardo de seguridad tras alcanzar posición, antes de habilitar bombas *)
timer_interlock(IN := bInterlockOK, PT := GVL_Params.P55_SeasonInterlockDelay);

(* ---------- Estación confirmada solo cuando el enclavamiento es estable ---------- *)
IF timer_interlock.Q THEN
    eSeason := eSeasonTarget;
END_IF

(* ---------- V3V estacional: posición coordinada ---------- *)
(* FALSE = a D2 (carga tándem, invierno) ; TRUE = a buffer frío (verano) *)
bV3V_Seasonal_B := (eSeason = E_Season.SUMMER);

(* ---------- Bombas ---------- *)
(* P1 (primario clima) SOLO en invierno y con enclavamiento OK *)
P1(cmd_run := (eSeason = E_Season.WINTER) AND bClimateDemand AND timer_interlock.Q,
   min_on_time := GVL_Params.P14_SolarPumpMinOnTime,
   min_off_time := GVL_Params.P15_SolarPumpMinOffTime,
   enabled := bEnable);
bP1_run := P1.running;

(* P2 (secundario → fancoils) siempre que haya demanda y enclavamiento OK *)
P2(cmd_run := bClimateDemand AND timer_interlock.Q,
   enabled := bEnable);
bP2_run := P2.running;
