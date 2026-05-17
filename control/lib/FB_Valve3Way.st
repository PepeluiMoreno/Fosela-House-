(* ============================================================
   FB_Valve3Way.st
   Gestión de válvula motorizada 3 vías todo-nada.
   - Protege contra cambios de posición durante la maniobra.
   - Salida: DO_valve = FALSE → posición A (muelle/reposo)
             DO_valve = TRUE  → posición B (energizada)
   - Reutilizado en: V3V1, V3V2, V3V3, V3V_SOL
   ============================================================ *)

FUNCTION_BLOCK FB_Valve3Way

VAR_INPUT
    cmd_pos_B       : BOOL;             (* TRUE = ir a posición B *)
    enabled         : BOOL := TRUE;     (* FALSE fuerza posición A *)
    travel_time     : TIME := T#30S;    (* Tiempo de maniobra *)
END_VAR

VAR_OUTPUT
    DO_valve        : BOOL;             (* Señal física al actuador *)
    position        : E_Valve3Way_Pos;  (* Posición confirmada *)
    in_transit      : BOOL;             (* TRUE durante maniobra *)
END_VAR

VAR
    timer_travel    : TON;
    last_cmd        : BOOL := FALSE;
    target          : BOOL := FALSE;
END_VAR

(* --- Implementación --- *)

IF NOT enabled THEN
    DO_valve    := FALSE;
    position    := V3W_POS_A;
    in_transit  := FALSE;
    last_cmd    := FALSE;
    timer_travel(IN := FALSE, PT := travel_time);
    RETURN;
END_IF

target := cmd_pos_B;

(* Detecta cambio de comando *)
IF target <> last_cmd THEN
    timer_travel(IN := FALSE, PT := travel_time); (* Reinicia timer *)
    in_transit := TRUE;
    last_cmd   := target;
END_IF

(* Temporizador de maniobra *)
timer_travel(IN := in_transit, PT := travel_time);

IF timer_travel.Q THEN
    in_transit := FALSE;
    timer_travel(IN := FALSE, PT := travel_time);
END_IF

(* Salida física *)
DO_valve := target;

(* Posición confirmada solo cuando no está en maniobra *)
IF NOT in_transit THEN
    IF DO_valve THEN
        position := V3W_POS_B;
    ELSE
        position := V3W_POS_A;
    END_IF
END_IF

END_FUNCTION_BLOCK
