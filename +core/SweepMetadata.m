classdef SweepMetadata
    methods(Static)
        function dev = device(devName,comment,mode,X,Y,raw,meta)
            dev = struct();
            dev.name = devName;
            dev.comment = data.CommentUtil.sanitize(comment);
            dev.mode = mode;
            dev.X = X;
            dev.Y = Y;
            dev.visible = true;
            dev.raw = raw;
            dev.meta = meta;
        end

        function raw = emptyRaw(n)
            raw = cell(n,1);
            raw(:) = {''};
        end

        function meta = create(devName,mode,sweepName,X,compliance,nplc,settleT,Y,context)
            meta = struct();
            meta.Device = devName;
            if isfield(context,'Comment')
                meta.Comment = data.CommentUtil.sanitize(context.Comment);
            else
                meta.Comment = '';
            end
            if isfield(context,'Operator')
                meta.Operator = data.CommentUtil.sanitize(context.Operator);
            else
                meta.Operator = meta.Comment;
            end
            meta.DateTime = core.TimeUtil.dateTimeText();
            meta.Mode = mode;
            if isfield(context,'MeasurementType')
                meta.MeasurementType = context.MeasurementType;
            else
                meta.MeasurementType = 'Sweep';
            end
            meta.SweepType = sweepName;
            meta.SweepDirection = context.SweepDirection;
            if isfield(context,'SenseMode')
                meta.SenseMode = context.SenseMode;
            else
                meta.SenseMode = '2-wire';
            end
            meta.Terminal = context.Terminal;
            meta.ComPort = context.ComPort;
            meta.Baud = context.Baud;
            meta.InstrumentID = context.InstrumentID;
            if isfield(context,'InstrumentModel')
                meta.InstrumentModel = context.InstrumentModel;
            end
            meta.Start = X(1);
            meta.Stop = X(end);
            meta.Points = numel(X);
            meta.ComplianceOrLimit = compliance;
            if isfield(context,'MeasureRangeMode')
                meta.MeasureRangeMode = context.MeasureRangeMode;
            else
                meta.MeasureRangeMode = 'Auto range';
            end
            if isfield(context,'MeasureRangeValue')
                meta.MeasureRangeValue = context.MeasureRangeValue;
            else
                meta.MeasureRangeValue = NaN;
            end
            [hit,hitCount,maxRatio] = core.SweepMath.complianceHitSummary(Y,compliance);
            meta.ComplianceHit = hit;
            meta.ComplianceHitCount = hitCount;
            meta.MaxComplianceRatio = maxRatio;
            meta.NPLC = nplc;
            meta.Delay_s = settleT;
            if isfield(context,'FixedSource')
                meta.FixedSource = context.FixedSource;
            end
            if isfield(context,'TimeTraceDuration_s')
                meta.TimeTraceDuration_s = context.TimeTraceDuration_s;
            end
            if isfield(context,'TimeTraceInterval_s')
                meta.TimeTraceInterval_s = context.TimeTraceInterval_s;
            end
            meta.EstimatedTime = core.SweepMath.estimateSweepTimeText(numel(X),nplc,settleT);
            meta.CacheLogFile = context.CacheLogFile;
            if strcmp(sweepName,'adaptive')
                meta.AdaptiveRules = core.SweepMetadata.adaptiveRulesText(context.AdaptiveRules);
            else
                meta.AdaptiveRules = '';
            end
        end

        function txt = adaptiveRulesText(rules)
            rules = core.SweepMath.validateAdaptiveRules(rules);
            parts = strings(size(rules,1),1);
            for k = 1:size(rules,1)
                parts(k) = sprintf('[%g,%g] step %g',rules(k,1),rules(k,2),rules(k,3));
            end
            txt = strjoin(parts,'; ');
        end
    end
end
