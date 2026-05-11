function check_all_export_metadata
% Verify all-device export keeps per-device metadata importable.

tmpFolder = fullfile(tempdir,'iv_studio_dev_checks');
data.DataManager.ensureFolder(tmpFolder);
filename = fullfile(tmpFolder,'all_metadata.csv');

dev1 = makeDevice('DevMix','first','VOLT','2-wire',[-1; 0; 1],[-1e-6; 0; 1e-6]);
dev2 = makeDevice('DevMix','second','CURR','4-wire',[-1e-6; 0; 1e-6],[-0.1; 0; 0.1]);
devicesIn = [dev1 dev2];

T = data.DataManager.tableForAllDevicesExport(devicesIn,false);
rows = data.DataManager.metadataRowsForAllDevices(devicesIn,'simple');
data.CsvIO.writeTableWithMetadata(filename,T,rows);

T2 = data.CsvIO.readCsvDataTable(filename);
devicesOut = data.ImportManager.devicesFromTable(T2,filename);

assert(numel(devicesOut) == 2);
assert(strcmp(devicesOut(1).comment,'first'));
assert(strcmp(devicesOut(2).comment,'second'));
assert(strcmp(devicesOut(1).mode,'VOLT'));
assert(strcmp(devicesOut(2).mode,'CURR'));
assert(strcmp(devicesOut(1).meta.SenseMode,'2-wire'));
assert(strcmp(devicesOut(2).meta.SenseMode,'4-wire'));
assert(strcmp(devicesOut(1).meta.MeasureRangeMode,'Auto range'));
assert(strcmp(devicesOut(2).meta.MeasureRangeMode,'Fixed measure range'));
assert(abs(str2double(devicesOut(2).meta.MeasureRangeValue) - 0.2) < 1e-12);
assert(max(abs(devicesOut(1).X - dev1.X)) < 1e-12);
assert(max(abs(devicesOut(2).Y - dev2.Y)) < 1e-12);

fprintf('check_all_export_metadata passed.\n');
end

function dev = makeDevice(name,comment,mode,senseMode,X,Y)
dev = struct();
dev.name = name;
dev.comment = comment;
dev.mode = mode;
dev.X = X(:);
dev.Y = Y(:);
dev.visible = true;
dev.raw = {};
if strcmp(mode,'VOLT')
    rangeMode = 'Auto range';
    rangeValue = NaN;
else
    rangeMode = 'Fixed measure range';
    rangeValue = 0.2;
end
dev.meta = struct('Device',name,'Comment',comment,'Mode',mode,'SenseMode',senseMode, ...
    'MeasureRangeMode',rangeMode,'MeasureRangeValue',rangeValue);
end
