classdef RecoveryWorkflow
    methods(Static)
        function rows = tableRows(app)
            rows = data.DataManager.recoveryTableData(app.cacheFolder,app.recoveryMaxRows);
        end

        function [filename,ok] = selectedFile(app)
            filename = '';
            ok = false;
            sel = app.recoveryTable.Selection;
            if isempty(sel)
                return;
            end
            recoveryRows = app.recoveryTable.Data;
            row = sel(1);
            if row < 1 || row > size(recoveryRows,1)
                return;
            end
            filename = fullfile(app.cacheFolder,recoveryRows{row,1});
            ok = true;
        end


        function openCacheFolder(app)
            data.DataManager.ensureFolder(app.cacheFolder);
            try
                if ispc
                    winopen(app.cacheFolder);
                elseif ismac
                    system(['open ' char(34) app.cacheFolder char(34)]);
                else
                    system(['xdg-open ' char(34) app.cacheFolder char(34) ' &']);
                end
            catch
                uialert(app.fig,app.cacheFolder,'Cache Folder');
            end
        end
    end
end
