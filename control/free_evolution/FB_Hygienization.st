(* ============================================================
   FB_Hygienization.st  –  Ciclo de higienización térmica
   Máquina de estados: IDLE → HEAT_D2 → HOLD_D2 → FLUSH → DONE
   ============================================================ *)
FUNCTION_BLOCK FB_Hygienization
VAR_INPUT
    TT5             : REAL;
    manual_request  : BOOL;
    enabled         : BOOL := TRUE;
END_VAR
VAR_OUTPUT
    phase           : E_Hygienization_Phase;
    active          : BOOL;
    apt_idx         : UINT;   (* Apartamento actual en purgado 1-5 *)
    force_BDC_ACS   : BOOL;   (* Forzar BDC a modo ACS *)
    force_APT_prec  : BOOL;   (* Forzar V3V_APT a precalentada *)
END_VAR
VAR
    timer_hold      : TON;
    timer_flush     : TON;
    ctrl_hyg        : FB_Hysteresis;
    r_manual        : R_TRIG;
    scheduled_trigger: BOOL;  (* TODO: conectar al programador horario *)
END_VAR

r_manual(CLK := manual_request);

CASE phase OF

HYG_IDLE:
    active         := FALSE;
    force_BDC_ACS  := FALSE;
    force_APT_prec := FALSE;
    apt_idx        := 1;
    timer_hold(IN := FALSE, PT := P72_HygienizationHoldTime);
    timer_flush(IN := FALSE, PT := P73_HygienizationFlushTime);
    IF (r_manual.Q OR scheduled_trigger) AND enabled THEN
        phase := HYG_HEAT_D2;
    END_IF

HYG_HEAT_D2:
    active        := TRUE;
    force_BDC_ACS := TRUE;
    force_APT_prec:= TRUE;
    ctrl_hyg(
        measured   := TT5,
        setpoint   := P70_HygienizationTarget,
        hysteresis := P71_HygienizationHysteresis,
        mode_heat  := TRUE
    );
    IF NOT ctrl_hyg.output THEN
        phase := HYG_HOLD_D2;
    END_IF

HYG_HOLD_D2:
    active        := TRUE;
    force_BDC_ACS := TRUE;
    force_APT_prec:= TRUE;
    timer_hold(IN := TRUE, PT := P72_HygienizationHoldTime);
    IF timer_hold.Q THEN
        timer_hold(IN := FALSE, PT := P72_HygienizationHoldTime);
        phase   := HYG_FLUSH;
        apt_idx := 1;
    END_IF

HYG_FLUSH:
    active        := TRUE;
    force_BDC_ACS := TRUE;
    force_APT_prec:= TRUE;
    timer_flush(IN := TRUE, PT := P73_HygienizationFlushTime);
    IF timer_flush.Q THEN
        timer_flush(IN := FALSE, PT := P73_HygienizationFlushTime);
        IF apt_idx < 5 THEN
            apt_idx := apt_idx + 1;
        ELSE
            phase := HYG_DONE;
        END_IF
    END_IF

HYG_DONE:
    active        := FALSE;
    force_BDC_ACS := FALSE;
    force_APT_prec:= FALSE;
    phase         := HYG_IDLE;

END_CASE

END_FUNCTION_BLOCK
