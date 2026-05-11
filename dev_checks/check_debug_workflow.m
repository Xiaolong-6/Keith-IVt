function check_debug_workflow
% Exercise the app-level debug workflow without a connected instrument.

fig = AppTestUtil.openApp();
cleanupObj = onCleanup(@AppTestUtil.cleanupFigures);

AppTestUtil.setValue(fig,'devEdit','DevWorkflow');
AppTestUtil.setValue(fig,'commentEdit','short note');
AppTestUtil.configureDebugSweep(fig,'DevWorkflow',-0.2,0.2,0.2,0.01,0);

AppTestUtil.connectDebug(fig);
AppTestUtil.pushButton(fig,'startBtn');
AppTestUtil.waitForDeviceRows(fig,1,10);

devTable = AppTestUtil.findByTag(fig,'devTable');
assert(~isempty(devTable.Data),'Debug sweep should add one device row.');
assert(strcmp(devTable.Data{1,2},'DevWorkflow'));
assert(strcmp(devTable.Data{1,3},'short note'));
assert(devTable.Data{1,5} == 3,'Expected three sweep points.');

recoveryTable = AppTestUtil.findByTag(fig,'recoveryTable');
assert(~isempty(recoveryTable.Data),'Debug sweep should create recovery/cache rows.');
assert(any(contains(recoveryTable.Data(:,1),'short_note')),'Recovery filename should include the comment.');

fprintf('check_debug_workflow passed.\n');
clear cleanupObj;
AppTestUtil.cleanupFigures();
end
