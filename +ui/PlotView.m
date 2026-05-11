classdef PlotView
    methods(Static)
        function h = prepareLive(app,mode,devName,prefix,X)
            axs = [app.axLin app.axLog app.axCalc app.axLinAll app.axLogAll app.axCalcAll];
            for ax = axs
                cla(ax);
            end

            isTimeTrace = contains(prefix,'Time Trace');
            if isTimeTrace && strcmp(mode,'VOLT')
                xLabel = 'Time (s)';
                yLabel = 'Current (A)';
                liveTitleLin = [prefix ': ' devName];
                liveTitleLog = [prefix ' Log |I|: ' devName];
            elseif isTimeTrace
                xLabel = 'Time (s)';
                yLabel = 'Voltage (V)';
                liveTitleLin = [prefix ': ' devName];
                liveTitleLog = [prefix ' Log |V|: ' devName];
            elseif strcmp(mode,'VOLT')
                xLabel = 'Voltage (V)';
                yLabel = 'Current (A)';
                liveTitleLin = [prefix ' Linear I-V: ' devName];
                liveTitleLog = [prefix ' Log |I|: ' devName];
            else
                xLabel = 'Current (A)';
                yLabel = 'Voltage (V)';
                liveTitleLin = [prefix ' Linear V-I: ' devName];
                liveTitleLog = [prefix ' Log |V|: ' devName];
            end

            title(app.axLin,liveTitleLin,'Interpreter','none');
            title(app.axLog,liveTitleLog,'Interpreter','none');
            title(app.axCalc,[prefix ' Resistance: ' devName],'Interpreter','none');
            title(app.axLinAll,liveTitleLin,'Interpreter','none');
            title(app.axLogAll,liveTitleLog,'Interpreter','none');
            title(app.axCalcAll,[prefix ' Resistance: ' devName],'Interpreter','none');
            xlabel(app.axLin,xLabel);
            ylabel(app.axLin,yLabel);
            xlabel(app.axLog,xLabel);
            ylabel(app.axLog,ui.PlotView.absAxisLabel(yLabel));
            xlabel(app.axCalc,xLabel);
            ylabel(app.axCalc,'Resistance (Ohm)');
            xlabel(app.axLinAll,xLabel);
            ylabel(app.axLinAll,yLabel);
            xlabel(app.axLogAll,xLabel);
            ylabel(app.axLogAll,ui.PlotView.absAxisLabel(yLabel));
            xlabel(app.axCalcAll,xLabel);
            ylabel(app.axCalcAll,'Resistance (Ohm)');

            for ax = axs
                grid(ax,'on');
                box(ax,'on');
            end
            app.axLog.YScale = 'log';
            app.axLogAll.YScale = 'log';

            h.lin = plot(app.axLin,nan,nan,'o-','LineWidth',1.5,'MarkerSize',3);
            h.log = semilogy(app.axLog,nan,nan,'o-','LineWidth',1.5,'MarkerSize',3);
            h.linAll = plot(app.axLinAll,nan,nan,'o-','LineWidth',1.5,'MarkerSize',3);
            h.logAll = semilogy(app.axLogAll,nan,nan,'o-','LineWidth',1.5,'MarkerSize',3);
            hold(app.axCalc,'on');
            hold(app.axCalcAll,'on');
            h.calcR = plot(app.axCalc,nan,nan,'o-','LineWidth',1.5,'MarkerSize',3,'DisplayName','R = V/I');
            h.calcDiff = plot(app.axCalc,nan,nan,'s--','LineWidth',1.5,'MarkerSize',3,'DisplayName','dV/dI');
            h.calcRAll = plot(app.axCalcAll,nan,nan,'o-','LineWidth',1.5,'MarkerSize',3,'DisplayName','R = V/I');
            h.calcDiffAll = plot(app.axCalcAll,nan,nan,'s--','LineWidth',1.5,'MarkerSize',3,'DisplayName','dV/dI');
            hold(app.axCalc,'off');
            hold(app.axCalcAll,'off');
            legend(app.axCalc,'Location','northwest','Interpreter','none');
            legend(app.axCalcAll,'Location','northwest','Interpreter','none');
            ui.PlotView.applyXRange(app,X);
        end

        function updateLive(~,h,mode,X,Y,k)
            set(h.lin,'XData',X(1:k),'YData',Y(1:k));
            set(h.linAll,'XData',X(1:k),'YData',Y(1:k));
            valid = ~isnan(Y(1:k)) & abs(Y(1:k)) > 0;
            set(h.log,'XData',X(valid),'YData',abs(Y(valid)));
            set(h.logAll,'XData',X(valid),'YData',abs(Y(valid)));

            calc = core.SweepMath.calcElectrical(mode,X(1:k),Y(1:k));
            validR = isfinite(calc.R_shunt_ohm);
            validDiff = isfinite(calc.R_diff_ohm);
            set(h.calcR,'XData',X(validR),'YData',calc.R_shunt_ohm(validR));
            set(h.calcDiff,'XData',X(validDiff),'YData',calc.R_diff_ohm(validDiff));
            set(h.calcRAll,'XData',X(validR),'YData',calc.R_shunt_ohm(validR));
            set(h.calcDiffAll,'XData',X(validDiff),'YData',calc.R_diff_ohm(validDiff));
        end

        function applyXRange(app,X)
            X = X(:);
            X = X(isfinite(X));
            if isempty(X)
                return;
            end
            xMin = min(X);
            xMax = max(X);
            if xMin == xMax
                pad = max(abs(xMin)*0.05,1);
                xLim = [xMin-pad xMax+pad];
            else
                pad = 0.02*(xMax-xMin);
                xLim = [xMin-pad xMax+pad];
            end
            set([app.axLin app.axLog app.axCalc app.axLinAll app.axLogAll app.axCalcAll],'XLim',xLim);
        end

        function label = absAxisLabel(yLabel)
            if startsWith(yLabel,'Current')
                label = '|Current| (A)';
            elseif startsWith(yLabel,'Voltage')
                label = '|Voltage| (V)';
            else
                label = ['|' yLabel '|'];
            end
        end
    end
end
