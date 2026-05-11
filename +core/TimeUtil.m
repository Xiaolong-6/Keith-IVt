classdef TimeUtil
    methods(Static)

        function text = dateTimeText()
            text = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
        end

        function text = fileStamp()
            text = char(datetime('now','Format','yyyyMMdd_HHmmss'));
        end

        function text = fromDatenum(value)
            text = char(datetime(value,'ConvertFrom','datenum','Format','yyyy-MM-dd HH:mm:ss'));
        end
    end
end
