(* ============================================================
   GVL_HMI_Params.st
   Parámetros editables del HMI con sus rangos y valores por defecto.
   FUENTE ÚNICA DE VERDAD para todos los setpoints del sistema.
   Cualquier modificación desde el panel actualiza estas variables;
   la lógica de control las lee desde aquí.
   ============================================================ *)

VAR_GLOBAL RETAIN  (* RETAIN: sobreviven a un corte de alimentación *)

    (* ---- SOLAR ------------------------------------------ *)
    P10_SolarDeltaTTarget     : REAL := 8.0;   (* ΔT objetivo P1  [3.0 – 15.0 K]   paso 0.5 *)
    P16_MinTempForPoolSolarHeating     : REAL := 75.0;  (* TT3 → piscina   [60.0 – 90.0 °C] paso 1.0 *)
    P19_SolarMode      : UINT := 0;     (* 0=AUTO 1=ACS 2=PISC 3=OFF *)

    (* ---- ACS -------------------------------------------- *)
    P30_ACSStorageSetPoint          : REAL := 65.0;  (* Setpoint D2 cab  [50.0 – 80.0 °C] paso 0.5 *)
    P31_ACSStorageHysteresis          : REAL := 3.0;   (* Histéresis TT5   [1.0 – 5.0 K]   paso 0.5 *)
    P32_ACSBDCStartTemp    : REAL := 50.0;  (* Umbral arrq BDC  [40.0 – 60.0 °C] paso 0.5 *)

    (* ---- CLIMATIZACIÓN ----------------------------------- *)
    P50_HeatingSetPoint         : REAL := 45.0;  (* Setpoint calefac [35.0 – 60.0 °C] paso 0.5 *)
    P52_CoolingSetPoint         : REAL := 9.0;   (* Setpoint refrig  [5.0 – 15.0 °C]  paso 0.5 *)
    P51_HeatingHysteresis         : REAL := 2.0;   (* Histéresis calef [1.0 – 5.0 K]   paso 0.5 *)
    P53_CoolingHysteresis         : REAL := 1.0;   (* Histéresis refrig[0.5 – 3.0 K]   paso 0.5 *)

    (* ---- PISCINA ---------------------------------------- *)
    P60_PoolSetPoint         : REAL := 27.0;  (* Setpoint piscina [20.0 – 35.0 °C] paso 0.5 *)
    P61_PoolHysteresis         : REAL := 1.0;   (* Histéresis pisc  [0.5 – 3.0 K]   paso 0.5 *)

    (* ---- PRECALENTAMIENTOÓN --------------------------------- *)
    P70_PreheatingTarget  : REAL := 70.0;  (* T objetivo past. [65.0 – 75.0 °C] paso 0.5 *)
    P72_PreheatingHoldTime   : UINT := 60;    (* Tiempo manten.   [30 – 120 min]   paso 5   *)
    P73_PreheatingFlushTime  : UINT := 30;    (* Tiempo purgado   [15 – 60 min]    paso 5   *)

    (* ---- APARTAMENTOS ----------------------------------- *)
    P40_AptMode_01     : UINT := 0;     (* 0=PRECALENTADA 1=AFS *)
    P41_AptMode_02     : UINT := 0;
    P42_AptMode_03     : UINT := 0;
    P43_AptMode_04     : UINT := 0;
    P44_AptMode_05     : UINT := 0;

    (* ---- CONFIGURACIÓN SISTEMA -------------------------- *)
    P80_BDCPriority    : UINT := 0;     (* 0=ACS>CLIM>PISC  1=ACS>PISC>CLIM *)
    P90_ModbusSlaveAddr   : UINT := 1;     (* Dir. Modbus Smart [1 – 247] *)
    P91_ModbusBaudrate     : UINT := 1;     (* 0=9600 1=19200 2=38400 *)

    (* ---- PIN DE ACCESO ---------------------------------- *)
    P94_PIN_L1        : UINT := 1234;  (* PIN acceso TEST  [0 – 9999] *)
    P95_PIN_CFG         : UINT := 9999;  (* PIN acceso CFG   [0 – 9999] *)

END_VAR

(* ---- Variables de estado HMI (no RETAIN) ---- *)
VAR_GLOBAL

    (* Solicitudes de acción desde panel *)
    pre_request : BOOL := FALSE; (* Pulso: lanzar precalentamientoón *)
    HMI_req_alm_reset   : BOOL := FALSE; (* Pulso: reset alarmas *)
    HMI_req_factory_rst : BOOL := FALSE; (* Pulso: reset fábrica (CFG) *)

    (* Estado del HMI *)
    HMI_test_active     : BOOL := FALSE; (* Modo test activo *)
    HMI_cfg_active      : BOOL := FALSE; (* Modo config activo *)
    HMI_pin_ok          : BOOL := FALSE; (* PIN validado en sesión *)

    (* Página actual visible *)
    HMI_current_page    : UINT := 0;     (* 0=MAIN 1=SOL 2=ACS … *)

END_VAR
