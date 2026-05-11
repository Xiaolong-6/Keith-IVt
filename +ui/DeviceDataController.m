classdef DeviceDataController
    methods(Static)
        function [app,refreshTable,refreshPlot,logLine] = tableEdited(app,event)
            [app,action,logLine] = ui.DeviceWorkflow.editTable(app,event);
            refreshTable = any(strcmp(action,{'refreshTable','refreshTableAndPlots'}));
            refreshPlot = any(strcmp(action,{'refreshPlots','refreshTableAndPlots'}));
        end

        function [app,ok,message,logLine] = deleteSelected(app)
            [app,name,ok] = ui.DeviceWorkflow.deleteSelected(app);
            message = '';
            logLine = '';
            if ~ok
                message = 'Select a device row first.';
                return;
            end
            logLine = ['Deleted device: ' name];
        end

        function [app,ok,message,logLine] = saveSelected(app)
            ok = false;
            message = '';
            logLine = '';
            idx = ui.DeviceWorkflow.selectedIndex(app);
            if isempty(idx)
                message = 'Select a device row first.';
                return;
            end
            [app,logLine] = ui.ExportUiWorkflow.saveDevice(app,app.devices(idx));
            ok = true;
        end

        function [app,ok,message,logLine] = chooseAndImport(app)
            ok = false;
            message = '';
            logLine = '';
            [app,filename,selected] = ui.ExportUiWorkflow.chooseImportFile(app);
            if ~selected
                return;
            end
            try
                [app,nAdded] = ui.ExportUiWorkflow.importCsv(app,filename);
                ok = true;
                logLine = sprintf('Imported %d device(s) from %s.',nAdded,filename);
            catch ME
                message = ME.message;
                logLine = ['Import failed: ' ME.message];
            end
        end

        function [app,ok,message,logLine] = importSelectedRecovery(app)
            ok = false;
            message = '';
            logLine = '';
            [filename,selected] = ui.RecoveryWorkflow.selectedFile(app);
            if ~selected
                message = 'Select one recovery file first.';
                return;
            end
            try
                [app,nAdded] = ui.ExportUiWorkflow.importCsv(app,filename);
                ok = true;
                logLine = sprintf('Imported %d device(s) from %s.',nAdded,filename);
            catch ME
                message = ME.message;
                logLine = ['Recovery import failed: ' ME.message];
            end
        end

        function [app,ok,message,logLine] = saveAll(app)
            ok = false;
            message = '';
            logLine = '';
            if isempty(app.devices)
                message = 'No devices to save.';
                return;
            end
            [app,logLine] = ui.ExportUiWorkflow.saveAllDevices(app);
            ok = true;
        end

        function [app,logLine] = clearAll(app)
            app = ui.DeviceWorkflow.clearAll(app);
            logLine = 'Cleared all stored devices.';
        end
    end
end
