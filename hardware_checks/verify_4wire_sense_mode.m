function results = verify_4wire_sense_mode(portName,baudRate,terminal,doOutputTest,currentCompliance,sourceVoltage)
%VERIFY_4WIRE_SENSE_MODE Hardware check for Keithley 2400 2-wire/4-wire control.
%
% Usage:
%   results = verify_4wire_sense_mode("COM3",9600,"REAR")
%
% This check is intended for open-circuit validation without a device
% connected. It connects to the Keithley, switches remote sense OFF/ON/OFF,
% queries :SYST:RSEN? after each step, and performs a gentle 0 V current
% reading to confirm that the meter returns numeric data. The current
% compliance defaults to 100 nA.

if nargin < 1 || isempty(portName)
    portName = "COM3";
end
if nargin < 2 || isempty(baudRate)
    baudRate = 9600;
end
if nargin < 3 || isempty(terminal)
    terminal = "REAR";
end
if nargin < 4 || isempty(doOutputTest)
    doOutputTest = true;
end
if nargin < 5 || isempty(currentCompliance)
    currentCompliance = 1e-7;
end
if nargin < 6 || isempty(sourceVoltage)
    sourceVoltage = 0;
end

fprintf('Keithley 2400 2-wire/4-wire verification\n');
fprintf('Port: %s, baud: %g, terminal: %s\n',string(portName),baudRate,string(terminal));
fprintf('Output test: %s\n',onOffText(doOutputTest));
fprintf('Open-circuit read settings: source %.6g V, current compliance %.6g A\n',sourceVoltage,currentCompliance);

driver = hardware.K2400Driver(portName,baudRate,terminal);
cleanupObj = onCleanup(@()safeDisconnect(driver));

driver.connect();
fprintf('Instrument ID: %s\n',driver.InstrumentID);

senseModes = {'2-wire','4-wire','2-wire'};
expected = {'0','1','0'};
rows = cell(numel(senseModes),7);

for k = 1:numel(senseModes)
    senseMode = senseModes{k};
    acceptedNplc = driver.configureSweep('VOLT',currentCompliance,0.1,senseMode);
    readback = driver.querySenseMode();
    passed = strcmp(strtrim(readback),expected{k});

    measurement = NaN;
    rawLine = '';
    if doOutputTest
        driver.zeroSource('VOLT');
        driver.outputOn();
        pause(0.1);
        [measurement,rawLine] = driver.readPoint('VOLT',sourceVoltage);
        driver.safeOff('VOLT');
    end

    numericReturned = ~doOutputTest || isfinite(measurement);
    passed = passed && numericReturned;
    rows(k,:) = {senseMode,expected{k},readback,passed,acceptedNplc,measurement,rawLine};
    fprintf('%s expected RSEN=%s, read RSEN=%s: %s\n',senseMode,expected{k},readback,passFailText(passed));
    if doOutputTest
        fprintf('  Open-circuit current read: %.6g A, raw: %s\n',measurement,rawLine);
    end
end

driver.safeOff('VOLT');
results = cell2table(rows,'VariableNames',{'SenseMode','ExpectedRSEN','ReadbackRSEN','Passed','AcceptedNPLC','MeasuredCurrent_A','RawReadLine'});

if ~all([results.Passed])
    error('Keithley remote sense verification failed. Check the RSEN readback values above.');
end

fprintf('Remote sense verification passed.\n');
clear cleanupObj;
driver.disconnect();
end

function safeDisconnect(driver)
try
    driver.disconnect();
catch
end
end

function txt = passFailText(passed)
if passed
    txt = 'PASS';
else
    txt = 'FAIL';
end
end

function txt = onOffText(tf)
if tf
    txt = 'enabled';
else
    txt = 'disabled';
end
end
