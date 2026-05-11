classdef AppTestUtil
    methods(Static)
        function fig = openApp()
            close all force;
            START_Keith_IVt;
            drawnow;
            fig = AppTestUtil.findAppFigure();
        end

        function fig = findAppFigure()
            fig = findall(groot,'Type','figure','Name',core.AppInfo.current().WindowTitle);
            assert(isscalar(fig),'Expected one IV Studio window.');
        end

        function cleanupFigures()
            close all force;
        end

        function obj = findByTag(fig,tag)
            obj = findall(fig,'Tag',tag);
            assert(isscalar(obj),'Expected one object with Tag "%s".',tag);
        end

        function pushButton(fig,tag)
            btn = AppTestUtil.findByTag(fig,tag);
            callback = btn.ButtonPushedFcn;
            callback(btn,[]);
            drawnow;
        end

        function setValue(fig,tag,value)
            ctrl = AppTestUtil.findByTag(fig,tag);
            ctrl.Value = value;
            if isprop(ctrl,'ValueChangedFcn') && ~isempty(ctrl.ValueChangedFcn)
                ctrl.ValueChangedFcn(ctrl,[]);
            end
            drawnow;
        end

        function waitForDeviceRows(fig,minRows,timeoutS)
            t0 = tic;
            while toc(t0) < timeoutS
                devTable = AppTestUtil.findByTag(fig,'devTable');
                if size(devTable.Data,1) >= minRows
                    return;
                end
                pause(0.1);
                drawnow;
            end
            error('Timed out waiting for device rows.');
        end

        function waitForStatus(fig,expectedText,timeoutS)
            t0 = tic;
            while toc(t0) < timeoutS
                labels = findall(fig,'Type','uilabel');
                texts = get(labels,'Text');
                if ischar(texts)
                    texts = {texts};
                end
                if any(strcmp(texts,expectedText))
                    return;
                end
                pause(0.1);
                drawnow;
            end
            error('Timed out waiting for status: %s',expectedText);
        end

        function waitForStatusContains(fig,expectedText,timeoutS)
            t0 = tic;
            while toc(t0) < timeoutS
                labels = findall(fig,'Type','uilabel');
                texts = get(labels,'Text');
                if ischar(texts)
                    texts = {texts};
                end
                if any(contains(texts,expectedText))
                    return;
                end
                pause(0.1);
                drawnow;
            end
            error('Timed out waiting for status containing: %s',expectedText);
        end

        function configureDebugSweep(fig,devName,startValue,stopValue,stepValue,nplc,delay)
            AppTestUtil.setValue(fig,'devEdit',devName);
            AppTestUtil.setValue(fig,'startEdit',startValue);
            AppTestUtil.setValue(fig,'stopEdit',stopValue);
            AppTestUtil.setValue(fig,'stepEdit',stepValue);
            AppTestUtil.setValue(fig,'compEdit',0.01);
            AppTestUtil.setValue(fig,'nplcEdit',nplc);
            AppTestUtil.setValue(fig,'delayEdit',delay);
        end

        function connectDebug(fig)
            AppTestUtil.pushButton(fig,'debugModeBtn');
            AppTestUtil.pushButton(fig,'connectBtn');
            AppTestUtil.waitForStatus(fig,'Debug mode',5);
        end


        function filename = recoveryFile(fig,row)
            if nargin < 2
                row = 1;
            end
            recoveryTable = AppTestUtil.findByTag(fig,'recoveryTable');
            assert(~isempty(recoveryTable.Data),'Expected recovery rows.');
            if row < 1 || row > size(recoveryTable.Data,1)
                error('Recovery row is out of range.');
            end
            cacheFolder = fullfile(fileparts(which('START_Keith_IVt')),'cache');
            filename = fullfile(cacheFolder,recoveryTable.Data{row,1});
            assert(isfile(filename),'Expected recovery file to exist: %s',filename);
        end        function deleteTimer(t)
            try
                if isvalid(t)
                    stop(t);
                    delete(t);
                end
            catch
            end
        end

        function deleteTimers(timers)
            for k = 1:numel(timers)
                AppTestUtil.deleteTimer(timers(k));
            end
        end
    end
end
