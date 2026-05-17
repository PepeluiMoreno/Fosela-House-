(* ============================================================
   FB_PI_Controller.st
   Controlador PI discreto con anti-windup y saturación.
   Usado para: bomba solar P1 (lazo ΔT constante).

   Salida: 0.0 – 100.0 (%) que el caller mapea a 0-10V / 0-1000‰
   ============================================================ *)

FUNCTION_BLOCK FB_PI_Controller

VAR_INPUT
    measured        : REAL;         (* Valor medido (ej: ΔT actual) *)
    setpoint        : REAL;         (* Consigna (ej: ΔT objetivo 8 K) *)
    Kp              : REAL := 0.5;  (* Ganancia proporcional *)
    Ki              : REAL := 0.08; (* Ganancia integral [1/s] *)
    out_min         : REAL := 0.0;  (* Límite inferior salida [%] *)
    out_max         : REAL := 100.0;(* Límite superior salida [%] *)
    dt_seconds      : REAL := 1.0;  (* Periodo de muestreo [s] — igualar al task cycle *)
    enabled         : BOOL := TRUE; (* FALSE → salida a out_min, integral a 0 *)
    reset           : BOOL := FALSE;(* Pulso → resetea integral *)
END_VAR

VAR_OUTPUT
    output          : REAL;         (* Salida [out_min..out_max] *)
    error           : REAL;         (* Setpoint - measured *)
    saturated       : BOOL;         (* TRUE si la salida está saturada *)
END_VAR

VAR
    integral        : REAL := 0.0;
    p_term          : REAL;
    i_term          : REAL;
    raw_output      : REAL;
END_VAR

(* --- Implementación --- *)

IF reset THEN
    integral := 0.0;
END_IF

IF NOT enabled THEN
    output   := out_min;
    integral := 0.0;
    saturated := FALSE;
    error    := 0.0;
    RETURN;
END_IF

error  := setpoint - measured;
p_term := Kp * error;

(* Anti-windup: solo integra si la salida no está saturada
   (o si el error va en dirección opuesta a la saturación) *)
IF NOT saturated OR
   (saturated AND ((output >= out_max AND error < 0.0) OR
                   (output <= out_min AND error > 0.0))) THEN
    integral := integral + Ki * error * dt_seconds;
END_IF

raw_output := p_term + integral;

(* Saturación de salida *)
IF raw_output > out_max THEN
    output    := out_max;
    saturated := TRUE;
ELSIF raw_output < out_min THEN
    output    := out_min;
    saturated := TRUE;
ELSE
    output    := raw_output;
    saturated := FALSE;
END_IF

END_FUNCTION_BLOCK
