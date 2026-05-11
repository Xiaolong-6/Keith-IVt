function check_csv_roundtrip
% Verify export/import round trip for simple device data.

tmpFolder = fullfile(tempdir,'iv_studio_dev_checks');
data.DataManager.ensureFolder(tmpFolder);
filename = fullfile(tmpFolder,'roundtrip.csv');

dev = struct();
dev.name = 'DevCheck';
dev.mode = 'VOLT';
dev.X = (-0.2:0.1:0.2)';
dev.Y = dev.X./1000;
dev.visible = true;
dev.raw = {};
dev.meta = struct('Check','csv_roundtrip');

T = data.DataManager.tableForDeviceData(dev,false);
data.CsvIO.writeTableWithMetadata(filename,T,data.DataManager.metadataRowsForDevice(dev,'simple'));
T2 = data.CsvIO.readCsvDataTable(filename);
devices = data.ImportManager.devicesFromTable(T2,filename);

assert(isscalar(devices));
assert(strcmp(devices(1).mode,'VOLT'));
assert(max(abs(devices(1).X - dev.X)) < 1e-12);
assert(max(abs(devices(1).Y - dev.Y)) < 1e-12);

fprintf('check_csv_roundtrip passed.\n');
end
