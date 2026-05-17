(* ============================================================
   Types_Common.st
   Tipos, enumeraciones y constantes compartidos entre
   FREE Smart (solar) y FREE Evolution (sistema principal).
   Proyecto: Fusela House — Jerez de la Frontera
   ============================================================ *)

(* ------------------------------------------------------------
   ENUMERACIONES
   ------------------------------------------------------------ *)

(* Modos del subsistema solar *)
TYPE E_Solar_Mode :
(
    SOLAR_AUTO      := 0,   (* Lógica automática según temperaturas *)
    SOLAR_FORCE_ACS := 1,   (* Forzar desvío a ACS *)
    SOLAR_FORCE_POOL:= 2,   (* Forzar desvío a piscina *)
    SOLAR_OFF       := 3    (* Solar desactivado *)
);
END_TYPE

(* Destino del primario de la BDC *)
TYPE E_BDC_Mode :
(
    BDC_OFF         := 0,
    BDC_ACS         := 1,   (* V3V1→D2 *)
    BDC_CLIMATE     := 2,   (* V3V1→V3V2→D3 *)
    BDC_POOL        := 3    (* V3V1→V3V2→HX_BDC *)
);
END_TYPE

(* Destino del HTR *)
TYPE E_HTR_Mode :
(
    HTR_ACS         := 0,   (* V3V3→serp.sup D2 (por defecto) *)
    HTR_POOL        := 1    (* V3V3→HX_HTR *)
);
END_TYPE

(* Estado de válvula de 3 vías *)
TYPE E_Valve3Way_Pos :
(
    V3W_POS_A       := 0,   (* Posición A (desenergizada / muelle) *)
    V3W_POS_B       := 1    (* Posición B (energizada) *)
);
END_TYPE

(* Modo de apartamento *)
TYPE E_Apartment_Mode :
(
    APT_PRECALENTADA := 0,  (* Alimenta CE desde agua precalentada (por defecto) *)
    APT_AFS          := 1   (* Alimenta CE desde AFS directa *)
);
END_TYPE

(* Fases del ciclo de pasteurización *)
TYPE E_Pasteurization_Phase :
(
    PAST_IDLE        := 0,  (* Sin ciclo activo *)
    PAST_HEAT_D2     := 1,  (* Calentando D2 a 70 °C *)
    PAST_HOLD_D2     := 2,  (* Manteniendo D2 ≥ 70 °C durante t_hold *)
    PAST_FLUSH_APT   := 3,  (* Purgado secuencial de apartamentos *)
    PAST_DONE        := 4   (* Ciclo completado *)
);
END_TYPE

(* Prioridad de la BDC *)
TYPE E_BDC_Priority :
(
    PRIO_ACS_CLIMATE_POOL := 0,  (* ACS > Climatización > Piscina *)
    PRIO_ACS_POOL_CLIMATE := 1   (* ACS > Piscina > Climatización *)
);
END_TYPE

(* ------------------------------------------------------------
   ESTRUCTURAS
   ------------------------------------------------------------ *)

(* Datos del subsistema solar publicados por FREE Smart *)
TYPE ST_SolarData :
STRUCT
    TT1             : REAL;     (* Temperatura colector [°C] *)
    TT2             : REAL;     (* D1 fondo [°C] *)
    TT3             : REAL;     (* D1 cabeza [°C] *)
    DT_solar        : REAL;     (* ΔT medido TT1-TT2 [K] *)
    vel_P1          : UINT;     (* Velocidad P1 [0-1000 ‰] *)
    pos_V3V_SOL     : BOOL;     (* FALSE=ACS, TRUE=piscina *)
    persianas_cerradas : BOOL;
    P2_activo       : BOOL;
    alarma_solar    : UINT;     (* 0=OK, ver códigos *)
    comm_ok         : BOOL;     (* Comunicación Modbus activa *)
END_STRUCT
END_TYPE

(* Alarmas del sistema *)
TYPE ST_SystemAlarms :
STRUCT
    (* Solar *)
    ALM_TT1_HIGH        : BOOL;  (* TT1 > ALM_TT1_MAX *)
    ALM_TT2_HIGH        : BOOL;  (* TT2 > ALM_TT2_MAX *)
    ALM_COMM_SMART      : BOOL;  (* Pérdida comunicación FREE Smart *)
    (* ACS *)
    ALM_TT5_LOW         : BOOL;  (* D2 cabeza por debajo de mínimo *)
    ALM_TT5_HIGH        : BOOL;  (* D2 sobretemperatura *)
    (* Piscina *)
    ALM_PISC_FLUJO      : BOOL;  (* IF_PISC sin flujo durante calentamiento *)
    ALM_PISC_T_HIGH     : BOOL;  (* TT11 > máximo piscina *)
    (* Climatización *)
    ALM_INUNDACION      : BOOL;  (* Sensor inundación bandeja fancoil *)
    ALM_D3_HIGH         : BOOL;  (* D3 sobretemperatura *)
    (* General *)
    ALM_BDC_FAULT       : BOOL;  (* Fallo BDC (entrada digital) *)
    CUALQUIER_ALARMA    : BOOL;  (* OR de todas *)
END_STRUCT
END_TYPE

(* ------------------------------------------------------------
   CONSTANTES — TEMPERATURAS (°C)
   ------------------------------------------------------------ *)
VAR_GLOBAL CONSTANT

    (* Solar *)
    C_SOLAR_DT_START    : REAL := 6.0;   (* ΔT arranque P1 *)
    C_SOLAR_DT_STOP     : REAL := 3.0;   (* ΔT parada P1 *)
    C_SOLAR_DT_TARGET   : REAL := 8.0;   (* ΔT objetivo lazo PI *)
    C_SOLAR_TT3_POOL    : REAL := 75.0;  (* TT3 mínimo para desvío a piscina *)
    C_SOLAR_TT1_MAX     : REAL := 95.0;  (* Alarma sobretemperatura colector *)
    C_SOLAR_TT2_DISS    : REAL := 85.0;  (* TT2 máximo antes de disipación *)
    C_SOLAR_TT2_LEGIONELLA : REAL := 45.0; (* Si TT2 lleva días por debajo → arranque forzado *)

    (* ACS *)
    C_ACS_TT4_START     : REAL := 50.0;  (* TT4 D2 fondo — arranque carga BDC *)
    C_ACS_TT4_STOP      : REAL := 55.0;  (* TT4 D2 fondo — parada carga BDC *)
    C_ACS_TT5_TARGET    : REAL := 65.0;  (* TT5 D2 cabeza — setpoint ACS *)
    C_ACS_TT5_HYST      : REAL := 3.0;   (* Histéresis TT5 *)
    C_ACS_VMT1          : REAL := 55.0;  (* Temperatura VMT1 [°C] — ajuste físico *)
    C_ACS_PAST_TARGET   : REAL := 70.0;  (* Temperatura pasteurización D2 *)
    C_ACS_PAST_HYST     : REAL := 2.0;   (* Histéresis pasteurización *)
    C_ACS_HTR_TT5_STOP  : REAL := 68.0;  (* TT5 que inhibe HTR hacia D2 *)

    (* Climatización *)
    C_CLIM_HEAT_START   : REAL := 45.0;  (* TT6 D3 arranque calefacción BDC *)
    C_CLIM_HEAT_STOP    : REAL := 50.0;  (* TT6 D3 parada calefacción *)
    C_CLIM_COOL_START   : REAL := 9.0;   (* TT7 D3 arranque refrigeración *)
    C_CLIM_COOL_STOP    : REAL := 7.0;   (* TT7 D3 parada refrigeración *)

    (* Piscina *)
    C_POOL_TARGET       : REAL := 27.0;  (* TT11 setpoint temperatura piscina *)
    C_POOL_HYST         : REAL := 1.0;   (* Histéresis piscina *)
    C_POOL_MAX          : REAL := 32.0;  (* TT11 máximo — alarma *)

    (* Alarmas hardware *)
    C_ALM_TT1_MAX       : REAL := 95.0;
    C_ALM_TT2_MAX       : REAL := 88.0;  (* TK1 termostato hardware ≈ 88°C *)
    C_ALM_TT5_MAX       : REAL := 92.0;  (* Z2 hardware ≈ 95°C *)

END_VAR

(* ------------------------------------------------------------
   CONSTANTES — TIEMPOS
   ------------------------------------------------------------ *)
VAR_GLOBAL CONSTANT

    C_SOLAR_MIN_ON_TIME     : TIME := T#30S;   (* Tiempo mínimo P1 encendida *)
    C_SOLAR_MIN_OFF_TIME    : TIME := T#20S;   (* Tiempo mínimo P1 apagada *)
    C_VALVE_TRAVEL_TIME     : TIME := T#30S;   (* Tiempo de maniobra V3V *)
    C_MODBUS_POLL_PERIOD    : TIME := T#5S;    (* Periodo polling Modbus maestro *)
    C_MODBUS_TIMEOUT        : TIME := T#15S;   (* Timeout comunicación *)
    C_PAST_HOLD_TIME        : TIME := T#60M;   (* Tiempo mantenimiento pasteurización *)
    C_PAST_FLUSH_TIME       : TIME := T#30M;   (* Tiempo purgado por apartamento *)
    C_ALM_FILTER_TIME       : TIME := T#10S;   (* Filtro antirrebote alarmas *)
    C_LEGIONELLA_MAX_DAYS   : TIME := T#168H;  (* 7 días sin llegar a 60°C en TT2 *)
    C_VACANCIA_THRESHOLD    : TIME := T#336H;  (* 14 días → cambiar APT a AFS *)

END_VAR

(* ------------------------------------------------------------
   CONSTANTES — MODBUS REGISTROS
   (FREE Smart esclavo dirección 1)
   ------------------------------------------------------------ *)
VAR_GLOBAL CONSTANT

    (* Registros de lectura (FREE Smart → FREE Evolution) *)
    MB_REG_TT1          : UINT := 100;
    MB_REG_TT2          : UINT := 101;
    MB_REG_TT3          : UINT := 102;
    MB_REG_VEL_P1       : UINT := 103;
    MB_REG_EST_V3VSOL   : UINT := 104;
    MB_REG_EST_PERS     : UINT := 105;
    MB_REG_EST_P2       : UINT := 106;
    MB_REG_ALM_SOLAR    : UINT := 107;
    MB_REG_DT_SOLAR     : UINT := 108;

    (* Registros de escritura (FREE Evolution → FREE Smart) *)
    MB_REG_SP_DT        : UINT := 200;
    MB_REG_MODO_SOLAR   : UINT := 201;
    MB_REG_ORD_PERS     : UINT := 202;
    MB_REG_SP_TT3_POOL  : UINT := 203;

    (* Escala para valores de temperatura en Modbus (×10) *)
    MB_TEMP_SCALE       : REAL := 10.0;

    (* Dirección esclavo FREE Smart *)
    MB_SMART_SLAVE_ADDR : UINT := 1;

END_VAR
