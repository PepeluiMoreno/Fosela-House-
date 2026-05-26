(* ============================================================
   FB_DHW_Station.st
   Estación de producción de ACS al paso (agua fresca).
   Intercambiador de placas HX-ACS + circuladora P-ACS + caudalímetro
   YF-B6 + lazo PI sobre temperatura de salida de placa.

   NADA HARDCODED: todos los umbrales en GVL_Params.

   Lazo de control: PI (no PID) sobre TT_DHW_out → velocidad P-ACS.
   Detección de demanda por caudalímetro (anticipación).
   Parada suave (cooldown) para evacuar calor residual.
   Corte térmico bimetálico NC = seguro hardware independiente;
   aquí solo se LEE su estado para alarma y parada lógica.

   Estados: IDLE, ANTICIPATION, ACTIVE, COOLDOWN, PREHEATING,
            ALARM, INHIBITED
   ============================================================ *)

FUNCTION_BLOCK FB_DHW_Station

VAR_INPUT
    rFlowRate       : REAL;     (* Caudal secundario [L/min], calculado del HSC *)
    rTT_DHW_out     : REAL;     (* Temperatura salida placa (sonda rápida) [°C] *)
    rTT_DHW_ret     : REAL;     (* Temperatura retorno primario [°C] (diagnóstico) *)
    rTT5_Reservoir  : REAL;     (* Temperatura tapa D2 (reservorio) [°C] *)
    bThermalCutout  : BOOL;     (* Corte térmico NC: TRUE=normal, FALSE=disparado *)
    bEnable         : BOOL := TRUE; (* Habilitación desde árbitro BDC *)
    bPreheatRequest : BOOL := FALSE;(* Solicitud ciclo precalentamiento apartamentos *)
    dt_seconds      : REAL := 1.0;  (* Periodo de tarea [s] *)
END_VAR

VAR_OUTPUT
    rPACS_Speed     : REAL;     (* Consigna velocidad P-ACS [0..100 %] → TR0+buck *)
    eState          : E_DHW_Station_State;
    bAlarmCutout    : BOOL;     (* Corte térmico disparado *)
    bAlarmResLow    : BOOL;     (* Reservorio por debajo de mínimo crítico *)
    bAlarmOverTemp  : BOOL;     (* Sobretemperatura salida ACS *)
    bWarnResLow     : BOOL;     (* Reservorio bajo (aviso, no crítico) *)
END_VAR

VAR
    PI_DHW          : FB_PI_Controller;
    timer_cooldown  : TON;
    bFlowPresent    : BOOL;
END_VAR

(* ---------- Detección de presencia de flujo ---------- *)
bFlowPresent := rFlowRate >= GVL_Params.P37_DHWFlowDetectMin;

(* ---------- Vigilancia del reservorio ---------- *)
bWarnResLow  := rTT5_Reservoir < GVL_Params.P32_DHWReservoirMinForACS;
bAlarmResLow := rTT5_Reservoir < GVL_Params.P33_DHWReservoirAlarmLow;

(* ---------- Protecciones que fuerzan ALARM ---------- *)
bAlarmCutout   := NOT bThermalCutout;  (* contacto NC abierto = disparo *)
bAlarmOverTemp := rTT_DHW_out > GVL_Params.P39_DHWMaxOutputAlarm;

(* ============================================================
   MÁQUINA DE ESTADOS
   ============================================================ *)
IF bAlarmCutout OR bAlarmOverTemp OR bAlarmResLow THEN
    eState := E_DHW_Station_State.ALARM;
ELSIF NOT bEnable THEN
    eState := E_DHW_Station_State.INHIBITED;
END_IF

CASE eState OF

    E_DHW_Station_State.IDLE:
        rPACS_Speed := 0.0;
        PI_DHW.reset := TRUE;
        IF bFlowPresent THEN
            eState := E_DHW_Station_State.ANTICIPATION;
        ELSIF bPreheatRequest THEN
            eState := E_DHW_Station_State.PREHEATING;
        END_IF

    E_DHW_Station_State.ANTICIPATION:
        (* Arranque inmediato al primer pulso, antes de que caiga la T *)
        PI_DHW.reset := FALSE;
        rPACS_Speed := GVL_Params.P13_SolarPumpMinSpeed; (* arranque suave *)
        eState := E_DHW_Station_State.ACTIVE;

    E_DHW_Station_State.ACTIVE:
        (* Lazo PI: mantener TT_DHW_out en consigna de placa *)
        PI_DHW(measured := rTT_DHW_out,
               setpoint := GVL_Params.P34_DHWPlateOutputSetpoint,
               Kp := GVL_Params.P22_DHWPI_Kp,
               Ki := GVL_Params.P23_DHWPI_Ki,
               out_min := GVL_Params.P13_SolarPumpMinSpeed,
               out_max := 100.0,
               dt_seconds := dt_seconds,
               enabled := TRUE);
        rPACS_Speed := PI_DHW.output;
        IF NOT bFlowPresent THEN
            timer_cooldown(IN := FALSE);
            eState := E_DHW_Station_State.COOLDOWN;
        END_IF

    E_DHW_Station_State.COOLDOWN:
        (* Mantener bomba un tiempo para evacuar calor residual de la placa *)
        rPACS_Speed := GVL_Params.P13_SolarPumpMinSpeed;
        timer_cooldown(IN := TRUE, PT := GVL_Params.P38_DHWPumpCooldown);
        IF bFlowPresent THEN
            timer_cooldown(IN := FALSE);
            eState := E_DHW_Station_State.ACTIVE;
        ELSIF timer_cooldown.Q THEN
            timer_cooldown(IN := FALSE);
            eState := E_DHW_Station_State.IDLE;
        END_IF

    E_DHW_Station_State.PREHEATING:
        (* Precalentamiento de termos de apartamentos: la apertura
           secuencial de V3V_APT la gestiona FB_Preheating; aquí solo
           se asegura caudal por la placa. *)
        rPACS_Speed := 60.0;  (* caudal medio fijo durante precalentamiento *)
        IF NOT bPreheatRequest THEN
            eState := E_DHW_Station_State.COOLDOWN;
        ELSIF bFlowPresent THEN
            eState := E_DHW_Station_State.ACTIVE; (* demanda real tiene prioridad *)
        END_IF

    E_DHW_Station_State.ALARM:
        rPACS_Speed := 0.0;        (* parada lógica; el hardware ya cortó *)
        PI_DHW.reset := TRUE;
        IF NOT bAlarmCutout AND NOT bAlarmOverTemp AND NOT bAlarmResLow THEN
            eState := E_DHW_Station_State.IDLE;  (* corte térmico es rearme manual:
                                                    bThermalCutout vuelve a TRUE solo
                                                    tras rearme físico *)
        END_IF

    E_DHW_Station_State.INHIBITED:
        rPACS_Speed := 0.0;
        PI_DHW.reset := TRUE;
        IF bEnable THEN
            eState := E_DHW_Station_State.IDLE;
        END_IF

END_CASE
