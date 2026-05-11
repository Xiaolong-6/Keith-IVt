classdef RunStateView
    methods(Static)
        function set(app,stateText)
            c = ui.Theme.colors(app);
            if isfield(app,'runStateLabel') && isvalid(app.runStateLabel)
                app.runStateLabel.Text = stateText;
                switch lower(stateText)
                    case 'ready'
                        app.runStateLabel.FontColor = [0.20 0.60 0.34];
                    case 'sweeping'
                        app.runStateLabel.FontColor = [0.85 0.58 0.08];
                    case 'paused'
                        app.runStateLabel.FontColor = [0.88 0.52 0.10];
                    otherwise
                        app.runStateLabel.FontColor = c.muted;
                end
            end
        end

        function setConnectionDetail(app,text)
            if isfield(app,'connectionDetailLabel') && isvalid(app.connectionDetailLabel)
                app.connectionDetailLabel.Text = text;
            end
        end

        function label = connectionLabel(app)
            model = ui.RunStateView.instrumentModel(app);
            label = sprintf('%s (%s, %s)',model,app.termDrop.Value,app.senseDrop.Value);
        end

        function model = instrumentModel(app)
            if ~isempty(app.instrumentProfile)
                model = hardware.InstrumentProfile.displayLabel(app.instrumentProfile);
            else
                model = 'Keithley 2400 Series';
            end
        end
    end
end
