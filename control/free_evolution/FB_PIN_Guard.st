(* ============================================================
   FB_PIN_Guard.st
   Gestión de acceso con PIN a menús restringidos (TEST, CFG).
   - Muestra "PIN:" en display y permite introducir 4 dígitos.
   - Bloqueo automático tras 3 intentos fallidos (5 minutos).
   - Timeout de sesión: cierra acceso tras inactividad.
   ============================================================ *)

FUNCTION_BLOCK FB_PIN_Guard

VAR_INPUT
    pin_stored      : UINT;             (* PIN configurado *)
    pin_entered     : UINT;             (* PIN introducido por operador *)
    confirm         : BOOL;             (* Pulso ENTER: validar PIN *)
    cancel          : BOOL;             (* Pulso ESC: cancelar *)
    activity        : BOOL;             (* TRUE si hay actividad en panel *)
    session_timeout : TIME := T#5M;     (* Tiempo de inactividad → cierre sesión *)
    lockout_time    : TIME := T#5M;     (* Tiempo de bloqueo tras 3 fallos *)
END_VAR

VAR_OUTPUT
    access_granted  : BOOL := FALSE;    (* TRUE = acceso concedido *)
    locked_out      : BOOL := FALSE;    (* TRUE = bloqueado por intentos *)
    attempts_left   : UINT := 3;        (* Intentos restantes *)
    show_error      : BOOL := FALSE;    (* Mostrar "Err" en display *)
END_VAR

VAR
    failed_attempts : UINT := 0;
    timer_session   : TON;
    timer_lockout   : TON;
    timer_error_msg : TON;
    r_confirm       : R_TRIG;
    r_cancel        : R_TRIG;
END_VAR

(* --- Detección de flancos --- *)
r_confirm(CLK := confirm);
r_cancel(CLK := cancel);

(* --- Bloqueo por intentos fallidos --- *)
timer_lockout(IN := locked_out, PT := lockout_time);
IF timer_lockout.Q THEN
    locked_out      := FALSE;
    failed_attempts := 0;
    timer_lockout(IN := FALSE, PT := lockout_time);
END_IF

(* --- Timeout de sesión por inactividad --- *)
timer_session(IN := access_granted AND NOT activity, PT := session_timeout);
IF timer_session.Q THEN
    access_granted := FALSE;
    timer_session(IN := FALSE, PT := session_timeout);
END_IF

(* --- Validación PIN --- *)
IF r_confirm.Q AND NOT locked_out AND NOT access_granted THEN
    IF pin_entered = pin_stored THEN
        access_granted  := TRUE;
        failed_attempts := 0;
        show_error      := FALSE;
    ELSE
        failed_attempts := failed_attempts + 1;
        show_error      := TRUE;
        timer_error_msg(IN := FALSE, PT := T#2S);
        IF failed_attempts >= 3 THEN
            locked_out := TRUE;
        END_IF
    END_IF
END_IF

(* Ocultar mensaje de error tras 2 segundos *)
timer_error_msg(IN := show_error, PT := T#2S);
IF timer_error_msg.Q THEN
    show_error := FALSE;
    timer_error_msg(IN := FALSE, PT := T#2S);
END_IF

(* --- Cancelar / cerrar sesión --- *)
IF r_cancel.Q THEN
    access_granted := FALSE;
END_IF

attempts_left := 3 - failed_attempts;

END_FUNCTION_BLOCK
