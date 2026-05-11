classdef ImportManager
    methods(Static)
        function devices = devicesFromTable(T,filename,deviceMeta)
            if nargin < 3
                deviceMeta = data.ExportMetadata.parseFile(filename);
            end
            devices = struct('name',{},'comment',{},'mode',{},'X',{},'Y',{},'visible',{},'raw',{},'meta',{});
            vars = T.Properties.VariableNames;
            used = false(size(vars));

            if any(strcmp(vars,'Voltage_V')) && any(strcmp(vars,'Current_A'))
                vIdx = find(strcmp(vars,'Voltage_V'),1);
                iIdx = find(strcmp(vars,'Current_A'),1);
                meta = data.ImportManager.singleDeviceMeta(deviceMeta,filename);
                if vIdx < iIdx
                    devices(end+1) = data.ImportManager.makeDevice(meta.name,'VOLT',T.Voltage_V,T.Current_A,filename,meta);
                else
                    devices(end+1) = data.ImportManager.makeDevice(meta.name,'CURR',T.Current_A,T.Voltage_V,filename,meta);
                end
                return;
            end
            if any(strcmp(vars,'Time_s')) && (any(strcmp(vars,'Current_A')) || any(strcmp(vars,'Voltage_V')))
                tIdx = find(strcmp(vars,'Time_s'),1);
                meta = data.ImportManager.singleDeviceMeta(deviceMeta,filename);
                meta.fields.MeasurementType = 'Time Trace';
                if any(strcmp(vars,'Current_A'))
                    devices(end+1) = data.ImportManager.makeDevice(meta.name,'VOLT',T.Time_s,T.Current_A,filename,meta);
                else
                    devices(end+1) = data.ImportManager.makeDevice(meta.name,'CURR',T.Time_s,T.Voltage_V,filename,meta);
                end
                used(tIdx) = true; %#ok<NASGU>
                return;
            end

            for k = 1:numel(vars)
                vName = vars{k};
                if used(k) || ~endsWith(vName,'_Time_s')
                    continue;
                end
                prefix = vName(1:end-length('_Time_s'));
                iName = [prefix '_Current_A'];
                vMeasName = [prefix '_Voltage_V'];
                iIdx = find(strcmp(vars,iName),1);
                vIdx = find(strcmp(vars,vMeasName),1);
                meta = data.ExportMetadata.findByPrefix(deviceMeta,prefix);
                if ~isempty(meta)
                    meta.fields.MeasurementType = 'Time Trace';
                end
                if ~isempty(iIdx)
                    dev = data.ImportManager.makeDevice(prefix,'VOLT',T.(vName),T.(iName),filename,meta);
                    devices(end+1) = dev; %#ok<AGROW>
                    used([k iIdx]) = true;
                elseif ~isempty(vIdx)
                    dev = data.ImportManager.makeDevice(prefix,'CURR',T.(vName),T.(vMeasName),filename,meta);
                    devices(end+1) = dev; %#ok<AGROW>
                    used([k vIdx]) = true;
                end
            end

            for k = 1:numel(vars)
                vName = vars{k};
                if used(k) || ~endsWith(vName,'_Voltage_V')
                    continue;
                end
                prefix = vName(1:end-length('_Voltage_V'));
                cName = [prefix '_Current_A'];
                cIdx = find(strcmp(vars,cName),1);
                if isempty(cIdx)
                    continue;
                end
                meta = data.ExportMetadata.findByPrefix(deviceMeta,prefix);

                if k < cIdx
                    dev = data.ImportManager.makeDevice(prefix,'VOLT',T.(vName),T.(cName),filename,meta);
                else
                    dev = data.ImportManager.makeDevice(prefix,'CURR',T.(cName),T.(vName),filename,meta);
                end
                if ~isempty(dev)
                    devices(end+1) = dev; %#ok<AGROW>
                end
                used([k cIdx]) = true;
            end

            for k = 1:numel(vars)
                cName = vars{k};
                if used(k) || ~endsWith(cName,'_Current_A')
                    continue;
                end
                prefix = cName(1:end-length('_Current_A'));
                vName = [prefix '_Voltage_V'];
                vIdx = find(strcmp(vars,vName),1);
                if isempty(vIdx) || used(vIdx)
                    continue;
                end
                meta = data.ExportMetadata.findByPrefix(deviceMeta,prefix);

                if k < vIdx
                    dev = data.ImportManager.makeDevice(prefix,'CURR',T.(cName),T.(vName),filename,meta);
                else
                    dev = data.ImportManager.makeDevice(prefix,'VOLT',T.(vName),T.(cName),filename,meta);
                end
                if ~isempty(dev)
                    devices(end+1) = dev; %#ok<AGROW>
                end
                used([k vIdx]) = true;
            end
        end

        function dev = makeDevice(name,mode,X,Y,filename,parsedMeta)
            if nargin < 6 || isempty(parsedMeta)
                parsedMeta = data.ExportMetadata.emptyParsedDevice();
                parsedMeta.name = name;
            end
            X = X(:);
            Y = Y(:);
            keep = ~(isnan(X) & isnan(Y));
            X = X(keep);
            Y = Y(keep);
            if isempty(X)
                dev = [];
                return;
            end

            dev = struct();
            if ~isempty(parsedMeta.name)
                dev.name = data.ImportManager.sanitizeName(parsedMeta.name);
            else
                dev.name = data.ImportManager.sanitizeName(name);
            end
            dev.comment = data.CommentUtil.sanitize(parsedMeta.comment);
            if ~isempty(parsedMeta.mode)
                dev.mode = parsedMeta.mode;
            else
                dev.mode = mode;
            end
            dev.X = X;
            dev.Y = Y;
            dev.visible = true;
            dev.raw = {};
            dev.meta = parsedMeta.fields;
            dev.meta.ImportedFrom = filename;
            dev.meta.DateTime = core.TimeUtil.dateTimeText();
        end

        function meta = singleDeviceMeta(deviceMeta,filename)
            if ~isempty(deviceMeta)
                meta = deviceMeta(1);
                if isempty(meta.name)
                    meta.name = data.ImportManager.fileBaseName(filename);
                end
            else
                meta = data.ExportMetadata.emptyParsedDevice();
                meta.name = data.ImportManager.fileBaseName(filename);
            end
        end

        function base = fileBaseName(filename)
            [~,base] = fileparts(filename);
            base = data.ImportManager.sanitizeName(base);
        end

        function safe = sanitizeName(name)
            name = char(name);
            safe = regexprep(name,'[^\w]','_');
            if isempty(safe)
                safe = 'Device';
            end
        end
    end
end
