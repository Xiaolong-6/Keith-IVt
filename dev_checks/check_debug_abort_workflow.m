function check_debug_abort_workflow
% Verify Abort works during a running debug sweep.

fig = AppTestUtil.openApp();
cleanupObj = onCleanup(@AppTestUtil.cleanupFigures);

AppTestUtil.configureDebugSweep(fig,'DevAbort',-1,1,0.05,10,0.02);
AppTestUtil.connectDebug(fig);

abortTimer = timer('StartDelay',0.35,'TimerFcn',@(~,~)AppTestUtil.pushButton(fig,'abortBtn'));
timerCleanup = onCleanup(@()AppTestUtil.deleteTimer(abortTimer));
start(abortTimer);
AppTestUtil.pushButton(fig,'startBtn');

AppTestUtil.waitForStatus(fig,'Debug mode: aborted',5);
devTable = AppTestUtil.findByTag(fig,'devTable');
assert(isempty(devTable.Data),'Aborted debug sweep should not add a completed device row.');

fprintf('check_debug_abort_workflow passed.\n');
clear timerCleanup cleanupObj;
AppTestUtil.cleanupFigures();
end
