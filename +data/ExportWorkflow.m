classdef ExportWorkflow
    methods(Static)
        function [defaultName,T,metadataRows,modeName] = selectedDeviceExport(dev,exportModeText)
            comment = '';
            if isfield(dev,'comment')
                comment = dev.comment;
            end
            defaultName = data.CsvIO.defaultCsvName(data.CommentUtil.fileLabel(dev.name,comment),data.ExportOptions.kindForDevice(dev,exportModeText));
            includeCalculated = data.ExportOptions.isAdvanced(exportModeText);
            modeName = data.ExportOptions.modeName(exportModeText);
            T = data.DataManager.tableForDeviceData(dev,includeCalculated);
            metadataRows = data.DataManager.metadataRowsForDevice(dev,modeName);
        end

        function [defaultName,T,metadataRows,modeName] = allDevicesExport(devices,exportModeText)
            defaultName = data.CsvIO.defaultCsvName('AllDevices','IV');
            includeCalculated = data.ExportOptions.isAdvanced(exportModeText);
            modeName = data.ExportOptions.modeName(exportModeText);
            T = data.DataManager.tableForAllDevicesExport(devices,includeCalculated);
            metadataRows = data.DataManager.metadataRowsForAllDevices(devices,modeName);
        end

        function importedDevices = importDevices(filename)
            T = data.CsvIO.readCsvDataTable(filename);
            deviceMeta = data.ExportMetadata.parseFile(filename);
            importedDevices = data.ImportManager.devicesFromTable(T,filename,deviceMeta);
            if isempty(importedDevices)
                error('No voltage/current column pairs were found in this file.');
            end
        end

        function writeCsv(filename,T,metadataRows)
            data.CsvIO.writeTableWithMetadata(filename,T,metadataRows);
        end

    end
end
