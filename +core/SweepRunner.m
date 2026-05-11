classdef SweepRunner
    methods(Static)
        function [Y,raw] = runHardware(driver,app,mode,X,compliance,nplc,settleT,devName,senseMode,rangeMode,rangeValue,callbacks)
            nPts = numel(X);
            Y = nan(nPts,1);
            raw = cell(nPts,1);

            h = ui.PlotView.prepareLive(app,mode,devName,'Live',X);
            acceptedNplc = driver.configureSweep(mode,compliance,nplc,senseMode,rangeMode,rangeValue);
            if ~isempty(acceptedNplc)
                callbacks.log(['Meter accepted NPLC: ' acceptedNplc]);
            else
                callbacks.log('NPLC was sent, but query-back failed.');
            end

            driver.autozeroOnce();
            driver.zeroSource(mode);
            driver.outputOn();

            for k = 1:nPts
                if callbacks.isAbort()
                    break;
                end

                while callbacks.isPaused() && ~callbacks.isAbort()
                    callbacks.setStatus(sprintf('Paused %d / %d',max(k-1,0),nPts),'busy');
                    drawnow;
                    pause(0.1);
                end
                if callbacks.isAbort()
                    break;
                end

                if core.SweepRunner.waitWithControls(settleT,callbacks,sprintf('Settling %d / %d',k,nPts),'busy')
                    break;
                end
                [Y(k),line] = driver.readPoint(mode,X(k));
                raw{k} = line;

                ui.PlotView.updateLive(app,h,mode,X,Y,k);
                callbacks.autosave('in_progress',X(1:k),Y(1:k),raw(1:k),k,'in_progress');
                callbacks.setStatus(sprintf('Sweeping %d / %d',k,nPts),'busy');
                drawnow limitrate;
            end

            driver.zeroSource(mode);
            pause(0.1);
            driver.outputOff();
        end

        function [Y,raw] = runDebug(app,mode,X,compliance,nplc,settleT,devName,profileChoice,callbacks,rangeMode,rangeValue)
            nPts = numel(X);
            Y = nan(nPts,1);
            raw = cell(nPts,1);
            if nargin < 10 || isempty(rangeMode)
                rangeMode = 'Auto range';
            end
            if nargin < 11 || isempty(rangeValue)
                rangeValue = Inf;
            end

            [fullY,profileName] = hardware.DebugSMU.generateMeasurement(mode,X,devName,nplc,profileChoice);
            [fullY,debugComplianceHit] = hardware.DebugSMU.applyCompliance(fullY,compliance);
            callbacks.log(sprintf('Debug measurement profile: %s. Simulated NPLC %.3g.',profileName,nplc));
            if debugComplianceHit
                callbacks.log(sprintf('Debug compliance limit reached. Simulated readings were clipped to %.4g.',compliance),'debug');
            end
            [fullY,debugRangeHit] = hardware.DebugSMU.applyMeasureRange(fullY,rangeMode,rangeValue);
            if debugRangeHit
                callbacks.log(sprintf('Debug fixed measurement range exceeded. Out-of-range simulated readings were set to NaN. Range = %.4g.',rangeValue),'debug');
            end

            h = ui.PlotView.prepareLive(app,mode,devName,'Debug',X);

            for k = 1:nPts
                if callbacks.isAbort()
                    break;
                end

                while callbacks.isPaused() && ~callbacks.isAbort()
                    callbacks.setStatus(sprintf('Paused %d/%d',max(k-1,0),nPts),'debug');
                    drawnow;
                    pause(0.1);
                end
                if callbacks.isAbort()
                    break;
                end

                if core.SweepRunner.waitWithControls(settleT + nplc/50,callbacks,sprintf('Settling %d/%d',k,nPts),'debug')
                    break;
                end
                Y(k) = fullY(k);
                if isnan(Y(k))
                    raw{k} = hardware.DebugSMU.rawLine(mode,X(k),Y(k),'OVR');
                else
                    raw{k} = hardware.DebugSMU.rawLine(mode,X(k),Y(k));
                end

                ui.PlotView.updateLive(app,h,mode,X,Y,k);
                callbacks.autosave('debug_in_progress',X(1:k),Y(1:k),raw(1:k),k,'in_progress');
                callbacks.setStatus(sprintf('Sweep %d/%d',k,nPts),'debug');
                drawnow limitrate;
            end
        end

        function [Y,raw] = runHardwareTimeTrace(driver,app,mode,timeS,fixedSource,compliance,nplc,settleT,devName,senseMode,rangeMode,rangeValue,callbacks)
            nPts = numel(timeS);
            Y = nan(nPts,1);
            raw = cell(nPts,1);

            h = ui.PlotView.prepareLive(app,mode,devName,'Time Trace',timeS);
            acceptedNplc = driver.configureSweep(mode,compliance,nplc,senseMode,rangeMode,rangeValue);
            if ~isempty(acceptedNplc)
                callbacks.log(['Meter accepted NPLC: ' acceptedNplc]);
            end

            driver.autozeroOnce();
            driver.zeroSource(mode);
            driver.outputOn();
            t0 = tic;
            if nPts > 1
                targetInterval = timeS(2) - timeS(1);
            else
                targetInterval = 0;
            end

            for k = 1:nPts
                if callbacks.isAbort()
                    break;
                end
                while callbacks.isPaused() && ~callbacks.isAbort()
                    callbacks.setStatus(sprintf('Paused %d / %d',max(k-1,0),nPts),'busy');
                    drawnow;
                    pause(0.1);
                end
                if core.SweepRunner.waitWithControls(settleT,callbacks,sprintf('Settling %d / %d',k,nPts),'busy')
                    break;
                end
                [Y(k),line] = driver.readPoint(mode,fixedSource);
                raw{k} = line;
                timeS(k) = toc(t0);
                ui.PlotView.updateLive(app,h,mode,timeS,Y,k);
                callbacks.autosave('time_trace_in_progress',timeS(1:k),Y(1:k),raw(1:k),k,'in_progress');
                callbacks.setStatus(sprintf('Time trace %d / %d',k,nPts),'busy');
                drawnow limitrate;
                if k < nPts
                    if core.SweepRunner.waitWithControls(max(0,k*targetInterval - toc(t0)),callbacks,sprintf('Waiting trace interval %d / %d',k,nPts),'busy')
                        break;
                    end
                end
            end

            driver.zeroSource(mode);
            pause(0.1);
            driver.outputOff();
        end

        function [Y,raw] = runDebugTimeTrace(app,mode,timeS,fixedSource,compliance,nplc,settleT,devName,profileChoice,callbacks,rangeMode,rangeValue)
            nPts = numel(timeS);
            Y = nan(nPts,1);
            raw = cell(nPts,1);
            if nargin < 11 || isempty(rangeMode)
                rangeMode = 'Auto range';
            end
            if nargin < 12 || isempty(rangeValue)
                rangeValue = Inf;
            end
            [baseY,profileName] = hardware.DebugSMU.generateMeasurement(mode,fixedSource + zeros(size(timeS)),devName,nplc,profileChoice);
            [baseY,debugComplianceHit] = hardware.DebugSMU.applyCompliance(baseY,compliance);
            callbacks.log(sprintf('Debug time trace profile: %s. Simulated NPLC %.3g.',profileName,nplc));
            if debugComplianceHit
                callbacks.log(sprintf('Debug compliance limit reached. Simulated readings were clipped to %.4g.',compliance),'debug');
            end
            [baseY,debugRangeHit] = hardware.DebugSMU.applyMeasureRange(baseY,rangeMode,rangeValue);
            if debugRangeHit
                callbacks.log(sprintf('Debug fixed measurement range exceeded. Out-of-range simulated readings were set to NaN. Range = %.4g.',rangeValue),'debug');
            end
            h = ui.PlotView.prepareLive(app,mode,devName,'Debug Time Trace',timeS);
            t0 = tic;
            if nPts > 1
                targetInterval = timeS(2) - timeS(1);
            else
                targetInterval = 0;
            end
            for k = 1:nPts
                if callbacks.isAbort()
                    break;
                end
                while callbacks.isPaused() && ~callbacks.isAbort()
                    callbacks.setStatus(sprintf('Paused %d/%d',max(k-1,0),nPts),'debug');
                    drawnow;
                    pause(0.1);
                end
                if core.SweepRunner.waitWithControls(settleT + nplc/50,callbacks,sprintf('Settling trace %d/%d',k,nPts),'debug')
                    break;
                end
                Y(k) = baseY(k);
                timeS(k) = toc(t0);
                if isnan(Y(k))
                    raw{k} = hardware.DebugSMU.rawLine(mode,fixedSource,Y(k),'OVR');
                else
                    raw{k} = hardware.DebugSMU.rawLine(mode,fixedSource,Y(k));
                end
                ui.PlotView.updateLive(app,h,mode,timeS,Y,k);
                callbacks.autosave('debug_time_trace_in_progress',timeS(1:k),Y(1:k),raw(1:k),k,'in_progress');
                callbacks.setStatus(sprintf('Trace %d/%d',k,nPts),'debug');
                drawnow limitrate;
                if k < nPts
                    if core.SweepRunner.waitWithControls(max(0,k*targetInterval - toc(t0)),callbacks,sprintf('Waiting trace interval %d/%d',k,nPts),'debug')
                        break;
                    end
                end
            end
        end

        function aborted = waitWithControls(durationS,callbacks,statusText,statusState)
            aborted = false;
            durationS = max(0,durationS);
            t0 = tic;
            while toc(t0) < durationS
                drawnow;
                if callbacks.isAbort()
                    aborted = true;
                    return;
                end
                while callbacks.isPaused() && ~callbacks.isAbort()
                    callbacks.setStatus(statusText,statusState);
                    drawnow;
                    pause(0.05);
                end
                if callbacks.isAbort()
                    aborted = true;
                    return;
                end
                pause(min(0.05,max(0,durationS - toc(t0))));
            end
        end

    end
end
