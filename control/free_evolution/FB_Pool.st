(* ============================================================
   FB_Pool.st  –  Control calentamiento/disipación piscina
   Dos intercambiadores de titanio independientes:
     HX_SOLAR : excedente solar → piscina
     HX_BC    : producción BC (solo en modo calefacción) → piscina
   La depuradora (P_DEPUR, existente) circula el agua de piscina
   por el secundario de ambos HX simultáneamente.
   ============================================================ *)
FUNCTION_BLOCK FB_Pool
VAR_INPUT
    TT11            : REAL;  (* Temperatura piscina [°C] *)
    solar_available : BOOL;  (* Solar excedente autorizado vía V3V_SOL *)
    bdc_available   : BOOL;  (* BC autorizado por árbitro AND en modo calor *)
    flow_ok         : BOOL;  (* Interruptor de flujo piscina activo *)
    enabled         : BOOL := TRUE;
END_VAR
VAR_OUTPUT
    cmd_VP_HX_SOLAR : BOOL;  (* Abrir válvula HX solar → piscina *)
    cmd_VP_HX_BC    : BOOL;  (* Abrir válvula HX aerotérmico → piscina *)
    demand_solar    : BOOL;  (* Solicitud aporte solar *)
    demand_BDC      : BOOL;  (* Solicitud aporte BC *)
    pool_satisfied  : BOOL;
    alarm_max_temp  : BOOL;
END_VAR
VAR
    ctrl_pool   : FB_Hysteresis;
    alm_max     : FB_Alarm;
END_VAR

ctrl_pool(
    measured   := TT11,
    setpoint   := P60_PoolSetPoint,
    hysteresis := P61_PoolHysteresis,
    mode_heat  := TRUE,
    enabled    := enabled
);
pool_satisfied := NOT ctrl_pool.output;

demand_solar := ctrl_pool.output AND flow_ok AND enabled;
demand_BDC   := ctrl_pool.output AND flow_ok AND enabled;

cmd_VP_HX_SOLAR := solar_available AND demand_solar;
cmd_VP_HX_BC    := bdc_available   AND demand_BDC;

alm_max(
    condition   := TT11 > P62_PoolMaxTemp,
    filter_time := K_ALM_FILTER,
    latch       := FALSE,
    enabled     := enabled
);
alarm_max_temp := alm_max.active;

IF alarm_max_temp THEN
    cmd_VP_HX_SOLAR := FALSE;
    cmd_VP_HX_BC    := FALSE;
END_IF

END_FUNCTION_BLOCK
