(* ============================================================
   FB_Hysteresis.st
   Control todo-nada con histéresis configurable.
   Reutilizado en: ACS, climatización, piscina, persianas.

   Ejemplo de uso:
     ctrl_TT5(
       measured    := TT5,
       setpoint    := P30_ACSStorageSetPoint,
       hysteresis  := P31_ACSStorageHysteresis,
       mode_heat   := TRUE   (* TRUE=calor: ON si T<SP; FALSE=frío: ON si T>SP *)
     );
     output_device := ctrl_TT5.output;
   ============================================================ *)

FUNCTION_BLOCK FB_Hysteresis

VAR_INPUT
    measured    : REAL;         (* Valor medido *)
    setpoint    : REAL;         (* Consigna *)
    hysteresis  : REAL;         (* Banda muerta total [mismas unidades que measured] *)
    mode_heat   : BOOL := TRUE; (* TRUE=modo calor (ON si T<SP); FALSE=modo frío (ON si T>SP) *)
    enabled     : BOOL := TRUE; (* FALSE inhibe la salida (→ FALSE) *)
END_VAR

VAR_OUTPUT
    output      : BOOL;         (* Salida de control *)
    error       : REAL;         (* SP - measured *)
END_VAR

VAR
    half_hyst   : REAL;
END_VAR

(* --- Implementación --- *)

error    := setpoint - measured;
half_hyst := hysteresis / 2.0;

IF NOT enabled THEN
    output := FALSE;

ELSIF mode_heat THEN
    (* Modo calor: activa cuando T cae por debajo de (SP - H/2) *)
    IF measured <= (setpoint - half_hyst) THEN
        output := TRUE;
    ELSIF measured >= (setpoint + half_hyst) THEN
        output := FALSE;
    END_IF
    (* Entre las dos bandas: mantiene estado anterior *)

ELSE
    (* Modo frío: activa cuando T sube por encima de (SP + H/2) *)
    IF measured >= (setpoint + half_hyst) THEN
        output := TRUE;
    ELSIF measured <= (setpoint - half_hyst) THEN
        output := FALSE;
    END_IF

END_IF

END_FUNCTION_BLOCK
