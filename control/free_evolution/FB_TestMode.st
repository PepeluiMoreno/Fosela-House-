(* ============================================================
   FB_TestMode.st
   Forzado manual de salidas para puesta en marcha y diagnóstico.
   SOLO activo si HMI_test_active = TRUE (acceso con PIN).
   Cuando test_active = FALSE todas las salidas de test se ponen
   a FALSE y el control normal retoma el mando.

   USO:
     Llamar en PLC_PRG_Evolution ANTES de las lógicas normales.
     Si test_active=TRUE las salidas del sistema se sobreescriben
     con los valores de test al FINAL del ciclo (mayor prioridad).
   ============================================================ *)

FUNCTION_BLOCK FB_TestMode

VAR_INPUT
    test_active         : BOOL;         (* TRUE = modo test habilitado *)
END_VAR

(* Comandos de test (editables desde HMI) *)
VAR_INPUT
    tst_P1_on           : BOOL;
    tst_P2_on           : BOOL;
    tst_P3_on           : BOOL;
    tst_P4_on           : BOOL;
    tst_V3V1_B          : BOOL;         (* TRUE = posición B *)
    tst_V3V2_B          : BOOL;
    tst_V3V3_B          : BOOL;
    tst_V3VSOL_B        : BOOL;
    tst_VP_HX1_open     : BOOL;
    tst_VP_HX_BDC_open  : BOOL;
    tst_VP_HX_HTR_open  : BOOL;
    tst_EV_BYPASS_open  : BOOL;
    tst_APT01_AFS       : BOOL;
    tst_APT02_AFS       : BOOL;
    tst_APT03_AFS       : BOOL;
    tst_APT04_AFS       : BOOL;
    tst_APT05_AFS       : BOOL;
    tst_PERS_close      : BOOL;
    tst_P1_speed_pct    : REAL := 50.0; (* Velocidad P1 test [0-100%] *)
END_VAR

VAR_OUTPUT
    (* Estas salidas sobreescriben las del sistema si test_active=TRUE *)
    out_DO_V3V1         : BOOL;
    out_DO_V3V2         : BOOL;
    out_DO_V3V3         : BOOL;
    out_DO_V3VSOL       : BOOL;
    out_DO_VP_HX1       : BOOL;
    out_DO_VP_HX_BDC    : BOOL;
    out_DO_VP_HX_HTR    : BOOL;
    out_DO_APT01        : BOOL;
    out_DO_APT02        : BOOL;
    out_DO_APT03        : BOOL;
    out_DO_APT04        : BOOL;
    out_DO_APT05        : BOOL;
    out_DO_P2           : BOOL;
    out_DO_P3           : BOOL;
    out_DO_P4           : BOOL;
    out_DO_PERS         : BOOL;
    out_P1_speed        : REAL;
    override_active     : BOOL;         (* TRUE si está sobreescribiendo *)
END_VAR

(* --- Implementación --- *)

override_active := test_active;

IF test_active THEN
    out_DO_V3V1         := tst_V3V1_B;
    out_DO_V3V2         := tst_V3V2_B;
    out_DO_V3V3         := tst_V3V3_B;
    out_DO_V3VSOL       := tst_V3VSOL_B;
    out_DO_VP_HX1       := tst_VP_HX1_open;
    out_DO_VP_HX_BDC    := tst_VP_HX_BDC_open;
    out_DO_VP_HX_HTR    := tst_VP_HX_HTR_open;
    out_DO_APT01        := tst_APT01_AFS;
    out_DO_APT02        := tst_APT02_AFS;
    out_DO_APT03        := tst_APT03_AFS;
    out_DO_APT04        := tst_APT04_AFS;
    out_DO_APT05        := tst_APT05_AFS;
    out_DO_P2           := tst_P2_on;
    out_DO_P3           := tst_P3_on;
    out_DO_P4           := tst_P4_on;
    out_DO_PERS         := tst_PERS_close;
    out_P1_speed        := LIMIT(0.0, tst_P1_speed_pct, 100.0);
ELSE
    (* Modo normal: no sobreescribir nada *)
    out_DO_V3V1         := FALSE;
    out_DO_V3V2         := FALSE;
    out_DO_V3V3         := FALSE;
    out_DO_V3VSOL       := FALSE;
    out_DO_VP_HX1       := FALSE;
    out_DO_VP_HX_BDC    := FALSE;
    out_DO_VP_HX_HTR    := FALSE;
    out_DO_APT01        := FALSE;
    out_DO_APT02        := FALSE;
    out_DO_APT03        := FALSE;
    out_DO_APT04        := FALSE;
    out_DO_APT05        := FALSE;
    out_DO_P2           := FALSE;
    out_DO_P3           := FALSE;
    out_DO_P4           := FALSE;
    out_DO_PERS         := FALSE;
    out_P1_speed        := 0.0;
END_IF

END_FUNCTION_BLOCK
