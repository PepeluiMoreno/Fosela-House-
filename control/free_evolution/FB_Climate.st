(* ============================================================
   FB_Climate.st  –  Control climatización fancoils
   Gestiona V3V2 (→D3), P3. Doble modo calor/frío.
   ============================================================ *)
FUNCTION_BLOCK FB_Climate
VAR_INPUT
    TT6             : REAL;  (* D3 cabeza *)
    TT7             : REAL;  (* D3 fondo *)
    bdc_available   : BOOL;
    mode_heat       : BOOL;  (* TRUE=calefacción FALSE=refrigeración *)
    enabled         : BOOL := TRUE;
END_VAR
VAR_OUTPUT
    cmd_V3V2_D3     : BOOL;  (* TRUE = primario BDC → D3 *)
    cmd_P3          : BOOL;  (* Bomba fancoils *)
    demand_BDC      : BOOL;
    climate_satisfied: BOOL;
END_VAR
VAR
    ctrl_heat : FB_Hysteresis;
    ctrl_cool : FB_Hysteresis;
    pump_P3   : FB_Pump;
END_VAR

IF mode_heat THEN
    ctrl_heat(
        measured   := TT6,
        setpoint   := P50_HeatingSetPoint,
        hysteresis := P51_HeatingHysteresis,
        mode_heat  := TRUE,
        enabled    := enabled
    );
    demand_BDC       := ctrl_heat.output;
    climate_satisfied := NOT ctrl_heat.output;
ELSE
    ctrl_cool(
        measured   := TT7,
        setpoint   := P52_CoolingSetPoint,
        hysteresis := P53_CoolingHysteresis,
        mode_heat  := FALSE,
        enabled    := enabled
    );
    demand_BDC       := ctrl_cool.output;
    climate_satisfied := NOT ctrl_cool.output;
END_IF

cmd_V3V2_D3 := bdc_available AND demand_BDC;

pump_P3(
    cmd_run     := cmd_V3V2_D3,
    min_on_time := T#60S,
    min_off_time:= T#30S,
    enabled     := enabled
);
cmd_P3 := pump_P3.DO_pump;

END_FUNCTION_BLOCK
