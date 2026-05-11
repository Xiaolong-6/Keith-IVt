function check_time_trace_workflow
% Verify debug Time Trace creates time-based data and metadata.

fig = AppTestUtil.openApp();
cleanupObj = onCleanup(@AppTestUtil.cleanupFigures);

AppTestUtil.setValue(fig,'devEdit','DevTimeTrace');
AppTestUtil.setValue(fig,'commentEdit','operator');
AppTestUtil.setValue(fig,'measureTypeDrop','Time Trace');
AppTestUtil.setValue(fig,'fixedSourceEdit',0);
AppTestUtil.setValue(fig,'durationEdit',0.2);
AppTestUtil.setValue(fig,'intervalEdit',0.1);
AppTestUtil.setValue(fig,'nplcEdit',0.01);
AppTestUtil.setValue(fig,'delayEdit',0);
AppTestUtil.setValue(fig,'compEdit',0.01);

AppTestUtil.connectDebug(fig);
AppTestUtil.pushButton(fig,'startBtn');
AppTestUtil.waitForDeviceRows(fig,1,10);

devTable = AppTestUtil.findByTag(fig,'devTable');
assert(strcmp(devTable.Data{1,2},'DevTimeTrace'));
assert(strcmp(devTable.Data{1,3},'operator'));
assert(devTable.Data{1,5} == 3,'Expected three time trace points.');

recoveryTable = AppTestUtil.findByTag(fig,'recoveryTable');
assert(~isempty(recoveryTable.Data),'Time Trace should create recovery/cache rows.');
txt = fileread(AppTestUtil.recoveryFile(fig,1));
assert(contains(txt,'# MeasurementType: Time Trace'),'Metadata should identify Time Trace.');
assert(contains(txt,'Time_s'),'CSV should export elapsed time.');

fprintf('check_time_trace_workflow passed.\n');
clear cleanupObj;
AppTestUtil.cleanupFigures();
end
