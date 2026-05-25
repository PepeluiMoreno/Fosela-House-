(* ============================================================
   FB_SolarPump.st
   Control de la bomba solar P1 (modulante via convertidor 0-10V→PWM).
   - Lazo PI discreto de ΔT constante
   - Tiempos mínimos anti-ciclado
   - Modos: AUTO, OFF, FORZADO
   ============================================================ *)

FUNCTION_BLOCK FB_SolarPump

VAR_INPUT
    TT1             : REAL;     (* Temperatura colector [°C] *)
    TT2             : REAL;     (* D1 fondo [°C] *)
    SP_DT           : REAL;     (* ΔT objetivo [K] *)
    mode            : E_Solar_Mode;
    fault           : BOOL := FALSE;
END_VAR

VAR_OUTPUT
    pump_run        : BOOL;     (* Orden de marcha a FB_Pump *)
    speed_pct       : REAL;     (* Velocidad [0-100 %] → mapear a 0-10V *)
    DT_measured     : REAL;     (* ΔT actual TT1-TT2 *)
    state_desc      : STRING;   (* Descripción estado para diagnóstico *)
END_VAR

VAR
    pi              : FB_PI_Controller;
    pump            : FB_Pump;
    DT_current      : REAL;
    pi_enabled      : BOOL;
END_VAR

(* --- Implementación --- *)

DT_current  := TT1 - TT2;
DT_measured := DT_current;

(* Decidir si P1 debe marchar *)
CASE mode OF

    SOLAR_AUTO:
        (* Arranque diferencial: DT > P11_SolarDeltaTStart *)
        (* Parada diferencial:   DT < P12_SolarDeltaTStop  *)
        (* (la histéresis la gestiona FB_Pump via min_on/min_off) *)
        pump_run := (DT_current > P11_SolarDeltaTStart) OR
                    (pump.running AND DT_current > P12_SolarDeltaTStop);
        pi_enabled := pump_run;
        state_desc := 'AUTO';

    SOLAR_FORCE_DHW, SOLAR_FORCE_POOL:
        pump_run   := TRUE;
        pi_enabled := TRUE;
        state_desc := 'FORZADO';

    SOLAR_OFF:
        pump_run   := FALSE;
        pi_enabled := FALSE;
        state_desc := 'OFF';

    ELSE
        pump_run   := FALSE;
        pi_enabled := FALSE;
        state_desc := 'DESCONOCIDO';
END_CASE

IF fault THEN
    pump_run   := FALSE;
    pi_enabled := FALSE;
    state_desc := 'FALLO';
END_IF

(* Lazo PI: error = ΔT_objetivo - ΔT_medido
   Si DT_current > SP_DT → error negativo → bajar caudal (bajar velocidad)
   Si DT_current < SP_DT → error positivo → subir caudal  *)
pi(
    measured    := DT_current,
    setpoint    := SP_DT,
    Kp          := 0.5,
    Ki          := 0.08,
    out_min     := 10.0,    (* Mínimo 10% para evitar cavitación a velocidad cero *)
    out_max     := 100.0,
    dt_seconds  := 1.0,
    enabled     := pi_enabled,
    reset       := NOT pump_run
);

(* Gestor de bomba (anti-ciclado) *)
pump(
    cmd_run      := pump_run,
    fault        := fault,
    min_on_time  := P14_SolarPumpMinOnTime,
    min_off_time := P15_SolarPumpMinOffTime
);

(* Velocidad: si la bomba no corre → 0; si corre → salida PI *)
IF pump.running THEN
    speed_pct := pi.output;
ELSE
    speed_pct := 0.0;
END_IF

END_FUNCTION_BLOCK
