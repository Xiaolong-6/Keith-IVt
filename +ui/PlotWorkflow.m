classdef PlotWorkflow
    methods(Static)
        function refresh(app)
            axs = ui.PlotWorkflow.plotAxes(app);
            ui.PlotWorkflow.resetAxes(axs);

            hasVolt = false;
            hasCurr = false;
            hasTime = false;
            visibleX = [];

            for k = 1:numel(app.devices)
                if ~app.devices(k).visible
                    continue;
                end
                col = app.colors(mod(k-1,size(app.colors,1))+1,:);
                X = app.devices(k).X;
                Y = app.devices(k).Y;
                visibleX = [visibleX; X(:)]; %#ok<AGROW>

                isTimeTrace = data.DataManager.isTimeTrace(app.devices(k));
                hasTime = hasTime || isTimeTrace;
                if strcmp(app.devices(k).mode,'VOLT')
                    hasVolt = true;
                    marker = 'o-';
                    name = app.devices(k).name;
                else
                    hasCurr = true;
                    marker = 's-';
                    name = [app.devices(k).name ' (I-src)'];
                end
                ui.PlotWorkflow.plotLinearTrace(app,X,Y,marker,col,name);

                if ~isTimeTrace
                    calc = core.SweepMath.calcElectrical(app.devices(k).mode,X,Y);
                    ui.PlotWorkflow.plotCalcTrace(app,X,calc.R_shunt_ohm,'^-',col,[app.devices(k).name ' R=V/I']);
                    ui.PlotWorkflow.plotCalcTrace(app,X,calc.R_diff_ohm,'v--',col,[app.devices(k).name ' dV/dI']);
                end
            end

            labels = ui.PlotWorkflow.storedAxisLabels(hasVolt,hasCurr,hasTime);
            ui.PlotWorkflow.labelStoredAxes(app,labels);
            ui.PlotWorkflow.finishAxes(app,axs);
            ui.PlotView.applyXRange(app,visibleX);
        end

        function resetDefault(app)
            axs = ui.PlotWorkflow.plotAxes(app);
            ui.PlotWorkflow.resetAxes(axs);
            ui.PlotWorkflow.labelStoredAxes(app,{'Linear I-V','Log |I|-V','Voltage (V)','Current (A)','|Current| (A)','Voltage (V)'});
            ui.PlotWorkflow.finishAxes(app,axs);
        end

        function linkAxes(app)
            try
                linkaxes([app.axLin app.axLog app.axCalc],'x');
                linkaxes([app.axLinAll app.axLogAll app.axCalcAll],'x');
            catch
            end
        end

        function applyAllArrangement(app)
            if ~isfield(app,'allArrangementDrop') || ~isvalid(app.allArrangementDrop)
                return;
            end
            axLinAll = app.axLinAll;
            axLogAll = app.axLogAll;
            axCalcAll = app.axCalcAll;
            if strcmp(app.allArrangementDrop.Value,'Horizontal')
                app.allPlotGrid.RowHeight = {'1x',1,1,1};
                app.allPlotGrid.ColumnWidth = {'1x','1x','1x'};
                axLinAll.Layout.Row = 1;
                axLinAll.Layout.Column = 1;
                axLogAll.Layout.Row = 1;
                axLogAll.Layout.Column = 2;
                axCalcAll.Layout.Row = 1;
                axCalcAll.Layout.Column = 3;
            else
                app.allPlotGrid.RowHeight = {'1x','1x','1x',1};
                app.allPlotGrid.ColumnWidth = {'1x','1x','1x'};
                axLinAll.Layout.Row = 1;
                axLinAll.Layout.Column = [1 3];
                axLogAll.Layout.Row = 2;
                axLogAll.Layout.Column = [1 3];
                axCalcAll.Layout.Row = 3;
                axCalcAll.Layout.Column = [1 3];
            end
            drawnow limitrate;
        end

        function openWindow(app,kind)
            fig = figure('Name',['Keith-IVt - ' upper(kind)],'Color','w');
            switch kind
                case 'all'
                    tiledlayout(fig,3,1);
                    ui.PlotWorkflow.copyAxisToTile(app.axLinAll);
                    ui.PlotWorkflow.copyAxisToTile(app.axLogAll);
                    ui.PlotWorkflow.copyAxisToTile(app.axCalcAll);
                case 'linear'
                    ui.PlotWorkflow.copyAxisToFigure(app.axLin,fig);
                case 'log'
                    ui.PlotWorkflow.copyAxisToFigure(app.axLog,fig);
                otherwise
                    ui.PlotWorkflow.copyAxisToFigure(app.axCalc,fig);
            end
        end

        function axs = plotAxes(app)
            axs = [app.axLin app.axLog app.axCalc app.axLinAll app.axLogAll app.axCalcAll];
        end

        function resetAxes(axs)
            for ax = axs
                cla(ax);
                hold(ax,'on');
            end
        end

        function labels = storedAxisLabels(hasVolt,hasCurr,hasTime)
            if hasTime && hasVolt && ~hasCurr
                labels = {'Current vs Time','Log |Current|-Time','Time (s)','Current (A)','|Current| (A)','Time (s)'};
            elseif hasTime && hasCurr && ~hasVolt
                labels = {'Voltage vs Time','Log |Voltage|-Time','Time (s)','Voltage (V)','|Voltage| (V)','Time (s)'};
            elseif hasTime
                labels = {'Time Traces','Log Time Traces','Time (s)','Measured value','|Measured value|','Time (s)'};
            elseif hasVolt && ~hasCurr
                labels = {'Linear I-V','Log |I|-V','Voltage (V)','Current (A)','|Current| (A)','Voltage (V)'};
            elseif hasCurr && ~hasVolt
                labels = {'Linear V-I','Log |V|-I','Current (A)','Voltage (V)','|Voltage| (V)','Current (A)'};
            else
                labels = {'Linear Stored Sweeps','Log Stored Sweeps','Source value','Measured value','|Measured value|','Source value'};
            end
        end

        function plotLinearTrace(app,X,Y,marker,col,name)
            plot(app.axLin,X,Y,marker,'Color',col,'LineWidth',1.5,'MarkerSize',3,'DisplayName',name);
            plot(app.axLinAll,X,Y,marker,'Color',col,'LineWidth',1.5,'MarkerSize',3,'DisplayName',name);
            valid = ~isnan(Y) & abs(Y) > 0;
            semilogy(app.axLog,X(valid),abs(Y(valid)),marker,'Color',col,'LineWidth',1.5,'MarkerSize',3,'DisplayName',name);
            semilogy(app.axLogAll,X(valid),abs(Y(valid)),marker,'Color',col,'LineWidth',1.5,'MarkerSize',3,'DisplayName',name);
        end

        function plotCalcTrace(app,X,Y,marker,col,name)
            valid = isfinite(Y);
            if any(valid)
                plot(app.axCalc,X(valid),Y(valid),marker,'Color',col,'LineWidth',1.5,'MarkerSize',3,'DisplayName',name);
                plot(app.axCalcAll,X(valid),Y(valid),marker,'Color',col,'LineWidth',1.5,'MarkerSize',3,'DisplayName',name);
            end
        end

        function labelStoredAxes(app,labels)
            ui.PlotWorkflow.setLinearLabels(app.axLin,labels{1},labels{3},labels{4});
            ui.PlotWorkflow.setLinearLabels(app.axLinAll,labels{1},labels{3},labels{4});
            ui.PlotWorkflow.setLinearLabels(app.axLog,labels{2},labels{3},labels{5});
            ui.PlotWorkflow.setLinearLabels(app.axLogAll,labels{2},labels{3},labels{5});
            ui.PlotWorkflow.setLinearLabels(app.axCalc,'Resistance: R = V/I and differential dV/dI',labels{6},'Resistance (Ohm)');
            ui.PlotWorkflow.setLinearLabels(app.axCalcAll,'Resistance: R = V/I and differential dV/dI',labels{6},'Resistance (Ohm)');
        end

        function setLinearLabels(ax,t,x,y)
            title(ax,t);
            xlabel(ax,x);
            ylabel(ax,y);
        end

        function finishAxes(app,axs)
            for ax = axs
                hold(ax,'off');
                grid(ax,'on');
                box(ax,'on');
                legend(ax,'Location','northwest','Interpreter','none');
            end
            app.axLog.YScale = 'log';
            app.axLogAll.YScale = 'log';
        end

        function copyAxisToTile(srcAx)
            ax = nexttile;
            ui.PlotWorkflow.copyAxisContent(srcAx,ax);
        end

        function copyAxisToFigure(srcAx,fig)
            ax = axes(fig);
            ui.PlotWorkflow.copyAxisContent(srcAx,ax);
        end

        function copyAxisContent(srcAx,dstAx)
            kids = copyobj(allchild(srcAx),dstAx);
            set(dstAx,'XScale',srcAx.XScale,'YScale',srcAx.YScale);
            title(dstAx,srcAx.Title.String,'Interpreter','none');
            xlabel(dstAx,srcAx.XLabel.String);
            ylabel(dstAx,srcAx.YLabel.String);
            grid(dstAx,'on');
            box(dstAx,'on');
            if ~isempty(kids)
                legend(dstAx,'Location','northwest','Interpreter','none');
            end
        end
    end
end
