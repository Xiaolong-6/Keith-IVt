classdef Theme
    methods(Static)
        function c = colors(source)
            if nargin < 1
                source = [];
            end
            themeName = 'Light';
            try
                if isstruct(source) && isfield(source,'themeName')
                    themeName = source.themeName;
                elseif ~isempty(source)
                    fig = ancestor(source,'figure');
                    if ~isempty(fig) && isappdata(fig,'KeithIVtThemeName')
                        themeName = getappdata(fig,'KeithIVtThemeName');
                    end
                elseif isappdata(groot,'KeithIVtThemeName')
                    themeName = getappdata(groot,'KeithIVtThemeName');
                end
            catch
            end
            useDark = strcmpi(char(string(themeName)),'Dark');

            c = struct();
            if useDark
                c.window = [0.090 0.105 0.120];
                c.panel = [0.115 0.130 0.145];
                c.panelSoft = [0.145 0.165 0.180];
                c.border = [0.250 0.280 0.300];
                c.borderSoft = [0.310 0.340 0.360];
                c.text = [0.900 0.920 0.930];
                c.muted = [0.650 0.690 0.720];
                c.primary = [0.400 0.650 0.520];
                c.primarySoft = [0.150 0.250 0.200];
                c.danger = [0.820 0.260 0.280];
                c.dangerSoft = [0.430 0.170 0.180];
                c.control = [0.155 0.175 0.190];
                c.controlText = c.text;
                c.edit = [0.100 0.115 0.128];
                c.table1 = [0.105 0.120 0.135];
                c.table2 = [0.130 0.148 0.162];
                c.axis = [0.095 0.105 0.115];
                c.disabled = [0.180 0.195 0.205];
                c.grid = [0.430 0.460 0.480];
            else
                c.window = [1 1 1];
                c.panel = [1 1 1];
                c.panelSoft = [0.970 0.985 0.978];
                c.border = [0.88 0.91 0.91];
                c.borderSoft = [0.93 0.95 0.95];
                c.text = [0.10 0.13 0.15];
                c.muted = [0.45 0.49 0.52];
                c.primary = [0.36 0.58 0.45];
                c.primarySoft = [0.84 0.91 0.87];
                c.danger = [0.86 0.22 0.24];
                c.dangerSoft = [0.95 0.55 0.56];
                c.control = [0.985 0.985 0.980];
                c.controlText = c.text;
                c.edit = [1 1 1];
                c.table1 = [1 1 1];
                c.table2 = [0.975 0.985 0.985];
                c.axis = [1 1 1];
                c.disabled = [0.93 0.93 0.91];
                c.grid = [0.74 0.78 0.78];
            end
        end

        function f = fonts()
            % Centralized typography.  MATLAB does not support a CSS-style
            % font stack, so pick the first installed modern UI font.
            modern = ui.Theme.chooseFont({ ...
                'Bahnschrift', ...              % Windows 10/11 modern DIN-like UI font
                'Aptos', ...                    % Microsoft 365 / recent Windows
                'Aptos Display', ...            % newer Microsoft UI, visually distinct
                'Segoe UI Variable Text', ...   % Windows 11 modern UI
                'Segoe UI', ...                 % reliable Windows fallback
                'Helvetica Neue', ...           % macOS fallback
                'Arial'});                      % last-resort fallback

            mono = ui.Theme.chooseFont({ ...
                'Cascadia Mono', ...
                'Consolas', ...
                'Menlo', ...
                'Monaco', ...
                'Courier New'});

            symbol = ui.Theme.chooseFont({ ...
                'Segoe Fluent Icons', ...
                'Segoe UI Symbol', ...
                'Segoe UI Emoji', ...
                modern});

            f = struct();
            f.ui = modern;
            f.mono = mono;
            f.symbol = symbol;
            f.base = 13;
            f.small = 11;
            f.nav = 14;
            f.header = 15;
            f.button = 13;
            f.table = 11;
            f.axis = 12;
        end


        function f = scaledFonts(source)
            f = ui.Theme.fonts();
            scale = 1.0;
            try
                if isstruct(source) && isfield(source,'fontScale')
                    scale = source.fontScale;
                else
                    fig = ancestor(source,'figure');
                    if ~isempty(fig) && isappdata(fig,'KeithIVtFontScale')
                        scale = getappdata(fig,'KeithIVtFontScale');
                    end
                end
            catch
            end
            if isempty(scale) || ~isnumeric(scale) || ~isfinite(scale) || scale <= 0
                scale = 1.0;
            end
            fields = {'base','small','nav','header','button','table','axis'};
            for kk = 1:numel(fields)
                name = fields{kk};
                f.(name) = max(8,round(f.(name) * scale));
            end
        end

        function applyDefaultFonts()
            f = ui.Theme.fonts();
            try, set(groot,'defaultUicontrolFontName',f.ui); catch, end
            try, set(groot,'defaultUitableFontName',f.ui); catch, end
            try, set(groot,'defaultAxesFontName',f.ui); catch, end
            try, set(groot,'defaultTextFontName',f.ui); catch, end
        end

        function name = chooseFont(candidates)
            % Prefer a modern platform UI font even when listfonts() is
            % incomplete for uifigure controls on some MATLAB/Windows builds.
            name = candidates{end};
            try
                if ispc
                    name = 'Bahnschrift';
                elseif ismac
                    name = 'Helvetica Neue';
                end
            catch
            end
            try
                installed = string(listfonts);
                for k = 1:numel(candidates)
                    candidate = string(candidates{k});
                    if any(strcmpi(installed,candidate))
                        name = char(candidate);
                        return;
                    end
                end
            catch
                % Keep the platform default selected above.
            end
        end

        function apply(app)
            if ~isfield(app,'fig') || ~isvalid(app.fig)
                return;
            end
            try
                setappdata(app.fig,'KeithIVtFontScale',app.fontScale);
                setappdata(app.fig,'KeithIVtThemeName',app.themeName);
                setappdata(groot,'KeithIVtThemeName',app.themeName);
            catch
            end
            c = ui.Theme.colors(app);
            f = ui.Theme.scaledFonts(app);
            ui.Theme.setIfProp(app.fig,'Color',c.window);
            ui.Theme.setIfProp(app.fig,'FontName',f.ui);
            ui.Theme.setIfProp(app.fig,'FontSize',f.base);

            objs = unique([findall(app.fig); findall(app.fig,'-property','FontName')]);
            for k = 1:numel(objs)
                obj = objs(k);
                ui.Theme.setIfProp(obj,'FontName',f.ui);
                ui.Theme.setIfProp(obj,'FontColor',c.text);
                ui.Theme.setIfProp(obj,'FontSize',f.base);
            end


            grids = findall(app.fig,'Type','uigridlayout');
            for k = 1:numel(grids)
                ui.Theme.setIfProp(grids(k),'BackgroundColor',c.panel);
            end

            panels = findall(app.fig,'Type','uipanel');
            for k = 1:numel(panels)
                ui.Theme.setIfProp(panels(k),'BackgroundColor',c.panel);
                if isprop(panels(k),'BorderColor')
                    panels(k).BorderColor = c.border;
                end
                if isprop(panels(k),'BorderType') && ~strcmp(panels(k).BorderType,'none')
                    panels(k).BorderType = 'line';
                end
            end

            labels = findall(app.fig,'Type','uilabel');
            for k = 1:numel(labels)
                ui.Theme.setIfProp(labels(k),'BackgroundColor',ui.Theme.parentBackground(labels(k),c.panel));
                ui.Theme.setIfProp(labels(k),'FontSize',f.base);
            end

            % Form controls: slightly larger, clean, readable.
            ui.Theme.styleControlGroup(app.fig,'uieditfield',f,c);
            ui.Theme.styleControlGroup(app.fig,'uidropdown',f,c);
            ui.Theme.styleControlGroup(app.fig,'uinumericeditfield',f,c);
            ui.Theme.styleControlGroup(app.fig,'uicheckbox',f,c);
            ui.Theme.styleControlGroup(app.fig,'uitextarea',f,c);

            buttons = findall(app.fig,'Type','uibutton');
            for k = 1:numel(buttons)
                ui.Theme.styleNeutralButton(buttons(k),c,f);
            end

            if isfield(app,'startBtn') && isvalid(app.startBtn)
                ui.Theme.stylePrimaryButton(app.startBtn,c,f);
            end
            if isfield(app,'abortBtn') && isvalid(app.abortBtn)
                ui.Theme.styleDangerButton(app.abortBtn,c,f);
            end
            if isfield(app,'pauseBtn') && isvalid(app.pauseBtn)
                ui.Theme.styleNeutralButton(app.pauseBtn,c,f);
            end

            if isfield(app,'startBtn') && isvalid(app.startBtn)
                ui.Theme.setIfProp(app.startBtn,'FontSize',f.header);
            end
            if isfield(app,'pauseBtn') && isvalid(app.pauseBtn)
                ui.Theme.setIfProp(app.pauseBtn,'FontSize',f.button);
            end
            if isfield(app,'abortBtn') && isvalid(app.abortBtn)
                ui.Theme.setIfProp(app.abortBtn,'FontSize',f.header);
            end

            if isfield(app,'controlTabButtons')
                ui.Theme.styleNavigation(app);
            end
            if isfield(app,'plotButtons') && isfield(app,'plotPages')
                ui.Theme.restylePageButtons(app.plotButtons,app.plotPages);
            end
            if isfield(app,'deviceTabButtons') && isfield(app,'devicePages')
                ui.Theme.restylePageButtons(app.deviceTabButtons,app.devicePages);
            end

            % Preserve icon/emoji labels after global font application.
            ui.Theme.restoreIconFonts(app,f);

            tables = findall(app.fig,'Type','uitable');
            for k = 1:numel(tables)
                ui.Theme.styleTable(tables(k),c,f);
            end

            ui.Theme.styleAboutView(app,f,c);

            axesList = findall(app.fig,'Type','axes');
            for k = 1:numel(axesList)
                ui.Theme.styleAxis(axesList(k),c,f);
            end
        end

        function styleControlGroup(fig,typeName,f,c)
            controls = findall(fig,'Type',typeName);
            for k = 1:numel(controls)
                ui.Theme.setIfProp(controls(k),'FontName',f.ui);
                ui.Theme.setIfProp(controls(k),'FontSize',f.base);
                ui.Theme.setIfProp(controls(k),'FontColor',c.text);
                ui.Theme.setIfProp(controls(k),'BackgroundColor',c.edit);
                if isprop(controls(k),'BorderColor')
                    controls(k).BorderColor = c.borderSoft;
                end
            end
        end

        function restoreIconFonts(app,f)
            fields = {'debugStatusIcon'};
            for k = 1:numel(fields)
                if isfield(app,fields{k}) && isvalid(app.(fields{k}))
                    ui.Theme.setIfProp(app.(fields{k}),'FontName',f.symbol);
                    if ismember(fields{k},{'startBtn','pauseBtn','abortBtn'})
                        ui.Theme.setIfProp(app.(fields{k}),'FontWeight','bold');
                    end
                end
            end
        end
        function styleAboutView(app,f,c)
            if ~isfield(app,'aboutViewPanel') || ~isvalid(app.aboutViewPanel)
                return;
            end
            labels = findall(app.aboutViewPanel,'Type','uilabel');
            for k = 1:numel(labels)
                lbl = labels(k);
                kind = 'body';
                try
                    if isstruct(lbl.UserData) && isfield(lbl.UserData,'Kind')
                        kind = lbl.UserData.Kind;
                    end
                catch
                end
                lbl.FontName = f.ui;
                lbl.FontColor = c.text;
                lbl.BackgroundColor = c.panel;
                switch kind
                    case 'title'
                        lbl.FontSize = f.header + 2;
                        lbl.FontWeight = 'bold';
                    case 'section'
                        lbl.FontSize = f.header;
                        lbl.FontWeight = 'bold';
                    otherwise
                        lbl.FontSize = f.base;
                        lbl.FontWeight = 'normal';
                end
            end
        end

        function styleTable(tbl,c,f)
            ui.Theme.setIfProp(tbl,'BackgroundColor',[c.table1; c.table2]);
            ui.Theme.setIfProp(tbl,'FontName',f.ui);
            ui.Theme.setIfProp(tbl,'FontSize',f.table);
            ui.Theme.setIfProp(tbl,'FontColor',c.text);
            if isprop(tbl,'ForegroundColor')
                tbl.ForegroundColor = c.text;
            end
            if isprop(tbl,'RowStriping')
                tbl.RowStriping = 'on';
            end
        end


        function styleNavigation(app)
            pages = app.controlPages;
            selected = 1;
            for k = 1:numel(pages)
                if strcmp(pages(k).Visible,'on')
                    selected = k;
                    break;
                end
            end
            ui.Theme.selectNavigation(app.controlTabButtons,selected);
        end

        function selectNavigation(buttons,index)
            c = ui.Theme.colors(buttons(1));
            f = ui.Theme.scaledFonts(buttons(1));
            for k = 1:numel(buttons)
                label = ui.Theme.navigationLabel(buttons(k));
                if ~isempty(label)
                    buttons(k).BorderType = 'none';
                    buttons(k).BackgroundColor = c.panel;
                    label.FontName = f.ui;
                    label.FontSize = f.nav;
                    label.FontWeight = 'normal';
                    label.FontColor = c.text;
                    label.BackgroundColor = c.panel;
                else
                    buttons(k).FontName = f.ui;
                    buttons(k).FontSize = f.nav;
                    buttons(k).FontWeight = 'normal';
                    buttons(k).FontColor = c.text;
                    buttons(k).BackgroundColor = c.panel;
                    ui.Theme.setIfProp(buttons(k),'BorderColor',c.panel);
                end
                if k == index
                    buttons(k).BackgroundColor = c.primarySoft;
                    if ~isempty(label)
                        label.FontWeight = 'bold';
                        label.BackgroundColor = c.primarySoft;
                    else
                        buttons(k).FontWeight = 'bold';
                        ui.Theme.setIfProp(buttons(k),'BorderColor',c.primarySoft);
                    end
                end
            end
        end

        function label = navigationLabel(item)
            label = [];
            try
                data = item.UserData;
                if isstruct(data) && isfield(data,'Label') && isvalid(data.Label)
                    label = data.Label;
                end
            catch
            end
        end

        function restylePageButtons(buttons,pages)
            selected = 1;
            for k = 1:numel(pages)
                if strcmp(pages(k).Visible,'on')
                    selected = k;
                    break;
                end
            end
            c = ui.Theme.colors(buttons(1));
            f = ui.Theme.scaledFonts(buttons(1));
            for k = 1:numel(buttons)
                buttons(k).FontName = f.ui;
                buttons(k).FontSize = f.button;
                buttons(k).FontWeight = 'normal';
                buttons(k).BackgroundColor = c.control;
                if isprop(buttons(k),'BorderColor'); buttons(k).BorderColor = c.border; end
                buttons(k).FontColor = c.text;
                if k == selected
                    buttons(k).FontWeight = 'bold';
                    buttons(k).BackgroundColor = c.primarySoft;
                end
            end
        end

        function styleNeutralButton(btn,c,f)
            if nargin < 3
                f = ui.Theme.fonts();
            end
            ui.Theme.setIfProp(btn,'FontName',f.ui);
            ui.Theme.setIfProp(btn,'FontSize',f.button);
            ui.Theme.setIfProp(btn,'BackgroundColor',c.control);
            ui.Theme.setIfProp(btn,'FontColor',c.controlText);
            ui.Theme.setIfProp(btn,'FontWeight','normal');
            ui.Theme.setIfProp(btn,'BorderColor',c.border);
        end

        function stylePrimaryButton(btn,c,f)
            if nargin < 3
                f = ui.Theme.fonts();
            end
            btn.FontName = f.ui;
            btn.FontSize = f.button;
            btn.BackgroundColor = c.primary;
            btn.FontColor = [1 1 1];
            btn.FontWeight = 'bold';
            ui.Theme.setIfProp(btn,'BorderColor',c.primary);
        end

        function styleDangerButton(btn,c,f)
            if nargin < 3
                f = ui.Theme.fonts();
            end
            btn.FontName = f.ui;
            btn.FontSize = max(f.button+1,f.base);
            btn.BackgroundColor = c.danger;
            btn.FontColor = [1 1 1];
            btn.FontWeight = 'bold';
            ui.Theme.setIfProp(btn,'BorderColor',c.danger);
        end

        function styleAxis(ax,c,f)
            if nargin < 3
                f = ui.Theme.fonts();
            end
            ax.Color = c.axis;
            ax.XColor = c.text;
            ax.YColor = c.text;
            ax.GridColor = c.grid;
            ax.MinorGridColor = min(c.grid + 0.08,1);
            ax.GridAlpha = 0.35;
            ax.LineWidth = 0.8;
            ax.FontName = f.ui;
            ax.FontSize = max(f.axis,f.base-1);
            ax.Title.FontSize = max(f.axis+1,f.base);
            ax.XLabel.FontSize = max(f.axis,f.base-1);
            ax.YLabel.FontSize = max(f.axis,f.base-1);
        end

        function setIfProp(obj,prop,value)
            try
                if isprop(obj,prop)
                    obj.(prop) = value;
                end
            catch
            end
        end

        function color = parentBackground(obj,fallback)
            color = fallback;
            try
                parent = obj.Parent;
                if isprop(parent,'BackgroundColor')
                    color = parent.BackgroundColor;
                elseif isprop(parent,'Color')
                    color = parent.Color;
                end
            catch
            end
        end
    end
end
