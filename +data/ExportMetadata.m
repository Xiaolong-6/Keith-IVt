classdef ExportMetadata
    methods(Static)
        function rows = forDevice(dev,exportModeName)
            rows = {'# Keithley 2400 IV export'; ['# Exported: ' core.TimeUtil.dateTimeText()]; ['# ExportType: ' exportModeName]};
            rows = [rows; data.ExportMetadata.deviceBlockRows(1,dev,data.CsvIO.sanitizeName(dev.name))];
            rows = [rows; data.DataManager.columnDescriptionRows(); '#'];
        end

        function rows = forAllDevices(devices,exportModeName)
            rows = {'# Keithley 2400 IV export - all devices'; ['# Exported: ' core.TimeUtil.dateTimeText()]; ...
                ['# ExportType: ' exportModeName]; ...
                '# Format: each device has its own source/measure column pair'; ...
                '# Advanced format also adds calculated resistance/conductance columns'; ...
                '# Data columns are named as Device_Quantity_Unit'};
            rows = [rows; data.DataManager.columnDescriptionRows()];

            prefixes = data.ExportMetadata.dataPrefixes(devices);
            for k = 1:numel(devices)
                rows = [rows; data.ExportMetadata.deviceBlockRows(k,devices(k),prefixes{k})]; %#ok<AGROW>
            end
            rows = [rows; '#'];
        end

        function rows = deviceBlockRows(index,dev,dataPrefix)
            rows = {sprintf('# Device %d',index); ...
                ['# Name: ' dev.name]; ...
                ['# Operator: ' data.ExportMetadata.deviceComment(dev)]; ...
                ['# DataPrefix: ' dataPrefix]; ...
                ['# Mode: ' dev.mode]};
            if isfield(dev,'meta') && ~isempty(dev.meta)
                rows = [rows; data.DataManager.metadataStructRows(dev.meta)];
            end
        end

        function prefixes = dataPrefixes(devices)
            prefixes = cell(1,numel(devices));
            used = cell(1,numel(devices));
            count = 0;
            for k = 1:numel(devices)
                prefix = data.DataManager.makeUniqueVarName(devices(k).name,used(1:count));
                count = count + 1;
                used{count} = prefix;
                prefixes{k} = prefix;
            end
        end

        function comment = deviceComment(dev)
            comment = '';
            if isfield(dev,'comment')
                comment = data.CommentUtil.sanitize(dev.comment);
            elseif isfield(dev,'meta') && isfield(dev.meta,'Operator')
                comment = data.CommentUtil.sanitize(dev.meta.Operator);
            elseif isfield(dev,'meta') && isfield(dev.meta,'Comment')
                comment = data.CommentUtil.sanitize(dev.meta.Comment);
            end
        end

        function deviceMeta = parseFile(filename)
            lines = data.CsvIO.readMetadataLines(filename);
            deviceMeta = struct('name',{},'comment',{},'dataPrefix',{},'mode',{},'fields',{});
            current = [];
            for k = 1:numel(lines)
                line = strtrim(lines{k});
                if startsWith(line,'#')
                    line = strtrim(extractAfter(line,1));
                end
                if startsWith(line,'Device ')
                    if ~isempty(current)
                        deviceMeta(end+1) = current; %#ok<AGROW>
                    end
                    current = data.ExportMetadata.emptyParsedDevice();
                    continue;
                end
                if isempty(current) || ~contains(line,':')
                    continue;
                end
                parts = split(line,':');
                key = strtrim(parts{1});
                value = strtrim(strjoin(parts(2:end),':'));
                switch key
                    case 'Name'
                        current.name = char(value);
                    case 'Comment'
                        current.comment = data.CommentUtil.sanitize(value);
                    case 'Operator'
                        current.comment = data.CommentUtil.sanitize(value);
                    case 'DataPrefix'
                        current.dataPrefix = char(value);
                    case 'Mode'
                        current.mode = char(value);
                end
                safeKey = matlab.lang.makeValidName(key);
                current.fields.(safeKey) = char(value);
            end
            if ~isempty(current)
                deviceMeta(end+1) = current;
            end
        end

        function parsed = emptyParsedDevice()
            parsed = struct('name','','comment','','dataPrefix','','mode','','fields',struct());
        end

        function meta = findByPrefix(deviceMeta,prefix)
            meta = [];
            for k = 1:numel(deviceMeta)
                if strcmp(deviceMeta(k).dataPrefix,prefix) || strcmp(deviceMeta(k).name,prefix)
                    meta = deviceMeta(k);
                    return;
                end
            end
        end
    end
end
