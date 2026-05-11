classdef ConnectionWorkflow
    methods(Static)
        function [app,result] = connect(app)
            result = struct('statusMsg','','statusState','','detail','','runState','Stopped','logLines',{{}},'errorMessage','');
            if app.connected
                result.logLines = {'Already connected.'};
                result.runState = 'Ready';
                return;
            end

            if app.debugMode
                app.smu = [];
                app.connected = true;
                app.instrumentID = 'Debug simulated Keithley 2400';
                app.instrumentProfile = hardware.InstrumentProfile.fromIdn(app.instrumentID);
                result.statusMsg = 'Debug mode';
                result.statusState = 'debug';
                result.detail = 'Sim Keithley 2400';
                result.runState = 'Ready';
                result.logLines = {'Debug mode connected. No serial port was opened.'};
                return;
            end

            try
                portName = strtrim(app.portEdit.Value);
                baudRate = app.baudEdit.Value;
                terminal = app.termDrop.Value;

                app.smu = hardware.K2400Driver(portName,baudRate,terminal);
                app.smu.connect();
                app.instrumentID = app.smu.InstrumentID;
                app.instrumentProfile = app.smu.Profile;
                app.connected = true;

                connectedLabel = ui.RunStateView.connectionLabel(app);
                result.statusMsg = 'Connected';
                result.statusState = 'connected';
                result.detail = connectedLabel;
                result.runState = 'Ready';
                result.logLines = {sprintf('%s on %s.',connectedLabel,portName), ['Instrument ID: ' app.instrumentID]};
            catch ME
                app.connected = false;
                app = ui.ConnectionWorkflow.safeOff(app);
                result.statusMsg = 'Connection failed';
                result.statusState = 'disconnected';
                result.detail = 'Not connected';
                result.runState = 'Stopped';
                result.errorMessage = ME.message;
                result.logLines = {['Connection failed: ' ME.message]};
            end
        end

        function app = safeOff(app)
            try
                if ~isempty(app.smu)
                    if startsWith(app.modeDrop.Value,'Voltage')
                        app.smu.safeOff('VOLT');
                    else
                        app.smu.safeOff('CURR');
                    end
                end
            catch
            end
        end

        function [app,statusMsg,statusState,logLine] = disconnect(app)
            app = ui.ConnectionWorkflow.safeOff(app);
            try
                if ~isempty(app.smu)
                    app.smu.disconnect();
                end
            catch
            end

            app.smu = [];
            app.connected = false;
            app.instrumentProfile = [];
            if app.debugMode
                statusMsg = 'Debug mode ready';
                statusState = 'debug';
                logLine = 'Debug simulated connection closed.';
            else
                statusMsg = 'Disconnected';
                statusState = 'disconnected';
                logLine = 'Disconnected.';
            end
        end

        function [app,statusMsg,statusState,logLine] = toggleDebugMode(app,devilIcon,helpMark)
            if app.connected || app.isSweeping
                error('Disconnect before changing debug mode.');
            end

            app.debugMode = ~app.debugMode;
            if app.debugMode
                app.debugModeBtn.Text = [devilIcon ' Disable Debug Mode ' devilIcon helpMark];
                statusMsg = 'Debug mode ready';
                statusState = 'debug';
                logLine = 'Debug mode enabled. Connect will use a simulated Keithley 2400.';
            else
                app.debugModeBtn.Text = [devilIcon ' Enable Debug Mode ' devilIcon helpMark];
                statusMsg = 'Disconnected';
                statusState = 'disconnected';
                logLine = 'Debug mode disabled.';
            end
        end
    end
end
