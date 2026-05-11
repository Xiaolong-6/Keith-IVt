classdef CsvIO
    methods(Static)
        function T = readCsvDataTable(filename)
            text = fileread(filename);
            fileLines = regexp(text,'\r\n|\n|\r','split')';
            keep = false(size(fileLines));
            for k = 1:numel(fileLines)
                line = strtrim(fileLines{k});
                keep(k) = ~isempty(line) && ~startsWith(line,'#');
            end
            dataLines = fileLines(keep);
            if isempty(dataLines)
                error('No data table found. The file contains only metadata or blank lines.');
            end

            header = strtrim(dataLines{1});
            if ~contains(header,'Voltage_V') && ~contains(header,'Current_A')
                error(['No voltage/current header was found. Re-save the data with this version so the CSV includes column names, ' ...
                    'or import a CSV containing Voltage_V/Current_A or Device_Voltage_V/Device_Current_A columns.']);
            end

            tmp = [tempname '.csv'];
            fid = fopen(tmp,'w');
            if fid < 0
                error('Could not create temporary import file.');
            end
            cleanupFile = onCleanup(@()data.CsvIO.deleteIfExists(tmp));
            cleanupFid = onCleanup(@()fclose(fid));
            for k = 1:numel(dataLines)
                fprintf(fid,'%s\n',dataLines{k});
            end
            clear cleanupFid;
            T = readtable(tmp,'FileType','text','PreserveVariableNames',true);
            clear cleanupFile;
        end

        function metadataLines = readMetadataLines(filename)
            text = fileread(filename);
            fileLines = regexp(text,'\r\n|\n|\r','split')';
            keep = false(size(fileLines));
            for k = 1:numel(fileLines)
                keep(k) = startsWith(strtrim(fileLines{k}),'#');
            end
            metadataLines = fileLines(keep);
        end

        function writeTableWithMetadata(filename,T,metadataRows)
            fid = fopen(filename,'w');
            if fid < 0
                error('Could not open file for writing: %s',filename);
            end
            cleanupObj = onCleanup(@()fclose(fid));
            for k = 1:numel(metadataRows)
                fprintf(fid,'%s\n',metadataRows{k});
            end
            fprintf(fid,'%s\n',strjoin(T.Properties.VariableNames,','));
            for r = 1:height(T)
                parts = cell(1,width(T));
                for c = 1:width(T)
                    val = T{r,c};
                    if isnumeric(val)
                        if isnan(val)
                            parts{c} = '';
                        else
                            parts{c} = sprintf('%.12g',val);
                        end
                    else
                        parts{c} = data.CsvIO.csvEscape(char(string(val)));
                    end
                end
                fprintf(fid,'%s\n',strjoin(parts,','));
            end
            clear cleanupObj;
        end

        function name = defaultCsvName(baseName,kind)
            stamp = core.TimeUtil.fileStamp();
            name = sprintf('%s_%s_%s.csv',data.CsvIO.sanitizeName(baseName),kind,stamp);
        end

        function safe = sanitizeName(name)
            name = char(name);
            safe = regexprep(name,'[^\w]','_');
            if isempty(safe)
                safe = 'Device';
            end
        end

        function out = csvEscape(in)
            if contains(in,',') || contains(in,'"') || contains(in,newline) || contains(in,char(13))
                out = ['"' strrep(in,'"','""') '"'];
            else
                out = in;
            end
        end

        function deleteIfExists(filename)
            if exist(filename,'file')
                delete(filename);
            end
        end
    end
end
