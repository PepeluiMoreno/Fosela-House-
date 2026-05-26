(* ============================================================
   FB_Solar.st
   Control del circuito solar primario (glicol) con:
   - MUESTREO A BAJO CAUDAL: arranque por intervalos en lugar de
     sonda de captador. La bomba P-SOL arranca al mínimo caudal
     periódicamente para "tomar muestra" de lo que baja del campo
     sin consumir apenas energía ni disipar calor del depósito.
   - Modulación PI sobre ΔT (ida-retorno) con la bomba en marcha.
   - DISIPACIÓN ENCADENADA: 1º desvío a piscina (HX-POOL-SOL) si
     admite calor (< P62_PoolMaxTemp); 2º cierre de persianas.

   NADA HARDCODED: umbrales en GVL_Params.

   Estados: SLEEP, SAMPLING, RUNNING, DISSIPATING, OVERHEAT
   ============================================================ *)

FUNCTION_BLOCK FB_Solar

VAR_INPUT
    rTT_glycol_in   : REAL;     (* Ida: glicol que baja del campo [°C] *)
    rTT_glycol_out  : REAL;     (* Retorno: glicol frío hacia el campo [°C] *)
    rTT_D1          : REAL;     (* Temperatura D1 (depósito solar) [°C] *)
    rTT_pool        : REAL;     (* Temperatura piscina [°C] *)
    bEnable         : BOOL := TRUE;
    dt_seconds      : REAL := 1.0;
END_VAR

VAR_OUTPUT
    rPSOL_Speed     : REAL;     (* Consigna velocidad P-SOL [0..100 %] *)
    bV3V_Dissip_Pool: BOOL;     (* TRUE = V3V de disipación desvía a HX-POOL-SOL *)
    bShutterClose   : BOOL;     (* TRUE = cerrar persianas (último recurso) *)
    eState          : E_Solar_State;
    rDeltaT         : REAL;     (* ΔT actual ida-retorno [K] (diagnóstico) *)
END_VAR

VAR
    PI_Solar        : FB_PI_Controller;
    timer_interval  : TON;      (* Espera entre muestreos *)
    timer_sample    : TON;      (* Duración de la ventana de muestreo *)
    bReservoirFull  : BOOL;
    bPoolCanTake    : BOOL;
    rDeltaT_sample  : REAL;     (* ΔT respecto al depósito en el muestreo *)
END_VAR

(* ---------- Cálculos auxiliares ---------- *)
rDeltaT        := rTT_glycol_in - rTT_glycol_out;
rDeltaT_sample := rTT_glycol_in - rTT_D1;
bReservoirFull := rTT_D1 >= GVL_Params.P00_AccumulatorMaxTemp;
bPoolCanTake   := rTT_pool < GVL_Params.P62_PoolMaxTemp;

IF NOT bEnable THEN
    eState := E_Solar_State.SLEEP;
END_IF

(* ============================================================
   MÁQUINA DE ESTADOS
   ============================================================ *)
CASE eState OF

    E_Solar_State.SLEEP:
        (* Bomba parada. Esperar intervalo y muestrear. *)
        rPSOL_Speed := 0.0;
        bV3V_Dissip_Pool := FALSE;
        bShutterClose := FALSE;
        PI_Solar.reset := TRUE;
        timer_interval(IN := bEnable, PT := GVL_Params.P56_SolarSampleInterval);
        IF timer_interval.Q THEN
            timer_interval(IN := FALSE);
            timer_sample(IN := FALSE);
            eState := E_Solar_State.SAMPLING;
        END_IF

    E_Solar_State.SAMPLING:
        (* Bomba a BAJO CAUDAL: mínimo consumo, mínima disipación.
           Esperar a que el glicol del campo llegue a la sonda de ida. *)
        rPSOL_Speed := GVL_Params.P13_SolarPumpMinSpeed;
        PI_Solar.reset := TRUE;
        timer_sample(IN := TRUE, PT := GVL_Params.P57_SolarSampleDuration);
        IF timer_sample.Q THEN
            timer_sample(IN := FALSE);
            IF rDeltaT_sample >= GVL_Params.P11_SolarDeltaTStart THEN
                IF bReservoirFull THEN
                    eState := E_Solar_State.DISSIPATING;
                ELSE
                    eState := E_Solar_State.RUNNING;
                END_IF
            ELSE
                eState := E_Solar_State.SLEEP;  (* no merece la pena *)
            END_IF
        END_IF

    E_Solar_State.RUNNING:
        (* Carga normal a D1. PI mantiene ΔT objetivo modulando caudal. *)
        bV3V_Dissip_Pool := FALSE;
        bShutterClose := FALSE;
        PI_Solar(measured := rDeltaT,
                 setpoint := GVL_Params.P10_SolarDeltaTTarget,
                 Kp := GVL_Params.P20_SolarPI_Kp,
                 Ki := GVL_Params.P21_SolarPI_Ki,
                 out_min := GVL_Params.P13_SolarPumpMinSpeed,
                 out_max := 100.0,
                 dt_seconds := dt_seconds,
                 enabled := TRUE);
        rPSOL_Speed := PI_Solar.output;
        IF rDeltaT_sample < GVL_Params.P12_SolarDeltaTStop THEN
            eState := E_Solar_State.SLEEP;       (* campo agotado *)
        ELSIF bReservoirFull THEN
            eState := E_Solar_State.DISSIPATING; (* reservorio lleno *)
        END_IF

    E_Solar_State.DISSIPATING:
        (* 1er escalón: desviar excedente a la piscina si admite calor. *)
        IF bPoolCanTake THEN
            bV3V_Dissip_Pool := TRUE;
            bShutterClose := FALSE;
            rPSOL_Speed := PI_Solar.output;      (* seguir circulando hacia piscina *)
            IF rPSOL_Speed < GVL_Params.P13_SolarPumpMinSpeed THEN
                rPSOL_Speed := GVL_Params.P13_SolarPumpMinSpeed;
            END_IF
            IF NOT bReservoirFull THEN
                eState := E_Solar_State.RUNNING; (* hay sitio otra vez en D1 *)
            END_IF
        ELSE
            eState := E_Solar_State.OVERHEAT;    (* piscina llena: no hay sumidero *)
        END_IF

    E_Solar_State.OVERHEAT:
        (* 2º escalón: cerrar persianas y rezar. Defensa pasiva. *)
        bShutterClose := TRUE;
        bV3V_Dissip_Pool := FALSE;
        rPSOL_Speed := 0.0;
        PI_Solar.reset := TRUE;
        (* Reapertura con histéresis cuando baje la radiación/temperatura *)
        IF rTT_glycol_in < (GVL_Params.P17_SolarOverheatShutterClose
                            - GVL_Params.P18_SolarOverheatShutterHyst) THEN
            eState := E_Solar_State.SLEEP;
        ELSIF bPoolCanTake AND NOT bReservoirFull THEN
            eState := E_Solar_State.RUNNING;
        END_IF

END_CASE
