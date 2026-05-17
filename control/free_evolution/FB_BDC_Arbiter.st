(* ============================================================
   FB_BDC_Arbiter.st  –  Árbitro de prioridades del primario BDC
   Asigna el primario BDC a un único subsistema según P80_BDCPriority.
   Prioridad 0: ACS > Climatización > Piscina
   Prioridad 1: ACS > Piscina > Climatización
   ============================================================ *)
FUNCTION_BLOCK FB_BDC_Arbiter
VAR_INPUT
    demand_ACS      : BOOL;
    demand_climate  : BOOL;
    demand_pool     : BOOL;
    enabled         : BOOL := TRUE;
END_VAR
VAR_OUTPUT
    grant_ACS       : BOOL;
    grant_climate   : BOOL;
    grant_pool      : BOOL;
    active_mode     : E_BDC_Mode;
END_VAR

grant_ACS     := FALSE;
grant_climate := FALSE;
grant_pool    := FALSE;
active_mode   := BDC_OFF;

IF NOT enabled THEN RETURN; END_IF

IF demand_ACS THEN
    grant_ACS   := TRUE;
    active_mode := BDC_ACS;

ELSIF P80_BDCPriority = UINT#0 THEN
    (* ACS > Climatización > Piscina *)
    IF demand_climate THEN
        grant_climate := TRUE;
        active_mode   := BDC_CLIMATE;
    ELSIF demand_pool THEN
        grant_pool  := TRUE;
        active_mode := BDC_POOL;
    END_IF

ELSE
    (* ACS > Piscina > Climatización *)
    IF demand_pool THEN
        grant_pool  := TRUE;
        active_mode := BDC_POOL;
    ELSIF demand_climate THEN
        grant_climate := TRUE;
        active_mode   := BDC_CLIMATE;
    END_IF
END_IF

END_FUNCTION_BLOCK
