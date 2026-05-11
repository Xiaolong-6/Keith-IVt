classdef DataManager
    methods(Static)
        function ensureFolder(folder)
            if ~isfolder(folder)
                mkdir(folder);
            end
        end

        function filename = cacheCsvPath(cacheFolder,baseName,kind)
            data.DataManager.ensureFolder(cacheFolder);
            baseName = data.CsvIO.sanitizeName(baseName);
            kind = data.CsvIO.sanitizeName(kind);
            filename = fullfile(cacheFolder,sprintf('%s_%s_latest.csv',baseName,kind));
        end

        function rows = recoveryTableData(cacheFolder,maxRows)
            data.DataManager.ensureFolder(cacheFolder);
            files = dir(fullfile(cacheFolder,'*.csv'));
            [~,idx] = sort([files.datenum],'descend');
            files = files(idx);
            if numel(files) > maxRows
                files = files(1:maxRows);
            end

            rows = cell(numel(files),3);
            for k = 1:numel(files)
                rows{k,1} = files(k).name;
                rows{k,2} = core.TimeUtil.fromDatenum(files(k).datenum);
                rows{k,3} = round(files(k).bytes/1024,1);
            end
        end

        function T = tableForDeviceData(dev,includeCalculated)
            if data.DataManager.isTimeTrace(dev)
                if strcmp(dev.mode,'VOLT')
                    T = table(dev.X(:),dev.Y(:),'VariableNames',{'Time_s','Current_A'});
                else
                    T = table(dev.X(:),dev.Y(:),'VariableNames',{'Time_s','Voltage_V'});
                end
            elseif strcmp(dev.mode,'VOLT')
                T = table(dev.X(:),dev.Y(:),'VariableNames',{'Voltage_V','Current_A'});
            else
                T = table(dev.X(:),dev.Y(:),'VariableNames',{'Current_A','Voltage_V'});
            end

            if includeCalculated && ~data.DataManager.isTimeTrace(dev)
                calc = core.SweepMath.calcElectrical(dev.mode,dev.X,dev.Y);
                T.ShuntResistance_ohm = calc.R_shunt_ohm(:);
                T.Conductance_S = calc.G_conductance_S(:);
                T.DifferentialResistance_ohm = calc.R_diff_ohm(:);
            end
        end

        function T = tableForAllDevicesExport(devices,includeCalculated)
            maxLen = max(arrayfun(@(dev)numel(dev.X),devices));
            T = table();
            usedDeviceNames = cell(1,numel(devices));
            deviceNameCount = 0;

            for k = 1:numel(devices)
                dev = devices(k);
                devBase = data.DataManager.makeUniqueVarName(dev.name,usedDeviceNames(1:deviceNameCount));
                deviceNameCount = deviceNameCount + 1;
                usedDeviceNames{deviceNameCount} = devBase;

                xCol = nan(maxLen,1);
                yCol = nan(maxLen,1);
                xCol(1:numel(dev.X)) = dev.X(:);
                yCol(1:numel(dev.Y)) = dev.Y(:);

                if data.DataManager.isTimeTrace(dev)
                    xName = data.DataManager.makeValidVarName([devBase '_Time_s']);
                    if strcmp(dev.mode,'VOLT')
                        yName = data.DataManager.makeValidVarName([devBase '_Current_A']);
                    else
                        yName = data.DataManager.makeValidVarName([devBase '_Voltage_V']);
                    end
                elseif strcmp(dev.mode,'VOLT')
                    xName = data.DataManager.makeValidVarName([devBase '_Voltage_V']);
                    yName = data.DataManager.makeValidVarName([devBase '_Current_A']);
                else
                    xName = data.DataManager.makeValidVarName([devBase '_Current_A']);
                    yName = data.DataManager.makeValidVarName([devBase '_Voltage_V']);
                end

                T.(xName) = xCol;
                T.(yName) = yCol;

                if includeCalculated && ~data.DataManager.isTimeTrace(dev)
                    calc = core.SweepMath.calcElectrical(dev.mode,dev.X,dev.Y);
                    rCol = nan(maxLen,1);
                    gCol = nan(maxLen,1);
                    rdCol = nan(maxLen,1);
                    rCol(1:numel(dev.X)) = calc.R_shunt_ohm(:);
                    gCol(1:numel(dev.X)) = calc.G_conductance_S(:);
                    rdCol(1:numel(dev.X)) = calc.R_diff_ohm(:);

                    rName = data.DataManager.makeValidVarName([devBase '_ShuntResistance_ohm']);
                    gName = data.DataManager.makeValidVarName([devBase '_Conductance_S']);
                    rdName = data.DataManager.makeValidVarName([devBase '_DifferentialResistance_ohm']);

                    T.(rName) = rCol;
                    T.(gName) = gCol;
                    T.(rdName) = rdCol;
                end
            end
        end

        function rows = metadataRowsForDevice(dev,exportModeName)
            rows = data.ExportMetadata.forDevice(dev,exportModeName);
        end

        function rows = metadataRowsForAllDevices(devices,exportModeName)
            rows = data.ExportMetadata.forAllDevices(devices,exportModeName);
        end

        function appendRotatingLog(logFile,line,maxBytes)
            if isempty(logFile)
                return;
            end
            cacheFolder = fileparts(logFile);
            data.DataManager.ensureFolder(cacheFolder);
            data.DataManager.rotateLogIfNeeded(logFile,maxBytes);

            fid = fopen(logFile,'a');
            if fid < 0
                return;
            end
            cleanupObj = onCleanup(@()fclose(fid));
            fprintf(fid,'%s\n',line);
            clear cleanupObj;
        end

        function rotateLogIfNeeded(logFile,maxBytes)
            if ~exist(logFile,'file')
                return;
            end
            info = dir(logFile);
            if isempty(info) || info.bytes < maxBytes
                return;
            end
            cacheFolder = fileparts(logFile);
            rotated = fullfile(cacheFolder,['session_log_' core.TimeUtil.fileStamp() '.txt']);
            movefile(logFile,rotated);
        end

        function rows = columnDescriptionRows()
            rows = {'# Column descriptions:'; ...
                '# Time_s or Device_Time_s: elapsed time in seconds for Time Trace data'; ...
                '# Voltage_V or Device_Voltage_V: voltage in V'; ...
                '# Current_A or Device_Current_A: current in A'; ...
                '# ShuntResistance_ohm: V/I in Ohm, recalculated from voltage/current'; ...
                '# Conductance_S: I/V in S, recalculated from voltage/current'; ...
                '# DifferentialResistance_ohm: numerical dV/dI in Ohm, recalculated from voltage/current'; ...
                '# Import uses only voltage/current columns; calculated columns are optional and can be reconstructed'; ...
                '# Columns use SI base units: V, A, Ohm, S'};
        end

        function rows = metadataStructRows(meta)
            f = fieldnames(meta);
            rows = cell(numel(f),1);
            for k = 1:numel(f)
                val = meta.(f{k});
                if isnumeric(val)
                    val = num2str(val);
                end
                rows{k} = ['# ' f{k} ': ' char(string(val))];
            end
        end

        function v = makeValidVarName(name)
            v = matlab.lang.makeValidName(char(string(name)));
        end

        function v = makeUniqueVarName(name,usedNames)
            v = data.DataManager.makeValidVarName(name);
            base = v;
            suffix = 2;
            while any(strcmp(v,usedNames))
                v = data.DataManager.makeValidVarName(sprintf('%s_%d',base,suffix));
                suffix = suffix + 1;
            end
        end

        function tf = isTimeTrace(dev)
            tf = isfield(dev,'meta') && isfield(dev.meta,'MeasurementType') && strcmp(dev.meta.MeasurementType,'Time Trace');
        end
    end
end
