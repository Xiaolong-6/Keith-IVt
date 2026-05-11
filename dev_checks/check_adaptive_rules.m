function check_adaptive_rules
% Verify default adaptive sweep ranges and boundary handling.

rules = [100 1 1; 1 0.1 0.1; 0.1 0.01 0.01; 0.01 0.001 0.001];
rules = core.SweepMath.validateAdaptiveRules(rules);
assert(isequal(rules,[0.001 0.01 0.001; 0.01 0.1 0.01; 0.1 1 0.1; 1 100 1]));

core.SweepMath.validateAdaptiveCoverage(rules,-5,5);
X = core.SweepMath.buildAdaptiveScanVector(-1,1,rules);
assert(X(1) == -1 && X(end) == 1);
assert(any(X == 0),'Adaptive sweep crossing zero should include zero.');
assert(all(diff(X) > 0),'Adaptive vector should be monotonic for ascending sweep.');

fprintf('check_adaptive_rules passed.\n');
end
