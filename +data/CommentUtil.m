classdef CommentUtil
    methods(Static)
        function comment = sanitize(comment)
            comment = char(string(comment));
            comment = strtrim(comment);
            if strlength(string(comment)) > 20
                comment = char(extractBefore(string(comment),21));
            end
        end

        function name = sanitizeDeviceName(name)
            name = data.CsvIO.sanitizeName(name);
            if strlength(string(name)) > 100
                name = char(extractBefore(string(name),101));
            end
            if isempty(name)
                name = 'Device';
            end
        end

        function label = fileLabel(name,comment)
            comment = data.CommentUtil.sanitize(comment);
            if isempty(comment)
                label = data.CsvIO.sanitizeName(name);
            else
                label = data.CsvIO.sanitizeName([char(string(name)) '_' comment]);
            end
        end
    end
end
