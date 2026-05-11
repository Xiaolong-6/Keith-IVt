classdef SweepAutosave
    methods(Static)
        function filename = recoveryFile(cacheFolder,devName,comment,sweepName)
            filename = data.DataManager.cacheCsvPath(cacheFolder,[data.CommentUtil.fileLabel(devName,comment) '_recovery_current'],sweepName);
        end

        function filename = finalFile(cacheFolder,devName,statusText,dev,exportModeText)
            kind = data.ExportOptions.kindForDevice(dev,exportModeText);
            filename = data.DataManager.cacheCsvPath(cacheFolder,[data.CommentUtil.fileLabel(devName,dev.comment) '_autosave_' statusText],kind);
        end

        function writeStarted(filename,devName,mode,sweepName,X,compliance,nplc,settleT,context,exportModeText)
            Y = nan(size(X));
            raw = core.SweepMetadata.emptyRaw(numel(X));
            core.SweepAutosave.writeSnapshot(filename,devName,mode,sweepName,X,Y,raw,0,compliance,nplc,settleT,'started',context,exportModeText);
        end

        function filename = writeFinal(cacheFolder,devName,mode,sweepName,X,Y,raw,compliance,nplc,settleT,statusText,context,exportModeText)
            data.DataManager.ensureFolder(cacheFolder);
            dev = core.SweepMetadata.device(devName,context.Comment,mode,X,Y,raw, ...
                core.SweepMetadata.create(devName,mode,sweepName,X,compliance,nplc,settleT,Y,context));
            dev.meta.AutosaveStatus = statusText;
            filename = core.SweepAutosave.finalFile(cacheFolder,devName,statusText,dev,exportModeText);
            core.SweepAutosave.writeDevice(filename,dev,exportModeText);
        end

        function writeSnapshot(filename,devName,mode,sweepName,X,Y,raw,k,compliance,nplc,settleT,statusText,context,exportModeText)
            dev = core.SweepMetadata.device(devName,context.Comment,mode,X(:),Y(:),raw, ...
                core.SweepMetadata.create(devName,mode,sweepName,X(:),compliance,nplc,settleT,Y,context));
            dev.meta.AutosaveStatus = statusText;
            dev.meta.PointsMeasured = k;
            core.SweepAutosave.writeDevice(filename,dev,exportModeText);
        end

        function writeDevice(filename,dev,exportModeText)
            T = data.DataManager.tableForDeviceData(dev,true);
            modeName = data.ExportOptions.modeName(exportModeText);
            data.CsvIO.writeTableWithMetadata(filename,T,data.DataManager.metadataRowsForDevice(dev,modeName));
        end
    end
end
