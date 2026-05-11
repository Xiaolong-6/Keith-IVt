function result = verify_connection_profile(portName,baudRate,terminal)
%VERIFY_CONNECTION_PROFILE Connect, read IDN, and parse the instrument profile.

driver = hardware.K2400Driver(portName,baudRate,terminal);
cleanupObj = onCleanup(@()safeDisconnect(driver));
driver.connect();

profile = driver.Profile;
fprintf('Instrument ID: %s\n',driver.InstrumentID);
fprintf('Detected model: %s\n',hardware.InstrumentProfile.displayLabel(profile));

result = struct();
result.InstrumentID = driver.InstrumentID;
result.Model = profile.Model;
result.Profile = profile;
result.Passed = ~isempty(driver.InstrumentID);

clear cleanupObj;
driver.disconnect();
end

function safeDisconnect(driver)
try
    driver.disconnect();
catch
end
end
