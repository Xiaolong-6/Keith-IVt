function results = run_hardware_checks(portName,baudRate,terminal)
%RUN_HARDWARE_CHECKS Manual open-circuit hardware checks for Keith-IVt.
%
% Usage:
%   results = run_hardware_checks("COM3",9600,"REAR")
%
% Keep the output open-circuit unless a specific check says otherwise. The
% checks use low current compliance and force output OFF after each section.

if nargin < 1 || isempty(portName)
    portName = "COM3";
end
if nargin < 2 || isempty(baudRate)
    baudRate = 9600;
end
if nargin < 3 || isempty(terminal)
    terminal = "REAR";
end

results = struct();
results.connection = verify_connection_profile(portName,baudRate,terminal);
results.senseMode = verify_4wire_sense_mode(portName,baudRate,terminal,true,1e-7,0);
results.measureRange = verify_measure_range(portName,baudRate,terminal);
results.openCircuitSweep = verify_open_circuit_sweep(portName,baudRate,terminal);
results.timeTrace = verify_time_trace(portName,baudRate,terminal);

fprintf('All hardware checks completed.\n');
end
