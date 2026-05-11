classdef StatusView
    methods(Static)
        function set(app,msg,state)
            if ~isfield(app,'fig') || ~isvalid(app.fig) || ...
                    ~isfield(app,'statusLabel') || ~isvalid(app.statusLabel)
                return;
            end
            app.statusLabel.Text = msg;
            ui.StatusView.updateDebugIcon(app,state);
            ui.StatusView.updateLampColor(app,state);
        end

        function updateDebugIcon(app,state)
            if ~isfield(app,'debugStatusIcon') || ~isvalid(app.debugStatusIcon)
                return;
            end

            if strcmp(state,'debug')
                app.connLamp.Visible = 'off';
                app.debugStatusIcon.Visible = 'on';
            else
                app.debugStatusIcon.Visible = 'off';
                app.connLamp.Visible = 'on';
            end
        end

        function updateLampColor(app,state)
            if ~isfield(app,'connLamp') || ~isvalid(app.connLamp)
                return;
            end
            switch state
                case 'connected'
                    app.connLamp.Color = [0.1 0.65 0.15];
                case 'busy'
                    app.connLamp.Color = [0.95 0.7 0.1];
                case 'debug'
                    app.connLamp.Color = [0.95 0.7 0.1];
                otherwise
                    app.connLamp.Color = [0.85 0.05 0.05];
            end
        end
    end
end
