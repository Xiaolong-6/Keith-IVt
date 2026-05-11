classdef ControlStateManager
    methods(Static)
        function app = update(app)
            if ~isfield(app,'startBtn') || ~isvalid(app.startBtn)
                return;
            end

            isBusy = app.isSweeping;
            hasDevices = ~isempty(app.devices);
            useAdaptive = strcmp(app.sweepDrop.Value,'Adaptive');
            isTimeTrace = strcmp(app.measureTypeDrop.Value,'Time Trace');

            ui.ControlStateManager.updatePrimaryActions(app,isBusy);
            ui.ControlStateManager.updateSweepInputs(app,isBusy,useAdaptive,isTimeTrace);
            ui.ControlStateManager.updateDataActions(app,isBusy,hasDevices);
            ui.ControlStateManager.updatePresetActions(app,isBusy);
            ui.ControlStateManager.updateRecoveryActions(app,isBusy);
            ui.ControlStateManager.updateDebugControls(app,isBusy);
        end

        function updatePrimaryActions(app,isBusy)
            app.connectBtn.Enable = ui.UiState.onOff(~app.connected && ~isBusy);
            app.disconnectBtn.Enable = ui.UiState.onOff(app.connected && ~isBusy);
            app.startBtn.Enable = ui.UiState.onOff(app.connected && ~isBusy);
            app.abortBtn.Enable = ui.UiState.onOff(app.connected || isBusy);
            app.pauseBtn.Enable = ui.UiState.onOff(isBusy);
        end

        function updateSweepInputs(app,isBusy,useAdaptive,isTimeTrace)
            enabled = ui.UiState.onOff(~isBusy);
            connectionSetupEnabled = ui.UiState.onOff(~isBusy && ~app.connected);
            app.portEdit.Enable = connectionSetupEnabled;
            app.baudEdit.Enable = connectionSetupEnabled;
            app.termDrop.Enable = connectionSetupEnabled;
            app.senseDrop.Enable = connectionSetupEnabled;
            app.exportFolderEdit.Enable = enabled;
            app.exportFolderBtn.Enable = enabled;
            app.exportModeDrop.Enable = enabled;
            app.devEdit.Enable = enabled;
            app.commentEdit.Enable = enabled;
            app.modeDrop.Enable = enabled;
            app.measureTypeDrop.Enable = enabled;
            app.directionDrop.Enable = enabled;
            app.sweepDrop.Enable = enabled;
            app.startEdit.Enable = enabled;
            app.stopEdit.Enable = enabled;
            app.fixedSourceEdit.Enable = enabled;
            app.durationEdit.Enable = enabled;
            app.intervalEdit.Enable = enabled;
            app.compEdit.Enable = enabled;
            app.rangeModeDrop.Enable = enabled;
            app.rangeValueEdit.Enable = ui.UiState.onOff(~isBusy && strcmp(app.rangeModeDrop.Value,'Fixed measure range'));
            app.nplcEdit.Enable = enabled;
            app.delayEdit.Enable = enabled;

            app.stepEdit.Enable = ui.UiState.onOff(~isBusy && ~useAdaptive && ~isTimeTrace);
            app.adaptiveTable.Enable = ui.UiState.onOff(~isBusy && useAdaptive && ~isTimeTrace);
            app.addRuleBtn.Enable = ui.UiState.onOff(~isBusy && useAdaptive && ~isTimeTrace);
            app.deleteRuleBtn.Enable = ui.UiState.onOff(~isBusy && useAdaptive && ~isTimeTrace);
            app.validateRuleBtn.Enable = ui.UiState.onOff(~isBusy && useAdaptive && ~isTimeTrace);
        end

        function updateDataActions(app,isBusy,hasDevices)
            app.saveAllBtn.Enable = ui.UiState.onOff(hasDevices && ~isBusy);
            app.clearAllBtn.Enable = ui.UiState.onOff(hasDevices && ~isBusy);
            app.saveSelBtn.Enable = ui.UiState.onOff(hasDevices && ~isBusy);
            app.deleteSelBtn.Enable = ui.UiState.onOff(hasDevices && ~isBusy);
            app.refreshBtn.Enable = ui.UiState.onOff(hasDevices && ~isBusy);
            app.importBtn.Enable = ui.UiState.onOff(~isBusy);
        end

        function updatePresetActions(app,isBusy)
            enabled = ui.UiState.onOff(~isBusy);
            app.loadPresetBtn.Enable = enabled;
            app.savePresetBtn.Enable = enabled;
            app.deletePresetBtn.Enable = enabled;
            app.presetDrop.Enable = enabled;
            app.presetNameEdit.Enable = enabled;
        end

        function updateRecoveryActions(app,isBusy)
            app.refreshRecoveryBtn.Enable = ui.UiState.onOff(~isBusy);
            app.importRecoveryBtn.Enable = ui.UiState.onOff(~isBusy && ~isempty(app.recoveryTable.Data));
            app.openCacheBtn.Enable = ui.UiState.onOff(~isBusy);
        end

        function updateDebugControls(app,isBusy)
            app.debugModeBtn.Enable = ui.UiState.onOff(~app.connected && ~isBusy);
            if ~isfield(app,'debugProfileDrop') || ~isvalid(app.debugProfileDrop)
                return;
            end

            visibleState = ui.UiState.onOff(app.debugMode);
            app.debugProfileLabel.Visible = visibleState;
            app.debugProfileDrop.Visible = visibleState;
            app.debugProfileDrop.Enable = ui.UiState.onOff(app.debugMode && ~isBusy);

            rows = app.actionGrid.RowHeight;
            if app.debugMode
                rows{1} = 36;
            else
                rows{1} = 0;
            end
            app.actionGrid.RowHeight = rows;
        end
    end
end
