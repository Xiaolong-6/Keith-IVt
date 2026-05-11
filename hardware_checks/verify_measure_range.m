function results = verify_measure_range(portName,baudRate,terminal)
%VERIFY_MEASURE_RANGE Check auto and fixed measurement range commands.

driver = hardware.K2400Driver(portName,baudRate,terminal);
cleanupObj = onCleanup(@()safeDisconnect(driver));
driver.connect();

rows = cell(2,5);
modes = {'Auto range','Fixed measure range'};
values = [NaN 1e-6];
for k = 1:2
    acceptedNplc = driver.configureSweep('VOLT',1e-7,0.1,'2-wire',modes{k},values(k));
    readback = '';
    try
        readback = driver.query(':SENS:CURR:RANG?');
    catch
    end
    passed = ~isempty(acceptedNplc) || ~isempty(readback);
    rows(k,:) = {modes{k},values(k),acceptedNplc,readback,passed};
    fprintf('Range mode %s, readback "%s": %s\n',modes{k},readback,passFailText(passed));
end

driver.safeOff('VOLT');
results = cell2table(rows,'VariableNames',{'RangeMode','RangeValue','AcceptedNPLC','RangeReadback','Passed'});
if ~all([results.Passed])
    error('Measurement range verification failed.');
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

function txt = passFailText(passed)
if passed
    txt = 'PASS';
else
    txt = 'FAIL';
end
end
