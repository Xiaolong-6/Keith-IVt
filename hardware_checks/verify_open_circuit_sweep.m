function results = verify_open_circuit_sweep(portName,baudRate,terminal)
%VERIFY_OPEN_CIRCUIT_SWEEP Gentle open-circuit voltage-source sweep check.

driver = hardware.K2400Driver(portName,baudRate,terminal);
cleanupObj = onCleanup(@()safeDisconnect(driver));
driver.connect();
driver.configureSweep('VOLT',1e-7,0.1,'2-wire','Auto range',NaN);
driver.zeroSource('VOLT');
driver.outputOn();

X = [-0.01; 0; 0.01];
Y = nan(size(X));
raw = cell(size(X));
for k = 1:numel(X)
    [Y(k),raw{k}] = driver.readPoint('VOLT',X(k));
end
driver.safeOff('VOLT');

passed = all(isfinite(Y));
results = table(X,Y,raw,'VariableNames',{'Voltage_V','Current_A','RawReadLine'});
fprintf('Open-circuit sweep returned %d/%d finite readings.\n',sum(isfinite(Y)),numel(Y));
if ~passed
    error('Open-circuit sweep did not return finite readings.');
end

clear cleanupObj;
driver.disconnect();
end

function safeDisconnect(driver)
try
    driver.disconnect();
catch
end
end
