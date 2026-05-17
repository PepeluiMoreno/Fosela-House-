(* ============================================================
   PLC_PRG_Smart.st
   Programa principal del controlador solar (controlador esclavo Modbus).
   Task cíclica: 1000 ms (térmica, no requiere ciclos cortos).

   MAPEO HARDWARE (configurar en Device → I/O en FREE Studio):
     AI1 → TT1  (NTC o Pt1000, rango -20..+150 °C)
     AI2 → TT2
     AI3 → TT3
     AO1 0-10V → DO_AO_P1 (mapear a GVL AO_P1_speed)
     Relay 1    → DO_V3V_SOL
     Relay 2    → DO_PERS_SOL
     Relay 3    → DO_P2
     Relay 4    → DO_ALM_SOLAR
   ============================================================ *)

PROGRAM PLC_PRG

VAR
    (* Instancias de function blocks *)
    solar_pump      : FB_SolarPump;
    solar_valves    : FB_SolarValves;
    alm_TT1_high    : FB_Alarm;
    alm_TT2_high    : FB_Alarm;

    (* Conversión velocidad PWM *)
    speed_volt      : REAL;     (* 0-10V para la salida analógica *)

    (* Pool demand externa recibida por Modbus *)
    pool_demand_ext : BOOL := FALSE;
END_VAR

(* ============================================================
   1. ACTUALIZAR SETPOINTS DESDE MODBUS
      (MB_Slave_Map escribe en GVL_Smart: P10_SolarDeltaTTarget,
       P16_MinTempForPoolSolarHeating, P19_SolarMode, P17_SolarOverheatShutterClose)
   ============================================================ *)
MB_Slave_Map();

(* ============================================================
   2. CONTROL DE BOMBA SOLAR P1
   ============================================================ *)
solar_pump(
    TT1     := TT1,
    TT2     := TT2,
    SP_DT   := P10_SolarDeltaTTarget,
    mode    := P19_SolarMode,
    fault   := ALM_TT1_HIGH
);

(* Mapear velocidad % → 0-10V para AO → convertidor 0-10V→PWM → bomba solar modulante *)
speed_volt      := solar_pump.speed_pct / 10.0;   (* 0-100% → 0.0-10.0 V *)
AO_P1_speed     := speed_volt;

(* Publicar velocidad en ‰ para Modbus *)
vel_P1_permil   := REAL_TO_UINT(solar_pump.speed_pct * 10.0);
DT_solar        := solar_pump.DT_measured;

(* ============================================================
   3. CONTROL DE VÁLVULAS Y PERSIANAS
   ============================================================ *)
solar_valves(
    TT2             := TT2,
    TT3             := TT3,
    SP_TT3_pool     := P16_MinTempForPoolSolarHeating,
    pool_demand     := pool_demand_ext,
    mode            := P19_SolarMode,
    force_shutters  := P17_SolarOverheatShutterClose,
    pump_running    := solar_pump.pump_run,
    fault           := ALM_TT1_HIGH
);

DO_V3V_SOL  := solar_valves.cmd_V3V_SOL_pool;
DO_PERS_SOL := solar_valves.cmd_shutters_close;
DO_P2       := solar_valves.cmd_P2_run;

(* ============================================================
   4. ALARMAS
   ============================================================ *)

(* Alarma TT1 alta — sobretemperatura colector *)
alm_TT1_high(
    condition   := (TT1 > P04_CollectorMaxOperTemp),
    reset_cmd   := FALSE,      (* Rearme automático cuando T baja *)
    filter_time := K_ALM_FILTER,
    latch       := FALSE,
    enabled     := TRUE
);
ALM_TT1_HIGH := alm_TT1_high.active;

(* Alarma TT2 alta — sobretemperatura D1 *)
alm_TT2_high(
    condition   := (TT2 > (P00_AccumulatorMaxTemp - 7.0)),
    reset_cmd   := FALSE,
    filter_time := K_ALM_FILTER,
    latch       := FALSE,
    enabled     := TRUE
);
ALM_TT2_HIGH := alm_TT2_high.active;

(* Código de alarma compuesto *)
solar_alarm_code := UINT#0;
IF ALM_TT1_HIGH AND NOT ALM_TT2_HIGH THEN
    solar_alarm_code := UINT#1;
ELSIF NOT ALM_TT1_HIGH AND ALM_TT2_HIGH THEN
    solar_alarm_code := UINT#2;
ELSIF ALM_TT1_HIGH AND ALM_TT2_HIGH THEN
    solar_alarm_code := UINT#3;
END_IF

(* Relé de alarma local *)
DO_ALM_SOLAR := ALM_TT1_HIGH OR ALM_TT2_HIGH;

(* ============================================================
   5. PUBLICAR REGISTROS MODBUS (ya llamado al inicio, se repite
      para asegurar que las salidas calculadas quedan en los
      registros antes del siguiente polling del maestro)
   ============================================================ *)
MB_Slave_Map();

END_PROGRAM
