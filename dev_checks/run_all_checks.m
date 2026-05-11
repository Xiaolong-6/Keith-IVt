function run_all_checks
% Run lightweight checks that do not require a connected instrument.

check_adaptive_rules;
check_driver_construction;
check_instrument_profile;
check_debug_sweep;
check_csv_roundtrip;
check_all_export_metadata;
check_debug_workflow;
check_comment_workflow;
check_time_trace_workflow;
check_debug_abort_workflow;
check_debug_pause_workflow;

fprintf('All dev checks passed.\n');
end
