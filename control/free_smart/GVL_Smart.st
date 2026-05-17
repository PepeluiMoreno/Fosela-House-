(* ============================================================
   GVL_Smart.st
   Variables globales del controlador solar (controlador esclavo Modbus).
   Subsistema solar — Fusela House
   ============================================================ *)

VAR_GLOBAL

    (* ---- Entradas analógicas (sondas NTC/Pt1000) ---- *)
    TT1             : REAL;     (* AI1 — temperatura salida colector [°C] *)
    TT2             : REAL;     (* AI2 — D1 fondo [°C] *)
    TT3             : REAL;     (* AI3 — D1 cabeza [°C] *)

    (* ---- Salidas analógicas ---- *)
    AO_P1_speed     : REAL;     (* AO 0-10V → convertidor PWM → bomba solar modulante [V] *)

    (* ---- Salidas digitales (relés) ---- *)
    DO_V3V_SOL      : BOOL;     (* Relé 1: FALSE=serp.inf D1 (ACS), TRUE=serp.sup D1 (piscina) *)
    DO_PERS_SOL     : BOOL;     (* Relé 2: FALSE=abiertas, TRUE=cerradas *)
    DO_P2           : BOOL;     (* Relé 3: bomba mini bucle intermedio *)
    DO_ALM_SOLAR    : BOOL;     (* Relé 4: alarma local solar *)

    (* ---- Datos calculados para publicación Modbus ---- *)
    DT_solar        : REAL;     (* ΔT medido TT1 - TT2 [K] *)
    vel_P1_permil   : UINT;     (* Velocidad P1 en ‰ (0-1000) *)

    (* ---- Setpoints recibidos del FRE via Modbus (registros 200-203) ---- *)
    SP_DT_solar     : REAL := 8.0;          (* ΔT objetivo P1 [K] *)
    modo_solar      : E_Solar_Mode := SOLAR_AUTO;
    orden_persianas : BOOL := FALSE;        (* FALSE=auto, TRUE=forzar cierre *)
    SP_TT3_piscina  : REAL := 75.0;         (* TT3 mínimo para desvío a piscina [°C] *)

    (* ---- Alarmas ---- *)
    ALM_TT1_HIGH    : BOOL;
    ALM_TT2_HIGH    : BOOL;
    alarma_solar_code : UINT;   (* 0=OK, 1=TT1 alta, 2=TT2 alta, 3=ambas *)

END_VAR
