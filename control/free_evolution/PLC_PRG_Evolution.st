(* ============================================================
   PLC_PRG_Evolution.st  –  Programa principal controlador principal
   Arquitectura: BC monobloc genérica (sin HTR) + solar térmico
   Task cíclica: 1000 ms
   Orden de ejecución:
     1. Aplicar offsets de sondas
     2. Polling Modbus controlador solar
     3. Higienización (máxima prioridad)
     4. Árbitro BDC
     5. ACS
     6. Climatización
     7. Piscina
     8. Apartamentos
     9. Modo test (sobreescribe salidas si activo)
    10. Escribir salidas físicas
    11. Alarmas
   ============================================================ *)
PROGRAM PLC_PRG

VAR
    (* ── Instancias de subsistemas ── *)
    mb_master       : FB_ModbusMaster;
    acs_ctrl        : FB_ACS;
    climate_ctrl    : FB_Climate;
    pool_ctrl       : FB_Pool;
    apt_ctrl        : FB_Apartments;
    bdc_arbiter     : FB_BDC_Arbiter;
    hyg_ctrl        : FB_Hygienization;
    alarms_ctrl     : FB_Alarms;
    test_ctrl       : FB_TestMode;

    (* ── Valores de sondas corregidos con offset ── *)
    TT4c  : REAL;  TT5c  : REAL;  TT6c  : REAL;  TT7c  : REAL;
    TT8c  : REAL;  TT9c  : REAL;  TT11c : REAL;
    TT12c : REAL;  TT13c : REAL;

    (* ── Auxiliares ── *)
    any_VP_open     : BOOL;
    alm_count_local : UINT;
    bdc_grant_pool  : BOOL;  (* BC a piscina solo si en modo calor *)
END_VAR

(* ============================================================
   1. APLICAR OFFSETS DE SONDAS
   ============================================================ *)
TT4c  := TT4  + OS03_TT4;
TT5c  := TT5  + OS04_TT5;
TT6c  := TT6  + OS05_TT6;
TT7c  := TT7  + OS06_TT7;
TT8c  := TT8  + OS07_TT8;
TT9c  := TT9  + OS08_TT9;
TT11c := TT11 + OS00_TT11;
TT12c := TT12 + OS00_TT12;
TT13c := TT13 + OS00_TT13;

(* ============================================================
   2. POLLING MODBUS  →  datos del controlador solar
   ============================================================ *)
mb_master(
    sp_dt_target    := P10_SolarDeltaTTarget,
    sp_tt3_pool     := P16_MinTempForPoolSolarHeating,
    sp_shutterclose := P17_SolarOverheatShutterClose,
    solar_mode      := P19_SolarMode,
    pool_demand     := pool_ctrl.demand_solar
);
SM := mb_master.solar;

(* ============================================================
   3. HIGIENIZACIÓN  (prioridad sobre todo)
   ============================================================ *)
hyg_ctrl(
    TT5            := TT5c,
    manual_request := hyg_request,
    enabled        := TRUE
);
hyg_phase   := hyg_ctrl.phase;
hyg_apt_idx := hyg_ctrl.apt_idx;

(* ============================================================
   4. ÁRBITRO BC
   ============================================================ *)
bdc_arbiter(
    demand_ACS     := acs_ctrl.demand_BDC OR hyg_ctrl.force_BDC_ACS,
    demand_climate := climate_ctrl.demand_BDC,
    demand_pool    := pool_ctrl.demand_BDC,
    enabled        := NOT DI_BDC_FAULT
);

(* La BC solo puede calentar la piscina en modo calor.
   En modo refrigeración su agua técnica está a 7-12°C. *)
bdc_grant_pool := bdc_arbiter.grant_pool AND bc_mode_heat;

(* ============================================================
   5. ACS
   ============================================================ *)
acs_ctrl(
    TT4           := TT4c,
    TT5           := TT5c,
    bdc_available := bdc_arbiter.grant_ACS,
    hyg_active    := hyg_ctrl.active,
    enabled       := TRUE
);

(* ============================================================
   6. CLIMATIZACIÓN
   ============================================================ *)
climate_ctrl(
    TT6           := TT6c,
    TT7           := TT7c,
    bdc_available := bdc_arbiter.grant_climate,
    mode_heat     := bc_mode_heat,
    enabled       := TRUE
);

(* ============================================================
   7. PISCINA
   ============================================================ *)
any_VP_open := DO_VP_HX_SOLAR OR DO_VP_HX_BC;
pool_ctrl(
    TT11           := TT11c,
    solar_available := SM.pos_V3V_SOL AND SM.P2_activo,
    bdc_available  := bdc_grant_pool,
    flow_ok        := DI_IF_PISC,
    enabled        := TRUE
);

(* ============================================================
   8. APARTAMENTOS
   ============================================================ *)
apt_ctrl(
    hyg_active       := hyg_ctrl.active,
    maintenance_mode := FALSE,
    enabled          := TRUE
);

(* ============================================================
   9. MODO TEST  (sobreescribe salidas si activo)
   ============================================================ *)
test_ctrl(test_active := HMI_test_active);

(* ============================================================
   10. ESCRIBIR SALIDAS DIGITALES
   ============================================================ *)
IF test_ctrl.override_active THEN
    DO_V3V1        := test_ctrl.out_DO_V3V1;
    DO_V3V2        := test_ctrl.out_DO_V3V2;
    DO_VP_HX_SOLAR := test_ctrl.out_DO_VP_HX1;
    DO_VP_HX_BC    := test_ctrl.out_DO_VP_HX_BDC;
    DO_V3V_APT_01  := test_ctrl.out_DO_APT01;
    DO_V3V_APT_02  := test_ctrl.out_DO_APT02;
    DO_V3V_APT_03  := test_ctrl.out_DO_APT03;
    DO_V3V_APT_04  := test_ctrl.out_DO_APT04;
    DO_P3          := test_ctrl.out_DO_P3;
ELSE
    (* Salidas normales *)
    (* V3V1: FALSE=reservorio (D2), TRUE=→V3V2 *)
    DO_V3V1        := NOT acs_ctrl.cmd_V3V1_reservorio AND NOT hyg_ctrl.force_BDC_ACS;
    (* V3V2: FALSE=fancoils (D3), TRUE=piscina (HX_BC) *)
    DO_V3V2        := pool_ctrl.cmd_VP_HX_BC AND NOT climate_ctrl.cmd_V3V2_D3;
    DO_VP_HX_SOLAR := pool_ctrl.cmd_VP_HX_SOLAR;
    DO_VP_HX_BC    := pool_ctrl.cmd_VP_HX_BC;
    DO_V3V_APT_01  := apt_ctrl.cmd_APT_01;
    DO_V3V_APT_02  := apt_ctrl.cmd_APT_02;
    DO_V3V_APT_03  := apt_ctrl.cmd_APT_03;
    DO_V3V_APT_04  := apt_ctrl.cmd_APT_04;
    DO_P3          := climate_ctrl.cmd_P3;
END_IF

(* ============================================================
   11. ALARMAS
   ============================================================ *)
alarms_ctrl(
    TT1           := SM.TT1,
    TT2           := SM.TT2,
    TT5           := TT5c,
    TT11          := TT11c,
    comm_solar_ok := SM.comm_ok,
    flow_pisc_ok  := DI_IF_PISC,
    vp_any_open   := any_VP_open,
    inundacion    := DI_INUND_FC,
    bdc_fault     := DI_BDC_FAULT,
    reset_cmd     := HMI_req_alm_reset,
    enabled       := TRUE
);
alarms          := alarms_ctrl.alarms;
alm_count_local := alarms_ctrl.alarm_count;

IF HMI_req_alm_reset THEN
    HMI_req_alm_reset := FALSE;
END_IF

END_PROGRAM
