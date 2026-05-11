classdef Tooltips
    methods(Static)
        function apply(app)
            tips = ui.Tooltips.tooltipMap();
            fields = fieldnames(tips);
            for k = 1:numel(fields)
                ui.Tooltips.setTooltip(app,fields{k},tips.(fields{k}));
            end
        end

        function tips = tooltipMap()
            tips = struct();

            tips.portLabel = 'COM Port is the Windows serial-port name for the Keithley connection. Check Device Manager if unsure.';
            tips.portEdit = 'Serial COM port used by the Keithley, for example COM3.';
            tips.baudLabel = 'Baud is the serial communication speed. The Keithley and MATLAB must use the same value.';
            tips.baudEdit = 'Serial baud rate. Keep 9600 unless the instrument is configured differently.';
            tips.termLabel = 'Terminal chooses which physical Keithley input/output connectors are active.';
            tips.termDrop = 'Select whether the Keithley uses rear or front terminals.';
            tips.senseLabel = 'Sense Mode chooses local 2-wire sensing or remote 4-wire sensing.';
            tips.senseDrop = '2-wire uses the source leads for sensing. 4-wire enables remote sensing to reduce lead resistance error.';
            tips.connectBtn = 'Open the serial connection, reset the Keithley, select terminals, and set output off.';
            tips.disconnectBtn = 'Turn output off, close the connection, and clear the stored device list after confirmation.';

            tips.exportLabel = 'Export Folder is the default place where CSV files are saved.';
            tips.exportFolderEdit = 'Default folder used by Save Selected Device and Save All.';
            tips.exportFolderBtn = 'Choose the folder used as the default CSV export location.';
            tips.exportModeLabel = 'Export Type chooses whether CSV files contain only measured V/A data or also calculated columns.';
            tips.exportModeDrop = 'Simple exports only voltage/current XY columns. Advanced adds resistance, conductance, and differential resistance.';

            tips.modeLabel = 'Source Mode chooses what the Keithley controls and what it measures.';
            tips.modeDrop = 'Choose whether the Keithley sources voltage and measures current, or sources current and measures voltage.';
            tips.devLabel = 'Device is a user-friendly name for this measurement, such as sample name or device number.';
            tips.devEdit = 'Device name for this run. Shown in the stored list, plot legend, and exported filenames. Leave blank to auto-name the next device.';
            tips.commentLabel = 'Operator name or initials saved with this measurement.';
            tips.commentEdit = 'User or operator name saved with the measurement. Optional, but useful for tracking who ran the sweep.';
            tips.measureTypeLabel = 'Measurement Type chooses between a source sweep and repeated readings over time.';
            tips.measureTypeDrop = 'Sweep changes the source across a range. Time Trace keeps one source value and records current or voltage over time.';
            tips.fixedSourceLabel = 'Fixed source value used for Time Trace.';
            tips.fixedSourceEdit = 'Constant voltage or current applied during Time Trace.';
            tips.durationLabel = 'Total Time Trace duration in seconds.';
            tips.durationEdit = 'How long Time Trace should keep measuring.';
            tips.intervalLabel = 'Target time between readings. USB/serial overhead and NPLC set the practical minimum.';
            tips.intervalEdit = 'Sampling interval in seconds. Increase it if the estimate says the interval is too short.';
            tips.startLabel = 'Start is the first voltage or current value applied at the beginning of the sweep.';
            tips.startEdit = 'First source value for the sweep, in V for voltage source or A for current source.';
            tips.stopLabel = 'Stop is the final voltage or current value applied at the end of the sweep.';
            tips.stopEdit = 'Final source value for the sweep, in V for voltage source or A for current source.';
            tips.stepLabel = 'Step is the fixed spacing between source values when using Linear sweep.';
            tips.stepEdit = 'Fixed source increment for Linear sweep. Disabled when Adaptive sweep is selected.';
            tips.sweepLabel = 'Sweep Type controls how source points are generated between Start and Stop.';
            tips.sweepDrop = 'Linear uses the fixed Step value. Adaptive uses the editable abs(source) table.';
            tips.directionLabel = 'Direction chooses whether the sweep runs once, or returns back from Stop to Start.';
            tips.directionDrop = 'Forward then backward measures hysteresis by sweeping Start to Stop and then Stop back to Start.';

            tips.compLabel = 'Compliance is a safety limit that protects the sample and instrument.';
            tips.compEdit = 'Safety limit: current compliance in voltage-source mode, or voltage limit in current-source mode.';
            tips.rangeModeLabel = 'Measure Range controls the measurement range for the sensed quantity.';
            tips.rangeModeDrop = 'Auto range lets the Keithley choose the measurement range. Fixed measure range uses the value below.';
            tips.rangeValueLabel = 'Fixed measurement range for the sensed quantity.';
            tips.rangeValueEdit = 'Positive fixed range value: amps when sourcing voltage, volts when sourcing current.';
            tips.nplcLabel = 'NPLC controls measurement averaging time. Larger values reduce noise but make sweeps slower.';
            tips.nplcEdit = 'Integration time in power-line cycles. Higher values are slower but less noisy.';
            tips.delayLabel = 'Delay waits after changing the source before reading, useful for slow or capacitive devices.';
            tips.delayEdit = 'Settling time after each source change before reading the measurement.';

            tips.adaptiveLabel = 'Adaptive rules choose smaller steps near zero and larger steps far from zero.';
            tips.adaptiveTable = 'Adaptive sweep rules. For each absolute source range, use the Step in the third column.';
            tips.addRuleBtn = 'Add one adaptive-rule row to the table.';
            tips.deleteRuleBtn = 'Delete the selected adaptive-rule row from the table.';
            tips.validateRuleBtn = 'Check that adaptive ranges are valid, continuous, and cover the current Start/Stop range.';

            tips.presetLabel = 'Preset profile containing sweep, timing, export, and adaptive-rule settings.';
            tips.presetDrop = 'Choose a stored profile to load. Profiles are versioned so future settings can be added safely.';
            tips.loadPresetBtn = 'Apply the selected preset to the current controls.';
            tips.savePresetBtn = 'Save the current controls as a preset profile.';
            tips.presetNameLabel = 'Name for the preset profile when saving current settings.';
            tips.presetNameEdit = 'Enter a memorable preset name, such as LowVoltageFast or SensitiveCurrent.';
            tips.deletePresetBtn = 'Delete the selected user preset.';

            tips.fontSizeLabel = 'UI Font Size changes the size of labels, buttons, tables, and plot text.';
            tips.fontSizeDrop = 'Choose Compact, Normal, Large, or Extra large UI text size. Useful when switching between low- and high-resolution monitors.';
            tips.themeLabel = 'Theme switches the application between light and dark visual modes.';
            tips.themeDrop = 'Choose Light or Dark theme. The change is applied immediately to panels, tables, buttons, and plots.';
            tips.aboutViewPanel = 'About this app, export formats, cache behavior, and basic safety notes.';
            tips.checkUpdateBtn = 'Open the configured release page to check for newer versions.';
            tips.debugModeBtn = 'Enable simulated connection and measurement data when the Keithley source meter is not available.';
            tips.startBtn = 'Start the measurement using the current measurement type, source mode, sweep or time-trace settings, range, compliance, NPLC, and delay.';
            tips.abortBtn = 'Abort immediately, force the source output off, and stop the active run as quickly as possible.';
            tips.pauseBtn = 'Pause after the current measurement point. Press again to resume from the same run.';
            tips.saveAllBtn = 'Export all stored devices as paired XY columns, so every device keeps its own X values.';
            tips.clearAllBtn = 'Remove all stored traces from the UI and clear the plots.';
            tips.connLamp = 'Connection state: red means disconnected/error, green means connected, yellow means sweeping.';
            tips.statusLabel = 'Connection status and latest instrument message.';
            tips.runStateLabel = 'Run state: Ready, Sweeping, Paused, or Stopped.';
            tips.statusHintLabel = 'Short explanation of the current run state.';
            tips.estimateLabel = 'Estimated run time from point count, NPLC, delay, and the timing model. Compare this with the actual elapsed time in Log.';
            tips.logArea = 'Timestamped messages from connection, sweep, abort, save, and error events.';

            tips.devTable = 'Stored measurements. Use Show to hide/show traces, edit Device names/operators, and select a row for save/delete.';
            tips.saveSelBtn = 'Export only the selected device as one X column and one Y column with standard V/A units.';
            tips.deleteSelBtn = 'Remove the selected device from the stored list and plots.';
            tips.refreshBtn = 'Redraw the plots using the current stored-device visibility and names.';
            tips.importBtn = 'Import a previously saved CSV file and add its voltage/current data to the device list.';

            tips.recoveryTable = 'Autosaved recovery CSV files in the cache folder.';
            tips.refreshRecoveryBtn = 'Refresh the list of cached autosave and recovery files.';
            tips.importRecoveryBtn = 'Import the selected cached CSV into the Devices list.';
            tips.openCacheBtn = 'Set the export/import folder to the cache folder.';
        end

        function setTooltip(app,fieldName,text)
            if isfield(app,fieldName) && isvalid(app.(fieldName)) && isprop(app.(fieldName),'Tooltip')
                app.(fieldName).Tooltip = text;
            end
        end
    end
end
