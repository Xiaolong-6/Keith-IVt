classdef PresetWorkflow
    methods(Static)
        function app = refreshList(app)
            presets = data.PresetManager.loadStore(app.presetFile);
            names = fieldnames(presets.items);
            if isempty(names)
                names = {'Default'};
            end
            app.presetDrop.Items = names(:)';
            if ~any(strcmp(app.presetDrop.Value,app.presetDrop.Items))
                app.presetDrop.Value = app.presetDrop.Items{1};
            end
        end

        function [app,name] = saveCurrent(app)
            name = data.CsvIO.sanitizeName(strtrim(app.presetNameEdit.Value));
            if isempty(name)
                name = 'Preset';
            end
            presets = data.PresetManager.loadStore(app.presetFile);
            presets.items.(name) = data.PresetManager.captureFromApp(app);
            data.PresetManager.saveStore(app.presetFile,presets);
            app = ui.PresetWorkflow.refreshList(app);
            app.presetDrop.Value = name;
        end

        function [app,name,found] = loadSelected(app)
            presets = data.PresetManager.loadStore(app.presetFile);
            name = app.presetDrop.Value;
            found = isfield(presets.items,name);
            if ~found
                app = ui.PresetWorkflow.refreshList(app);
                return;
            end
            app = data.PresetManager.applyToApp(app,presets.items.(name));
        end

        function [app,name,deleted,isDefault] = deleteSelected(app)
            presets = data.PresetManager.loadStore(app.presetFile);
            name = app.presetDrop.Value;
            isDefault = strcmp(name,'Default');
            deleted = false;
            if isDefault
                return;
            end
            if isfield(presets.items,name)
                presets.items = rmfield(presets.items,name);
                data.PresetManager.saveStore(app.presetFile,presets);
                deleted = true;
            end
            app = ui.PresetWorkflow.refreshList(app);
        end
    end
end
