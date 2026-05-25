(* ============================================================
   GVL_Params.st  –  Todos los parámetros Pnn del sistema
   RETAIN: sobreviven a corte de alimentación.
   Editables desde HMI según nivel de acceso (CFG / L1).
   Los rangos [Mín–Máx] se validan en runtime respecto a P00-P06.
   ============================================================ *)

VAR_GLOBAL RETAIN

    (* ── P00-P06  Límites de equipo (CFG) ───────────────────
       Introducir en puesta en marcha con datos de placa.
       No tienen defecto numérico: el instalador los introduce. *)
    P00_AccumulatorMaxTemp    : REAL := 0.0;  (* P00 *)
    P01_BDCMaxFlowTemp        : REAL := 0.0;  (* P01 *)
    P02_HTRMaxTemp            : REAL := 0.0;  (* P02 *)
    P03_BDCMinCoolTemp        : REAL := 0.0;  (* P03 *)
    P04_CollectorMaxOperTemp  : REAL := 0.0;  (* P04 *)
    P05_HXMaxTemp             : REAL := 0.0;  (* P05 *)
    P06_PumpMaxFluidTemp      : REAL := 0.0;  (* P06 *)

    (* ── P10-P19  Solar (L1) ─────────────────────────────── *)
    P10_SolarDeltaTTarget          : REAL := 8.0;   (* P10  K *)
    P11_SolarDeltaTStart           : REAL := 6.0;   (* P11  K *)
    P12_SolarDeltaTStop            : REAL := 3.0;   (* P12  K *)
    P13_SolarPumpMinSpeed          : REAL := 10.0;  (* P13  % *)
    P14_SolarPumpMinOnTime         : TIME := T#30S; (* P14 *)
    P15_SolarPumpMinOffTime        : TIME := T#20S; (* P15 *)
    P16_MinTempForPoolSolarHeating : REAL := 75.0;  (* P16  °C *)
    P17_SolarOverheatShutterClose  : REAL := 85.0;  (* P17  °C *)
    P18_SolarOverheatShutterHyst   : REAL := 4.0;   (* P18  K *)
    P19_SolarMode                  : UINT := 0;     (* P19  0=AUTO *)

    (* ── P20-P21  Regulador PI solar (CFG) ──────────────── *)
    P20_SolarPI_Kp : REAL := 0.50;  (* P20 *)
    P21_SolarPI_Ki : REAL := 0.08;  (* P21  1/s *)

    (* ── P30-P35  ACS (L1) ──────────────────────────────── *)
    P30_ACSStorageSetPoint  : REAL := 65.0;  (* P30  °C *)
    P31_ACSStorageHysteresis: REAL := 4.0;   (* P31  K *)
    P32_ACSBDCStartTemp     : REAL := 50.0;  (* P32  °C *)
    P33_ACSBDCStartHyst     : REAL := 3.0;   (* P33  K *)
    P34_HTRStopTemp         : REAL := 68.0;  (* P34  °C *)
    P35_HTRStopHyst         : REAL := 3.0;   (* P35  K *)

    (* ── P40-P46  ACS apartamentos (L1) ─────────────────── *)
    P40_AptMode_01       : UINT := 0;     (* P40  0=PREC 1=AFS *)
    P41_AptMode_02       : UINT := 0;     (* P41 *)
    P42_AptMode_03       : UINT := 0;     (* P42 *)
    P43_AptMode_04       : UINT := 0;     (* P43 *)
    P44_AptMode_05       : UINT := 0;     (* P44 *)

    (* ── P50-P53  Climatización (L1) ────────────────────── *)
    P50_HeatingSetPoint  : REAL := 45.0;  (* P50  °C *)
    P51_HeatingHysteresis: REAL := 4.0;   (* P51  K *)
    P52_CoolingSetPoint  : REAL := 9.0;   (* P52  °C *)
    P53_CoolingHysteresis: REAL := 2.0;   (* P53  K *)

    (* ── P60-P64  Piscina (L1) ──────────────────────────── *)
    P60_PoolSetPoint         : REAL := 27.0;   (* P60  °C *)
    P61_PoolHysteresis       : REAL := 1.0;    (* P61  K *)
    P62_PoolMaxTemp          : REAL := 32.0;   (* P62  °C *)
    P63_PoolDelay            : TIME := T#30S;  (* P63 *)
    P64_PoolValveTravelTime  : TIME := T#15S;  (* P64 *)

    (* ── P70-P77  Higienización (L1/CFG) ────────────────── *)
    P70_PreheatingTarget      : REAL := 70.0;    (* P70  °C  L1 *)
    P71_PreheatingHysteresis  : REAL := 2.0;     (* P71  K   L1 *)
    P72_PreheatingHoldTime    : TIME := T#60M;   (* P72       L1 *)
    P73_PreheatingFlushTime   : TIME := T#30M;   (* P73       L1 *)
    P74_PreheatingDayOfWeek   : UINT := 1;       (* P74  1=Lun L1 *)
    P75_PreheatingHour        : UINT := 3;       (* P75  hora L1 *)
    P76_D1PreheatingMaxDays   : UINT := 7;       (* P76  días CFG *)
    P77_D1PreheatingMinTemp   : REAL := 60.0;    (* P77  °C  CFG *)

    (* ── P80  Prioridades (CFG) ──────────────────────────── *)
    P80_BDCPriority : UINT := 0;  (* P80  0=ACS>CLIM>PISC *)

    (* ── P90-P97  Sistema / Modbus / HMI (CFG) ──────────── *)
    P90_ModbusSlaveAddr  : UINT := 1;     (* P90 *)
    P91_ModbusBaudrate   : UINT := 1;     (* P91  1=19200 *)
    P92_ModbusPollPeriod : TIME := T#5S;  (* P92 *)
    P93_ModbusTimeout    : TIME := T#15S; (* P93 *)
    P94_PIN_L1           : UINT := 1234;  (* P94 *)
    P95_PIN_CFG          : UINT := 9999;  (* P95 *)
    P96_PIN_MaxAttempts  : UINT := 3;     (* P96 *)
    P97_SessionTimeout   : TIME := T#10M; (* P97 *)

    (* ── OS00-OS13  Offsets de sondas (CFG) ─────────────── *)
    OS00_TT1  : REAL := 0.0;  (* OS00  K *)
    OS01_TT2  : REAL := 0.0;  (* OS01 *)
    OS02_TT3  : REAL := 0.0;  (* OS02 *)
    OS03_TT4  : REAL := 0.0;  (* OS03 *)
    OS04_TT5  : REAL := 0.0;  (* OS04 *)
    OS05_TT6  : REAL := 0.0;  (* OS05 *)
    OS06_TT7  : REAL := 0.0;  (* OS06 *)
    OS07_TT8  : REAL := 0.0;  (* OS07 *)
    OS08_TT9  : REAL := 0.0;  (* OS08 *)
    OS00_TT10 : REAL := 0.0;  (* OS09 *)
    OS00_TT11 : REAL := 0.0;  (* OS10 *)
    OS00_TT12 : REAL := 0.0;  (* OS11 *)
    OS00_TT13 : REAL := 0.0;  (* OS12 *)
    OS00_TT14 : REAL := 0.0;  (* OS13 *)

END_VAR
