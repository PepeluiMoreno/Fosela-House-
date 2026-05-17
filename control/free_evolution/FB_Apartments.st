(* ============================================================
   FB_Apartments.st  –  Gestión V3V_APT por apartamento
   
   Modo por defecto: precalentada (agua de D2 vía VMT1).
   Conmuta a AFS solo en mantenimiento del sistema central
   o por configuración manual del gestor.

   NOTA: La renovación del agua en los ramales interiores de
   cada apartamento (desde V3V_APT hasta los grifos) no puede
   garantizarse por software — requiere apertura manual de grifos
   en el protocolo de limpieza previo a cada entrada de huéspedes.
   Ver procedimiento operativo en la memoria técnica.
   ============================================================ *)
FUNCTION_BLOCK FB_Apartments

VAR_INPUT
    hyg_active       : BOOL;  (* Higienización activa → forzar precalentada *)
    maintenance_mode : BOOL;  (* Mantenimiento central → AFS *)
    enabled          : BOOL := TRUE;
END_VAR

VAR_OUTPUT
    (* FALSE = precalentada (energizada) · TRUE = AFS (desenergizada) *)
    cmd_APT_01 : BOOL;
    cmd_APT_02 : BOOL;
    cmd_APT_03 : BOOL;
    cmd_APT_04 : BOOL;
    cmd_APT_05 : BOOL;
END_VAR

(* Durante higienización: precalentada en todos — obligatorio
   para que el agua caliente circule por todos los ramales *)
IF hyg_active THEN
    cmd_APT_01 := FALSE;
    cmd_APT_02 := FALSE;
    cmd_APT_03 := FALSE;
    cmd_APT_04 := FALSE;
    cmd_APT_05 := FALSE;

ELSIF maintenance_mode THEN
    (* Mantenimiento central: AFS en todos *)
    cmd_APT_01 := TRUE;
    cmd_APT_02 := TRUE;
    cmd_APT_03 := TRUE;
    cmd_APT_04 := TRUE;
    cmd_APT_05 := TRUE;

ELSE
    (* Modo individual: gestor configura P40-P44 desde HMI
       0 = precalentada (normal)
       1 = AFS (mantenimiento del apartamento) *)
    cmd_APT_01 := (P40_AptMode_01 = UINT#1);
    cmd_APT_02 := (P41_AptMode_02 = UINT#1);
    cmd_APT_03 := (P42_AptMode_03 = UINT#1);
    cmd_APT_04 := (P43_AptMode_04 = UINT#1);
    cmd_APT_05 := (P44_AptMode_05 = UINT#1);
END_IF

END_FUNCTION_BLOCK
