(* ============================================================
   GVL_Evolution.st
   Variables globales del controlador principal (maestro Modbus).
   Sistema principal — Fosela House
   Arquitectura: BC monobloc genérica (sin HTR) + solar térmico
   ============================================================ *)

VAR_GLOBAL

    (* ---- Entradas analógicas locales (TT4-TT13) ---- *)
    TT4             : REAL;     (* D1 fondo — retorno agua técnica fría [°C] *)
    TT5             : REAL;     (* D2 cabeza — agua técnica caliente, salida a consumos [°C] *)
    TT6             : REAL;     (* Buffer D3 cabeza [°C] *)
    TT7             : REAL;     (* Buffer D3 fondo [°C] *)
    TT8             : REAL;     (* Ida primario BC [°C] *)
    TT9             : REAL;     (* Retorno primario BC [°C] *)
    TT11            : REAL;     (* Temperatura piscina [°C] *)
    TT12            : REAL;     (* Exterior [°C] *)
    TT13            : REAL;     (* Retorno fancoils [°C] *)

    (* ---- Entradas digitales ---- *)
    DI_Z1           : BOOL;     (* Termostato seguridad D1 activo *)
    DI_Z2           : BOOL;     (* Termostato seguridad D2 activo *)
    DI_INUND_FC     : BOOL;     (* Sensor inundación bandejas fancoils *)
    DI_BDC_FAULT    : BOOL;     (* Fallo BC (señal de la propia unidad) *)
    DI_IF_PISC      : BOOL;     (* Interruptor de flujo piscina *)

    (* ---- Salidas digitales ---- *)
    (* Distribución producción BC — dos V3V en cascada:
       V3V1: FALSE=Reservorio (D2 serpentines)  TRUE=→V3V2
       V3V2: FALSE=Buffer D3 fancoils           TRUE=HX_BC piscina *)
    DO_V3V1         : BOOL;     (* BC primario: FALSE=reservorio, TRUE=no-reservorio *)
    DO_V3V2         : BOOL;     (* no-reservorio: FALSE=fancoils (D3), TRUE=piscina (HX_BC) *)
    DO_VP_HX_SOLAR  : BOOL;     (* Válvula piscina lado HX solar *)
    DO_VP_HX_BC     : BOOL;     (* Válvula piscina lado HX aerotérmico *)
    DO_V3V_APT_01   : BOOL;     (* Aparto 1: FALSE=agua precalentada, TRUE=AFS red *)
    DO_V3V_APT_02   : BOOL;
    DO_V3V_APT_03   : BOOL;
    DO_V3V_APT_04   : BOOL;
    DO_P3           : BOOL;     (* Bomba fancoils arranque *)

    (* ---- Datos recibidos del controlador solar por Modbus ---- *)
    SM              : ST_SolarData;  (* Ver Types_Common.st *)

    (* ---- Modos y estados del sistema ---- *)
    bdc_mode        : E_BDC_Mode   := BDC_OFF;
    bdc_priority    : E_BDC_Priority := PRIO_ACS_CLIMATE_POOL;
    bc_mode_heat    : BOOL := TRUE;   (* TRUE=calefacción/ACS, FALSE=refrigeración *)

    (* ---- Ciclo de pasteurización ---- *)
    hyg_phase      : E_Hygienization_Phase := HYG_IDLE;
    hyg_request    : BOOL := FALSE;
    hyg_apt_idx    : UINT := 1;

    (* ---- Alarmas ---- *)
    alarms          : ST_SystemAlarms;

    (* ---- Setpoints enviados al controlador solar vía Modbus ---- *)
    P10_SolarDeltaTTarget           : UINT := 80;    (* 8.0 K ×10 *)
    P16_MinTempForPoolSolarHeating  : UINT := 750;   (* 75.0°C ×10 *)
    P17_SolarOverheatShutterClose   : UINT := 0;
    P19_SolarMode                   : UINT := 0;
    pool_demand_ext                 : UINT := 0;

END_VAR
