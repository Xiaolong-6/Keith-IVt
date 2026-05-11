classdef AppLog
    methods(Static)
        function write(logText,cacheLogFile,cacheLogMaxBytes,msg,level)
            if nargin < 5 || isempty(level)
                level = ui.AppLog.inferLevel(msg);
            end
            msg = char(string(msg));
            stamp = core.TimeUtil.dateTimeText();
            level = char(string(level));
            line = [stamp '  [' upper(level) '] ' msg];

            ui.AppLog.appendToTextArea(logText,line);
            try
                data.DataManager.appendRotatingLog(cacheLogFile,line,cacheLogMaxBytes);
            catch
            end
            drawnow limitrate;
        end

        function tf = shouldShow(developerLog,msg,level)
            if developerLog
                tf = true;
                return;
            end
            if nargin < 3 || isempty(level)
                level = ui.AppLog.inferLevel(msg);
            end
            level = lower(char(string(level)));
            msgLower = lower(char(string(msg)));
            if any(strcmp(level,{'error','warning'}))
                tf = true;
                return;
            end
            important = { ...
                'session started', ...
                'connected', ...
                'disconnected', ...
                'connection failed', ...
                'sweep finished', ...
                'sweep aborted', ...
                'sweep error', ...
                'saved', ...
                'imported', ...
                'cleared', ...
                'autosaved completed', ...
                'autosaved aborted'};
            tf = false;
            for k = 1:numel(important)
                if contains(msgLower,important{k})
                    tf = true;
                    return;
                end
            end
        end
        function appendToTextArea(logText,line)
            if isempty(logText) || ~isvalid(logText)
                return;
            end
            old = logText.Value;
            if isempty(old)
                old = {};
            elseif ischar(old) || isstring(old)
                old = cellstr(old);
            end
            logText.Value = [old(:); {line}];
            ui.AppLog.scrollToLatest(logText);
        end

        function scrollToLatest(logText)
            try
                lastRow = numel(logText.Value);
                if lastRow < 1
                    return;
                end
                logText.Value = logText.Value;
                drawnow limitrate;
                scroll(logText,'bottom');
            catch
            end
        end

        function level = inferLevel(msg)
            msg = lower(char(string(msg)));
            if contains(msg,'error') || contains(msg,'failed') || contains(msg,'problem')
                level = 'error';
            elseif contains(msg,'finished') || contains(msg,'saved') || contains(msg,'connected') || contains(msg,'validated')
                level = 'success';
            elseif contains(msg,'debug')
                level = 'debug';
            else
                level = 'info';
            end
        end
    end
end
