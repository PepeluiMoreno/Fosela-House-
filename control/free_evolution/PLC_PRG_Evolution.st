(* ============================================================
   PLC_PRG_Evolution.st  –  Programa principal controlador principal
   Task cíclica: 1000 ms
   Orden de ejecución:
     1. Leer entradas analógicas (mapeadas en device config)
     2. Aplicar offsets de sondas
     3. Polling Modbus controlador solar
     4. Árbitros de prioridad
     5. Lógicas de subsistemas
     6. Higienización
     7. Test mode (sobreescribe salidas si activo)
     8. Alarmas
     9. Escribir salidas físicas
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
    htr_arbiter     : FB_HTR_Arbiter;
    hyg_ctrl        : FB_Hygienization;
    alarms_ctrl     : FB_Alarms;
    test_ctrl       : FB_TestMode;

    (* ── Valores de sondas corregidos con offset ── *)
    TT4c  : REAL;  TT5c  : REAL;  TT6c  : REAL;  TT7c  : REAL;
    TT8c  : REAL;  TT9c  : REAL;  TT10c : REAL;  TT11c : REAL;
    TT12c : REAL;  TT13c : REAL;  TT14c : REAL;

    (* ── Modo climatización ── *)
    mode_heat       : BOOL := TRUE;

    (* ── Auxiliares ── *)
    any_VP_open     : BOOL;
    alm_count_local : UINT;
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
TT10c := TT10 + OS00_TT10;
TT11c := TT11 + OS00_TT11;
TT12c := TT12 + OS00_TT12;
TT13c := TT13 + OS00_TT13;
TT14c := TT14 + OS00_TT14;

(* ============================================================
   2. POLLING MODBUS  →  datos del controlador solar
   ============================================================ *)
mb_master(
    sp_dt_target  := P10_SolarDeltaTTarget,
    sp_tt3_pool   := P16_MinTempForPoolSolarHeating,
    sp_shutterclose := P17_SolarOverheatShutterClose,
    solar_mode    := P19_SolarMode,
    pool_demand   := pool_ctrl.demand_solar
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
hyg_phase := hyg_ctrl.phase;
hyg_apt_idx := hyg_ctrl.apt_idx;

(* ============================================================
   4. ÁRBITRO BDC
   ============================================================ *)
bdc_arbiter(
    demand_ACS     := acs_ctrl.demand_BDC OR hyg_ctrl.force_BDC_ACS,
    demand_climate := climate_ctrl.demand_BDC,
    demand_pool    := pool_ctrl.demand_BDC,
    enabled        := NOT DI_BDC_FAULT
);

(* ============================================================
   5. ACS
   ============================================================ *)
acs_ctrl(
    TT4           := TT4c,
    TT5           := TT5c,
    TT10          := TT10c,
    bdc_available := bdc_arbiter.grant_ACS,
    hyg_active    := hyg_ctrl.active,
    enabled       := TRUE
);

(* ============================================================
   6. HTR ÁRBITRO
   ============================================================ *)
htr_arbiter(
    acs_satisfied := acs_ctrl.acs_satisfied,
    demand_pool   := pool_ctrl.demand_HTR,
    enabled       := TRUE
);

(* ============================================================
   7. CLIMATIZACIÓN
   ============================================================ *)
climate_ctrl(
    TT6           := TT6c,
    TT7           := TT7c,
    bdc_available := bdc_arbiter.grant_climate,
    mode_heat     := mode_heat,
    enabled       := TRUE
);

(* ============================================================
   8. PISCINA
   ============================================================ *)
any_VP_open := DO_VP_HX1 OR DO_VP_HX_BDC OR DO_VP_HX_HTR;
pool_ctrl(
    TT11           := TT11c,
    TT14           := TT14c,
    solar_available:= SM.pos_V3V_SOL AND SM.P2_activo,
    bdc_available  := bdc_arbiter.grant_pool,
    htr_available  := htr_arbiter.htr_to_pool,
    flow_ok        := DI_IF_PISC,
    enabled        := TRUE
);

(* ============================================================
   9. APARTAMENTOS
   ============================================================ *)
apt_ctrl(
    hyg_active       := hyg_ctrl.active,
    maintenance_mode := FALSE,
    enabled          := TRUE
);

(* ============================================================
   10. MODO TEST  (sobreescribe salidas si activo)
   ============================================================ *)
test_ctrl(test_active := HMI_test_active);

(* ============================================================
   11. ESCRIBIR SALIDAS DIGITALES
   ============================================================ *)
IF test_ctrl.override_active THEN
    DO_V3V1       := test_ctrl.out_DO_V3V1;
    DO_V3V2       := test_ctrl.out_DO_V3V2;
    DO_V3V3       := test_ctrl.out_DO_V3V3;
    DO_VP_HX1     := test_ctrl.out_DO_VP_HX1;
    DO_VP_HX_BDC  := test_ctrl.out_DO_VP_HX_BDC;
    DO_VP_HX_HTR  := test_ctrl.out_DO_VP_HX_HTR;
    DO_V3V_APT_01 := test_ctrl.out_DO_APT01;
    DO_V3V_APT_02 := test_ctrl.out_DO_APT02;
    DO_V3V_APT_03 := test_ctrl.out_DO_APT03;
    DO_V3V_APT_04 := test_ctrl.out_DO_APT04;
    DO_V3V_APT_05 := test_ctrl.out_DO_APT05;
    DO_P3         := test_ctrl.out_DO_P3;
    DO_P4         := test_ctrl.out_DO_P4;
ELSE
    (* Salidas normales *)
    DO_V3V1       := acs_ctrl.cmd_V3V1_D2 OR hyg_ctrl.force_BDC_ACS;
    DO_V3V2       := climate_ctrl.cmd_V3V2_D3 OR pool_ctrl.cmd_VP_HX_BDC;
    DO_V3V3       := NOT acs_ctrl.cmd_V3V3_D2;  (* FALSE=D2, TRUE=piscina *)
    DO_VP_HX1     := pool_ctrl.cmd_VP_HX1;
    DO_VP_HX_BDC  := pool_ctrl.cmd_VP_HX_BDC;
    DO_VP_HX_HTR  := pool_ctrl.cmd_VP_HX_HTR;
    DO_V3V_APT_01 := apt_ctrl.cmd_APT_01;
    DO_V3V_APT_02 := apt_ctrl.cmd_APT_02;
    DO_V3V_APT_03 := apt_ctrl.cmd_APT_03;
    DO_V3V_APT_04 := apt_ctrl.cmd_APT_04;
    DO_V3V_APT_05 := apt_ctrl.cmd_APT_05;
    DO_P3         := climate_ctrl.cmd_P3;
    DO_P4         := TRUE; (* P4 siempre en marcha con BDC activa *)
END_IF

(* ============================================================
   12. ALARMAS
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
alarms        := alarms_ctrl.alarms;
alm_count_local := alarms_ctrl.alarm_count;

(* Reset solicitud alarmas tras ejecutar *)
IF HMI_req_alm_reset THEN
    HMI_req_alm_reset := FALSE;
END_IF

END_PROGRAM
