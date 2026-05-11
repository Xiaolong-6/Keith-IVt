function results = verify_time_trace(portName,baudRate,terminal)
%VERIFY_TIME_TRACE Gentle open-circuit Time Trace hardware check.

driver = hardware.K2400Driver(portName,baudRate,terminal);
cleanupObj = onCleanup(@()safeDisconnect(driver));
driver.connect();
driver.configureSweep('VOLT',1e-7,0.1,'2-wire','Auto range',NaN);
driver.zeroSource('VOLT');
driver.outputOn();

nPts = 3;
intervalS = 0.2;
timeS = nan(nPts,1);
currentA = nan(nPts,1);
raw = cell(nPts,1);
t0 = tic;
for k = 1:nPts
    [currentA(k),raw{k}] = driver.readPoint('VOLT',0);
    timeS(k) = toc(t0);
    if k < nPts
        pause(intervalS);
    end
end
driver.safeOff('VOLT');

passed = all(isfinite(currentA));
results = table(timeS,currentA,raw,'VariableNames',{'Time_s','Current_A','RawReadLine'});
fprintf('Time Trace returned %d/%d finite readings.\n',sum(isfinite(currentA)),nPts);
if ~passed
    error('Time Trace hardware check did not return finite readings.');
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
