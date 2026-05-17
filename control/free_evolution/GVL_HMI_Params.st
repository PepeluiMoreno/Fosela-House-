(* ============================================================
   GVL_HMI_Params.st
   Parámetros editables del HMI con sus rangos y valores por defecto.
   FUENTE ÚNICA DE VERDAD para todos los setpoints del sistema.
   Cualquier modificación desde el panel actualiza estas variables;
   la lógica de control las lee desde aquí.
   ============================================================ *)

VAR_GLOBAL RETAIN  (* RETAIN: sobreviven a un corte de alimentación *)

    (* ---- SOLAR ------------------------------------------ *)
    HMI_SP_DT_solar     : REAL := 8.0;   (* ΔT objetivo P1  [3.0 – 15.0 K]   paso 0.5 *)
    HMI_SP_TT3_pool     : REAL := 75.0;  (* TT3 → piscina   [60.0 – 90.0 °C] paso 1.0 *)
    HMI_modo_solar      : UINT := 0;     (* 0=AUTO 1=ACS 2=PISC 3=OFF *)

    (* ---- ACS -------------------------------------------- *)
    HMI_SP_TT5          : REAL := 65.0;  (* Setpoint D2 cab  [50.0 – 80.0 °C] paso 0.5 *)
    HMI_HS_TT5          : REAL := 3.0;   (* Histéresis TT5   [1.0 – 5.0 K]   paso 0.5 *)
    HMI_SP_TT4_start    : REAL := 50.0;  (* Umbral arrq BDC  [40.0 – 60.0 °C] paso 0.5 *)

    (* ---- CLIMATIZACIÓN ----------------------------------- *)
    HMI_SP_heat         : REAL := 45.0;  (* Setpoint calefac [35.0 – 60.0 °C] paso 0.5 *)
    HMI_SP_cool         : REAL := 9.0;   (* Setpoint refrig  [5.0 – 15.0 °C]  paso 0.5 *)
    HMI_HS_heat         : REAL := 2.0;   (* Histéresis calef [1.0 – 5.0 K]   paso 0.5 *)
    HMI_HS_cool         : REAL := 1.0;   (* Histéresis refrig[0.5 – 3.0 K]   paso 0.5 *)

    (* ---- PISCINA ---------------------------------------- *)
    HMI_SP_pool         : REAL := 27.0;  (* Setpoint piscina [20.0 – 35.0 °C] paso 0.5 *)
    HMI_HS_pool         : REAL := 1.0;   (* Histéresis pisc  [0.5 – 3.0 K]   paso 0.5 *)

    (* ---- PASTEURIZACIÓN --------------------------------- *)
    HMI_SP_past_target  : REAL := 70.0;  (* T objetivo past. [65.0 – 75.0 °C] paso 0.5 *)
    HMI_past_hold_min   : UINT := 60;    (* Tiempo manten.   [30 – 120 min]   paso 5   *)
    HMI_past_flush_min  : UINT := 30;    (* Tiempo purgado   [15 – 60 min]    paso 5   *)

    (* ---- APARTAMENTOS ----------------------------------- *)
    HMI_apt_mode_01     : UINT := 0;     (* 0=PRECALENTADA 1=AFS *)
    HMI_apt_mode_02     : UINT := 0;
    HMI_apt_mode_03     : UINT := 0;
    HMI_apt_mode_04     : UINT := 0;
    HMI_apt_mode_05     : UINT := 0;

    (* ---- CONFIGURACIÓN SISTEMA -------------------------- *)
    HMI_bdc_priority    : UINT := 0;     (* 0=ACS>CLIM>PISC  1=ACS>PISC>CLIM *)
    HMI_mb_slave_addr   : UINT := 1;     (* Dir. Modbus Smart [1 – 247] *)
    HMI_mb_baudrate     : UINT := 1;     (* 0=9600 1=19200 2=38400 *)

    (* ---- PIN DE ACCESO ---------------------------------- *)
    HMI_pin_test        : UINT := 1234;  (* PIN acceso TEST  [0 – 9999] *)
    HMI_pin_cfg         : UINT := 9999;  (* PIN acceso CFG   [0 – 9999] *)

END_VAR

(* ---- Variables de estado HMI (no RETAIN) ---- *)
VAR_GLOBAL

    (* Solicitudes de acción desde panel *)
    HMI_req_past_manual : BOOL := FALSE; (* Pulso: lanzar pasteurización *)
    HMI_req_alm_reset   : BOOL := FALSE; (* Pulso: reset alarmas *)
    HMI_req_factory_rst : BOOL := FALSE; (* Pulso: reset fábrica (CFG) *)

    (* Estado del HMI *)
    HMI_test_active     : BOOL := FALSE; (* Modo test activo *)
    HMI_cfg_active      : BOOL := FALSE; (* Modo config activo *)
    HMI_pin_ok          : BOOL := FALSE; (* PIN validado en sesión *)

    (* Página actual visible *)
    HMI_current_page    : UINT := 0;     (* 0=MAIN 1=SOL 2=ACS … *)

END_VAR
