(* ============================================================
   MB_Slave_Map.st
   Mapa de registros Modbus del controlador solar (esclavo Modbus dir. 1).

   CONFIGURACIÓN EN FREE STUDIO PLUS:
   En Device → Modbus RTU Slave → Memory Mapping, mapear:
     - Holding Registers 100-108: área de lectura (FRE lee)
     - Holding Registers 200-203: área de escritura (FRE escribe)

   Este PROGRAM prepara los valores en las variables globales
   que el driver Modbus publicará automáticamente.
   Se llama en cada ciclo del PLC_PRG.

   Encoding temperatura: REAL → INT multiplicando ×10
     Ejemplo: 42.5 °C → 425 (INT)
     Límite: ±3276.7 °C — suficiente para todas las sondas
   ============================================================ *)

PROGRAM MB_Slave_Map

(* ---- Variables publicadas como Holding Registers (FRE lee) ---- *)
VAR_GLOBAL

    (* Reg 100 *) MB_OUT_TT1          : INT;  (* TT1 ×10 *)
    (* Reg 101 *) MB_OUT_TT2          : INT;  (* TT2 ×10 *)
    (* Reg 102 *) MB_OUT_TT3          : INT;  (* TT3 ×10 *)
    (* Reg 103 *) MB_OUT_VEL_P1       : UINT; (* velocidad P1 ‰ 0-1000 *)
    (* Reg 104 *) MB_OUT_V3VSOL_POS   : UINT; (* 0=ACS, 1=piscina *)
    (* Reg 105 *) MB_OUT_PERS_CLOSED  : UINT; (* 0=abiertas, 1=cerradas *)
    (* Reg 106 *) MB_OUT_P2_RUNNING   : UINT; (* 0=parada, 1=marcha *)
    (* Reg 107 *) MB_OUT_ALM_CODE     : UINT; (* 0=OK, 1=TT1, 2=TT2, 3=ambas *)
    (* Reg 108 *) MB_OUT_DT_SOLAR     : INT;  (* ΔT medido ×10 *)

END_VAR

(* ---- Setpoints recibidos (FRE escribe en estos registros) ---- *)
VAR_GLOBAL

    (* Reg 200 *) MB_IN_SP_DT         : UINT := 80;  (* ΔT objetivo ×10 → 8.0 K *)
    (* Reg 201 *) MB_IN_MODO_SOLAR    : UINT := 0;   (* E_Solar_Mode *)
    (* Reg 202 *) MB_IN_ORD_PERS      : UINT := 0;   (* 0=auto, 1=forzar cierre *)
    (* Reg 203 *) MB_IN_SP_TT3_POOL   : UINT := 750; (* TT3 umbral ×10 → 75.0°C *)
    (* Reg 204 *) MB_IN_POOL_DEMAND   : UINT := 0;   (* 0=no demanda, 1=piscina pide calor *)

END_VAR

VAR
    (* Conversiones de entrada *)
    sp_dt_real      : REAL;
    sp_tt3_real     : REAL;
END_VAR

(* ----------------------------------------------------------------
   Actualizar registros de salida (cada ciclo)
   ---------------------------------------------------------------- *)

MB_OUT_TT1        := REAL_TO_INT(TT1 * MB_TEMP_SCALE);
MB_OUT_TT2        := REAL_TO_INT(TT2 * MB_TEMP_SCALE);
MB_OUT_TT3        := REAL_TO_INT(TT3 * MB_TEMP_SCALE);
MB_OUT_VEL_P1     := REAL_TO_UINT(vel_P1_permil);
MB_OUT_V3VSOL_POS := UINT#0;
IF DO_V3V_SOL THEN MB_OUT_V3VSOL_POS := UINT#1; END_IF
MB_OUT_PERS_CLOSED:= UINT#0;
IF DO_PERS_SOL THEN MB_OUT_PERS_CLOSED := UINT#1; END_IF
MB_OUT_P2_RUNNING := UINT#0;
IF DO_P2 THEN MB_OUT_P2_RUNNING := UINT#1; END_IF
MB_OUT_ALM_CODE   := solar_alarm_code;
MB_OUT_DT_SOLAR   := REAL_TO_INT(DT_solar * MB_TEMP_SCALE);

(* ----------------------------------------------------------------
   Decodificar registros de entrada recibidos del FRE
   ---------------------------------------------------------------- *)

sp_dt_real    := UINT_TO_REAL(MB_IN_SP_DT) / MB_TEMP_SCALE;
sp_tt3_real   := UINT_TO_REAL(MB_IN_SP_TT3_POOL) / MB_TEMP_SCALE;

(* Actualizar GVL con valores recibidos *)
IF sp_dt_real >= 3.0 AND sp_dt_real <= 20.0 THEN
    P10_SolarDeltaTTarget := sp_dt_real;
END_IF
IF sp_tt3_real >= 50.0 AND sp_tt3_real <= 90.0 THEN
    P16_MinTempForPoolSolarHeating := sp_tt3_real;
END_IF

P19_SolarMode        := INT_TO_E_Solar_Mode(UINT_TO_INT(MB_IN_MODO_SOLAR));
P17_SolarOverheatShutterClose   := (MB_IN_ORD_PERS = UINT#1);
pool_demand_ext   := (MB_IN_POOL_DEMAND = UINT#1);

END_PROGRAM
