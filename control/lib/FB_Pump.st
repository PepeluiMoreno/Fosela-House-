(* ============================================================
   FB_Pump.st
   Gestión de bomba/circuladora con:
   - Tiempo mínimo encendida (anti-ciclado)
   - Tiempo mínimo apagada (anti-ciclado)
   - Inhibición por alarma
   Reutilizado en: P1, P2, P3, P4
   ============================================================ *)

FUNCTION_BLOCK FB_Pump

VAR_INPUT
    cmd_run         : BOOL;             (* TRUE = orden de marcha *)
    fault           : BOOL := FALSE;    (* TRUE = fallo externo → parada forzada *)
    min_on_time     : TIME := T#30S;    (* Tiempo mínimo encendida *)
    min_off_time    : TIME := T#20S;    (* Tiempo mínimo apagada *)
    enabled         : BOOL := TRUE;
END_VAR

VAR_OUTPUT
    DO_pump         : BOOL;             (* Señal física *)
    running         : BOOL;             (* Confirmación de marcha *)
    inhibited       : BOOL;             (* TRUE si en periodo de inhibición *)
END_VAR

VAR
    timer_min_on    : TON;
    timer_min_off   : TON;
    internal_run    : BOOL := FALSE;
END_VAR

(* --- Implementación --- *)

IF NOT enabled OR fault THEN
    internal_run := FALSE;
    DO_pump      := FALSE;
    running      := FALSE;
    inhibited    := FALSE;
    timer_min_on(IN := FALSE, PT := min_on_time);
    timer_min_off(IN := FALSE, PT := min_off_time);
    RETURN;
END_IF

(* Timer anti-ciclado apagado: una vez parada no vuelve a arrancar hasta cumplir min_off *)
timer_min_off(IN := NOT internal_run, PT := min_off_time);

(* Arranque: cmd_run activo Y periodo mínimo de parada cumplido *)
IF cmd_run AND (timer_min_off.Q OR internal_run) THEN
    internal_run := TRUE;
END_IF

(* Timer anti-ciclado encendido: una vez arrancada no para hasta cumplir min_on *)
timer_min_on(IN := internal_run, PT := min_on_time);

(* Parada: cmd_run inactivo Y periodo mínimo de marcha cumplido *)
IF NOT cmd_run AND timer_min_on.Q THEN
    internal_run := FALSE;
END_IF

DO_pump  := internal_run;
running  := internal_run;
inhibited := (cmd_run AND NOT timer_min_off.Q AND NOT internal_run) OR
             (NOT cmd_run AND NOT timer_min_on.Q AND internal_run);

END_FUNCTION_BLOCK
