classdef DeviceWorkflow
    methods(Static)
        function rows = tableRows(app)
            rows = data.DeviceSummary.tableRows(app.devices);
        end

        function idx = selectedIndex(app)
            idx = [];
            sel = app.devTable.Selection;
            if isempty(sel)
                return;
            end
            idx = sel(1);
            if idx < 1 || idx > numel(app.devices)
                idx = [];
            end
        end

        function [app,action,logLine] = editTable(app,event)
            action = 'none';
            logLine = '';
            row = event.Indices(1);
            col = event.Indices(2);
            if row > numel(app.devices)
                return;
            end

            if col == 1
                app.devices(row).visible = logical(event.NewData);
                action = 'refreshPlots';
            elseif col == 2
                newName = data.CsvIO.sanitizeName(string(event.NewData));
                if strlength(newName) == 0
                    newName = "Device";
                end
                app.devices(row).name = char(newName);
                action = 'refreshTableAndPlots';
                logLine = sprintf('Device %d renamed to %s.',row,char(newName));
            elseif col == 3
                app.devices(row).comment = data.CommentUtil.sanitize(event.NewData);
                action = 'refreshTable';
                logLine = sprintf('Device %d operator updated.',row);
            end
        end

        function [app,name,ok] = deleteSelected(app)
            idx = ui.DeviceWorkflow.selectedIndex(app);
            ok = ~isempty(idx);
            name = '';
            if ~ok
                return;
            end
            name = app.devices(idx).name;
            app.devices(idx) = [];
        end

        function app = clearAll(app)
            app.devices = struct('name',{},'comment',{},'mode',{},'X',{},'Y',{},'visible',{},'raw',{},'meta',{});
        end
    end
end
