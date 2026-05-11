classdef ExportUiWorkflow
    methods(Static)
        function [app,logLine] = saveDevice(app,dev)
            logLine = '';
            app.exportFolder = strtrim(app.exportFolderEdit.Value);
            [defaultName,T,metadataRows,modeName] = data.ExportWorkflow.selectedDeviceExport(dev,app.exportModeDrop.Value);

            [file,path] = uiputfile('*.csv','Save device data',fullfile(app.exportFolder,defaultName));
            if ~ischar(file)
                return;
            end

            app.exportFolder = path;
            app.exportFolderEdit.Value = path;
            data.ExportWorkflow.writeCsv(fullfile(path,file),T,metadataRows);
            logLine = ['Saved device in ' modeName ' format: ' fullfile(path,file)];
        end

        function [app,logLine] = saveAllDevices(app)
            logLine = '';
            app.exportFolder = strtrim(app.exportFolderEdit.Value);
            [defaultName,T,metadataRows,modeName] = data.ExportWorkflow.allDevicesExport(app.devices,app.exportModeDrop.Value);

            [file,path] = uiputfile('*.csv','Save all devices',fullfile(app.exportFolder,defaultName));
            if ~ischar(file)
                return;
            end

            app.exportFolder = path;
            app.exportFolderEdit.Value = path;
            data.ExportWorkflow.writeCsv(fullfile(path,file),T,metadataRows);
            logLine = ['Saved all devices in ' modeName ' format: ' fullfile(path,file)];
        end

        function [app,filename,selected] = chooseImportFile(app)
            [file,path] = uigetfile('*.csv','Import measured CSV data',app.exportFolder);
            selected = ischar(file);
            filename = '';
            if ~selected
                return;
            end
            filename = fullfile(path,file);
            app.exportFolder = path;
            app.exportFolderEdit.Value = path;
        end

        function [app,nAdded] = importCsv(app,filename)
            importedDevices = data.ExportWorkflow.importDevices(filename);
            app.devices = [app.devices importedDevices];
            nAdded = numel(importedDevices);
        end
    end
end
