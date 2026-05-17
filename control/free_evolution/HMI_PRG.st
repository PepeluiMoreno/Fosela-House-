(* ============================================================
   HMI_PRG.st
   Programa HMI del controlador principal.
   Display 4 dígitos 7-segmentos + teclas ▲▼ ENTER ESC F1 F2.

   ARQUITECTURA:
   - Usa library_SmartHMI (disponible en FREE Studio Plus)
   - Si SmartHMI no está disponible: sustituir FB_HMI_Page y
     FB_HMI_Item por los equivalentes del driver de display disponible.

   ESTRUCTURA DE MENÚS:
   [MAIN] → SOL / ACS / CLIM / PISC / APT / PAST / ALR / TEST / CFG

   CONVENCIONES DISPLAY 4 DÍGITOS:
   - Letras: abreviaturas 4 chars ("SOL." "ACS." "TT 1" "SP.5")
   - Números: con punto decimal cuando aplica ("27.0" "65.0")
   - Estados BOOL: " On " / " OFF"
   - Enums: "AUto" "PIsc" "AFS." "PREC"
   - Errores: "Err." "----" "HHH." "LLL."

   TECLAS:
   - ▲▼     Navegar entre ítems / cambiar valor
   - ENTER  Entrar en menú / confirmar edición
   - ESC    Volver al nivel superior / cancelar edición
   - F1     Acceso rápido a ALARMAS desde cualquier página
   - F2     Acceso rápido a página principal (MAIN)
   ============================================================ *)

PROGRAM HMI_PRG

VAR
    (* ---- Instancias SmartHMI (library_SmartHMI) ---- *)
    (* NOTA: Verificar nombres exactos de FB en FREE Studio Plus:
       Library Manager → library_SmartHMI → ver lista de FBs.
       Los nombres indicados aquí son los más probables según
       la documentación de la gama FREE. *)

    hmi             : FB_HMIController;     (* Controlador principal HMI *)

    (* Páginas principales *)
    pg_main         : FB_HMIPage;
    pg_sol          : FB_HMIPage;
    pg_acs          : FB_HMIPage;
    pg_clim         : FB_HMIPage;
    pg_pisc         : FB_HMIPage;
    pg_apt          : FB_HMIPage;
    pg_past         : FB_HMIPage;
    pg_alr          : FB_HMIPage;
    pg_test         : FB_HMIPage;
    pg_cfg          : FB_HMIPage;

    (* PIN guards *)
    pin_test        : FB_PIN_Guard;
    pin_cfg         : FB_PIN_Guard;
    pin_entered_val : UINT := 0;

    (* Test mode *)
    test_mode       : FB_TestMode;

    (* Auxiliares *)
    timer_alm_blink : TON;
    alm_blink_state : BOOL;
    any_alarm       : BOOL;

    (* Actividad panel (reset timeout sesión) *)
    panel_activity  : BOOL;

END_VAR

(* ============================================================
   1. GESTIÓN DE ALARMAS Y PARPADEO
   ============================================================ *)
any_alarm := alarms.CUALQUIER_ALARMA;

timer_alm_blink(IN := any_alarm, PT := T#500MS);
IF timer_alm_blink.Q THEN
    alm_blink_state := NOT alm_blink_state;
    timer_alm_blink(IN := FALSE, PT := T#500MS);
END_IF

(* ============================================================
   2. PROTECCIÓN PIN
   ============================================================ *)
pin_test(
    pin_stored      := P94_PIN_L1,
    pin_entered     := pin_entered_val,
    confirm         := hmi.key_enter AND HMI_current_page = UINT#8,
    cancel          := hmi.key_esc,
    activity        := panel_activity,
    session_timeout := T#10M,
    lockout_time    := T#5M
);

pin_cfg(
    pin_stored      := P95_PIN_CFG,
    pin_entered     := pin_entered_val,
    confirm         := hmi.key_enter AND HMI_current_page = UINT#9,
    cancel          := hmi.key_esc,
    activity        := panel_activity,
    session_timeout := T#10M,
    lockout_time    := T#5M
);

HMI_test_active := pin_test.access_granted;
HMI_cfg_active  := pin_cfg.access_granted;

(* ============================================================
   3. MODO TEST
   ============================================================ *)
test_mode(test_active := HMI_test_active);
(* Las salidas de test_mode se aplican en PLC_PRG_Evolution *)

(* ============================================================
   4. DEFINICIÓN DE PÁGINAS HMI
   ============================================================
   NOTA IMPLEMENTACIÓN:
   En FREE Studio Plus con library_SmartHMI, cada FB_HMIPage
   se configura con:
     - title      : STRING (4 chars para 7-seg)
     - items[]    : array de FB_HMIItem
   Cada FB_HMIItem tiene:
     - label      : STRING (4 chars)
     - pVar       : POINTER TO variable
     - type       : READ_ONLY / EDITABLE / ACTION
     - min/max/step (para editables)
   La navegación es automática vía el FB_HMIController.
   ============================================================ *)

(* ---- PÁGINA MAIN ----------------------------------------- *)
(*
   Display muestra "MAIN"
   Items:
   [1] "SOL." → entrar pg_sol
   [2] "ACS." → entrar pg_acs
   [3] "CLIM" → entrar pg_clim
   [4] "PISC" → entrar pg_pisc
   [5] "APT." → entrar pg_apt
   [6] "PAST" → entrar pg_past
   [7] "ALR." → entrar pg_alr  ← parpadea si hay alarma activa
   [8] "TEST" → entrar pg_test (pide PIN)
   [9] "CFG." → entrar pg_cfg  (pide PIN)
*)
pg_main(
    title           := 'MAIN',
    show_alarm_icon := any_alarm
);

(* ---- PÁGINA SOLAR ---------------------------------------- *)
(*
   Label  | Variable              | Tipo        | Min  | Max   | Paso
   -------|----------------------|-------------|------|-------|------
   "TT 1" | SM.TT1               | READ_ONLY   |      |       |
   "TT 2" | TT2 (vía Modbus)     | READ_ONLY   |      |       |
   "TT 3" | SM.TT3               | READ_ONLY   |      |       |
   "d  T" | SM.DT_solar          | READ_ONLY   |      |       |
   "P  1" | SM.vel_P1 (→ % /10) | READ_ONLY   |      |       |
   "VLV." | SM.pos_V3V_SOL       | READ_ONLY   | ACS/PISC     |
   "PRS." | SM.persianas_cerr.   | READ_ONLY   | ABR/CER      |
   "SP.T" | P10_SolarDeltaTTarget      | EDITABLE    | 3.0  | 15.0  | 0.5
   "SP.P" | P16_MinTempForPoolSolarHeating      | EDITABLE    | 60.0 | 90.0  | 1.0
   "MOD." | P19_SolarMode       | EDITABLE    | AUTO/ACS/PISC/OFF
*)
pg_sol(
    title           := 'SOL.',
    item_01_label   := 'TT 1', item_01_var := ADR(SM.TT1),           item_01_type := HMI_READ_ONLY,
    item_02_label   := 'TT 2', item_02_var := ADR(SM.TT2),           item_02_type := HMI_READ_ONLY,
    item_03_label   := 'TT 3', item_03_var := ADR(SM.TT3),           item_03_type := HMI_READ_ONLY,
    item_04_label   := 'd  T', item_04_var := ADR(SM.DT_solar),      item_04_type := HMI_READ_ONLY,
    item_05_label   := 'P  1', item_05_var := ADR(SM.vel_P1),        item_05_type := HMI_READ_ONLY,
    item_06_label   := 'SP.T', item_06_var := ADR(P10_SolarDeltaTTarget),  item_06_type := HMI_EDITABLE,
        item_06_min := 3.0,   item_06_max := 15.0,  item_06_step := 0.5,
    item_07_label   := 'SP.P', item_07_var := ADR(P16_MinTempForPoolSolarHeating),  item_07_type := HMI_EDITABLE,
        item_07_min := 60.0,  item_07_max := 90.0,  item_07_step := 1.0,
    item_08_label   := 'MOD.', item_08_var := ADR(P19_SolarMode),   item_08_type := HMI_EDITABLE,
        item_08_min := 0,     item_08_max := 3,     item_08_step := 1
);

(* ---- PÁGINA ACS ------------------------------------------ *)
(*
   "TT 4" | TT4               | READ_ONLY
   "TT 5" | TT5               | READ_ONLY
   "SP.5" | P30_ACSStorageSetPoint        | EDITABLE  50-80  paso 0.5
   "HS.5" | P31_ACSStorageHysteresis        | EDITABLE  1.0-5.0 paso 0.5
   "SP.4" | P32_ACSBDCStartTemp  | EDITABLE  40-60  paso 0.5
   "V3.1" | DO_V3V1           | READ_ONLY (ACS/nAC)
   "V3.2" | DO_V3V2           | READ_ONLY (D3/HX)
   "V3.3" | DO_V3V3           | READ_ONLY (ACS/HX)
*)
pg_acs(
    title           := 'ACS.',
    item_01_label   := 'TT 4', item_01_var := ADR(TT4),              item_01_type := HMI_READ_ONLY,
    item_02_label   := 'TT 5', item_02_var := ADR(TT5),              item_02_type := HMI_READ_ONLY,
    item_03_label   := 'SP.5', item_03_var := ADR(P30_ACSStorageSetPoint),       item_03_type := HMI_EDITABLE,
        item_03_min := 50.0,  item_03_max := 80.0,  item_03_step := 0.5,
    item_04_label   := 'HS.5', item_04_var := ADR(P31_ACSStorageHysteresis),       item_04_type := HMI_EDITABLE,
        item_04_min := 1.0,   item_04_max := 5.0,   item_04_step := 0.5,
    item_05_label   := 'SP.4', item_05_var := ADR(P32_ACSBDCStartTemp), item_05_type := HMI_EDITABLE,
        item_05_min := 40.0,  item_05_max := 60.0,  item_05_step := 0.5,
    item_06_label   := 'V3.1', item_06_var := ADR(DO_V3V1),          item_06_type := HMI_READ_ONLY,
    item_07_label   := 'V3.2', item_07_var := ADR(DO_V3V2),          item_07_type := HMI_READ_ONLY,
    item_08_label   := 'V3.3', item_08_var := ADR(DO_V3V3),          item_08_type := HMI_READ_ONLY
);

(* ---- PÁGINA CLIMATIZACIÓN -------------------------------- *)
pg_clim(
    title           := 'CLIM',
    item_01_label   := 'TT 6', item_01_var := ADR(TT6),         item_01_type := HMI_READ_ONLY,
    item_02_label   := 'TT 7', item_02_var := ADR(TT7),         item_02_type := HMI_READ_ONLY,
    item_03_label   := 'SP.H', item_03_var := ADR(P50_HeatingSetPoint), item_03_type := HMI_EDITABLE,
        item_03_min := 35.0,  item_03_max := 60.0, item_03_step := 0.5,
    item_04_label   := 'SP.C', item_04_var := ADR(P52_CoolingSetPoint), item_04_type := HMI_EDITABLE,
        item_04_min := 5.0,   item_04_max := 15.0, item_04_step := 0.5,
    item_05_label   := 'HS.H', item_05_var := ADR(P51_HeatingHysteresis), item_05_type := HMI_EDITABLE,
        item_05_min := 1.0,   item_05_max := 5.0,  item_05_step := 0.5,
    item_06_label   := 'HS.C', item_06_var := ADR(P53_CoolingHysteresis), item_06_type := HMI_EDITABLE,
        item_06_min := 0.5,   item_06_max := 3.0,  item_06_step := 0.5,
    item_07_label   := 'P  3', item_07_var := ADR(DO_P3),       item_07_type := HMI_READ_ONLY
);

(* ---- PÁGINA PISCINA ------------------------------------- *)
pg_pisc(
    title           := 'PISC',
    item_01_label   := 'TT11', item_01_var := ADR(TT11),          item_01_type := HMI_READ_ONLY,
    item_02_label   := 'TT14', item_02_var := ADR(TT14),          item_02_type := HMI_READ_ONLY,
    item_03_label   := 'SP.P', item_03_var := ADR(P60_PoolSetPoint),   item_03_type := HMI_EDITABLE,
        item_03_min := 20.0,  item_03_max := 35.0, item_03_step := 0.5,
    item_04_label   := 'HS.P', item_04_var := ADR(P61_PoolHysteresis),   item_04_type := HMI_EDITABLE,
        item_04_min := 0.5,   item_04_max := 3.0,  item_04_step := 0.5,
    item_05_label   := 'VP.1', item_05_var := ADR(DO_VP_HX1),     item_05_type := HMI_READ_ONLY,
    item_06_label   := 'VP.B', item_06_var := ADR(DO_VP_HX_BDC),  item_06_type := HMI_READ_ONLY,
    item_07_label   := 'VP.H', item_07_var := ADR(DO_VP_HX_HTR),  item_07_type := HMI_READ_ONLY,
    item_08_label   := 'FLW.', item_08_var := ADR(DI_IF_PISC),    item_08_type := HMI_READ_ONLY
);

(* ---- PÁGINA APARTAMENTOS -------------------------------- *)
(*  Cada ítem: label "A 01"  valor: 0=PREC 1=AFS  *)
pg_apt(
    title           := 'APT.',
    item_01_label   := 'A 01', item_01_var := ADR(P40_AptMode_01), item_01_type := HMI_EDITABLE,
        item_01_min := 0, item_01_max := 1, item_01_step := 1,
    item_02_label   := 'A 02', item_02_var := ADR(P41_AptMode_02), item_02_type := HMI_EDITABLE,
        item_02_min := 0, item_02_max := 1, item_02_step := 1,
    item_03_label   := 'A 03', item_03_var := ADR(P42_AptMode_03), item_03_type := HMI_EDITABLE,
        item_03_min := 0, item_03_max := 1, item_03_step := 1,
    item_04_label   := 'A 04', item_04_var := ADR(P43_AptMode_04), item_04_type := HMI_EDITABLE,
        item_04_min := 0, item_04_max := 1, item_04_step := 1,
    item_05_label   := 'A 05', item_05_var := ADR(P44_AptMode_05), item_05_type := HMI_EDITABLE,
        item_05_min := 0, item_05_max := 1, item_05_step := 1
);

(* ---- PÁGINA PASTEURIZACIÓN ------------------------------ *)
pg_past(
    title           := 'PAST',
    item_01_label   := 'STA.', item_01_var := ADR(hyg_phase),        item_01_type := HMI_READ_ONLY,
    item_02_label   := 'TT 5', item_02_var := ADR(TT5),               item_02_type := HMI_READ_ONLY,
    item_03_label   := 'APT.', item_03_var := ADR(hyg_apt_idx),      item_03_type := HMI_READ_ONLY,
    item_04_label   := 'SP.T', item_04_var := ADR(P70_HygienizationTarget),item_04_type := HMI_EDITABLE,
        item_04_min := 65.0,  item_04_max := 75.0, item_04_step := 0.5,
    item_05_label   := 'T.Ho', item_05_var := ADR(P72_HygienizationHoldTime), item_05_type := HMI_EDITABLE,
        item_05_min := 30,    item_05_max := 120,  item_05_step := 5,
    item_06_label   := 'T.Fl', item_06_var := ADR(P73_HygienizationFlushTime),item_06_type := HMI_EDITABLE,
        item_06_min := 15,    item_06_max := 60,   item_06_step := 5,
    item_07_label   := 'RUN.', item_07_var := ADR(hyg_request),item_07_type := HMI_ACTION
);

(* ---- PÁGINA ALARMAS ------------------------------------- *)
(*  Cada alarma: label 4 chars, valor BOOL READ_ONLY
    "ACT." muestra el número de alarmas activas
    "RST." reset con ENTER                               *)
pg_alr(
    title           := 'ALR.',
    item_01_label   := 'ACT.', item_01_var := ADR(alm_count),             item_01_type := HMI_READ_ONLY,
    item_02_label   := 'TT1H', item_02_var := ADR(alarms.ALM_TT1_HIGH),   item_02_type := HMI_READ_ONLY,
    item_03_label   := 'TT2H', item_03_var := ADR(alarms.ALM_TT2_HIGH),   item_03_type := HMI_READ_ONLY,
    item_04_label   := 'COMM', item_04_var := ADR(alarms.ALM_COMM_SMART),  item_04_type := HMI_READ_ONLY,
    item_05_label   := 'TT5L', item_05_var := ADR(alarms.ALM_TT5_LOW),    item_05_type := HMI_READ_ONLY,
    item_06_label   := 'TT5H', item_06_var := ADR(alarms.ALM_TT5_HIGH),   item_06_type := HMI_READ_ONLY,
    item_07_label   := 'PFLW', item_07_var := ADR(alarms.ALM_PISC_FLUJO), item_07_type := HMI_READ_ONLY,
    item_08_label   := 'PTHH', item_08_var := ADR(alarms.ALM_PISC_T_HIGH),item_08_type := HMI_READ_ONLY,
    item_09_label   := 'INF.', item_09_var := ADR(alarms.ALM_INUNDACION),  item_09_type := HMI_READ_ONLY,
    item_10_label   := 'BDC.', item_10_var := ADR(alarms.ALM_BDC_FAULT),  item_10_type := HMI_READ_ONLY,
    item_11_label   := 'RST.', item_11_var := ADR(HMI_req_alm_reset),     item_11_type := HMI_ACTION
);

(* ---- PÁGINA TEST (requiere PIN) ------------------------- *)
pg_test(
    title           := 'TEST',
    locked          := NOT HMI_test_active,
    item_01_label   := 'P  1', item_01_var := ADR(test_mode.tst_P1_on),        item_01_type := HMI_EDITABLE,
        item_01_min := 0, item_01_max := 1, item_01_step := 1,
    item_02_label   := 'P1 %', item_02_var := ADR(test_mode.tst_P1_speed_pct), item_02_type := HMI_EDITABLE,
        item_02_min := 0.0, item_02_max := 100.0, item_02_step := 5.0,
    item_03_label   := 'P  2', item_03_var := ADR(test_mode.tst_P2_on),        item_03_type := HMI_EDITABLE,
        item_03_min := 0, item_03_max := 1, item_03_step := 1,
    item_04_label   := 'P  3', item_04_var := ADR(test_mode.tst_P3_on),        item_04_type := HMI_EDITABLE,
        item_04_min := 0, item_04_max := 1, item_04_step := 1,
    item_05_label   := 'P  4', item_05_var := ADR(test_mode.tst_P4_on),        item_05_type := HMI_EDITABLE,
        item_05_min := 0, item_05_max := 1, item_05_step := 1,
    item_06_label   := 'V3.1', item_06_var := ADR(test_mode.tst_V3V1_B),       item_06_type := HMI_EDITABLE,
        item_06_min := 0, item_06_max := 1, item_06_step := 1,
    item_07_label   := 'V3.2', item_07_var := ADR(test_mode.tst_V3V2_B),       item_07_type := HMI_EDITABLE,
        item_07_min := 0, item_07_max := 1, item_07_step := 1,
    item_08_label   := 'V3.3', item_08_var := ADR(test_mode.tst_V3V3_B),       item_08_type := HMI_EDITABLE,
        item_08_min := 0, item_08_max := 1, item_08_step := 1,
    item_09_label   := 'V3.S', item_09_var := ADR(test_mode.tst_V3VSOL_B),     item_09_type := HMI_EDITABLE,
        item_09_min := 0, item_09_max := 1, item_09_step := 1,
    item_10_label   := 'VP.1', item_10_var := ADR(test_mode.tst_VP_HX1_open),  item_10_type := HMI_EDITABLE,
        item_10_min := 0, item_10_max := 1, item_10_step := 1,
    item_11_label   := 'VP.B', item_11_var := ADR(test_mode.tst_VP_HX_BDC_open),item_11_type := HMI_EDITABLE,
        item_11_min := 0, item_11_max := 1, item_11_step := 1,
    item_12_label   := 'VP.H', item_12_var := ADR(test_mode.tst_VP_HX_HTR_open),item_12_type := HMI_EDITABLE,
        item_12_min := 0, item_12_max := 1, item_12_step := 1,
    item_13_label   := 'TA01', item_13_var := ADR(test_mode.tst_APT01_AFS),    item_13_type := HMI_EDITABLE,
        item_13_min := 0, item_13_max := 1, item_13_step := 1,
    item_14_label   := 'TA02', item_14_var := ADR(test_mode.tst_APT02_AFS),    item_14_type := HMI_EDITABLE,
        item_14_min := 0, item_14_max := 1, item_14_step := 1,
    item_15_label   := 'TA03', item_15_var := ADR(test_mode.tst_APT03_AFS),    item_15_type := HMI_EDITABLE,
        item_15_min := 0, item_15_max := 1, item_15_step := 1,
    item_16_label   := 'TA04', item_16_var := ADR(test_mode.tst_APT04_AFS),    item_16_type := HMI_EDITABLE,
        item_16_min := 0, item_16_max := 1, item_16_step := 1,
    item_17_label   := 'TA05', item_17_var := ADR(test_mode.tst_APT05_AFS),    item_17_type := HMI_EDITABLE,
        item_17_min := 0, item_17_max := 1, item_17_step := 1,
    item_18_label   := 'PRS.', item_18_var := ADR(test_mode.tst_PERS_close),   item_18_type := HMI_EDITABLE,
        item_18_min := 0, item_18_max := 1, item_18_step := 1,
    item_19_label   := 'EXT.', item_19_var := ADR(HMI_test_active),            item_19_type := HMI_ACTION
);

(* ---- PÁGINA CONFIGURACIÓN (requiere PIN) --------------- *)
pg_cfg(
    title           := 'CFG.',
    locked          := NOT HMI_cfg_active,
    item_01_label   := 'PRI.', item_01_var := ADR(P80_BDCPriority),   item_01_type := HMI_EDITABLE,
        item_01_min := 0, item_01_max := 1, item_01_step := 1,
    item_02_label   := 'BDA.', item_02_var := ADR(P90_ModbusSlaveAddr),  item_02_type := HMI_EDITABLE,
        item_02_min := 1, item_02_max := 247, item_02_step := 1,
    item_03_label   := 'BDB.', item_03_var := ADR(P91_ModbusBaudrate),    item_03_type := HMI_EDITABLE,
        item_03_min := 0, item_03_max := 2, item_03_step := 1,
    item_04_label   := 'PIN.', item_04_var := ADR(P94_PIN_L1),       item_04_type := HMI_EDITABLE,
        item_04_min := 0, item_04_max := 9999, item_04_step := 1,
    item_05_label   := 'PIC.', item_05_var := ADR(P95_PIN_CFG),        item_05_type := HMI_EDITABLE,
        item_05_min := 0, item_05_max := 9999, item_05_step := 1,
    item_06_label   := 'RST.', item_06_var := ADR(HMI_req_factory_rst),item_06_type := HMI_ACTION
);

(* ============================================================
   5. CONTROLADOR HMI PRINCIPAL
   Conecta todas las páginas y gestiona la navegación.
   ============================================================ *)
hmi(
    pages           := [pg_main, pg_sol, pg_acs, pg_clim,
                        pg_pisc, pg_apt, pg_past, pg_alr,
                        pg_test, pg_cfg],
    root_page       := ADR(pg_main),
    alarm_blink     := alm_blink_state,
    key_f1_page     := ADR(pg_alr),     (* F1 → acceso directo alarmas *)
    key_f2_page     := ADR(pg_main)     (* F2 → volver al inicio *)
);

HMI_current_page := hmi.current_page_idx;
panel_activity   := hmi.any_key_pressed;

(* ============================================================
   6. PROPAGACIÓN DE SETPOINTS HMI → LÓGICA DE CONTROL
   Los setpoints editados en el panel se reflejan automáticamente
   en las constantes usadas por los FBs de control porque
   apuntan a las mismas variables GVL_HMI_Params (por referencia).
   No es necesario copiar valores — DRY: una sola variable.
   ============================================================ *)

(* Actualizar Modbus hacia controlador solar con los setpoints editados *)
P10_SolarDeltaTTarget       := REAL_TO_UINT(P10_SolarDeltaTTarget * MB_TEMP_SCALE);
P19_SolarMode        := P19_SolarMode;
P16_MinTempForPoolSolarHeating := REAL_TO_UINT(P16_MinTempForPoolSolarHeating * MB_TEMP_SCALE);

END_PROGRAM
