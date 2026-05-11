classdef AdaptiveRuleWorkflow
    methods(Static)
        function [app,changed] = addRule(app)
            changed = true;
            rulesData = app.adaptiveTable.Data;
            if isempty(rulesData)
                newRow = [0.001 0.1 0.001];
            else
                rulesData = double(rulesData);
                lastHigh = max(max(rulesData(:,1:2)));
                newRow = [lastHigh lastHigh*10 max(rulesData(end,3)*10,eps)];
            end
            app.adaptiveTable.Data = [rulesData; newRow];
        end

        function [app,changed,message] = deleteSelectedRule(app)
            changed = false;
            message = '';
            rulesData = app.adaptiveTable.Data;
            if isempty(rulesData)
                return;
            end
            sel = app.adaptiveTable.Selection;
            if isempty(sel)
                message = 'Select a rule row first.';
                return;
            end
            row = sel(1);
            if row >= 1 && row <= size(rulesData,1)
                rulesData(row,:) = [];
                app.adaptiveTable.Data = rulesData;
                changed = true;
            end
        end

        function [ok,message] = validateRules(app)
            try
                core.SweepMath.validateAdaptiveCoverage(app.adaptiveTable.Data,app.startEdit.Value,app.stopEdit.Value);
                ok = true;
                message = 'Adaptive rules are valid and cover the current Start/Stop range.';
            catch ME
                ok = false;
                message = ME.message;
            end
        end
    end
end
