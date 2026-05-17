(* ============================================================
   FB_Alarm.st
   Alarma con filtro antirrebote, enclavamiento (latch) y reset.
   - filter_time: la condición debe persistir antes de activar alarma.
   - Latch: una vez activa, se mantiene hasta reset explícito.
   ============================================================ *)

FUNCTION_BLOCK FB_Alarm

VAR_INPUT
    condition       : BOOL;             (* TRUE = condición de alarma *)
    reset_cmd       : BOOL;             (* Pulso → desenclavamiento *)
    filter_time     : TIME := T#10S;    (* Tiempo de filtrado *)
    latch           : BOOL := TRUE;     (* TRUE = enclavamiento activo *)
    enabled         : BOOL := TRUE;
END_VAR

VAR_OUTPUT
    active          : BOOL;             (* Alarma activa (enclavada si latch) *)
    pending         : BOOL;             (* Condición presente pero no enclavada aún *)
END_VAR

VAR
    timer_filter    : TON;
    latched         : BOOL := FALSE;
END_VAR

(* --- Implementación --- *)

IF NOT enabled THEN
    active  := FALSE;
    pending := FALSE;
    latched := FALSE;
    timer_filter(IN := FALSE, PT := filter_time);
    RETURN;
END_IF

(* Filtro antirrebote *)
timer_filter(IN := condition, PT := filter_time);
pending := condition AND NOT timer_filter.Q;

(* Enclavamiento *)
IF timer_filter.Q THEN
    latched := TRUE;
END_IF

IF reset_cmd AND NOT condition THEN
    latched := FALSE;
END_IF

IF latch THEN
    active := latched;
ELSE
    active := timer_filter.Q;
END_IF

END_FUNCTION_BLOCK
