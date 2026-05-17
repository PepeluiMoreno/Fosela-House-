(* ============================================================
   FB_Alarms.st  –  Gestión centralizada de alarmas del sistema
   ============================================================ *)
FUNCTION_BLOCK FB_Alarms
VAR_INPUT
    TT1             : REAL;
    TT2             : REAL;
    TT5             : REAL;
    TT11            : REAL;
    comm_solar_ok   : BOOL;
    flow_pisc_ok    : BOOL;
    vp_any_open     : BOOL;
    inundacion      : BOOL;
    bdc_fault       : BOOL;
    reset_cmd       : BOOL;
    enabled         : BOOL := TRUE;
END_VAR
VAR_OUTPUT
    alarms          : ST_SystemAlarms;
    alarm_count     : UINT;
END_VAR
VAR
    alm_TT1         : FB_Alarm;
    alm_TT2         : FB_Alarm;
    alm_comm        : FB_Alarm;
    alm_TT5_low     : FB_Alarm;
    alm_TT5_high    : FB_Alarm;
    alm_pisc_flow   : FB_Alarm;
    alm_pisc_temp   : FB_Alarm;
    alm_inund       : FB_Alarm;
    alm_bdc         : FB_Alarm;
END_VAR

alm_TT1(condition := TT1 > P04_CollectorMaxOperTemp,
         reset_cmd := reset_cmd, filter_time := K_ALM_FILTER, latch := FALSE, enabled := enabled);
alm_TT2(condition := TT2 > (P00_AccumulatorMaxTemp - 7.0),
         reset_cmd := reset_cmd, filter_time := K_ALM_FILTER, latch := FALSE, enabled := enabled);
alm_comm(condition := NOT comm_solar_ok,
         reset_cmd := reset_cmd, filter_time := P93_ModbusTimeout, latch := TRUE, enabled := enabled);
alm_TT5_low(condition := TT5 < 40.0,
         reset_cmd := reset_cmd, filter_time := T#120M, latch := TRUE, enabled := enabled);
alm_TT5_high(condition := TT5 > (P00_AccumulatorMaxTemp - 5.0),
         reset_cmd := reset_cmd, filter_time := K_ALM_FILTER, latch := FALSE, enabled := enabled);
alm_pisc_flow(condition := NOT flow_pisc_ok AND vp_any_open,
         reset_cmd := reset_cmd, filter_time := T#30S, latch := TRUE, enabled := enabled);
alm_pisc_temp(condition := TT11 > P62_PoolMaxTemp,
         reset_cmd := reset_cmd, filter_time := K_ALM_FILTER, latch := FALSE, enabled := enabled);
alm_inund(condition := inundacion,
         reset_cmd := reset_cmd, filter_time := T#5S, latch := TRUE, enabled := enabled);
alm_bdc(condition := bdc_fault,
         reset_cmd := reset_cmd, filter_time := T#5S, latch := TRUE, enabled := enabled);

alarms.ALM_TT1_HIGH      := alm_TT1.active;
alarms.ALM_TT2_HIGH      := alm_TT2.active;
alarms.ALM_COMM_SOLAR    := alm_comm.active;
alarms.ALM_TT5_LOW       := alm_TT5_low.active;
alarms.ALM_TT5_HIGH      := alm_TT5_high.active;
alarms.ALM_PISC_FLUJO    := alm_pisc_flow.active;
alarms.ALM_PISC_T_HIGH   := alm_pisc_temp.active;
alarms.ALM_INUNDACION    := alm_inund.active;
alarms.ALM_BDC_FAULT     := alm_bdc.active;
alarms.CUALQUIER_ALARMA  :=
    alm_TT1.active OR alm_TT2.active OR alm_comm.active OR
    alm_TT5_low.active OR alm_TT5_high.active OR alm_pisc_flow.active OR
    alm_pisc_temp.active OR alm_inund.active OR alm_bdc.active;

alarm_count := 0;
IF alarms.ALM_TT1_HIGH    THEN alarm_count := alarm_count + 1; END_IF
IF alarms.ALM_TT2_HIGH    THEN alarm_count := alarm_count + 1; END_IF
IF alarms.ALM_COMM_SOLAR  THEN alarm_count := alarm_count + 1; END_IF
IF alarms.ALM_TT5_LOW     THEN alarm_count := alarm_count + 1; END_IF
IF alarms.ALM_TT5_HIGH    THEN alarm_count := alarm_count + 1; END_IF
IF alarms.ALM_PISC_FLUJO  THEN alarm_count := alarm_count + 1; END_IF
IF alarms.ALM_PISC_T_HIGH THEN alarm_count := alarm_count + 1; END_IF
IF alarms.ALM_INUNDACION  THEN alarm_count := alarm_count + 1; END_IF
IF alarms.ALM_BDC_FAULT   THEN alarm_count := alarm_count + 1; END_IF

END_FUNCTION_BLOCK
