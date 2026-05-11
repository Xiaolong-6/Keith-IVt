classdef AppUiWorkflow
    methods(Static)
        function [app,logLine] = applyFontScale(app,value)
            value = ui.AppUiWorkflow.choiceText(value,'Normal');
            switch value
                case 'Compact'
                    app.fontScale = 0.92;
                case 'Large'
                    app.fontScale = 1.14;
                case 'Extra large'
                    app.fontScale = 1.28;
                otherwise
                    app.fontScale = 1.00;
            end
            try
                setappdata(app.fig,'KeithIVtFontScale',app.fontScale);
            catch
            end
            ui.Theme.apply(app);
            logLine = sprintf('UI font size changed to %s (scale %.2f).',value,app.fontScale);
        end

        function [app,runState,logLine] = applyTheme(app,value)
            app.themeName = ui.AppUiWorkflow.choiceText(value,'Light');
            if ~strcmp(app.themeName,'Dark')
                app.themeName = 'Light';
            end
            try
                setappdata(app.fig,'KeithIVtThemeName',app.themeName);
                setappdata(groot,'KeithIVtThemeName',app.themeName);
            catch
            end
            ui.Theme.apply(app);
            runState = ui.AppUiWorkflow.currentRunState(app);
            logLine = sprintf('UI theme changed to %s.',app.themeName);
        end

        function [app,selected,logLine] = chooseExportFolder(app)
            selected = false;
            logLine = '';
            folder = uigetdir(app.exportFolder,'Choose default export folder');
            if isequal(folder,0)
                return;
            end
            selected = true;
            app.exportFolder = folder;
            app.exportFolderEdit.Value = folder;
            logLine = ['Export folder set to: ' folder];
        end

        function lines = loadAboutText(aboutFile)
            if exist(aboutFile,'file')
                txt = fileread(aboutFile);
                lines = regexp(txt,'\r\n|\n|\r','split')';
                if ~isempty(lines) && isempty(lines{end})
                    lines(end) = [];
                end
                return;
            end
            lines = { ...
                'ABOUT.txt not found.'; ...
                'Keep ABOUT.txt in the project root folder to show app information here.' ...
                };
        end

        function [ok,logLine,errorMessage] = openReleasePage(url)
            ok = false;
            logLine = '';
            errorMessage = '';
            try
                web(url,'-browser');
                ok = true;
                logLine = ['Opened release page: ' url];
            catch ME
                errorMessage = ME.message;
                logLine = ['Could not open release page: ' ME.message];
            end
        end

        function state = currentRunState(app)
            if app.isSweeping && app.pauseRequested
                state = 'Paused';
            elseif app.isSweeping
                state = 'Sweeping';
            elseif app.connected
                state = 'Ready';
            else
                state = 'Stopped';
            end
        end

        function value = choiceText(value,fallback)
            try
                value = char(string(value));
            catch
                value = fallback;
            end
            if isempty(value)
                value = fallback;
            end
        end
    end
end
