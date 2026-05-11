function check_driver_construction
% Verify the packaged driver constructor accepts app-level arguments.

driver = hardware.K2400Driver('COM_TEST_ONLY',9600,'REAR');
assert(isa(driver,'hardware.K2400Driver'));
assert(strcmp(driver.PortName,'COM_TEST_ONLY'));
assert(driver.BaudRate == 9600);
assert(strcmp(driver.Terminal,'REAR'));

fprintf('check_driver_construction passed.\n');
end
