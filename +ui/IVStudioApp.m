function IVStudioApp(appRoot)
% Main UI coordinator for Keith-IVt.

clc;
if nargin < 1 || isempty(appRoot)
    if isdeployed
        appRoot = ctfroot;
    else
        appRoot = fileparts(fileparts(mfilename('fullpath')));
    end
end
resourceRoot = appRoot;
dataRoot = appRoot;
if isdeployed
    dataRoot = fullfile(prefdir,'Keith-IVt');
    if ~isfolder(dataRoot)
        mkdir(dataRoot);
    end
end
helpMark = '';
devilIcon = native2unicode(uint8([240 159 152 136]),'UTF-8');
emojiFont = 'Segoe UI Emoji';

%% ---------------- App state ----------------
app = struct();
app.info = core.AppInfo.current();
app.smu = [];
app.abortRequested = false;
app.pauseRequested = false;
app.isSweeping = false;
app.connected = false;
app.debugMode = false;
app.developerLog = true;
app.fontScale = 1.0;
app.themeName = 'Light';
app.leftPanelWidth = 380;
app.rightPanelWidth = 340;
app.collapsedPanelWidth = 36;
app.compactModeBreakpoint = 0;
app.layoutTimer = [];
app.instrumentID = '';
app.instrumentProfile = [];
app.exportFolder = dataRoot;
app.cacheFolder = fullfile(dataRoot,'cache');
app.currentAutosaveFile = '';
app.cacheLogFile = '';
app.cacheLogMaxBytes = 1024*1024;
app.recoveryMaxRows = 50;
app.configFolder = fullfile(dataRoot,'config');
if ~isfolder(app.configFolder)
    mkdir(app.configFolder);
end
app.presetFile = fullfile(app.configFolder,'presets.mat');
legacyPresetFile = fullfile(dataRoot,'presets.mat');
if ~isfile(app.presetFile) && isfile(legacyPresetFile)
    movefile(legacyPresetFile,app.presetFile);
end
app.aboutFile = fullfile(resourceRoot,'ABOUT.txt');
% mode: 'VOLT' means X=V, Y=I. mode: 'CURR' means X=I, Y=V.
app.devices = struct('name',{},'comment',{},'mode',{},'X',{},'Y',{},'visible',{},'raw',{},'meta',{});
app.colors = lines(50);
app.lastMeasureType = 'Sweep';
app.lastSourceMode = 'Voltage source: source V, measure I';

%% ---------------- UI layout ----------------
ui.Theme.applyDefaultFonts();
app.fig = uifigure('Name',app.info.WindowTitle, ...
    'Position',[100 100 1320 740], ...
    'CloseRequestFcn',@onClose, ...
    'DeleteFcn',@cleanupTimer);
try
    app.fig.WindowState = 'maximized';
catch
    app.fig.Position = get(0,'ScreenSize');
end
setappdata(app.fig,'KeithIVtAbortRequested',false);
setappdata(app.fig,'KeithIVtPauseRequested',false);

root = uigridlayout(app.fig,[3 2]);
root.ColumnWidth = {500,'1x'};
root.RowHeight = {'2.15x','1x',28};
root.BackgroundColor = ui.Theme.colors().window;

%% Left panel: controls
leftColumn = uipanel(root,'Title','','BorderType','none','BackgroundColor',[1 1 1]);
leftColumn.Layout.Row = [1 2];
leftColumn.Layout.Column = 1;
leftColumnGrid = uigridlayout(leftColumn,[1 1]);
try, leftColumnGrid.BackgroundColor = [1 1 1]; catch, end
app.leftColumnGrid = leftColumnGrid;
leftColumnGrid.RowHeight = {'1x'};
leftColumnGrid.ColumnWidth = {'1x'};
leftColumnGrid.Padding = [0 0 0 0];
leftColumnGrid.RowSpacing = 8;

left = uipanel(leftColumnGrid,'Title','Measurement Controls','BackgroundColor',[1 1 1]);
try
    left.Scrollable = 'on';
catch
end
left.Layout.Row = 1;
left.Layout.Column = 1;
leftShell = uigridlayout(left,[2 1]);
try, leftShell.BackgroundColor = [1 1 1]; catch, end
app.leftShell = leftShell;
leftShell.RowHeight = {0,'1x'};
leftShell.ColumnWidth = {'1x'};
leftShell.Padding = [4 2 4 4];
leftShell.RowSpacing = 8;

statusGrid = uigridlayout(leftShell,[1 4]);
try, statusGrid.BackgroundColor = [1 1 1]; catch, end
statusGrid.Layout.Row = 1;
statusGrid.Visible = 'off';
statusGrid.RowHeight = {24};
statusGrid.ColumnWidth = {26,'1x',8,135};
statusGrid.Padding = [0 0 0 0];
statusGrid.RowSpacing = 0;
statusGrid.ColumnSpacing = 4;
app.connLamp = uilamp(statusGrid,'Color',[0.85 0.05 0.05]);
app.connLamp.Layout.Row = 1;
app.connLamp.Layout.Column = 1;
app.debugStatusIcon = uilabel(statusGrid,'Text',devilIcon,'FontName',emojiFont,'FontSize',19,'HorizontalAlignment','center','Visible','off');
app.debugStatusIcon.Layout.Row = 1;
app.debugStatusIcon.Layout.Column = 1;
app.statusLabel = uilabel(statusGrid,'Text','Disconnected','FontWeight','bold');
app.statusLabel.Layout.Row = 1;
app.statusLabel.Layout.Column = 2;
app.connectionDetailLabel = uilabel(statusGrid,'Text','Not connected','FontColor',[0.45 0.49 0.52]);
app.connectionDetailLabel.Layout.Row = 1;
app.connectionDetailLabel.Layout.Column = 4;
leftGrid = uigridlayout(leftShell,[1 1]);
try, leftGrid.BackgroundColor = [1 1 1]; catch, end
app.leftContentGrid = leftGrid;
leftGrid.Layout.Row = 2;
leftGrid.RowHeight = {'1x'};
leftGrid.Padding = [8 8 8 8];
leftGrid.RowSpacing = 8;

controlCallbacks = struct();
controlCallbacks.connectSMU = @connectSMU;
controlCallbacks.disconnectSMU = @disconnectSMU;
controlCallbacks.modeChanged = @modeChanged;
controlCallbacks.measureTypeChanged = @measureTypeChanged;
controlCallbacks.deviceNameChanged = @deviceNameChanged;
controlCallbacks.rangeModeChanged = @rangeModeChanged;
controlCallbacks.commentChanged = @commentChanged;
controlCallbacks.updateEstimate = @(~,~)updateEstimate();
controlCallbacks.sweepTypeChanged = @sweepTypeChanged;
controlCallbacks.addAdaptiveRule = @addAdaptiveRule;
controlCallbacks.deleteAdaptiveRule = @deleteAdaptiveRule;
controlCallbacks.validateAdaptiveRule = @validateAdaptiveRuleButton;
controlCallbacks.chooseExportFolder = @chooseExportFolder;
controlCallbacks.loadPreset = @loadPresetButton;
controlCallbacks.savePreset = @savePresetButton;
controlCallbacks.deletePreset = @deletePresetButton;
controlCallbacks.toggleDebugMode = @toggleDebugMode;
controlCallbacks.loadAboutText = @loadAboutText;
controlCallbacks.startSweep = @startSweep;
controlCallbacks.abortSweep = @abortSweep;
controlCallbacks.togglePause = @togglePause;
controlCallbacks.checkUpdate = @checkUpdate;
controlCallbacks.fontScaleChanged = @fontScaleChanged;
controlCallbacks.themeChanged = @themeChanged;
controlCallbacks.developerLogChanged = @developerLogChanged;
app = ui.ControlsPanel.build(app,leftGrid,helpMark,devilIcon,emojiFont,controlCallbacks);

%% Middle panel: embedded plots
plotCallbacks = struct();
plotCallbacks.applyAllPlotArrangement = @(~,~)applyAllPlotArrangement();
plotCallbacks.openAll = @(~,~)openPlotWindow('all');
plotCallbacks.openLinear = @(~,~)openPlotWindow('linear');
plotCallbacks.openLog = @(~,~)openPlotWindow('log');
plotCallbacks.openResistance = @(~,~)openPlotWindow('resistance');
plotCallbacks.openCurrent = @(~,~)openCurrentPlotWindow();
app = ui.PlotPanel.build(app,root,plotCallbacks);
linkPlotAxes();
applyAllPlotArrangement();

%% Right panel: device list
deviceCallbacks = struct();
deviceCallbacks.deviceTableEdited = @deviceTableEdited;
deviceCallbacks.saveSelectedDevice = @saveSelectedDevice;
deviceCallbacks.deleteSelectedDevice = @deleteSelectedDevice;
deviceCallbacks.refreshPlots = @(~,~)refreshPlots();
deviceCallbacks.importDataFile = @importDataFile;
deviceCallbacks.saveAllDevices = @saveAllDevices;
deviceCallbacks.clearAllDevices = @clearAllDevices;
deviceCallbacks.refreshRecoveryPanel = @refreshRecoveryPanel;
deviceCallbacks.importSelectedRecovery = @importSelectedRecovery;
deviceCallbacks.openCacheFolder = @openCacheFolder;
app = ui.DevicesPanel.build(app,root,helpMark,deviceCallbacks);

%% Bottom status bar
app = ui.StatusBarPanel.build(app,root,devilIcon,emojiFont);

data.DataManager.ensureFolder(app.cacheFolder);
app.cacheLogFile = fullfile(app.cacheFolder,'session_log_current.txt');
logMsg('Session started.','info');

ui.Tooltips.apply(app);
ui.Theme.apply(app);

applyResponsiveLayout();
app.layoutTimer = timer('ExecutionMode','fixedSpacing','Period',0.5,'TimerFcn',@(~,~)applyResponsiveLayout());
start(app.layoutTimer);
modeChanged();
ui.Theme.apply(app);
refreshPresetList();
refreshRecoveryPanel();
updateControlStates();

drawnow;
try
    applyResponsiveLayout();
    ui.Theme.apply(app);
    drawnow;
    app.fig.Visible = 'on';
    figure(app.fig);
catch
    try
        app.fig.Visible = 'on';
    catch
    end
end

%% ---------------- Nested callbacks ----------------

    function modeChanged(src,event)
        if nargin < 1
            src = [];
        end
        if nargin < 2
            event = [];
        end
        if nargin >= 2 && ~isempty(event) && isprop(event,'PreviousValue')
            previousValue = event.PreviousValue;
        else
            previousValue = app.lastSourceMode;
        end
        if ~confirmParameterSwitch(src,previousValue,'source mode')
            return;
        end
        app.lastSourceMode = app.modeDrop.Value;

        if startsWith(app.modeDrop.Value,'Voltage')
            app.startLabel.Text = ['Start V' helpMark];
            app.stopLabel.Text  = ['Stop V' helpMark];
            app.stepLabel.Text  = ['Step V' helpMark];
            app.compLabel.Text  = ['Compliance A' helpMark];
            app.rangeValueLabel.Text = ['Current Range A' helpMark];
            app.fixedSourceLabel.Text = ['Fixed Source V' helpMark];
            app.adaptiveLabel.Text = ['Adaptive abs(source) rules (V)' helpMark];
            title(app.axLin,'Linear I-V');
            title(app.axLog,'Log |I|-V');
            title(app.axLinAll,'Linear I-V');
            title(app.axLogAll,'Log |I|-V');
        else
            app.startLabel.Text = ['Start I (A)' helpMark];
            app.stopLabel.Text  = ['Stop I (A)' helpMark];
            app.stepLabel.Text  = ['Step I (A)' helpMark];
            app.compLabel.Text  = ['Voltage Limit V' helpMark];
            app.rangeValueLabel.Text = ['Voltage Range V' helpMark];
            app.fixedSourceLabel.Text = ['Fixed Source A' helpMark];
            app.adaptiveLabel.Text = ['Adaptive abs(source) rules (A)' helpMark];
            title(app.axLin,'Linear V-I');
            title(app.axLog,'Log |V|-I');
            title(app.axLinAll,'Linear V-I');
            title(app.axLogAll,'Log |V|-I');
        end
        measureTypeChanged();
        rangeModeChanged();
        sweepTypeChanged();
        updateEstimate();
    end

    function measureTypeChanged(src,event)
        if nargin < 1
            src = [];
        end
        if nargin < 2
            event = [];
        end
        if nargin >= 2 && ~isempty(event) && isprop(event,'PreviousValue')
            previousValue = event.PreviousValue;
        else
            previousValue = app.lastMeasureType;
        end
        if ~confirmParameterSwitch(src,previousValue,'measurement type')
            return;
        end
        app.lastMeasureType = app.measureTypeDrop.Value;

        isTimeTrace = strcmp(app.measureTypeDrop.Value,'Time Trace');
        sweepState = ui.UiState.onOff(~isTimeTrace);
        timeState = ui.UiState.onOff(isTimeTrace);
        app.startLabel.Visible = sweepState;
        app.startEdit.Visible = sweepState;
        app.stopLabel.Visible = sweepState;
        app.stopEdit.Visible = sweepState;
        app.stepLabel.Visible = sweepState;
        app.stepEdit.Visible = sweepState;
        app.sweepLabel.Visible = sweepState;
        app.sweepDrop.Visible = sweepState;
        app.directionLabel.Visible = sweepState;
        app.directionDrop.Visible = sweepState;
        app.fixedSourceLabel.Visible = timeState;
        app.fixedSourceEdit.Visible = timeState;
        app.durationLabel.Visible = timeState;
        app.durationEdit.Visible = timeState;
        app.intervalLabel.Visible = timeState;
        app.intervalEdit.Visible = timeState;
        adaptiveState = ui.UiState.onOff(~isTimeTrace && strcmp(app.sweepDrop.Value,'Adaptive'));
        app.adaptiveLabel.Visible = adaptiveState;
        app.adaptiveTable.Visible = adaptiveState;
        app.addRuleBtn.Visible = adaptiveState;
        app.deleteRuleBtn.Visible = adaptiveState;
        app.validateRuleBtn.Visible = adaptiveState;
        rows = app.measureGridBaseRowHeight;
        if isTimeTrace
            for row = 4:8
                rows{row} = 0;
            end
            for row = 9:11
                rows{row} = 32;
            end
            rows{18} = 0;
            rows{19} = 0;
            rows{20} = 0;
        else
            for row = 4:8
                rows{row} = 32;
            end
            for row = 9:11
                rows{row} = 0;
            end
            if strcmp(app.sweepDrop.Value,'Adaptive')
                rows{18} = 24;
                rows{19} = 132;
                rows{20} = 34;
            else
                rows{18} = 0;
                rows{19} = 0;
                rows{20} = 0;
            end
        end
        app.measureGrid.RowHeight = rows;
        adjustMeasureScrollHeight();
        updateEstimate();
        updateControlStates();
    end

    function adjustMeasureScrollHeight()
        try
            rows = app.measureGrid.RowHeight;
            total = 0;
            for rr = 1:numel(rows)
                item = rows{rr};
                if isnumeric(item)
                    total = total + item;
                elseif ischar(item) || isstring(item)
                    if strcmp(char(string(item)),'1x')
                        total = total + 120;
                    else
                        v = str2double(char(string(item)));
                        if ~isnan(v)
                            total = total + v;
                        end
                    end
                end
            end
            total = total + app.measureGrid.Padding(2) + app.measureGrid.Padding(4) + app.measureGrid.RowSpacing * (numel(rows)-1) + 20;
            holder = app.measureGrid.Parent;
            page = holder.Parent;
            pos = holder.Position;
            pagePos = page.Position;
            pos(4) = max(pagePos(4),total);
            holder.Position = pos;
        catch
        end
    end

    function ok = confirmParameterSwitch(src,previousValue,whatChanged)
        ok = true;
        if isempty(app.devices) || app.isSweeping || isempty(src) || ~isvalid(src)
            return;
        end
        try
            currentValue = src.Value;
        catch
            return;
        end
        if strcmp(char(string(currentValue)),char(string(previousValue)))
            return;
        end

        choice = uiconfirm(app.fig, ...
            sprintf('Changing %s will clear the current stored measurements to avoid mixing incompatible data. Save or clear the existing data before switching.',whatChanged), ...
            'Stored Data Exists', ...
            'Options',{'Save All + Clear + Switch','Clear + Switch','Cancel'}, ...
            'DefaultOption','Save All + Clear + Switch', ...
            'CancelOption','Cancel', ...
            'Icon','warning');

        switch choice
            case 'Save All + Clear + Switch'
                saveAllDevices();
                app = ui.DeviceWorkflow.clearAll(app);
                updateDeviceTable();
                resetDefaultPlots();
                logMsg(sprintf('Saved and cleared stored data before changing %s.',whatChanged));
            case 'Clear + Switch'
                app = ui.DeviceWorkflow.clearAll(app);
                updateDeviceTable();
                resetDefaultPlots();
                logMsg(sprintf('Cleared stored data before changing %s.',whatChanged));
            otherwise
                src.Value = previousValue;
                ok = false;
        end
        updateControlStates();
    end

    function rangeModeChanged(~,~)
        if strcmp(app.rangeModeDrop.Value,'Auto range') || app.isSweeping
            app.rangeValueEdit.Enable = 'off';
        else
            app.rangeValueEdit.Enable = 'on';
        end
    end

    function sweepTypeChanged(~,~)
        useAdaptive = strcmp(app.sweepDrop.Value,'Adaptive');
        isTimeTrace = strcmp(app.measureTypeDrop.Value,'Time Trace');
        app.stepEdit.Enable = ui.UiState.onOff(~useAdaptive && ~isTimeTrace && ~app.isSweeping);

        adaptiveState = ui.UiState.onOff(useAdaptive && ~isTimeTrace);
        app.adaptiveLabel.Visible = adaptiveState;
        app.adaptiveTable.Visible = adaptiveState;
        app.addRuleBtn.Visible = adaptiveState;
        app.deleteRuleBtn.Visible = adaptiveState;
        app.validateRuleBtn.Visible = adaptiveState;

        rows = app.measureGrid.RowHeight;
        if useAdaptive && ~isTimeTrace
            rows{18} = 24;
            rows{19} = 132;
            rows{20} = 34;
        else
            rows{18} = 0;
            rows{19} = 0;
            rows{20} = 0;
        end
        app.measureGrid.RowHeight = rows;
        adjustMeasureScrollHeight();
        updateEstimate();
        updateControlStates();
    end

    function fontScaleChanged(src,~)
        [app,logLine] = ui.AppUiWorkflow.applyFontScale(app,src.Value);
        updateControlStates();
        logMsg(logLine);
    end


    function themeChanged(src,~)
        [app,runState,logLine] = ui.AppUiWorkflow.applyTheme(app,src.Value);
        setRunState(runState);
        updateControlStates();
        logMsg(logLine);
    end

    function developerLogChanged(src,~)
        app.developerLog = logical(src.Value);
        if app.developerLog
            logMsg('Developer log enabled.');
        else
            logMsg('Developer log disabled. Routine details will be hidden.','info');
        end
    end

    function chooseExportFolder(~,~)
        [app,selected,logLine] = ui.AppUiWorkflow.chooseExportFolder(app);
        if selected
            logMsg(logLine);
        end
    end

    function commentChanged(src,~)
        src.Value = data.CommentUtil.sanitize(src.Value);
    end

    function deviceNameChanged(src,~)
        src.Value = data.CommentUtil.sanitizeDeviceName(src.Value);
    end

    function lines = loadAboutText()
        lines = ui.AppUiWorkflow.loadAboutText(app.aboutFile);
    end

    function refreshPresetList()
        app = ui.PresetWorkflow.refreshList(app);
    end

    function savePresetButton(~,~)
        [app,name] = ui.PresetWorkflow.saveCurrent(app);
        logMsg(['Saved preset: ' name]);
    end

    function loadPresetButton(~,~)
        [app,name,found] = ui.PresetWorkflow.loadSelected(app);
        if ~found
            uialert(app.fig,'Selected preset was not found.','Preset Missing');
            return;
        end
        modeChanged();
        updateEstimate();
        updateControlStates();
        logMsg(['Loaded preset: ' name]);
    end

    function checkUpdate(~,~)
        url = app.info.ReleaseURL;
        [ok,logLine,~] = ui.AppUiWorkflow.openReleasePage(url);
        if ok
            logMsg(logLine);
        else
            logMsg(logLine,'error');
            uialert(app.fig,url,'Release URL');
        end
    end

    function deletePresetButton(~,~)
        [app,name,~,isDefault] = ui.PresetWorkflow.deleteSelected(app);
        if isDefault
            uialert(app.fig,'Default preset cannot be deleted.','Preset');
            return;
        end
        logMsg(['Deleted preset: ' name]);
    end

    function addAdaptiveRule(~,~)
        [app,changed] = ui.AdaptiveRuleWorkflow.addRule(app);
        if changed
            updateEstimate();
        end
    end

    function deleteAdaptiveRule(~,~)
        [app,changed,message] = ui.AdaptiveRuleWorkflow.deleteSelectedRule(app);
        if ~isempty(message)
            uialert(app.fig,message,'No Rule Selected');
            return;
        end
        if changed
            updateEstimate();
        end
    end

    function validateAdaptiveRuleButton(~,~)
        [ok,message] = ui.AdaptiveRuleWorkflow.validateRules(app);
        if ok
            uialert(app.fig,message,'Adaptive Rules OK','Icon','info');
            logMsg('Adaptive rules validated successfully.');
        else
            uialert(app.fig,message,'Adaptive Rule Problem');
            logMsg(['Adaptive rule validation failed: ' message]);
        end
    end

    function connectSMU(~,~)
        [app,result] = ui.ConnectionWorkflow.connect(app);
        if ~isempty(result.statusMsg)
            setStatus(result.statusMsg,result.statusState);
        end
        if ~isempty(result.detail)
            setConnectionDetail(result.detail);
        end
        setRunState(result.runState);
        for logIdx = 1:numel(result.logLines)
            logMsg(result.logLines{logIdx});
        end
        if ~isempty(result.errorMessage)
            uialert(app.fig,result.errorMessage,'Connection Error');
        end
        updateControlStates();
    end

    function disconnectSMU(~,~)
        if ~confirmDisconnectAndMaybeSave()
            return;
        end
        [app,statusMsg,statusState,logLine] = ui.ConnectionWorkflow.disconnect(app);
        if ~isempty(app.devices)
            app = ui.DeviceWorkflow.clearAll(app);
            updateDeviceTable();
            resetDefaultPlots();
            logMsg('Stored device list cleared after disconnect.');
        end
        setStatus(statusMsg,statusState);
        setConnectionDetail('Not connected');
        setRunState('Stopped');
        logMsg(logLine);
        updateControlStates();
    end

    function ok = confirmDisconnectAndMaybeSave()
        ok = true;
        if isempty(app.devices)
            return;
        end

        choice = uiconfirm(app.fig, ...
            ['Disconnect will clear the current stored device list to avoid mixing data from different connection settings. ' ...
            'Autosave files are already in the cache, but Save All is recommended before disconnecting.'], ...
            'Save Before Disconnect?', ...
            'Options',{'Save All First','Disconnect and Clear','Cancel'}, ...
            'DefaultOption','Save All First', ...
            'CancelOption','Cancel', ...
            'Icon','warning');

        switch choice
            case 'Save All First'
                saveAllDevices();
                ok = false;
            case 'Disconnect and Clear'
                ok = true;
            otherwise
                ok = false;
        end
    end

    function startSweep(~,~)
        if ~app.connected || (~app.debugMode && isempty(app.smu))
            uialert(app.fig,'Connect to the Keithley first.','Not Connected');
            return;
        end

        app = ui.SweepWorkflow.begin(app,helpMark);
        runOutcome = 'running';
        setRunState('Sweeping');
        setRunFlag('abort',false);
        setRunFlag('pause',false);
        updateControlStates();

        try
            [app,plan,timing,logLines] = ui.SweepWorkflow.prepare(app,ui.SweepMetadataWorkflow.context(app));
            devName = plan.devName;
            X = plan.X;
            mode = plan.mode;
            sweepName = plan.sweepName;
            compliance = timing.compliance;
            nplc = timing.nplc;
            settleT = timing.settleT;
            rangeMode = timing.rangeMode;
            rangeValue = timing.rangeValue;
            for logIdx = 1:numel(logLines)
                logMsg(logLines{logIdx});
            end
            runStartTic = tic;
            runStartStamp = datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');
            estimatedText = core.SweepMath.estimateSweepTimeText(numel(X),nplc,settleT);
            logMsg(sprintf('Actual run started at %s. Estimate basis: measurement=%s, mode=%s, points=%d, NPLC=%.4g, delay=%.4g s, range=%s %.4g, assumed line=50 Hz, overhead=0.15 s/point -> %s.', ...
                runStartStamp,plan.measurementType,mode,numel(X),nplc,settleT,rangeMode,rangeValue,estimatedText));

            if app.debugMode
                setStatus('Debug sweep','debug');
                [Y,raw] = runDebugSweepLive(mode,X,compliance,nplc,settleT,devName,plan,rangeMode,rangeValue);
            else
                setStatus('Sweeping...','busy');
                [Y,raw] = runSourceSweepLive(mode,X,compliance,nplc,settleT,devName,plan.senseMode,rangeMode,rangeValue,plan);
            end

            if isRunAbortRequested()
                app.abortRequested = true;
                actualElapsedS = toc(runStartTic);
                logMsg(sprintf('Sweep aborted: %s. Actual elapsed time before abort: %.3f s. Original estimate: %s.',devName,actualElapsedS,estimatedText));
                autosaveFinalDevice(devName,mode,sweepName,X,Y,raw,compliance,nplc,settleT,'aborted');
                setStatusAfterSweep('aborted');
                runOutcome = 'aborted';
            else
                app = ui.SweepWorkflow.addCompletedDevice(app,plan,Y,raw,createSweepMeta(devName,mode,sweepName,X,compliance,nplc,settleT,Y));

                updateDeviceTable();
                refreshPlots();
                autosaveFinalDevice(devName,mode,sweepName,X,Y,raw,compliance,nplc,settleT,'completed');
                setStatusAfterSweep('sweep done');
                runOutcome = 'completed';
                actualElapsedS = toc(runStartTic);
                logMsg(sprintf('Sweep finished: %s. Actual elapsed time: %.3f s. Original estimate: %s.',devName,actualElapsedS,estimatedText));
            end

        catch ME
            safeOff();
            if app.debugMode
                setStatus('Debug error','debug');
            else
                setStatus('Error / output off','disconnected');
            end
            runOutcome = 'error';
            setRunState('Stopped');
            logMsg(['Sweep error: ' ME.message]);
            uialert(app.fig,ME.message,'Sweep Error');
        end

        app = ui.SweepWorkflow.finish(app,helpMark);
        setRunFlag('pause',false);
        setRunFlag('abort',false);
        refreshRunStateAfterRun(runOutcome);
        sweepTypeChanged();
        updateControlStates();
    end

    function abortSweep(~,~)
        app.abortRequested = true;
        setRunFlag('abort',true);
        safeOff();
        if app.debugMode
            setStatus('Debug abort','debug');
        else
            setStatus('Connected: abort requested','connected');
        end
        setRunState('Stopped');
        logMsg('Abort requested. Output forced OFF.');
    end

    function togglePause(~,~)
        if strcmp(app.pauseBtn.Enable,'off')
            return;
        end
        app.pauseRequested = ~isRunPauseRequested();
        setRunFlag('pause',app.pauseRequested);
        if app.pauseRequested
            app.pauseBtn.Text = [char(9654) '  Resume' helpMark];
            setRunState('Paused');
            setStatus('Paused after point','busy');
            logMsg('Pause requested. Sweep will hold at the current source until Resume.');
        else
            app.pauseBtn.Text = [char(9208) '  Pause' helpMark];
            setRunState('Sweeping');
            if app.debugMode
                setStatus('Debug sweep','debug');
            else
                setStatus('Sweeping...','busy');
            end
            logMsg('Sweep resumed.');
        end
    end

    function toggleDebugMode(~,~)
        try
            [app,statusMsg,statusState,logLine] = ui.ConnectionWorkflow.toggleDebugMode(app,devilIcon,helpMark);
        catch ME
            uialert(app.fig,ME.message,'Debug Mode');
            return;
        end
        setStatus(statusMsg,statusState);
        if app.connected
            setRunState('Ready');
        else
            setRunState('Stopped');
        end
        logMsg(logLine);
        updateControlStates();
    end


    function refreshRunStateAfterRun(runOutcome)
        % Keep the bottom status bar consistent after the runner returns.
        % Successful completion means the instrument/debug connection is idle and
        % ready for another run; abort/error/disconnect mean stopped.
        if nargin < 1 || isempty(runOutcome)
            runOutcome = 'unknown';
        end
        switch lower(char(string(runOutcome)))
            case 'completed'
                if app.connected
                    setRunState('Ready');
                else
                    setRunState('Stopped');
                end
            otherwise
                setRunState('Stopped');
        end
    end

    function setStatusAfterSweep(detail)
        [msg,state] = ui.SweepWorkflow.statusAfterSweep(app,detail);
        setStatus(msg,state);
    end

    function [Y,raw] = runSourceSweepLive(mode,X,compliance,nplc,settleT,devName,senseMode,rangeMode,rangeValue,plan)
        callbacks = sweepRunnerCallbacks(devName,mode,compliance,nplc,settleT);
        if strcmp(plan.measurementType,'Time Trace')
            [Y,raw] = core.SweepRunner.runHardwareTimeTrace(app.smu,app,mode,X,plan.fixedSource,compliance,nplc,settleT,devName,senseMode,rangeMode,rangeValue,callbacks);
        else
            [Y,raw] = core.SweepRunner.runHardware(app.smu,app,mode,X,compliance,nplc,settleT,devName,senseMode,rangeMode,rangeValue,callbacks);
        end
    end

    function [Y,raw] = runDebugSweepLive(mode,X,compliance,nplc,settleT,devName,plan,rangeMode,rangeValue)
        profileChoice = ui.SweepWorkflow.debugProfileChoice(app);
        callbacks = sweepRunnerCallbacks(devName,mode,compliance,nplc,settleT);
        if strcmp(plan.measurementType,'Time Trace')
            [Y,raw] = core.SweepRunner.runDebugTimeTrace(app,mode,X,plan.fixedSource,compliance,nplc,settleT,devName,profileChoice,callbacks,rangeMode,rangeValue);
        else
            [Y,raw] = core.SweepRunner.runDebug(app,mode,X,compliance,nplc,settleT,devName,profileChoice,callbacks,rangeMode,rangeValue);
        end
    end

    function callbacks = sweepRunnerCallbacks(devName,mode,compliance,nplc,settleT)
        callbacks = struct();
        callbacks.log = @logMsg;
        callbacks.setStatus = @setStatus;
        callbacks.isAbort = @()isRunAbortRequested();
        callbacks.isPaused = @()isRunPauseRequested();
        callbacks.autosave = @(sweepName,x,y,r,k,statusText)autosaveSnapshotIfEnabled(devName,mode,sweepName,x,y,r,k,compliance,nplc,settleT,statusText);
    end

    function autosaveSnapshotIfEnabled(devName,mode,sweepName,X,Y,raw,k,compliance,nplc,settleT,statusText)
        if ~isempty(app.currentAutosaveFile)
            core.SweepAutosave.writeSnapshot(app.currentAutosaveFile,devName,mode,sweepName,X,Y,raw,k,compliance,nplc,settleT,statusText,ui.SweepMetadataWorkflow.context(app),app.exportModeDrop.Value);
        end
    end

    function deviceTableEdited(~,event)
        [app,refreshTable,refreshPlot,logLine] = ui.DeviceDataController.tableEdited(app,event);
        if refreshTable
            updateDeviceTable();
        end
        if refreshPlot
            refreshPlots();
        end
        if ~isempty(logLine)
            logMsg(logLine);
        end
    end

    function updateDeviceTable()
        app.devTable.Data = ui.DeviceWorkflow.tableRows(app);
        ui.DevicesPanel.updateEmptyState(app);
        updateControlStates();
    end

    function refreshPlots()
        ui.PlotWorkflow.refresh(app);
    end

    function deleteSelectedDevice(~,~)
        [app,ok,message,logLine] = ui.DeviceDataController.deleteSelected(app);
        if ~ok
            uialert(app.fig,message,'No Device Selected');
            return;
        end
        updateDeviceTable();
        refreshPlots();
        logMsg(logLine);
    end

    function saveSelectedDevice(~,~)
        [app,ok,message,logLine] = ui.DeviceDataController.saveSelected(app);
        if ~ok
            uialert(app.fig,message,'No Device Selected');
            return;
        end
        if ~isempty(logLine)
            logMsg(logLine);
        end
    end

    function importDataFile(~,~)
        [app,ok,message,logLine] = ui.DeviceDataController.chooseAndImport(app);
        if ~ok
            if ~isempty(message)
                uialert(app.fig,message,'Import Error');
                logMsg(logLine);
            end
            return;
        end
        updateDeviceTable();
        refreshPlots();
        updateControlStates();
        logMsg(logLine);
    end

    function refreshRecoveryPanel(~,~)
        app.recoveryTable.Data = ui.RecoveryWorkflow.tableRows(app);
        ui.DevicesPanel.updateEmptyState(app);
        updateControlStates();
    end

    function importSelectedRecovery(~,~)
        [app,ok,message,logLine] = ui.DeviceDataController.importSelectedRecovery(app);
        if ~ok
            if isempty(logLine)
                uialert(app.fig,message,'No Recovery File Selected');
            else
                uialert(app.fig,message,'Recovery Import Error');
                logMsg(logLine);
            end
            return;
        end
        updateDeviceTable();
        refreshPlots();
        updateControlStates();
        logMsg(logLine);
    end

    function openCacheFolder(~,~)
        ui.RecoveryWorkflow.openCacheFolder(app);
        logMsg(['Opened cache folder: ' app.cacheFolder]);
    end

    function saveAllDevices(varargin)
        [app,ok,message,logLine] = ui.DeviceDataController.saveAll(app);
        if ~ok
            uialert(app.fig,message,'Empty');
            return;
        end
        if ~isempty(logLine)
            logMsg(logLine);
        end
    end

    function clearAllDevices(varargin)
        [app,logLine] = ui.DeviceDataController.clearAll(app);
        updateDeviceTable();
        resetDefaultPlots();
        logMsg(logLine);
        updateControlStates();
    end

    function resetDefaultPlots()
        ui.PlotWorkflow.resetDefault(app);
    end

    function updateEstimate()
        if isfield(app,'estimateLabel') && isvalid(app.estimateLabel)
            app.estimateLabel.Text = ui.EstimateWorkflow.textFromControls(app);
        end
    end

    function autosaveFinalDevice(devName,mode,sweepName,X,Y,raw,compliance,nplc,settleT,statusText)
        filename = ui.SweepMetadataWorkflow.autosaveFinalDevice(app,devName,mode,sweepName,X,Y,raw,compliance,nplc,settleT,statusText);
        logMsg(['Autosaved ' statusText ' data: ' filename]);
        refreshRecoveryPanel();
    end

    function meta = createSweepMeta(devName,mode,sweepName,X,compliance,nplc,settleT,Y)
        meta = ui.SweepMetadataWorkflow.create(app,devName,mode,sweepName,X,compliance,nplc,settleT,Y);
    end

    function setRunFlag(kind,value)
        try
            switch kind
                case 'abort'
                    setappdata(app.fig,'KeithIVtAbortRequested',logical(value));
                case 'pause'
                    setappdata(app.fig,'KeithIVtPauseRequested',logical(value));
            end
        catch
        end
    end

    function tf = isRunAbortRequested()
        tf = app.abortRequested;
        try
            if isappdata(app.fig,'KeithIVtAbortRequested')
                tf = logical(getappdata(app.fig,'KeithIVtAbortRequested'));
            end
        catch
        end
    end

    function tf = isRunPauseRequested()
        tf = app.pauseRequested;
        try
            if isappdata(app.fig,'KeithIVtPauseRequested')
                tf = logical(getappdata(app.fig,'KeithIVtPauseRequested'));
            end
        catch
        end
    end

    function safeOff()
        app = ui.ConnectionWorkflow.safeOff(app);
    end

    function label = connectionStatusLabel()
        label = ui.RunStateView.connectionLabel(app);
    end

    function model = instrumentModelText()
        model = ui.RunStateView.instrumentModel(app);
    end

    function setRunState(stateText)
        ui.RunStateView.set(app,stateText);
    end

    function setConnectionDetail(text)
        ui.RunStateView.setConnectionDetail(app,text);
    end

    function onClose(~,~)
        app.abortRequested = true;
        setRunFlag('abort',true);
        safeOff();
        cleanupTimer();
        try
            if ~isempty(app.smu)
                app.smu.disconnect();
            end
        catch
        end
        delete(app.fig);
    end

    function cleanupTimer(varargin)
        try
            if ~isempty(app.layoutTimer) && isvalid(app.layoutTimer)
                stop(app.layoutTimer);
                delete(app.layoutTimer);
            end
            app.layoutTimer = [];
        catch
        end
    end

    function applyResponsiveLayout()
        ui.LayoutManager.apply(app,root);
    end

    function linkPlotAxes()
        ui.PlotWorkflow.linkAxes(app);
    end

    function applyAllPlotArrangement()
        ui.PlotWorkflow.applyAllArrangement(app);
    end

    function openPlotWindow(kind)
        ui.PlotWorkflow.openWindow(app,kind);
    end

    function openCurrentPlotWindow()
        kind = 'linear';
        if isfield(app,'plotPages')
            for k = 1:numel(app.plotPages)
                if strcmp(app.plotPages(k).Visible,'on')
                    kind = app.plotPageKeys{k};
                    break;
                end
            end
        end
        openPlotWindow(kind);
    end

    function logMsg(msg,level)
        if nargin < 2
            level = [];
        end
        try
            if ~ui.AppLog.shouldShow(app.developerLog,msg,level)
                return;
            end
            ui.AppLog.write(app.logText,app.cacheLogFile,app.cacheLogMaxBytes,msg,level);
        catch
        end
    end

    function setStatus(msg,state)
        ui.StatusView.set(app,msg,state);
    end

    function updateControlStates()
        app = ui.ControlStateManager.update(app);
    end

end
