function check_debug_sweep
% Verify debug profiles, compliance clipping, and NPLC noise scaling.

X = linspace(-1,1,101)';
profiles = {'Resistor','Diode','Leaky nonlinear device','Noisy contact'};
for k = 1:numel(profiles)
    [Y,profileName] = hardware.DebugSMU.generateMeasurement('VOLT',X,'DevCheck',1,profiles{k});
    assert(numel(Y) == numel(X));
    assert(all(isfinite(Y)));
    assert(strcmpi(profileName,profiles{k}));
end

[YLow,~] = hardware.DebugSMU.generateMeasurement('VOLT',X,'DevCheck',0.1,'Resistor');
[YHigh,~] = hardware.DebugSMU.generateMeasurement('VOLT',X,'DevCheck',10,'Resistor');
ideal = X./120e3 + 1.5e-9;
assert(std(YLow - ideal) > std(YHigh - ideal),'Higher NPLC should reduce debug noise.');

[YClip,hit] = hardware.DebugSMU.applyCompliance(100*ones(size(X)),0.01);
assert(hit);
assert(all(abs(YClip) <= 0.0098 + eps));

fprintf('check_debug_sweep passed.\n');
end
