(* ============================================================
   FB_HTR_Arbiter.st  –  Árbitro del circuito HTR
   HTR va a D2 (ACS) por defecto.
   Deriva a piscina cuando D2 está satisfecho.
   ============================================================ *)
FUNCTION_BLOCK FB_HTR_Arbiter
VAR_INPUT
    acs_satisfied   : BOOL;
    demand_pool     : BOOL;
    enabled         : BOOL := TRUE;
END_VAR
VAR_OUTPUT
    cmd_V3V3_pool   : BOOL;  (* TRUE = HTR → HX_HTR (piscina) *)
    htr_to_pool     : BOOL;  (* Señal para FB_Pool *)
END_VAR

IF NOT enabled THEN
    cmd_V3V3_pool := FALSE;
    htr_to_pool   := FALSE;
    RETURN;
END_IF

cmd_V3V3_pool := acs_satisfied AND demand_pool;
htr_to_pool   := cmd_V3V3_pool;

END_FUNCTION_BLOCK
