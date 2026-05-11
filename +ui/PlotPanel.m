classdef PlotPanel
    methods(Static)
        function app = build(app,root,callbacks)
            mid = uipanel(root,'Title','Live / Stored Plots');
            mid.Layout.Row = 1;
            mid.Layout.Column = 2;
            plotGrid = uigridlayout(mid,[2 1]);
            plotGrid.RowHeight = {34,'1x'};
            plotGrid.ColumnWidth = {'1x'};
            plotGrid.Padding = [8 8 8 8];
            plotGrid.RowSpacing = 6;

            toolbar = uigridlayout(plotGrid,[1 9]);
            toolbar.Layout.Row = 1;
            toolbar.ColumnWidth = {54,70,54,88,'1x',0,124,8,128};
            toolbar.Padding = [0 0 0 0];
            toolbar.ColumnSpacing = 0;

            pageStack = uipanel(plotGrid,'Title','','BorderType','none');
            pageStack.Layout.Row = 2;
            pageStack.Layout.Column = 1;
            pageGrid = uigridlayout(pageStack,[1 1]);
            pageGrid.RowHeight = {'1x'};
            pageGrid.ColumnWidth = {'1x'};
            pageGrid.Padding = [0 0 0 0];

            plotNames = {'All','Linear','Log','Resistance'};
            plotKeys = {'all','linear','log','resistance'};
            plotButtons = gobjects(1,numel(plotNames));
            plotPages = gobjects(1,numel(plotNames));
            for k = 1:numel(plotNames)
                plotButtons(k) = uibutton(toolbar,'push','Text',plotNames{k});
                plotButtons(k).Layout.Row = 1;
                plotButtons(k).Layout.Column = k;
                plotPages(k) = uipanel(pageGrid,'Title','','BorderType','none','Visible','off');
                plotPages(k).Layout.Row = 1;
                plotPages(k).Layout.Column = 1;
            end
            app.plotButtons = plotButtons;
            app.plotPages = plotPages;
            app.plotPageKeys = plotKeys;

            arrangementLabel = uilabel(toolbar,'Text','');
            arrangementLabel.Layout.Row = 1;
            arrangementLabel.Layout.Column = 6;
            app.allArrangementDrop = uidropdown(toolbar, ...
                'Items',{'Vertical','Horizontal'}, ...
                'Value','Horizontal', ...
                'ValueChangedFcn',callbacks.applyAllPlotArrangement);
            app.allArrangementDrop.Layout.Row = 1;
            app.allArrangementDrop.Layout.Column = 7;
            app.fullCurrentBtn = uibutton(toolbar,'push','Text','Fullscreen','ButtonPushedFcn',callbacks.openCurrent);
            app.fullCurrentBtn.Layout.Row = 1;
            app.fullCurrentBtn.Layout.Column = 9;
            arrangementDrop = app.allArrangementDrop;
            for k = 1:numel(plotNames)
                plotButtons(k).ButtonPushedFcn = ui.PlotPanel.makePageCallback(plotButtons,plotPages,k,arrangementDrop,toolbar);
            end

            allPlotGrid = uigridlayout(plotPages(1),[4 3]);
            app.allPlotGrid = allPlotGrid;
            allPlotGrid.RowHeight = {'1x','1x','1x',1};
            allPlotGrid.ColumnWidth = {'1x','1x','1x'};
            allPlotGrid.Padding = [6 6 6 6];
            allPlotGrid.RowSpacing = 8;
            allPlotGrid.ColumnSpacing = 8;
            linPlotGrid = uigridlayout(plotPages(2),[1 1]);
            linPlotGrid.RowHeight = {'1x'};
            linPlotGrid.Padding = [6 6 6 6];
            linPlotGrid.RowSpacing = 8;
            logPlotGrid = uigridlayout(plotPages(3),[1 1]);
            logPlotGrid.RowHeight = {'1x'};
            logPlotGrid.Padding = [6 6 6 6];
            logPlotGrid.RowSpacing = 8;
            calcPlotGrid = uigridlayout(plotPages(4),[1 1]);
            calcPlotGrid.RowHeight = {'1x'};
            calcPlotGrid.Padding = [6 6 6 6];
            calcPlotGrid.RowSpacing = 8;

            [app.axLinAll,app.axLogAll,app.axCalcAll] = ui.PlotPanel.addAllAxes(allPlotGrid);
            [app.axLin,app.axLog,app.axCalc] = ui.PlotPanel.addSingleAxes(linPlotGrid,logPlotGrid,calcPlotGrid);
            ui.PlotPanel.selectPlotPage(plotButtons,plotPages,2,app.allArrangementDrop,toolbar);
        end

        function callback = makePageCallback(buttons,pages,index,arrangementDrop,toolbar)
            callback = @(~,~)ui.PlotPanel.selectPlotPage(buttons,pages,index,arrangementDrop,toolbar);
        end

        function selectPlotPage(buttons,pages,index,arrangementDrop,toolbar)
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
            if nargin >= 4 && ~isempty(arrangementDrop) && isvalid(arrangementDrop)
                showArrangement = index == 1;
                arrangementDrop.Visible = ui.UiState.onOff(showArrangement);
                if nargin >= 5 && ~isempty(toolbar) && isvalid(toolbar)
                    if showArrangement
                        toolbar.ColumnWidth = {54,70,54,88,'1x',0,124,8,128};
                    else
                        toolbar.ColumnWidth = {54,70,54,88,'1x',0,0,8,128};
                    end
                end
            end
        end

        function [axLinAll,axLogAll,axCalcAll] = addAllAxes(allPlotGrid)
            axLinAll = uiaxes(allPlotGrid);
            axLinAll.Layout.Row = 1;
            axLinAll.Layout.Column = 1;
            ui.PlotPanel.styleAxis(axLinAll,'Linear I-V','Voltage (V)','Current (A)',false);

            axLogAll = uiaxes(allPlotGrid);
            axLogAll.Layout.Row = 2;
            axLogAll.Layout.Column = 1;
            ui.PlotPanel.styleAxis(axLogAll,'Log |I|-V','Voltage (V)','|Current| (A)',true);

            axCalcAll = uiaxes(allPlotGrid);
            axCalcAll.Layout.Row = 3;
            axCalcAll.Layout.Column = 1;
            ui.PlotPanel.styleAxis(axCalcAll,'Resistance','Voltage (V)','Resistance (Ohm): R and dV/dI',false);
        end

        function [axLin,axLog,axCalc] = addSingleAxes(linPlotGrid,logPlotGrid,calcPlotGrid)
            axLin = uiaxes(linPlotGrid);
            axLin.Layout.Row = 1;
            axLin.Layout.Column = 1;
            ui.PlotPanel.styleAxis(axLin,'Linear I-V','Voltage (V)','Current (A)',false);

            axLog = uiaxes(logPlotGrid);
            axLog.Layout.Row = 1;
            axLog.Layout.Column = 1;
            ui.PlotPanel.styleAxis(axLog,'Log |I|-V','Voltage (V)','|Current| (A)',true);

            axCalc = uiaxes(calcPlotGrid);
            axCalc.Layout.Row = 1;
            axCalc.Layout.Column = 1;
            ui.PlotPanel.styleAxis(axCalc,'Resistance','Voltage (V)','Resistance (Ohm): R and dV/dI',false);
        end

        function styleAxis(ax,titleText,xText,yText,useLogY)
            title(ax,titleText);
            xlabel(ax,xText);
            ylabel(ax,yText);
            if useLogY
                ax.YScale = 'log';
            end
            grid(ax,'on');
            box(ax,'on');
        end
    end
end
