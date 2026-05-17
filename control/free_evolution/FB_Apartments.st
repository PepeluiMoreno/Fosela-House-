(* ============================================================
   FB_Apartments.st  –  Gestión V3V_APT por apartamento
   Modo por defecto: precalentada.
   Conmuta a AFS en mantenimiento, vacancia o higienización.
   ============================================================ *)
FUNCTION_BLOCK FB_Apartments
VAR_INPUT
    hyg_active          : BOOL;  (* Higienización activa → forzar precalentada *)
    maintenance_mode    : BOOL;  (* Mantenimiento central → AFS *)
    enabled             : BOOL := TRUE;
END_VAR
VAR_OUTPUT
    (* FALSE = precalentada (energiza), TRUE = AFS (desenergiza) *)
    cmd_APT_01 : BOOL;
    cmd_APT_02 : BOOL;
    cmd_APT_03 : BOOL;
    cmd_APT_04 : BOOL;
    cmd_APT_05 : BOOL;
END_VAR

(* Durante higienización: forzar precalentada en todos *)
IF hyg_active THEN
    cmd_APT_01 := FALSE;
    cmd_APT_02 := FALSE;
    cmd_APT_03 := FALSE;
    cmd_APT_04 := FALSE;
    cmd_APT_05 := FALSE;
ELSIF maintenance_mode THEN
    (* Mantenimiento central: todos a AFS *)
    cmd_APT_01 := TRUE;
    cmd_APT_02 := TRUE;
    cmd_APT_03 := TRUE;
    cmd_APT_04 := TRUE;
    cmd_APT_05 := TRUE;
ELSE
    (* Modo individual según P40_AptMode_XX..P44_AptMode_05 *)
    cmd_APT_01 := (P40_AptMode_01 = UINT#1);
    cmd_APT_02 := (P41_AptMode_02 = UINT#1);
    cmd_APT_03 := (P42_AptMode_03 = UINT#1);
    cmd_APT_04 := (P43_AptMode_04 = UINT#1);
    cmd_APT_05 := (P44_AptMode_05 = UINT#1);
END_IF

END_FUNCTION_BLOCK
