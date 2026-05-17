(* ============================================================
   FB_Valve2Way.st
   Gestión de válvula motorizada 2 vías todo-nada.
   - Tiempo mínimo de apertura para proteger el actuador.
   - Reutilizado en: VP_HX1, VP_HX_BDC, VP_HX_HTR
   ============================================================ *)

FUNCTION_BLOCK FB_Valve2Way

VAR_INPUT
    cmd_open        : BOOL;             (* TRUE = abrir *)
    enabled         : BOOL := TRUE;     (* FALSE fuerza cierre *)
    min_open_time   : TIME := T#10S;    (* Tiempo mínimo apertura *)
    travel_time     : TIME := T#15S;    (* Tiempo de maniobra *)
END_VAR

VAR_OUTPUT
    DO_valve        : BOOL;             (* Señal física al actuador *)
    is_open         : BOOL;             (* Confirmación apertura *)
    in_transit      : BOOL;
END_VAR

VAR
    timer_min       : TON;
    timer_travel    : TON;
    last_cmd        : BOOL := FALSE;
END_VAR

(* --- Implementación --- *)

IF NOT enabled THEN
    DO_valve   := FALSE;
    is_open    := FALSE;
    in_transit := FALSE;
    timer_min(IN := FALSE, PT := min_open_time);
    timer_travel(IN := FALSE, PT := travel_time);
    last_cmd := FALSE;
    RETURN;
END_IF

(* Tiempo mínimo de apertura: una vez abierta no cierra hasta cumplir min_open_time *)
IF cmd_open AND NOT last_cmd THEN
    timer_min(IN := FALSE, PT := min_open_time);
END_IF
timer_min(IN := DO_valve, PT := min_open_time);

(* Comando efectivo: abre si cmd_open, o mantiene abierto durante min_open_time *)
DO_valve := (cmd_open AND enabled) OR (timer_min.Q = FALSE AND DO_valve AND enabled);

(* Confirmar cambio de estado → in_transit *)
IF DO_valve <> last_cmd THEN
    in_transit := TRUE;
    timer_travel(IN := FALSE, PT := travel_time);
END_IF
last_cmd := DO_valve;

timer_travel(IN := in_transit, PT := travel_time);
IF timer_travel.Q THEN
    in_transit := FALSE;
    timer_travel(IN := FALSE, PT := travel_time);
END_IF

is_open := DO_valve AND NOT in_transit;

END_FUNCTION_BLOCK
