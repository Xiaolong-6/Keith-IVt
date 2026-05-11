function check_debug_pause_workflow
% Verify Pause and Resume work during a running debug sweep.

fig = AppTestUtil.openApp();
cleanupObj = onCleanup(@AppTestUtil.cleanupFigures);

AppTestUtil.configureDebugSweep(fig,'DevPause',-1,1,0.05,10,0.02);
AppTestUtil.connectDebug(fig);

pauseTimer = timer('StartDelay',0.35,'TimerFcn',@(~,~)AppTestUtil.pushButton(fig,'pauseBtn'));
resumeTimer = timer('StartDelay',0.9,'TimerFcn',@(~,~)AppTestUtil.pushButton(fig,'pauseBtn'));
timerCleanup = onCleanup(@()AppTestUtil.deleteTimers([pauseTimer resumeTimer]));
start(pauseTimer);
start(resumeTimer);
AppTestUtil.pushButton(fig,'startBtn');

AppTestUtil.waitForDeviceRows(fig,1,5);
devTable = AppTestUtil.findByTag(fig,'devTable');
assert(strcmp(devTable.Data{1,2},'DevPause'));
assert(devTable.Data{1,5} == 41,'Paused/resumed sweep should still finish all points.');

fprintf('check_debug_pause_workflow passed.\n');
clear timerCleanup cleanupObj;
AppTestUtil.cleanupFigures();
end
