(* ============================================================
   FB_SolarValves.st
   Gestión de V3V_SOL, P2 (mini bucle) y PERS_SOL (persianas).

   Reglas de arbitraje V3V_SOL:
   - Por defecto: posición A (ACS) — serp.inf D1
   - Desvío a piscina (pos. B) si:
       * modo = SOLAR_FORCE_POOL, O
       * modo = SOLAR_AUTO AND TT3 >= SP_TT3_pool AND pool_demand=TRUE
   - Persianas: cierran si TT2 >= P17_SolarOverheatShutterClose o forzado externo
   - P2 (mini bucle): marcha si V3V_SOL está en posición B (piscina)
   ============================================================ *)

FUNCTION_BLOCK FB_SolarValves

VAR_INPUT
    TT2             : REAL;         (* D1 fondo [°C] *)
    TT3             : REAL;         (* D1 cabeza [°C] *)
    SP_TT3_pool     : REAL;         (* Umbral TT3 para desvío a piscina *)
    pool_demand     : BOOL;         (* TRUE = piscina necesita calor *)
    mode            : E_Solar_Mode;
    force_shutters  : BOOL;         (* TRUE = forzar cierre persianas (del FRE) *)
    pump_running    : BOOL;         (* P1 en marcha *)
    fault           : BOOL := FALSE;
END_VAR

VAR_OUTPUT
    cmd_V3V_SOL_pool : BOOL;        (* TRUE = posición B (piscina) *)
    cmd_P2_run       : BOOL;        (* TRUE = arrancar P2 *)
    cmd_shutters_close : BOOL;      (* TRUE = cerrar persianas *)
    dissipation_active : BOOL;      (* TRUE = disipación activa *)
END_VAR

VAR
    valve_sol       : FB_Valve3Way;
    pump_P2         : FB_Pump;
    want_pool       : BOOL;
    want_dissipate  : BOOL;
END_VAR

(* --- Lógica de desvío a piscina --- *)
CASE mode OF
    SOLAR_FORCE_POOL:
        want_pool := TRUE;

    SOLAR_AUTO:
        want_pool := (TT3 >= SP_TT3_pool) AND pool_demand AND pump_running;

    SOLAR_FORCE_ACS, SOLAR_OFF:
        want_pool := FALSE;
END_CASE

IF fault THEN
    want_pool := FALSE;
END_IF

(* --- V3V_SOL --- *)
valve_sol(
    cmd_pos_B   := want_pool,
    enabled     := NOT fault,
    travel_time := K_VALVE_TRAVEL
);
cmd_V3V_SOL_pool := valve_sol.DO_valve;

(* --- P2: solo corre si V3V_SOL está en posición piscina Y no en maniobra --- *)
cmd_P2_run := valve_sol.DO_valve AND
              NOT valve_sol.in_transit AND
              pump_running AND
              NOT fault;

(* --- Persianas: cierre por disipación o forzado externo --- *)
want_dissipate := (TT2 >= P17_SolarOverheatShutterClose);
dissipation_active := want_dissipate;

cmd_shutters_close := want_dissipate OR force_shutters OR fault;

END_FUNCTION_BLOCK
