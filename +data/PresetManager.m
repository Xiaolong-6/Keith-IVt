classdef PresetManager
    methods(Static)
        function presets = loadStore(presetFile)
            presets = struct('version',1,'items',struct());
            presets.items.Default = data.PresetManager.defaultPreset();
            if exist(presetFile,'file')
                S = load(presetFile,'presets');
                if isfield(S,'presets') && isstruct(S.presets)
                    saved = S.presets;
                    if isfield(saved,'items') && isstruct(saved.items)
                        names = fieldnames(saved.items);
                        for k = 1:numel(names)
                            presets.items.(names{k}) = saved.items.(names{k});
                        end
                    end
                end
            end
        end

        function saveStore(presetFile,presets)
            save(presetFile,'presets');
        end

        function preset = defaultPreset()
            preset = struct();
            preset.version = 1;
            preset.sourceMode = 'Voltage source: source V, measure I';
            preset.measurementType = 'Sweep';
            preset.senseMode = '2-wire';
            preset.start = -5;
            preset.stop = 5;
            preset.step = 0.1;
            preset.sweepType = 'Linear';
            preset.direction = 'Forward only';
            preset.fixedSource = 0;
            preset.duration = 10;
            preset.interval = 0.5;
            preset.compliance = 0.01;
            preset.measureRangeMode = 'Auto range';
            preset.measureRangeValue = 1e-6;
            preset.nplc = 1.0;
            preset.delay = 0.05;
            preset.exportType = 'Simple: voltage/current only';
            preset.comment = '';
            preset.debugProfile = 'Auto random';
            preset.adaptiveRules = [100 1 1; 1 0.1 0.1; 0.1 0.01 0.01; 0.01 0.001 0.001];
        end

        function preset = captureFromApp(app)
            preset = data.PresetManager.defaultPreset();
            preset.version = 1;
            preset.sourceMode = app.modeDrop.Value;
            preset.measurementType = app.measureTypeDrop.Value;
            preset.senseMode = app.senseDrop.Value;
            preset.start = app.startEdit.Value;
            preset.stop = app.stopEdit.Value;
            preset.step = app.stepEdit.Value;
            preset.sweepType = app.sweepDrop.Value;
            preset.direction = app.directionDrop.Value;
            preset.fixedSource = app.fixedSourceEdit.Value;
            preset.duration = app.durationEdit.Value;
            preset.interval = app.intervalEdit.Value;
            preset.compliance = app.compEdit.Value;
            preset.measureRangeMode = app.rangeModeDrop.Value;
            preset.measureRangeValue = app.rangeValueEdit.Value;
            preset.nplc = app.nplcEdit.Value;
            preset.delay = app.delayEdit.Value;
            preset.exportType = app.exportModeDrop.Value;
            if isfield(app,'commentEdit') && isvalid(app.commentEdit)
                preset.comment = data.CommentUtil.sanitize(app.commentEdit.Value);
            end
            if isfield(app,'debugProfileDrop') && isvalid(app.debugProfileDrop)
                preset.debugProfile = app.debugProfileDrop.Value;
            end
            preset.adaptiveRules = app.adaptiveTable.Data;
        end

        function app = applyToApp(app,preset)
            preset = data.PresetManager.mergeDefaults(preset,data.PresetManager.defaultPreset());
            data.PresetManager.setDropValue(app.modeDrop,preset.sourceMode);
            data.PresetManager.setDropValue(app.measureTypeDrop,preset.measurementType);
            data.PresetManager.setDropValue(app.senseDrop,preset.senseMode);
            app.startEdit.Value = preset.start;
            app.stopEdit.Value = preset.stop;
            app.stepEdit.Value = preset.step;
            data.PresetManager.setDropValue(app.sweepDrop,preset.sweepType);
            data.PresetManager.setDropValue(app.directionDrop,preset.direction);
            app.fixedSourceEdit.Value = preset.fixedSource;
            app.durationEdit.Value = preset.duration;
            app.intervalEdit.Value = preset.interval;
            app.compEdit.Value = preset.compliance;
            data.PresetManager.setDropValue(app.rangeModeDrop,preset.measureRangeMode);
            app.rangeValueEdit.Value = preset.measureRangeValue;
            app.nplcEdit.Value = preset.nplc;
            app.delayEdit.Value = preset.delay;
            data.PresetManager.setDropValue(app.exportModeDrop,preset.exportType);
            if isfield(app,'commentEdit') && isvalid(app.commentEdit)
                app.commentEdit.Value = data.CommentUtil.sanitize(preset.comment);
            end
            if isfield(app,'debugProfileDrop') && isvalid(app.debugProfileDrop)
                data.PresetManager.setDropValue(app.debugProfileDrop,preset.debugProfile);
            end
            app.adaptiveTable.Data = preset.adaptiveRules;
        end

        function out = mergeDefaults(in,d)
            out = d;
            if ~isstruct(in)
                return;
            end
            names = fieldnames(in);
            for k = 1:numel(names)
                out.(names{k}) = in.(names{k});
            end
        end

        function setDropValue(drop,value)
            if any(strcmp(drop.Items,value))
                drop.Value = value;
            end
        end
    end
end
