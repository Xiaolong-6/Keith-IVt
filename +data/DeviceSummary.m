classdef DeviceSummary
    methods(Static)
        function rows = tableRows(devices)
            n = numel(devices);
            rows = cell(n,6);
            for k = 1:n
                rows{k,1} = devices(k).visible;
                rows{k,2} = devices(k).name;
                if isfield(devices,'comment')
                    rows{k,3} = devices(k).comment;
                else
                    rows{k,3} = '';
                end
                rows{k,4} = devices(k).mode;
                rows{k,5} = numel(devices(k).X);
                rows{k,6} = max(abs(devices(k).Y),[],'omitnan');
            end
        end
    end
end
