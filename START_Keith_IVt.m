function START_Keith_IVt
% Launch Keith-IVt from the project folder.
if isdeployed
    ui.IVStudioApp(ctfroot);
else
    ui.IVStudioApp(fileparts(mfilename('fullpath')));
end
end
