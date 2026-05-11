classdef ExportOptions
    methods(Static)
        function tf = isAdvanced(exportModeText)
            tf = startsWith(exportModeText,'Advanced');
        end

        function name = modeName(exportModeText)
            if data.ExportOptions.isAdvanced(exportModeText)
                name = 'advanced';
            else
                name = 'simple';
            end
        end

        function kind = kindForDevice(dev,exportModeText)
            if strcmp(dev.mode,'VOLT')
                kind = 'IV';
            else
                kind = 'VI';
            end

            if data.ExportOptions.isAdvanced(exportModeText)
                kind = [kind '_advanced'];
            else
                kind = [kind '_simple'];
            end
        end
    end
end
