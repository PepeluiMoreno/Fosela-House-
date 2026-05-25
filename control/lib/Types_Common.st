(* ============================================================
   Types_Common.st  –  ENUMs, STRUCTs y constantes de sistema
   NO contiene setpoints ni límites configurables (ver GVL_Params.st)
   ============================================================ *)

TYPE E_Solar_Mode   : ( SOLAR_AUTO:=0, SOLAR_FORCE_ACS:=1, SOLAR_FORCE_POOL:=2, SOLAR_OFF:=3 ); END_TYPE
TYPE E_BDC_Mode     : ( BDC_OFF:=0, BDC_ACS:=1, BDC_CLIMATE:=2, BDC_POOL:=3 ); END_TYPE
TYPE E_Valve3Way_Pos: ( V3W_POS_A:=0, V3W_POS_B:=1 ); END_TYPE
TYPE E_Apartment_Mode:( APT_PRECALENTADA:=0, APT_AFS:=1 ); END_TYPE
TYPE E_BDC_Priority : ( PRIO_ACS_CLIMATE_POOL:=0, PRIO_ACS_POOL_CLIMATE:=1 ); END_TYPE

TYPE E_Hygienization_Phase :
( HYG_IDLE:=0, HYG_HEAT_D2:=1, HYG_HOLD_D2:=2, HYG_FLUSH:=3, HYG_DONE:=4 );
END_TYPE

TYPE ST_SolarData :
STRUCT
    TT1                : REAL;
    TT2                : REAL;
    TT3                : REAL;
    DT_solar           : REAL;
    vel_P1             : UINT;
    pos_V3V_SOL        : BOOL;
    persianas_cerradas : BOOL;
    P2_activo          : BOOL;
    alarma_solar       : UINT;
    comm_ok            : BOOL;
END_STRUCT
END_TYPE

TYPE ST_SystemAlarms :
STRUCT
    ALM_TT1_HIGH     : BOOL;
    ALM_TT2_HIGH     : BOOL;
    ALM_COMM_SOLAR   : BOOL;
    ALM_TT5_LOW      : BOOL;
    ALM_TT5_HIGH     : BOOL;
    ALM_PISC_FLUJO   : BOOL;
    ALM_PISC_T_HIGH  : BOOL;
    ALM_INUNDACION   : BOOL;
    ALM_BDC_FAULT    : BOOL;
    CUALQUIER_ALARMA : BOOL;
END_STRUCT
END_TYPE

(* ---- Constantes de sistema NO configurables --------------- *)
VAR_GLOBAL CONSTANT
    (* Tiempos internos fijos *)
    K_ALM_FILTER        : TIME := T#10S;
    K_VALVE_TRAVEL      : TIME := T#30S;
    K_PUMP_MIN_ON       : TIME := T#30S;
    K_PUMP_MIN_OFF      : TIME := T#20S;
    (* Escala Modbus para temperaturas *)
    MB_TEMP_SCALE       : REAL := 10.0;
    MB_SOLAR_SLAVE_ADDR : UINT := 1;
    (* Registros Modbus – controlador solar (lectura) *)
    MB_R_TT1        : UINT := 100;
    MB_R_TT2        : UINT := 101;
    MB_R_TT3        : UINT := 102;
    MB_R_VEL_P1     : UINT := 103;
    MB_R_V3VSOL     : UINT := 104;
    MB_R_PERS       : UINT := 105;
    MB_R_P2         : UINT := 106;
    MB_R_ALM        : UINT := 107;
    MB_R_DT         : UINT := 108;
    (* Registros Modbus – controlador solar (escritura) *)
    MB_W_P10        : UINT := 200;
    MB_W_P16        : UINT := 201;
    MB_W_P17        : UINT := 202;
    MB_W_P19        : UINT := 203;
    MB_W_POOL_DEM   : UINT := 204;
END_VAR
