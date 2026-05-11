classdef SweepWorkflow
    methods(Static)
        function app = begin(app,helpMark)
            app.abortRequested = false;
            app.pauseRequested = false;
            app.isSweeping = true;
            app.pauseBtn.Text = [char(9208) '  Pause' helpMark];
        end

        function app = finish(app,helpMark)
            app.isSweeping = false;
            app.pauseBtn.Text = [char(9208) '  Pause' helpMark];
            app.pauseRequested = false;
        end

        function [app,plan,timing,logLines] = prepare(app,context)
            timing = struct();
            timing.compliance = app.compEdit.Value;
            timing.nplc = app.nplcEdit.Value;
            timing.settleT = app.delayEdit.Value;
            timing.rangeMode = app.rangeModeDrop.Value;
            timing.rangeValue = app.rangeValueEdit.Value;
            timing.measurementType = app.measureTypeDrop.Value;
            if strcmp(timing.measurementType,'Time Trace')
                minInterval = core.SweepPlan.minimumTimeTraceInterval(timing.nplc,timing.settleT);
                if app.intervalEdit.Value < minInterval
                    error('Time Trace interval is too short for the current NPLC/delay over USB. Use at least %.3g s.',minInterval);
                end
            end

            app.exportFolder = strtrim(app.exportFolderEdit.Value);
            data.DataManager.ensureFolder(app.cacheFolder);

            devName = strtrim(app.devEdit.Value);
            if isempty(devName) || strcmpi(devName,'Device name')
                devName = sprintf('Dev%02d',numel(app.devices)+1);
                app.devEdit.Value = devName;
            end
            operatorName = strtrim(app.commentEdit.Value);
            if strcmpi(operatorName,'User name')
                operatorName = '';
                app.commentEdit.Value = '';
            end

            plan = core.SweepPlan.create(devName,operatorName,app.senseDrop.Value,app.startEdit.Value,app.stopEdit.Value,app.stepEdit.Value, ...
                app.sweepDrop.Value,app.directionDrop.Value,app.modeDrop.Value,app.adaptiveTable.Data,app.measureTypeDrop.Value, ...
                app.fixedSourceEdit.Value,app.durationEdit.Value,app.intervalEdit.Value);

            app.currentAutosaveFile = core.SweepAutosave.recoveryFile(app.cacheFolder,plan.devName,plan.comment,plan.sweepName);
            core.SweepAutosave.writeStarted(app.currentAutosaveFile,plan.devName,plan.mode,plan.sweepName,plan.X, ...
                timing.compliance,timing.nplc,timing.settleT,context,app.exportModeDrop.Value);

            logLines = { ...
                sprintf('Starting %s %s: %s, %s, %d points.',plan.sweepName,plan.modeLogName,plan.devName,plan.senseMode,numel(plan.X)); ...
                ['Autosave recovery file: ' app.currentAutosaveFile]; ...
                ['Estimated sweep time: ' core.SweepMath.estimateSweepTimeText(numel(plan.X),timing.nplc,timing.settleT)] ...
                };
        end

        function app = addCompletedDevice(app,plan,Y,raw,meta)
            idx = numel(app.devices) + 1;
            app.devices(idx) = core.SweepMetadata.device(plan.devName,plan.comment,plan.mode,plan.X,Y,raw,meta);
        end

        function [msg,state] = statusAfterSweep(app,detail)
            if app.debugMode
                msg = ['Debug mode: ' detail];
                state = 'debug';
            else
                msg = ['Connected: ' detail];
                state = 'connected';
            end
        end

        function profileChoice = debugProfileChoice(app)
            profileChoice = 'Auto random';
            if isfield(app,'debugProfileDrop') && isvalid(app.debugProfileDrop)
                profileChoice = app.debugProfileDrop.Value;
            end
        end
    end
end
