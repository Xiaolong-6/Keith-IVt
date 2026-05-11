classdef ControlsPanel
    methods(Static)
        function app = build(app,leftGrid,helpMark,devilIcon,emojiFont,callbacks)
            controlScrollPanel = uipanel(leftGrid,'Title','','BorderType','none','BackgroundColor',[1 1 1]);
            controlScrollPanel.Layout.Row = 1;
            controlScrollPanel.Layout.Column = 1;
            controlScrollGrid = uigridlayout(controlScrollPanel,[1 2]);
            try, controlScrollGrid.BackgroundColor = [1 1 1]; catch, end
            controlScrollGrid.RowHeight = {'1x'};
            controlScrollGrid.ColumnWidth = {112,'1x'};
            controlScrollGrid.Padding = [0 0 0 0];
            controlScrollGrid.ColumnSpacing = 0;
            controlScrollGrid.Scrollable = 'off';

            navPanel = uipanel(controlScrollGrid,'Title','','BorderType','none','BackgroundColor',[1 1 1]);
            navPanel.Layout.Row = 1;
            navPanel.Layout.Column = 1;
            navGrid = uigridlayout(navPanel,[7 1]);
            try, navGrid.BackgroundColor = [1 1 1]; catch, end
            navGrid.RowHeight = [{48,48,48,48,48,48},{'1x'}];
            navGrid.ColumnWidth = {'1x'};
            navGrid.Padding = [6 6 6 6];
            navGrid.RowSpacing = 7;
            navGrid.Scrollable = 'off';
            app.controlNavGrid = navGrid;

            pageStack = uipanel(controlScrollGrid,'Title','','BorderType','none','BackgroundColor',[1 1 1]);
            pageStack.Layout.Row = 1;
            pageStack.Layout.Column = 2;

            pageStackGrid = uigridlayout(pageStack,[2 1]);
            try, pageStackGrid.BackgroundColor = [1 1 1]; catch, end
            pageStackGrid.RowHeight = {'1x',210};
            pageStackGrid.ColumnWidth = {'1x'};
            pageStackGrid.Padding = [0 0 0 0];
            pageStackGrid.RowSpacing = 8;
            app.controlPageStack = pageStack;
            app.controlPageStackGrid = pageStackGrid;

            pageGrid = uigridlayout(pageStackGrid,[1 1]);
            try, pageGrid.BackgroundColor = [1 1 1]; catch, end
            pageGrid.Layout.Row = 1;
            pageGrid.Layout.Column = 1;
            pageGrid.RowHeight = {'1x'};
            pageGrid.ColumnWidth = {'1x'};
            pageGrid.Padding = [0 0 0 0];

            tabNames = {'Setup','Measure','Export','Presets','Log','About'};
            tabIcons = {char(9881),char(8767),char(8679),char(9734),char(9776),char(9432)};
            buttons = gobjects(1,numel(tabNames));
            pages = gobjects(1,numel(tabNames));
            for k = 1:numel(tabNames)
                buttons(k) = uibutton(navGrid,'push', ...
                    'Text',[tabIcons{k} '  ' tabNames{k}], ...
                    'FontSize',14, ...
                    'FontName',ui.Theme.fonts().ui, ...
                    'HorizontalAlignment','left');
                buttons(k).Layout.Row = k;
                pages(k) = uipanel(pageGrid,'Title','','Visible','off','BorderType','none','BackgroundColor',[1 1 1]);
                pages(k).AutoResizeChildren = 'off';
                pages(k).Scrollable = 'on';
                pages(k).Layout.Row = 1;
                pages(k).Layout.Column = 1;
            end
            app.controlTabButtons = buttons;
            app.controlPages = pages;
            for k = 1:numel(tabNames)
                buttons(k).ButtonPushedFcn = @(~,~)ui.ControlsPanel.selectControlPage(buttons,pages,k);
            end

            actionShell = uipanel(pageStackGrid,'Title','','BorderType','none','BackgroundColor',[1 1 1]);
            actionShell.Layout.Row = 2;
            actionShell.Layout.Column = 1;
            app.actionShell = actionShell;

            app = ui.ControlsPanel.addSetupTab(app,pages(1),helpMark,callbacks);
            app = ui.ControlsPanel.addMeasureTab(app,pages(2),helpMark,callbacks);
            app = ui.ControlsPanel.addActionButtons(app,actionShell,helpMark,callbacks);
            app = ui.ControlsPanel.addExportTab(app,pages(3),helpMark,callbacks);
            app = ui.ControlsPanel.addPresetTab(app,pages(4),helpMark,callbacks);
            app = ui.ControlsPanel.addLogTab(app,pages(5));
            app = ui.ControlsPanel.addAboutTab(app,pages(6),helpMark,devilIcon,emojiFont,callbacks);
            ui.ControlsPanel.selectControlPage(buttons,pages,1);
        end

        function selectControlPage(buttons,pages,index)
            for k = 1:numel(pages)
                pages(k).Visible = ui.UiState.onOff(k == index);
            end
            ui.Theme.selectNavigation(buttons,index);
            drawnow;
        end

        function app = addSetupTab(app,setupTab,helpMark,callbacks)
            setupGrid = ui.ControlsPanel.scrollPageGrid(setupTab,[5 2],225);
            setupGrid.RowHeight = repmat({32},1,5);
            setupGrid.ColumnWidth = {115,'1x'};
            setupGrid.Padding = [10 10 10 10];

            app.portLabel = uilabel(setupGrid,'Text',['COM Port' helpMark]);
            app.portEdit = uieditfield(setupGrid,'text','Value','COM3');
            app.baudLabel = uilabel(setupGrid,'Text',['Baud' helpMark]);
            app.baudEdit = uieditfield(setupGrid,'numeric','Value',9600,'Limits',[1 Inf]);
            app.termLabel = uilabel(setupGrid,'Text',['Terminal' helpMark]);
            app.termDrop = uidropdown(setupGrid,'Items',{'REAR','FRONT'},'Value','REAR');
            app.senseLabel = uilabel(setupGrid,'Text',['Sense Mode' helpMark]);
            app.senseLabel.Layout.Row = 4;
            app.senseLabel.Layout.Column = 1;
            app.senseDrop = uidropdown(setupGrid,'Items',{'2-wire','4-wire'},'Value','2-wire');
            app.senseDrop.Layout.Row = 4;
            app.senseDrop.Layout.Column = 2;

            app.connectBtn = uibutton(setupGrid,'push','Text',['Connect' helpMark],'ButtonPushedFcn',callbacks.connectSMU);
            app.connectBtn.Tag = 'connectBtn';
            app.connectBtn.Layout.Row = 5;
            app.connectBtn.Layout.Column = 1;
            app.disconnectBtn = uibutton(setupGrid,'push','Text',['Disconnect' helpMark],'ButtonPushedFcn',callbacks.disconnectSMU);
            app.disconnectBtn.Tag = 'disconnectBtn';
            app.disconnectBtn.Layout.Row = 5;
            app.disconnectBtn.Layout.Column = 2;
        end

        function app = addMeasureTab(app,measureTab,helpMark,callbacks)
            measureGrid = ui.ControlsPanel.scrollPageGrid(measureTab,[28 2],980,185);
            measureGrid.RowHeight = [{26},repmat({32},1,10),{26},repmat({32},1,5),{26,132,32,'1x',28,0,0,0,0,0,0}];
            measureGrid.ColumnWidth = {92,'1x'};
            measureGrid.Padding = [6 8 6 8];
            measureGrid.RowSpacing = 5;
            app.sweepGrid = measureGrid;
            app.measureGrid = measureGrid;
            app.measureGridBaseRowHeight = measureGrid.RowHeight;

            sweepHeader = uilabel(measureGrid,'Text','Sweep Parameters','FontWeight','bold');
            sweepHeader.Layout.Row = 1;
            sweepHeader.Layout.Column = [1 2];
            app.measureTypeLabel = uilabel(measureGrid,'Text',['Type' helpMark]);
            app.measureTypeLabel.Layout.Row = 2;
            app.measureTypeDrop = uidropdown(measureGrid,'Items',{'Sweep','Time Trace'}, ...
                'Value','Sweep','ValueChangedFcn',callbacks.measureTypeChanged);
            app.measureTypeDrop.Tag = 'measureTypeDrop';
            app.measureTypeDrop.Layout.Row = 2;
            app.measureTypeDrop.Layout.Column = 2;
            app.modeLabel = uilabel(measureGrid,'Text',['Source' helpMark]);
            app.modeLabel.Layout.Row = 3;
            app.modeDrop = uidropdown(measureGrid,'Items',{'Voltage source: source V, measure I','Current source: source I, measure V'}, ...
                'Value','Voltage source: source V, measure I','ValueChangedFcn',callbacks.modeChanged);
            app.modeDrop.Layout.Row = 3;
            app.modeDrop.Layout.Column = 2;
            app.startLabel = uilabel(measureGrid,'Text',['Start V' helpMark]);
            app.startLabel.Layout.Row = 4;
            app.startEdit = uieditfield(measureGrid,'numeric','Value',-5,'ValueChangedFcn',callbacks.updateEstimate);
            app.startEdit.Tag = 'startEdit';
            app.startEdit.Layout.Row = 4;
            app.startEdit.Layout.Column = 2;
            app.stopLabel = uilabel(measureGrid,'Text',['Stop V' helpMark]);
            app.stopLabel.Layout.Row = 5;
            app.stopEdit = uieditfield(measureGrid,'numeric','Value',5,'ValueChangedFcn',callbacks.updateEstimate);
            app.stopEdit.Tag = 'stopEdit';
            app.stopEdit.Layout.Row = 5;
            app.stopEdit.Layout.Column = 2;
            app.stepLabel = uilabel(measureGrid,'Text',['Step V' helpMark]);
            app.stepLabel.Layout.Row = 6;
            app.stepEdit = uieditfield(measureGrid,'numeric','Value',0.1,'ValueChangedFcn',callbacks.updateEstimate);
            app.stepEdit.Tag = 'stepEdit';
            app.stepEdit.Layout.Row = 6;
            app.stepEdit.Layout.Column = 2;
            app.sweepLabel = uilabel(measureGrid,'Text',['Sweep Type' helpMark]);
            app.sweepLabel.Layout.Row = 7;
            app.sweepDrop = uidropdown(measureGrid,'Items',{'Linear','Adaptive'},'Value','Linear','ValueChangedFcn',callbacks.sweepTypeChanged);
            app.sweepDrop.Layout.Row = 7;
            app.sweepDrop.Layout.Column = 2;
            app.directionLabel = uilabel(measureGrid,'Text',['Direction' helpMark]);
            app.directionLabel.Layout.Row = 8;
            app.directionDrop = uidropdown(measureGrid,'Items',{'Forward only','Forward then backward'}, ...
                'Value','Forward only','ValueChangedFcn',callbacks.updateEstimate);
            app.directionDrop.Layout.Row = 8;
            app.directionDrop.Layout.Column = 2;
            app.fixedSourceLabel = uilabel(measureGrid,'Text',['Fixed Source V' helpMark]);
            app.fixedSourceLabel.Layout.Row = 9;
            app.fixedSourceEdit = uieditfield(measureGrid,'numeric','Value',0,'ValueChangedFcn',callbacks.updateEstimate);
            app.fixedSourceEdit.Tag = 'fixedSourceEdit';
            app.fixedSourceEdit.Layout.Row = 9;
            app.fixedSourceEdit.Layout.Column = 2;
            app.durationLabel = uilabel(measureGrid,'Text',['Duration s' helpMark]);
            app.durationLabel.Layout.Row = 10;
            app.durationEdit = uieditfield(measureGrid,'numeric','Value',10,'Limits',[eps Inf],'ValueChangedFcn',callbacks.updateEstimate);
            app.durationEdit.Tag = 'durationEdit';
            app.durationEdit.Layout.Row = 10;
            app.durationEdit.Layout.Column = 2;
            app.intervalLabel = uilabel(measureGrid,'Text',['Interval s' helpMark]);
            app.intervalLabel.Layout.Row = 11;
            app.intervalEdit = uieditfield(measureGrid,'numeric','Value',0.5,'Limits',[eps Inf],'ValueChangedFcn',callbacks.updateEstimate);
            app.intervalEdit.Tag = 'intervalEdit';
            app.intervalEdit.Layout.Row = 11;
            app.intervalEdit.Layout.Column = 2;

            timingHeader = uilabel(measureGrid,'Text','Timing and Range','FontWeight','bold');
            timingHeader.Layout.Row = 12;
            timingHeader.Layout.Column = [1 2];
            app.compLabel = uilabel(measureGrid,'Text',['Compliance A' helpMark]);
            app.compLabel.Layout.Row = 13;
            app.compEdit = uieditfield(measureGrid,'numeric','Value',0.01,'Limits',[eps Inf]);
            app.compEdit.Tag = 'compEdit';
            app.compEdit.Layout.Row = 13;
            app.compEdit.Layout.Column = 2;
            app.nplcLabel = uilabel(measureGrid,'Text',['NPLC' helpMark]);
            app.nplcLabel.Layout.Row = 14;
            app.nplcEdit = uieditfield(measureGrid,'numeric','Value',1.0,'Limits',[0.01 10],'ValueChangedFcn',callbacks.updateEstimate);
            app.nplcEdit.Tag = 'nplcEdit';
            app.nplcEdit.Layout.Row = 14;
            app.nplcEdit.Layout.Column = 2;
            app.delayLabel = uilabel(measureGrid,'Text',['Delay s' helpMark]);
            app.delayLabel.Layout.Row = 15;
            app.delayEdit = uieditfield(measureGrid,'numeric','Value',0.05,'Limits',[0 Inf],'ValueChangedFcn',callbacks.updateEstimate);
            app.delayEdit.Tag = 'delayEdit';
            app.delayEdit.Layout.Row = 15;
            app.delayEdit.Layout.Column = 2;
            app.rangeModeLabel = uilabel(measureGrid,'Text',['Range' helpMark]);
            app.rangeModeLabel.Layout.Row = 16;
            app.rangeModeDrop = uidropdown(measureGrid,'Items',{'Auto range','Fixed measure range'}, ...
                'Value','Auto range','ValueChangedFcn',callbacks.rangeModeChanged);
            app.rangeModeDrop.Layout.Row = 16;
            app.rangeModeDrop.Layout.Column = 2;
            app.rangeValueLabel = uilabel(measureGrid,'Text',['Range A' helpMark]);
            app.rangeValueLabel.Layout.Row = 17;
            app.rangeValueEdit = uieditfield(measureGrid,'numeric','Value',1e-6,'Limits',[eps Inf]);
            app.rangeValueEdit.Tag = 'rangeValueEdit';
            app.rangeValueEdit.Layout.Row = 17;
            app.rangeValueEdit.Layout.Column = 2;

            app.adaptiveLabel = uilabel(measureGrid,'Text',['Adaptive Rules (V)' helpMark],'FontWeight','bold');
            app.adaptiveLabel.Layout.Row = 18;
            app.adaptiveLabel.Layout.Column = [1 2];
            app.adaptiveTable = uitable(measureGrid, ...
                'Data',[100 1 1; 1 0.1 0.1; 0.1 0.01 0.01; 0.01 0.001 0.001], ...
                'ColumnName',{'Abs From','Abs To','Step'}, ...
                'ColumnWidth',{54,54,54}, ...
                'ColumnEditable',[true true true], ...
                'CellEditCallback',callbacks.updateEstimate);
            app.adaptiveTable.Layout.Row = 19;
            app.adaptiveTable.Layout.Column = [1 2];

            adaptiveBtnGrid = uigridlayout(measureGrid,[1 3]);
            adaptiveBtnGrid.Layout.Row = 20;
            adaptiveBtnGrid.Layout.Column = [1 2];
            adaptiveBtnGrid.RowHeight = {30};
            adaptiveBtnGrid.ColumnWidth = {'1x','1x','1x'};
            adaptiveBtnGrid.Padding = [0 0 0 0];
            app.addRuleBtn = uibutton(adaptiveBtnGrid,'push','Text',['Add Rule' helpMark],'ButtonPushedFcn',callbacks.addAdaptiveRule);
            app.deleteRuleBtn = uibutton(adaptiveBtnGrid,'push','Text',['Delete Rule' helpMark],'ButtonPushedFcn',callbacks.deleteAdaptiveRule);
            app.validateRuleBtn = uibutton(adaptiveBtnGrid,'push','Text',['Validate' helpMark],'ButtonPushedFcn',callbacks.validateAdaptiveRule);
        end

        function app = addExportTab(app,exportTab,helpMark,callbacks)
            exportGrid = ui.ControlsPanel.scrollPageGrid(exportTab,[4 2],190);
            exportGrid.RowHeight = repmat({32},1,4);
            exportGrid.ColumnWidth = {115,'1x'};
            exportGrid.Padding = [10 10 10 10];

            app.exportLabel = uilabel(exportGrid,'Text',['Export Folder' helpMark]);
            app.exportLabel.Layout.Row = 1;
            app.exportLabel.Layout.Column = 1;
            app.exportFolderEdit = uieditfield(exportGrid,'text','Value',app.exportFolder);
            app.exportFolderEdit.Layout.Row = 1;
            app.exportFolderEdit.Layout.Column = 2;
            app.exportFolderBtn = uibutton(exportGrid,'push','Text',['Browse' helpMark],'ButtonPushedFcn',callbacks.chooseExportFolder);
            app.exportFolderBtn.Layout.Row = 2;
            app.exportFolderBtn.Layout.Column = [1 2];

            app.exportModeLabel = uilabel(exportGrid,'Text',['Export Type' helpMark]);
            app.exportModeLabel.Layout.Row = 3;
            app.exportModeLabel.Layout.Column = 1;
            app.exportModeDrop = uidropdown(exportGrid,'Items',{'Simple: voltage/current only','Advanced: include calculated columns'}, ...
                'Value','Simple: voltage/current only');
            app.exportModeDrop.Layout.Row = 3;
            app.exportModeDrop.Layout.Column = 2;
        end

        function app = addPresetTab(app,presetTab,helpMark,callbacks)
            presetGrid = ui.ControlsPanel.scrollPageGrid(presetTab,[4 2],190);
            presetGrid.RowHeight = repmat({32},1,4);
            presetGrid.ColumnWidth = {115,'1x'};
            presetGrid.Padding = [10 10 10 10];

            app.presetLabel = uilabel(presetGrid,'Text',['Profile' helpMark]);
            app.presetDrop = uidropdown(presetGrid,'Items',{'Default'},'Value','Default');
            app.loadPresetBtn = uibutton(presetGrid,'push','Text',['Load' helpMark],'ButtonPushedFcn',callbacks.loadPreset);
            app.loadPresetBtn.Layout.Row = 2;
            app.loadPresetBtn.Layout.Column = 1;
            app.savePresetBtn = uibutton(presetGrid,'push','Text',['Save Current' helpMark],'ButtonPushedFcn',callbacks.savePreset);
            app.savePresetBtn.Layout.Row = 2;
            app.savePresetBtn.Layout.Column = 2;
            app.presetNameLabel = uilabel(presetGrid,'Text',['Name' helpMark]);
            app.presetNameLabel.Layout.Row = 3;
            app.presetNameLabel.Layout.Column = 1;
            app.presetNameEdit = uieditfield(presetGrid,'text','Value','MyPreset');
            app.presetNameEdit.Layout.Row = 3;
            app.presetNameEdit.Layout.Column = 2;
            app.deletePresetBtn = uibutton(presetGrid,'push','Text',['Delete' helpMark],'ButtonPushedFcn',callbacks.deletePreset);
            app.deletePresetBtn.Layout.Row = 4;
            app.deletePresetBtn.Layout.Column = [1 2];
        end

        function app = addLogTab(app,logTab)
            logGrid = ui.ControlsPanel.scrollPageGrid(logTab,[1 1],300);
            logGrid.RowHeight = {'1x'};
            logGrid.ColumnWidth = {'1x'};
            logGrid.Padding = [10 10 10 10];
            app.logText = uitextarea(logGrid,'Editable','off','Value',cell(0,1));
            app.logText.Layout.Row = 1;
            app.logText.Layout.Column = 1;
        end

        function app = addAboutTab(app,aboutTab,helpMark,devilIcon,emojiFont,callbacks)
            aboutGrid = ui.ControlsPanel.scrollPageGrid(aboutTab,[7 2],390);
            aboutGrid.RowHeight = {34,32,32,32,32,10,'1x'};
            aboutGrid.ColumnWidth = {115,'1x'};
            aboutGrid.Padding = [10 10 10 10];
            aboutGrid.RowSpacing = 6;

            app.debugModeBtn = uibutton(aboutGrid,'push','Text',[devilIcon ' Enable Debug Mode ' devilIcon helpMark], ...
                'FontName',emojiFont,'ButtonPushedFcn',callbacks.toggleDebugMode);
            app.debugModeBtn.Tag = 'debugModeBtn';
            app.debugModeBtn.Layout.Row = 1;
            app.debugModeBtn.Layout.Column = [1 2];

            app.checkUpdateBtn = uibutton(aboutGrid,'push','Text',['Check Update' helpMark], ...
                'ButtonPushedFcn',callbacks.checkUpdate);
            app.checkUpdateBtn.Tag = 'checkUpdateBtn';
            app.checkUpdateBtn.Layout.Row = 2;
            app.checkUpdateBtn.Layout.Column = [1 2];

            app.fontSizeLabel = uilabel(aboutGrid,'Text',['UI Font Size' helpMark]);
            app.fontSizeLabel.Layout.Row = 3;
            app.fontSizeLabel.Layout.Column = 1;
            app.fontSizeDrop = uidropdown(aboutGrid,'Items',{'Compact','Normal','Large','Extra large'}, ...
                'Value','Normal','ValueChangedFcn',callbacks.fontScaleChanged);
            app.fontSizeDrop.Layout.Row = 3;
            app.fontSizeDrop.Layout.Column = 2;

            app.themeLabel = uilabel(aboutGrid,'Text',['Theme' helpMark]);
            app.themeLabel.Layout.Row = 4;
            app.themeLabel.Layout.Column = 1;
            app.themeDrop = uidropdown(aboutGrid,'Items',{'Light','Dark'}, ...
                'Value','Light','ValueChangedFcn',callbacks.themeChanged);
            app.themeDrop.Layout.Row = 4;
            app.themeDrop.Layout.Column = 2;

            app.developerLogCheck = uicheckbox(aboutGrid,'Text',['Developer Log' helpMark], ...
                'Value',true,'ValueChangedFcn',callbacks.developerLogChanged);
            app.developerLogCheck.Layout.Row = 5;
            app.developerLogCheck.Layout.Column = [1 2];

            app.aboutViewPanel = ui.AboutView.build(aboutGrid,callbacks.loadAboutText());
            app.aboutViewPanel.Layout.Row = 7;
            app.aboutViewPanel.Layout.Column = [1 2];
        end

        function app = addActionButtons(app,parentPanel,helpMark,callbacks)
            actionGrid = uigridlayout(parentPanel,[6 3]);
            app.actionGrid = actionGrid;
            try, actionGrid.BackgroundColor = [1 1 1]; catch, end
            actionGrid.RowHeight = {0,32,32,38,44,0};
            actionGrid.ColumnWidth = {92,'1x',124};
            actionGrid.Padding = [0 4 0 8];
            actionGrid.RowSpacing = 6;
            actionGrid.ColumnSpacing = 8;

            app.debugProfileLabel = uilabel(actionGrid,'Text',['Debug Device' helpMark], ...
                'Visible','off', ...
                'FontWeight','bold', ...
                'FontColor',[0.65 0.28 0.02], ...
                'BackgroundColor',[1 1 1]);
            app.debugProfileLabel.Layout.Row = 1;
            app.debugProfileLabel.Layout.Column = 1;

            app.debugProfileDrop = uidropdown(actionGrid, ...
                'Items',{'Auto random','Resistor','Diode','Leaky nonlinear device','Noisy contact'}, ...
                'Value','Auto random', ...
                'Visible','off');
            app.debugProfileDrop.Layout.Row = 1;
            app.debugProfileDrop.Layout.Column = [2 3];

            app.devLabel = uilabel(actionGrid,'Text',['Device' helpMark]);
            app.devLabel.Layout.Row = 2;
            app.devLabel.Layout.Column = 1;
            app.devEdit = uieditfield(actionGrid,'text','Value','Dev01', ...
                'ValueChangedFcn',callbacks.deviceNameChanged);
            app.devEdit.Tag = 'devEdit';
            app.devEdit.Layout.Row = 2;
            app.devEdit.Layout.Column = [2 3];

            app.commentLabel = uilabel(actionGrid,'Text',['Operator' helpMark]);
            app.commentLabel.Layout.Row = 3;
            app.commentLabel.Layout.Column = 1;
            app.commentEdit = uieditfield(actionGrid,'text','Value','', ...
                'ValueChangedFcn',callbacks.commentChanged);
            app.commentEdit.Tag = 'commentEdit';
            app.commentEdit.Layout.Row = 3;
            app.commentEdit.Layout.Column = [2 3];

            app.startBtn = uibutton(actionGrid,'push','Text',[char(9654) '  Start Sweep' helpMark], ...
                'FontName',ui.Theme.fonts().ui, ...
                'ButtonPushedFcn',callbacks.startSweep);
            app.startBtn.Tag = 'startBtn';
            app.startBtn.Layout.Row = 4;
            app.startBtn.Layout.Column = [1 2];
            app.startBtn.FontWeight = 'bold';
            app.startBtn.BackgroundColor = [0.12 0.55 0.25];
            app.startBtn.FontColor = [1 1 1];

            app.pauseBtn = uibutton(actionGrid,'push','Text',[char(9208) '  Pause' helpMark], ...
                'FontName',ui.Theme.fonts().ui, ...
                'ButtonPushedFcn',callbacks.togglePause);
            app.pauseBtn.Tag = 'pauseBtn';
            app.pauseBtn.Layout.Row = 4;
            app.pauseBtn.Layout.Column = 3;
            app.pauseBtn.Enable = 'off';

            app.abortBtn = uibutton(actionGrid,'push','Text',[char(9632) '  STOP / OUTPUT OFF' helpMark], ...
                'FontName',ui.Theme.fonts().ui, ...
                'ButtonPushedFcn',callbacks.abortSweep, ...
                'FontWeight','bold', ...
                'BackgroundColor',[0.85 0.05 0.05], ...
                'FontColor',[1 1 1]);
            app.abortBtn.Tag = 'abortBtn';
            app.abortBtn.Layout.Row = 5;
            app.abortBtn.Layout.Column = [1 3];
        end

        function trySetPlaceholder(ctrl,textValue)
            try
                ctrl.Placeholder = textValue;
            catch
                if isempty(strtrim(ctrl.Value))
                    ctrl.Value = textValue;
                end
            end
        end

        function grid = scrollPageGrid(parent,gridSize,minHeight,minWidth)
            if nargin < 4 || isempty(minWidth)
                minWidth = 210;
            end
            parent.Scrollable = 'on';
            parent.AutoResizeChildren = 'off';
            holder = uipanel(parent,'Title','','BorderType','none','BackgroundColor',[1 1 1]);
            try, parent.BackgroundColor = [1 1 1]; catch, end
            holder.Position = [0 0 max(parent.Position(3)-18,minWidth) minHeight];
            grid = uigridlayout(holder,gridSize);
            try, grid.BackgroundColor = [1 1 1]; catch, end
            parent.SizeChangedFcn = @(src,~)ui.ControlsPanel.resizeScrollHolder(src,holder,minHeight,minWidth);
            ui.ControlsPanel.resizeScrollHolder(parent,holder,minHeight,minWidth);
        end

        function resizeScrollHolder(parent,holder,minHeight,minWidth)
            if nargin < 4 || isempty(minWidth)
                minWidth = 210;
            end
            if ~isvalid(parent) || ~isvalid(holder)
                return;
            end
            pos = parent.Position;
            holder.Position = [0 0 max(pos(3)-18,minWidth) max(pos(4),minHeight)];
        end
    end
end
