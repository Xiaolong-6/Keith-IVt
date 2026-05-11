classdef DevicesPanel
    methods(Static)
        function app = build(app,root,helpMark,callbacks)
            right = uipanel(root,'Title','Devices');
            right.Layout.Row = 2;
            right.Layout.Column = 2;
            rightShell = uigridlayout(right,[1 1]);
            rightShell.RowHeight = {'1x'};
            rightShell.ColumnWidth = {'1x'};
            rightShell.Padding = [8 8 8 8];
            rightShell.RowSpacing = 6;

            rightGrid = uigridlayout(rightShell,[2 1]);
            app.rightContentGrid = rightGrid;
            rightGrid.Layout.Row = 1;
            rightGrid.RowHeight = {30,'1x'};
            rightGrid.ColumnWidth = {'1x'};
            rightGrid.Padding = [0 0 0 0];
            rightGrid.RowSpacing = 0;

            tabBar = uigridlayout(rightGrid,[1 4]);
            tabBar.Layout.Row = 1;
            tabBar.ColumnWidth = {86,90,'1x',1};
            tabBar.Padding = [0 0 0 0];
            tabBar.ColumnSpacing = 0;
            deviceButtons = gobjects(1,2);
            deviceButtons(1) = uibutton(tabBar,'push','Text','Devices');
            deviceButtons(2) = uibutton(tabBar,'push','Text','Recovery');
            deviceButtons(1).Layout.Column = 1;
            deviceButtons(2).Layout.Column = 2;

            pageStack = uipanel(rightGrid,'Title','','BorderType','none');
            pageStack.Layout.Row = 2;
            stackGrid = uigridlayout(pageStack,[1 1]);
            stackGrid.RowHeight = {'1x'};
            stackGrid.ColumnWidth = {'1x'};
            stackGrid.Padding = [0 0 0 0];

            devicesTab = uipanel(stackGrid,'Title','','BorderType','none','Visible','off');
            recoveryTab = uipanel(stackGrid,'Title','','BorderType','none','Visible','off');
            devicesTab.Layout.Row = 1;
            devicesTab.Layout.Column = 1;
            recoveryTab.Layout.Row = 1;
            recoveryTab.Layout.Column = 1;
            ui.Theme.setIfProp(devicesTab,'Scrollable','on');
            ui.Theme.setIfProp(recoveryTab,'Scrollable','on');

            app = ui.DevicesPanel.addDevicesTab(app,devicesTab,helpMark,callbacks);
            app = ui.DevicesPanel.addRecoveryTab(app,recoveryTab,helpMark,callbacks);
            app.deviceTabButtons = deviceButtons;
            app.devicePages = [devicesTab recoveryTab];
            for k = 1:numel(deviceButtons)
                deviceButtons(k).ButtonPushedFcn = @(~,~)ui.DevicesPanel.selectDevicePage(deviceButtons,app.devicePages,k);
            end
            ui.DevicesPanel.selectDevicePage(deviceButtons,app.devicePages,1);
        end

        function app = addDevicesTab(app,devicesTab,helpMark,callbacks)
            rg = ui.DevicesPanel.scrollContentGrid(devicesTab,245);
            rg.RowHeight = {'1x'};
            rg.ColumnWidth = {'1x',132};
            rg.Padding = [6 6 6 6];

            app.devTable = uitable(rg, ...
                'Data',cell(0,6), ...
                'ColumnName',{'Show','Device','Operator','Mode','Points','Max |Y|'}, ...
                'ColumnWidth',{46,82,72,48,48,64}, ...
                'ColumnEditable',[true true true false false false], ...
                'CellEditCallback',callbacks.deviceTableEdited, ...
                'SelectionType','row');
            app.devTable.Tag = 'devTable';
            app.devTable.Layout.Row = 1;
            app.devTable.Layout.Column = 1;
            ui.DevicesPanel.setDeviceTableWidths(app.devTable,420);
            app.devEmptyLabel = uilabel(rg,'Text','No stored devices','HorizontalAlignment','center');
            app.devEmptyLabel.Layout.Row = 1;
            app.devEmptyLabel.Layout.Column = 1;

            app.deviceMenu = uicontextmenu(app.fig);
            app.saveSelBtn = uimenu(app.deviceMenu,'Text','Save Selected Device','MenuSelectedFcn',callbacks.saveSelectedDevice);
            app.deleteSelBtn = uimenu(app.deviceMenu,'Text','Delete Selected Device','MenuSelectedFcn',callbacks.deleteSelectedDevice);
            app.refreshMenu = uimenu(app.deviceMenu,'Text','Refresh Plot','MenuSelectedFcn',callbacks.refreshPlots);
            app.devTable.ContextMenu = app.deviceMenu;

            deviceActionGrid = uigridlayout(rg,[5 1]);
            deviceActionGrid.Layout.Row = 1;
            deviceActionGrid.Layout.Column = 2;
            deviceActionGrid.RowHeight = {32,32,32,32,'1x'};
            deviceActionGrid.Padding = [0 0 0 0];
            deviceActionGrid.RowSpacing = 6;
            app.refreshBtn = uibutton(deviceActionGrid,'push','Text',[char(8635) '  Refresh Plot' helpMark],'ButtonPushedFcn',callbacks.refreshPlots);
            app.importBtn = uibutton(deviceActionGrid,'push','Text',[char(8681) '  Import Data' helpMark],'ButtonPushedFcn',callbacks.importDataFile);
            app.saveAllBtn = uibutton(deviceActionGrid,'push','Text',[char(8679) '  Save All' helpMark],'ButtonPushedFcn',callbacks.saveAllDevices);
            app.saveAllBtn.BackgroundColor = [0.94 0.94 0.94];
            app.clearAllBtn = uibutton(deviceActionGrid,'push','Text',[char(10005) '  Clear All' helpMark],'ButtonPushedFcn',callbacks.clearAllDevices);
            app.clearAllBtn.BackgroundColor = [0.94 0.94 0.94];
        end

        function app = addRecoveryTab(app,recoveryTab,helpMark,callbacks)
            recGrid = ui.DevicesPanel.scrollContentGrid(recoveryTab,180);
            recGrid.RowHeight = {'1x'};
            recGrid.ColumnWidth = {'1x',132};
            recGrid.Padding = [6 6 6 6];

            app.recoveryTable = uitable(recGrid, ...
                'Data',cell(0,3), ...
                'ColumnName',{'File','Modified','Size KB'}, ...
                'ColumnEditable',[false false false], ...
                'SelectionType','row');
            app.recoveryTable.Tag = 'recoveryTable';
            app.recoveryTable.Layout.Row = 1;
            app.recoveryTable.Layout.Column = 1;
            ui.DevicesPanel.setRecoveryTableWidths(app.recoveryTable,420);
            app.recoveryEmptyLabel = uilabel(recGrid,'Text','No recovery files','HorizontalAlignment','center');
            app.recoveryEmptyLabel.Layout.Row = 1;
            app.recoveryEmptyLabel.Layout.Column = 1;

            recoveryActionGrid = uigridlayout(recGrid,[4 1]);
            recoveryActionGrid.Layout.Row = 1;
            recoveryActionGrid.Layout.Column = 2;
            recoveryActionGrid.RowHeight = {32,32,32,'1x'};
            recoveryActionGrid.Padding = [0 0 0 0];
            recoveryActionGrid.RowSpacing = 6;
            app.refreshRecoveryBtn = uibutton(recoveryActionGrid,'push','Text',['Refresh Cache' helpMark],'ButtonPushedFcn',callbacks.refreshRecoveryPanel);
            app.importRecoveryBtn = uibutton(recoveryActionGrid,'push','Text',['Import Selected Recovery' helpMark],'ButtonPushedFcn',callbacks.importSelectedRecovery);
            app.openCacheBtn = uibutton(recoveryActionGrid,'push','Text',[char(8599) '  Open Cache Folder' helpMark],'ButtonPushedFcn',callbacks.openCacheFolder);
        end

        function grid = scrollContentGrid(parent,minHeight)
            parent.Scrollable = 'on';
            parent.AutoResizeChildren = 'off';
            holder = uipanel(parent,'Title','','BorderType','none');
            holder.Position = [0 0 max(parent.Position(3)-18,360) minHeight];
            grid = uigridlayout(holder,[1 2]);
            grid.RowHeight = {'1x'};
            grid.ColumnWidth = {'1x','fit'};
            grid.Padding = [0 0 0 0];
            parent.SizeChangedFcn = @(src,~)ui.DevicesPanel.resizeScrollHolder(src,holder,minHeight);
            ui.DevicesPanel.resizeScrollHolder(parent,holder,minHeight);
        end

        function resizeScrollHolder(parent,holder,minHeight)
            if ~isvalid(parent) || ~isvalid(holder)
                return;
            end
            pos = parent.Position;
            holder.Position = [0 0 max(pos(3)-18,360) max(pos(4),minHeight)];
            ui.DevicesPanel.resizeContainedTables(holder);
        end

        function resizeContainedTables(holder)
            if ~isvalid(holder)
                return;
            end
            actionColW = 132;
            usableW = max(holder.Position(3) - actionColW - 28, 260);

            devTables = findobj(holder,'Tag','devTable');
            for k = 1:numel(devTables)
                ui.DevicesPanel.setDeviceTableWidths(devTables(k),usableW);
            end

            recTables = findobj(holder,'Tag','recoveryTable');
            for k = 1:numel(recTables)
                ui.DevicesPanel.setRecoveryTableWidths(recTables(k),usableW);
            end
        end

        function setDeviceTableWidths(tbl,usableW)
            if isempty(tbl) || ~isvalid(tbl)
                return;
            end
            usableW = max(usableW,260);
            if usableW < 430
                widths = {44,78,66,46,46,max(62,usableW-44-78-66-46-46-10)};
            else
                showW = 46;
                modeW = 52;
                pointsW = 58;
                maxW = 86;
                leftover = max(usableW - showW - modeW - pointsW - maxW - 12, 170);
                devW = max(96,round(leftover*0.50));
                opW = max(82,leftover-devW);
                widths = {showW,devW,opW,modeW,pointsW,maxW};
            end
            tbl.ColumnWidth = widths;
        end

        function setRecoveryTableWidths(tbl,usableW)
            if isempty(tbl) || ~isvalid(tbl)
                return;
            end
            usableW = max(usableW,260);
            sizeW = 64;
            modW = 132;
            fileW = max(120,usableW - modW - sizeW - 10);
            tbl.ColumnWidth = {fileW,modW,sizeW};
        end

        function updateEmptyState(app)
            ui.DevicesPanel.updateOneEmptyState(app,'devTable','devEmptyLabel','No stored devices');
            ui.DevicesPanel.updateOneEmptyState(app,'recoveryTable','recoveryEmptyLabel','No recovery files');
        end

        function updateOneEmptyState(app,tableField,labelField,text)
            if ~isfield(app,tableField) || ~isfield(app,labelField) || ...
                    ~isvalid(app.(tableField)) || ~isvalid(app.(labelField))
                return;
            end
            hasRows = ~isempty(app.(tableField).Data) && size(app.(tableField).Data,1) > 0;
            app.(tableField).Visible = ui.UiState.onOff(hasRows);
            app.(labelField).Visible = ui.UiState.onOff(~hasRows);
            app.(labelField).Text = text;
            c = ui.Theme.colors(app.(labelField));
            app.(labelField).FontColor = c.muted;
            app.(labelField).BackgroundColor = c.panel;
        end
        function selectDevicePage(buttons,pages,index)
            c = ui.Theme.colors();
            for k = 1:numel(pages)
                pages(k).Visible = ui.UiState.onOff(k == index);
                buttons(k).FontWeight = 'normal';
                buttons(k).BackgroundColor = c.control;
                if k == index
                    buttons(k).FontWeight = 'bold';
                    buttons(k).BackgroundColor = c.primarySoft;
                end
            end
        end
    end
end
