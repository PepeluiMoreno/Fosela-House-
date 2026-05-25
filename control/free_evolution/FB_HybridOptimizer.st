(* ============================================================
   FB_HybridOptimizer.st
   Optimizador de fuente BC: Agua-Agua vs Aire-Agua
   
   PRINCIPIO MATEMÁTICO:
   ─────────────────────
   COP_WW_cal = η·(T_cond+273) / [T_cond − (T_pool − ΔT_ap)]
   COP_AW_cal = η·(T_cond+273) / [T_cond − T_air]
   
   COP_WW > COP_AW  ⟺  T_pool − ΔT_ap > T_air
                    ⟺  T_pool > T_air + ΔT_ap     [calefacción]
   
   COP_WW_frio = η·(T_evap+273) / [(T_pool + ΔT_ap) − T_evap]
   COP_AW_frio = η·(T_evap+273) / [T_air − T_evap]
   
   COP_WW > COP_AW  ⟺  T_pool + ΔT_ap < T_air
                    ⟺  T_pool < T_air − ΔT_ap     [refrigeración]
   
   El umbral óptimo de conmutación ES la temperatura de approach
   del intercambiador agua↔refrigerante. No es un parámetro
   heurístico: es la condición exacta de igualdad de COPs.
   
   Con histéresis para evitar cicleo en la zona de indiferencia.
   ============================================================ *)

FUNCTION_BLOCK FB_HybridOptimizer
VAR_INPUT
    T_pool          : REAL;     (* Temperatura piscina [°C] *)
    T_air           : REAL;     (* Temperatura exterior [°C] *)
    mode_heat       : BOOL;     (* TRUE=calefacción/ACS, FALSE=refrigeración *)
    pool_available  : BOOL;     (* Piscina operativa (T_pool > T_pool_min) *)
    enabled         : BOOL := TRUE;
END_VAR

VAR_OUTPUT
    use_WW          : BOOL;     (* TRUE = usar BC agua-agua *)
    use_AW          : BOOL;     (* TRUE = usar BC aire-agua *)
    COP_WW          : REAL;     (* COP calculado BC agua-agua *)
    COP_AW          : REAL;     (* COP calculado BC aire-agua *)
    COP_advantage   : REAL;     (* % ventaja de la fuente elegida vs la otra *)
    source_str      : STRING;   (* "WW" o "AW" para HMI *)
END_VAR

VAR
    (* Parámetros termodinámicos — configurables en puesta en marcha *)
    eta_carnot      : REAL := 0.50;   (* Eficiencia relativa al Carnot *)
    T_cond_cal      : REAL := 47.0;   (* °C condensación modo calefacción *)
    T_evap_ref      : REAL := 7.0;    (* °C evaporación modo refrigeración *)
    DT_approach     : REAL := 5.0;    (* K approach agua↔refrigerante *)
    histeresis      : REAL := 1.5;    (* K banda muerta para evitar cicleo *)
    
    (* Estado interno *)
    last_use_WW     : BOOL := FALSE;
    timer_min_run   : TON;
    MIN_RUN_TIME    : TIME := T#10M;  (* Tiempo mínimo en cada modo *)
    
    (* Variables de cálculo *)
    denom_WW        : REAL;
    denom_AW        : REAL;
    threshold       : REAL;
    T_cond_K        : REAL;
    T_evap_K        : REAL;
END_VAR

(* ── Protección denominadores ────────────────────────────── *)
T_cond_K := T_cond_cal + 273.15;
T_evap_K  := T_evap_ref + 273.15;

IF NOT enabled OR NOT pool_available THEN
    use_WW      := FALSE;
    use_AW      := TRUE;
    COP_WW      := 0.0;
    COP_AW      := 0.0;
    COP_advantage:= 0.0;
    source_str  := 'AW';
    RETURN;
END_IF

(* ── Calcular COPs reales ────────────────────────────────── *)
IF mode_heat THEN
    (* Calefacción: evap en piscina (WW) o en aire (AW), cond en edificio *)
    denom_WW := T_cond_cal - (T_pool - DT_approach);
    denom_AW := T_cond_cal - T_air;
    IF denom_WW < 3.0 THEN denom_WW := 3.0; END_IF
    IF denom_AW < 3.0 THEN denom_AW := 3.0; END_IF
    COP_WW := eta_carnot * T_cond_K / denom_WW;
    COP_AW := eta_carnot * T_cond_K / denom_AW;
    
    (* Umbral analítico: T_pool = T_air + DT_approach *)
    threshold := T_air + DT_approach;

ELSE
    (* Refrigeración: evap en edificio, cond en piscina (WW) o en aire (AW) *)
    denom_WW := (T_pool + DT_approach) - T_evap_ref;
    denom_AW := T_air - T_evap_ref;
    IF denom_WW < 3.0 THEN denom_WW := 3.0; END_IF
    IF denom_AW < 3.0 THEN denom_AW := 3.0; END_IF
    COP_WW := eta_carnot * T_evap_K / denom_WW;
    COP_AW := eta_carnot * T_evap_K / denom_AW;
    
    (* Umbral analítico: T_pool = T_air - DT_approach *)
    threshold := T_air - DT_approach;
END_IF

(* ── Decisión con histéresis ─────────────────────────────── *)
(* Timer mínimo: no conmutar si llevamos menos de MIN_RUN_TIME en el modo actual *)
timer_min_run(IN := TRUE, PT := MIN_RUN_TIME);

IF timer_min_run.Q THEN
    (* Permitido conmutar: aplicar histéresis *)
    IF mode_heat THEN
        IF T_pool > threshold + histeresis THEN
            last_use_WW := TRUE;   timer_min_run(IN:=FALSE);
        ELSIF T_pool < threshold - histeresis THEN
            last_use_WW := FALSE;  timer_min_run(IN:=FALSE);
        END_IF
        (* Entre ±histeresis: mantener el modo anterior *)
    ELSE
        (* Refrigeración: WW mejor cuando piscina MÁS FRÍA que el umbral *)
        IF T_pool < threshold - histeresis THEN
            last_use_WW := TRUE;   timer_min_run(IN:=FALSE);
        ELSIF T_pool > threshold + histeresis THEN
            last_use_WW := FALSE;  timer_min_run(IN:=FALSE);
        END_IF
    END_IF
END_IF

(* ── Salidas ─────────────────────────────────────────────── *)
use_WW := last_use_WW;
use_AW := NOT last_use_WW;

IF use_WW THEN
    source_str    := 'WW';
    IF COP_AW > 0.0 THEN
        COP_advantage := (COP_WW - COP_AW) / COP_AW * 100.0;
    END_IF
ELSE
    source_str    := 'AW';
    IF COP_WW > 0.0 THEN
        COP_advantage := (COP_AW - COP_WW) / COP_WW * 100.0;
    END_IF
END_IF

END_FUNCTION_BLOCK


(* ============================================================
   NOTA DE IMPLEMENTACIÓN PARA FREE STUDIO
   ─────────────────────────────────────────
   Entradas físicas necesarias:
     TT11 → T_pool (sonda NTC en piscina, ya existente)
     TT12 → T_air  (sonda NTC exterior, ya existente)
   
   Salidas digitales:
     DO_SEL_WW → Activa circuito agua-agua (abre V_WW, arranca P_circ_ww)
     DO_SEL_AW → Activa circuito aire-agua (selecciona modo AW en BC)
   
   Variables HMI a mapear:
     COP_WW, COP_AW, COP_advantage, source_str
   
   El bloque se llama en PLC_PRG_Evolution antes de FB_BDC_Arbiter.
   use_WW / use_AW condicionan qué circuito de fuente se activa
   antes de que el árbitro asigne el modo (cal/frio/ACS/piscina).
   ============================================================ *)
