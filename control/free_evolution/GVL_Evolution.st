(* ============================================================
   GVL_Evolution.st
   Variables globales del FREE Evolution.
   Sistema principal — Fusela House
   ============================================================ *)

VAR_GLOBAL

    (* ---- Entradas analógicas locales (TT4-TT14) ---- *)
    TT4             : REAL;     (* D2 fondo [°C] *)
    TT5             : REAL;     (* D2 cabeza [°C] *)
    TT6             : REAL;     (* D3 cabeza [°C] *)
    TT7             : REAL;     (* D3 fondo [°C] *)
    TT8             : REAL;     (* Ida primario BDC [°C] *)
    TT9             : REAL;     (* Retorno primario BDC [°C] *)
    TT10            : REAL;     (* Ida HTR [°C] *)
    TT11            : REAL;     (* Temperatura piscina [°C] *)
    TT12            : REAL;     (* Exterior [°C] *)
    TT13            : REAL;     (* Retorno fancoils [°C] *)
    TT14            : REAL;     (* Mini bucle intermedio piscina [°C] *)

    (* ---- Entradas digitales ---- *)
    DI_Z1           : BOOL;     (* Termostato seguridad D1 activo *)
    DI_Z2           : BOOL;     (* Termostato seguridad D2 activo *)
    DI_INUND_FC     : BOOL;     (* Sensor inundación bandejas fancoils *)
    DI_BDC_FAULT    : BOOL;     (* Fallo BDC (señal de la propia BDC) *)

    (* ---- Salidas digitales ---- *)
    DO_V3V1         : BOOL;     (* Primario BDC: FALSE=D2, TRUE=no-D2 *)
    DO_V3V2         : BOOL;     (* no-D2: FALSE=D3, TRUE=HX_BDC *)
    DO_V3V3         : BOOL;     (* HTR: FALSE=D2sup, TRUE=HX_HTR *)
    DO_VP_HX1       : BOOL;     (* Lado piscina HX1 *)
    DO_VP_HX_BDC    : BOOL;     (* Lado piscina HX_BDC *)
    DO_VP_HX_HTR    : BOOL;     (* Lado piscina HX_HTR *)
    DO_V3V_APT_01   : BOOL;     (* Aparto 1: FALSE=precalentada, TRUE=AFS *)
    DO_V3V_APT_02   : BOOL;
    DO_V3V_APT_03   : BOOL;
    DO_V3V_APT_04   : BOOL;
    DO_V3V_APT_05   : BOOL;
    DO_P3           : BOOL;     (* Bomba fancoils arranque *)
    DO_P4           : BOOL;     (* Bomba HTR arranque *)

    (* ---- Datos recibidos del FREE Smart por Modbus ---- *)
    SM              : ST_SolarData;  (* Ver Types_Common.st *)

    (* ---- Modos y estados del sistema ---- *)
    bdc_mode        : E_BDC_Mode   := BDC_OFF;
    htr_mode        : E_HTR_Mode   := HTR_ACS;
    bdc_priority    : E_BDC_Priority := PRIO_ACS_CLIMATE_POOL;

    (* ---- Ciclo de pasteurización ---- *)
    past_phase      : E_Pasteurization_Phase := PAST_IDLE;
    past_request    : BOOL := FALSE;    (* Solicitud manual o automática *)
    past_apt_idx    : UINT := 1;        (* Apartamento actual en purgado *)

    (* ---- Alarmas ---- *)
    alarms          : ST_SystemAlarms;

    (* ---- Setpoints enviados al FREE Smart vía Modbus ---- *)
    MB_TO_SMART_SP_DT       : UINT := 80;   (* 8.0K ×10 *)
    MB_TO_SMART_MODO        : UINT := 0;
    MB_TO_SMART_PERS        : UINT := 0;
    MB_TO_SMART_SP_TT3_POOL : UINT := 750;  (* 75.0°C ×10 *)
    MB_TO_SMART_POOL_DEMAND : UINT := 0;

END_VAR
