function check_comment_workflow
% Verify measurement comments are limited, displayed, and exported.

fig = AppTestUtil.openApp();
cleanupObj = onCleanup(@AppTestUtil.cleanupFigures);

longComment = 'abcdefghijklmnopqrstuvwxyz';
expectedComment = 'abcdefghijklmnopqrst';

AppTestUtil.setValue(fig,'devEdit','DevComment');
AppTestUtil.setValue(fig,'commentEdit',longComment);
commentEdit = AppTestUtil.findByTag(fig,'commentEdit');
assert(strcmp(commentEdit.Value,expectedComment),'Comment should be limited to 20 characters.');

AppTestUtil.configureDebugSweep(fig,'DevComment',-0.2,0.2,0.2,0.01,0);
AppTestUtil.setValue(fig,'commentEdit',longComment);
AppTestUtil.connectDebug(fig);
AppTestUtil.pushButton(fig,'startBtn');
AppTestUtil.waitForDeviceRows(fig,1,10);

devTable = AppTestUtil.findByTag(fig,'devTable');
assert(strcmp(devTable.Data{1,2},'DevComment'));
assert(strcmp(devTable.Data{1,3},expectedComment));

recoveryTable = AppTestUtil.findByTag(fig,'recoveryTable');
assert(~isempty(recoveryTable.Data),'Comment workflow should create recovery rows.');
assert(contains(recoveryTable.Data{1,1},expectedComment),'Recovery filename should include the comment.');

recoveryText = fileread(AppTestUtil.recoveryFile(fig,1));
assert(contains(recoveryText,['# Comment: ' expectedComment]),'Recovery metadata should include the comment.');

dev = struct('name','DevComment','comment',expectedComment,'mode','VOLT', ...
    'X',[-0.2; 0; 0.2],'Y',[-1e-6; 0; 1e-6],'visible',true,'raw',{{}},'meta',struct('Comment',expectedComment));
[defaultName,~,~,~] = data.ExportWorkflow.selectedDeviceExport(dev,'Simple: voltage/current only');
assert(contains(defaultName,'DevComment_abcdefghijklmnopqrst'),'Selected export filename should include the comment.');

fprintf('check_comment_workflow passed.\n');
clear cleanupObj;
AppTestUtil.cleanupFigures();
end
