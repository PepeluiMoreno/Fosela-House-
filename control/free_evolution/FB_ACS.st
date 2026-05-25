(* ============================================================
   FB_ACS.st  –  Control de producción de ACS
   BC monobloc genérica (sin HTR).
   La BC puede producir ACS de dos formas según el equipo:
     a) Modo ACS dedicado (BDC_ACS): produce agua caliente 55-65°C
        directamente al reservorio (D2 serpentines).
     b) Inversión de ciclo (ACS como calefacción): misma V3V1,
        igual lógica, la BC produce caliente al reservorio.
   En ambos casos la lógica PLC es idéntica: V3V1 hacia reservorio
   y la BC en el modo que proceda.
   ============================================================ *)
FUNCTION_BLOCK FB_ACS
VAR_INPUT
    TT4             : REAL;  (* D1 fondo — agua técnica fría *)
    TT5             : REAL;  (* D2 cabeza — agua técnica caliente *)
    bdc_available   : BOOL;  (* BC autorizada por árbitro *)
    hyg_active      : BOOL;  (* Ciclo de higienización activo *)
    enabled         : BOOL := TRUE;
END_VAR
VAR_OUTPUT
    cmd_V3V1_reservorio : BOOL;  (* TRUE = BC primario → reservorio (D2) *)
    demand_BDC          : BOOL;  (* Solicitud al árbitro *)
    acs_satisfied       : BOOL;  (* Reservorio en setpoint *)
END_VAR
VAR
    ctrl_TT5    : FB_Hysteresis;
    ctrl_TT4    : FB_Hysteresis;
END_VAR

(* ACS satisfecho cuando TT5 (D2 cabeza) supera la consigna *)
ctrl_TT5(
    measured   := TT5,
    setpoint   := P30_ACSStorageSetPoint,
    hysteresis := P31_ACSStorageHysteresis,
    mode_heat  := TRUE,
    enabled    := enabled
);
acs_satisfied := NOT ctrl_TT5.output;

(* Demanda BC: cuando TT4 (fondo D1) cae bajo el umbral de arranque *)
ctrl_TT4(
    measured   := TT4,
    setpoint   := P32_ACSBDCStartTemp,
    hysteresis := P33_ACSBDCStartHyst,
    mode_heat  := TRUE,
    enabled    := enabled AND NOT acs_satisfied
);
demand_BDC := ctrl_TT4.output OR hyg_active;

(* V3V1: BC primario hacia reservorio cuando está autorizado *)
cmd_V3V1_reservorio := bdc_available AND (demand_BDC OR hyg_active);

END_FUNCTION_BLOCK
