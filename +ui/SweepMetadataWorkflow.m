classdef SweepMetadataWorkflow
    methods(Static)
        function filename = autosaveFinalDevice(app,devName,mode,sweepName,X,Y,raw,compliance,nplc,settleT,statusText)
            filename = core.SweepAutosave.writeFinal( ...
                app.cacheFolder,devName,mode,sweepName,X,Y,raw,compliance,nplc,settleT, ...
                statusText,ui.SweepMetadataWorkflow.context(app),app.exportModeDrop.Value);
        end

        function meta = create(app,devName,mode,sweepName,X,compliance,nplc,settleT,Y)
            meta = core.SweepMetadata.create( ...
                devName,mode,sweepName,X,compliance,nplc,settleT,Y, ...
                ui.SweepMetadataWorkflow.context(app));
        end

        function context = context(app)
            context = struct();
            context.SweepDirection = app.directionDrop.Value;
            context.SenseMode = app.senseDrop.Value;
            context.MeasureRangeMode = app.rangeModeDrop.Value;
            context.MeasureRangeValue = app.rangeValueEdit.Value;
            context.MeasurementType = app.measureTypeDrop.Value;
            context.FixedSource = app.fixedSourceEdit.Value;
            context.TimeTraceDuration_s = app.durationEdit.Value;
            context.TimeTraceInterval_s = app.intervalEdit.Value;
            context.Terminal = app.termDrop.Value;
            context.ComPort = strtrim(app.portEdit.Value);
            context.Baud = app.baudEdit.Value;
            context.InstrumentID = app.instrumentID;
            context.InstrumentModel = ui.RunStateView.instrumentModel(app);
            context.CacheLogFile = app.cacheLogFile;
            context.AdaptiveRules = app.adaptiveTable.Data;
            context.Comment = data.CommentUtil.sanitize(app.commentEdit.Value);
            context.Operator = data.CommentUtil.sanitize(app.commentEdit.Value);
        end
    end
end