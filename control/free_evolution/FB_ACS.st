(* ============================================================
   FB_ACS.st  –  Control de producción de ACS
   Gestiona V3V1 (primario BDC), V3V3 (HTR) y sus modos.
   ============================================================ *)
FUNCTION_BLOCK FB_ACS
VAR_INPUT
    TT4             : REAL;  (* D2 fondo *)
    TT5             : REAL;  (* D2 cabeza *)
    TT10            : REAL;  (* Ida HTR *)
    bdc_available   : BOOL;  (* BDC autorizada por árbitro *)
    hyg_active      : BOOL;  (* Ciclo de higienización activo *)
    enabled         : BOOL := TRUE;
END_VAR
VAR_OUTPUT
    cmd_V3V1_D2     : BOOL;  (* TRUE = primario BDC → D2 *)
    cmd_V3V3_D2     : BOOL;  (* TRUE = HTR → D2 sup *)
    demand_BDC      : BOOL;  (* Solicitud al árbitro *)
    acs_satisfied   : BOOL;  (* D2 en setpoint *)
END_VAR
VAR
    ctrl_TT5        : FB_Hysteresis;
    ctrl_TT4        : FB_Hysteresis;
    ctrl_HTR_stop   : FB_Hysteresis;
END_VAR

(* ACS satisfecho cuando TT5 supera la consigna *)
ctrl_TT5(
    measured   := TT5,
    setpoint   := P30_ACSStorageSetPoint,
    hysteresis := P31_ACSStorageHysteresis,
    mode_heat  := TRUE,
    enabled    := enabled
);
acs_satisfied := NOT ctrl_TT5.output;

(* Demanda BDC: TT4 bajo setpoint de arranque *)
ctrl_TT4(
    measured   := TT4,
    setpoint   := P32_ACSBDCStartTemp,
    hysteresis := P33_ACSBDCStartHyst,
    mode_heat  := TRUE,
    enabled    := enabled AND NOT acs_satisfied
);
demand_BDC := ctrl_TT4.output OR hyg_active;

(* V3V1: BDC primario hacia D2 cuando está autorizado *)
cmd_V3V1_D2 := bdc_available AND (demand_BDC OR hyg_active);

(* HTR hacia D2: por defecto, salvo que D2 esté ya caliente *)
ctrl_HTR_stop(
    measured   := TT5,
    setpoint   := P34_HTRStopTemp,
    hysteresis := P35_HTRStopHyst,
    mode_heat  := FALSE,
    enabled    := enabled
);
cmd_V3V3_D2 := NOT ctrl_HTR_stop.output OR hyg_active;

END_FUNCTION_BLOCK
