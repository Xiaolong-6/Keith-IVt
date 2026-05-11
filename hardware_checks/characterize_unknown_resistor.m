function result = characterize_unknown_resistor(portName,baudRate,terminal,senseMode,voltagePoints,currentCompliance,nplc,settleTime)
%CHARACTERIZE_UNKNOWN_RESISTOR Conservative hardware check for an unknown resistor.
%
% Usage:
%   result = characterize_unknown_resistor("COM3",9600,"REAR")
%
% The default sweep uses small voltages and 1 uA current compliance so it is
% safe for an unknown resistor in normal lab conditions. The output is forced
% off during cleanup.

if nargin < 1 || isempty(portName)
    portName = "COM3";
end
if nargin < 2 || isempty(baudRate)
    baudRate = 9600;
end
if nargin < 3 || isempty(terminal)
    terminal = "REAR";
end
if nargin < 4 || isempty(senseMode)
    senseMode = "2-wire";
end
if nargin < 5 || isempty(voltagePoints)
    voltagePoints = [-0.1 -0.05 -0.01 0.01 0.05 0.1];
end
if nargin < 6 || isempty(currentCompliance)
    currentCompliance = 1e-6;
end
if nargin < 7 || isempty(nplc)
    nplc = 1;
end
if nargin < 8 || isempty(settleTime)
    settleTime = 0.1;
end

fprintf('Unknown resistor characterization\n');
fprintf('Port: %s, baud: %g, terminal: %s, sense: %s\n',string(portName),baudRate,string(terminal),string(senseMode));
fprintf('Voltage points: %s V\n',mat2str(voltagePoints,5));
fprintf('Current compliance: %.6g A, NPLC: %.6g\n',currentCompliance,nplc);

driver = hardware.K2400Driver(portName,baudRate,terminal);
cleanupObj = onCleanup(@()safeDisconnect(driver));

driver.connect();
fprintf('Instrument ID: %s\n',driver.InstrumentID);
fprintf('Detected model: %s\n',hardware.InstrumentProfile.displayLabel(driver.Profile));

acceptedNplc = driver.configureSweep('VOLT',currentCompliance,nplc,senseMode,'Auto range');
fprintf('Accepted current NPLC readback: %s\n',acceptedNplc);

driver.zeroSource('VOLT');
driver.outputOn();
pause(settleTime);

n = numel(voltagePoints);
measuredCurrent = NaN(n,1);
rawLine = strings(n,1);
for k = 1:n
    sourceVoltage = voltagePoints(k);
    pause(settleTime);
    [measuredCurrent(k),rawLine(k)] = driver.readPoint('VOLT',sourceVoltage);
    fprintf('%+.6g V -> %+.6g A, raw: %s\n',sourceVoltage,measuredCurrent(k),rawLine(k));
end

driver.safeOff('VOLT');

power_W = abs(voltagePoints(:) .* measuredCurrent);
pointResistance_Ohm = voltagePoints(:) ./ measuredCurrent;
valid = isfinite(measuredCurrent) & abs(measuredCurrent) > 1e-12;

fitResistance_Ohm = NaN;
fitSlope_A_per_V = NaN;
if nnz(valid) >= 2 && range(voltagePoints(valid)) > 0
    coeff = polyfit(voltagePoints(valid),measuredCurrent(valid).',1);
    fitSlope_A_per_V = coeff(1);
    if isfinite(fitSlope_A_per_V) && abs(fitSlope_A_per_V) > 0
        fitResistance_Ohm = 1 / fitSlope_A_per_V;
    end
end

data = table(voltagePoints(:),measuredCurrent,pointResistance_Ohm,power_W,rawLine, ...
    'VariableNames',{'SourceVoltage_V','MeasuredCurrent_A','PointResistance_Ohm','AbsPower_W','RawReadLine'});

fprintf('Finite readings: %d/%d\n',nnz(isfinite(measuredCurrent)),n);
fprintf('Max absolute power: %.6g W\n',max(power_W,[],'omitnan'));
if isfinite(fitResistance_Ohm)
    fprintf('Fitted resistance: %.6g ohm\n',fitResistance_Ohm);
else
    fprintf('Fitted resistance: unavailable; currents may be near noise floor or compliance-limited.\n');
end

result = struct();
result.InstrumentID = driver.InstrumentID;
result.Model = driver.Profile.Model;
result.Terminal = char(string(terminal));
result.SenseMode = char(string(senseMode));
result.CurrentCompliance_A = currentCompliance;
result.AcceptedNPLC = acceptedNplc;
result.Data = data;
result.FitSlope_A_per_V = fitSlope_A_per_V;
result.FitResistance_Ohm = fitResistance_Ohm;
result.MaxAbsPower_W = max(power_W,[],'omitnan');
result.Passed = nnz(isfinite(measuredCurrent)) == n;

clear cleanupObj;
driver.disconnect();
end

function safeDisconnect(driver)
try
    driver.safeOff('VOLT');
catch
end
try
    driver.disconnect();
catch
end
end
