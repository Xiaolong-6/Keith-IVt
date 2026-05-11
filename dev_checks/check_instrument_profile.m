function check_instrument_profile
% Verify IDN parsing and profile labels for Keithley 2400-series instruments.

p = hardware.InstrumentProfile.fromIdn('KEITHLEY INSTRUMENTS INC.,MODEL 2400,123456,C30');
assert(strcmp(p.Model,'2400'));
assert(strcmp(hardware.InstrumentProfile.displayLabel(p),'Keithley 2400'));
assert(p.SupportsRemoteSense);
assert(abs(p.VoltageSourceLimit_V - 210) < 1e-12);
assert(abs(p.CurrentSourceLimit_A - 1.05) < 1e-12);

p2 = hardware.InstrumentProfile.fromIdn('KEITHLEY INSTRUMENTS INC.,2410,123456,C30');
assert(strcmp(p2.Model,'2410'));
assert(p2.VoltageSourceLimit_V >= 1000);

p3 = hardware.InstrumentProfile.fromIdn('KEITHLEY INSTRUMENTS INC.,MODEL 2430,123456,C30');
assert(p3.SupportsPulseMode);
assert(any(abs(p3.CurrentMeasureRanges_A - 10) < eps));

p4 = hardware.InstrumentProfile.fromIdn('KEITHLEY INSTRUMENTS INC.,MODEL 2440,123456,C30');
assert(abs(p4.VoltageSourceLimit_V - 42) < 1e-12);
assert(abs(p4.CurrentSourceLimit_A - 5.25) < 1e-12);

fprintf('check_instrument_profile passed.\n');
end
