(* ============================================================
   FB_Pool.st  –  Control calentamiento piscina
   Gestiona VP_HX1, VP_HX_BDC, VP_HX_HTR y sus primarios.
   ============================================================ *)
FUNCTION_BLOCK FB_Pool
VAR_INPUT
    TT11            : REAL;  (* Temperatura piscina *)
    TT14            : REAL;  (* Mini bucle intermedio *)
    solar_available : BOOL;  (* Solar autorizado (V3V_SOL en piscina) *)
    bdc_available   : BOOL;
    htr_available   : BOOL;
    flow_ok         : BOOL;  (* IF_PISC con flujo *)
    enabled         : BOOL := TRUE;
END_VAR
VAR_OUTPUT
    cmd_VP_HX1      : BOOL;
    cmd_VP_HX_BDC   : BOOL;
    cmd_VP_HX_HTR   : BOOL;
    demand_solar    : BOOL;
    demand_BDC      : BOOL;
    demand_HTR      : BOOL;
    pool_satisfied  : BOOL;
    alarm_max_temp  : BOOL;
END_VAR
VAR
    ctrl_pool   : FB_Hysteresis;
    alm_max     : FB_Alarm;
    timer_delay : TON;
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
demand_HTR   := ctrl_pool.output AND flow_ok AND enabled;

(* Abrir VP solo si hay flujo (IF_PISC) y hay aporte disponible *)
cmd_VP_HX1    := solar_available AND demand_solar;
cmd_VP_HX_BDC := bdc_available   AND demand_BDC;
cmd_VP_HX_HTR := htr_available   AND demand_HTR;

(* Alarma temperatura máxima piscina *)
alm_max(
    condition   := TT11 > P62_PoolMaxTemp,
    filter_time := K_ALM_FILTER,
    latch       := FALSE,
    enabled     := enabled
);
alarm_max_temp := alm_max.active;

(* Cortar calentamiento si supera máximo *)
IF alarm_max_temp THEN
    cmd_VP_HX1    := FALSE;
    cmd_VP_HX_BDC := FALSE;
    cmd_VP_HX_HTR := FALSE;
END_IF

END_FUNCTION_BLOCK
