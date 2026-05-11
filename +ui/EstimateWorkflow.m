classdef EstimateWorkflow
    methods(Static)
        function text = textFromControls(app)
            try
                nPts = ui.EstimateWorkflow.pointCount(app);
                text = ['Est. ' core.SweepMath.estimateSweepTimeText(nPts,app.nplcEdit.Value,app.delayEdit.Value)];
            catch ME
                if startsWith(ME.identifier,'KeithIVt:Estimate:')
                    text = ME.message;
                else
                    text = 'Est. check settings';
                end
            end
        end

        function nPts = pointCount(app)
            if strcmp(app.measureTypeDrop.Value,'Time Trace')
                minInterval = core.SweepPlan.minimumTimeTraceInterval(app.nplcEdit.Value,app.delayEdit.Value);
                if app.intervalEdit.Value < minInterval
                    error('KeithIVt:Estimate:Interval','Est. interval >= %.3g s',minInterval);
                end
                nPts = floor(app.durationEdit.Value/app.intervalEdit.Value) + 1;
            elseif strcmp(app.sweepDrop.Value,'Adaptive')
                core.SweepMath.validateAdaptiveCoverage(app.adaptiveTable.Data,app.startEdit.Value,app.stopEdit.Value);
                X = core.SweepMath.buildAdaptiveScanVector(app.startEdit.Value,app.stopEdit.Value,app.adaptiveTable.Data);
                X = core.SweepPlan.applyDirection(X,app.directionDrop.Value);
                nPts = numel(X);
            else
                X = core.SweepMath.buildScanVector(app.startEdit.Value,app.stopEdit.Value,app.stepEdit.Value);
                X = core.SweepPlan.applyDirection(X,app.directionDrop.Value);
                nPts = numel(X);
            end
        end
    end
end
