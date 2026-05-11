classdef AppInfo
    methods(Static)
        function info = current()
            info = struct();
            info.Name = 'Keith-IVt';
            info.Version = '0.3.0 beta';
            info.ReleaseURL = 'https://github.com/Xiaolong-6/Keith-IVt/releases';
            info.WindowTitle = [info.Name ' ' info.Version];
        end
    end
end
