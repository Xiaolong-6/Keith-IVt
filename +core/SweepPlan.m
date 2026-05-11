classdef SweepPlan
    methods(Static)
        function plan = create(devName,comment,senseMode,xStart,xStop,xStep,sweepType,direction,modeText,adaptiveRules,measurementType,fixedSource,duration,interval)
            plan = struct();
            plan.devName = data.CommentUtil.sanitizeDeviceName(devName);
            plan.comment = data.CommentUtil.sanitize(comment);
            plan.senseMode = char(string(senseMode));
            plan.xStart = xStart;
            plan.xStop = xStop;
            plan.xStep = xStep;
            if nargin < 11 || isempty(measurementType)
                measurementType = 'Sweep';
            end
            plan.measurementType = char(string(measurementType));

            if strcmp(plan.measurementType,'Time Trace')
                if nargin < 14 || duration <= 0 || interval <= 0
                    error('Time Trace duration and interval must be positive.');
                end
                nPts = floor(duration/interval) + 1;
                plan.X = (0:nPts-1)' * interval;
                plan.fixedSource = fixedSource;
                plan.sweepName = 'time_trace';
            else
                plan.fixedSource = NaN;
                if strcmp(sweepType,'Adaptive')
                    core.SweepMath.validateAdaptiveCoverage(adaptiveRules,xStart,xStop);
                    plan.X = core.SweepMath.buildAdaptiveScanVector(xStart,xStop,adaptiveRules);
                    plan.sweepName = 'adaptive';
                else
                    plan.X = core.SweepMath.buildScanVector(xStart,xStop,xStep);
                    plan.sweepName = 'linear';
                end

                plan.X = core.SweepPlan.applyDirection(plan.X,direction);
            end
            if isempty(plan.X)
                error('Scan vector is empty. Check start/stop/step.');
            end

            if startsWith(modeText,'Voltage')
                plan.mode = 'VOLT';
                plan.modeLogName = 'voltage-source';
            else
                plan.mode = 'CURR';
                plan.modeLogName = 'current-source';
            end
        end

        function X = applyDirection(X,direction)
            X = X(:);
            if strcmp(direction,'Forward then backward') && numel(X) > 1
                X = [X; flipud(X(1:end-1))];
            end
        end

        function minInterval = minimumTimeTraceInterval(nplc,delayS)
            lineFrequencyHz = 50;
            serialOverheadS = 0.03;
            minInterval = max(0.05,delayS + nplc/lineFrequencyHz + serialOverheadS);
        end
    end
end
