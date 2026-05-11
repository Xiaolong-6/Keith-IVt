classdef AboutView
    methods(Static)
        function panel = build(parent,lines)
            panel = uipanel(parent,'Title','','BorderType','line');
            panel.AutoResizeChildren = 'off';
            panel.Scrollable = 'on';
            panel.Tag = 'aboutViewPanel';
            c = ui.Theme.colors(parent);
            f = ui.Theme.scaledFonts(parent);
            panel.BackgroundColor = c.panel;
            if isprop(panel,'BorderColor')
                panel.BorderColor = c.border;
            end

            rows = ui.AboutView.rowsFromLines(lines);
            rowHeights = ui.AboutView.rowHeights(rows,f);
            holderHeight = max(260,sum(cell2mat(rowHeights)) + 28);
            holder = uipanel(panel,'Title','','BorderType','none','BackgroundColor',c.panel);
            holder.Tag = 'aboutViewHolder';
            holder.Position = [0 0 max(parent.Position(3)-24,260) holderHeight];

            grid = uigridlayout(holder,[numel(rows) 1]);
            grid.RowHeight = rowHeights;
            grid.ColumnWidth = {'1x'};
            grid.Padding = [10 10 10 10];
            grid.RowSpacing = 3;
            grid.BackgroundColor = c.panel;
            grid.Tag = 'aboutViewGrid';

            for k = 1:numel(rows)
                row = rows(k);
                if strcmp(row.Kind,'spacer')
                    lbl = uilabel(grid,'Text','');
                else
                    lbl = uilabel(grid,'Text',row.Text);
                    lbl.WordWrap = 'on';
                    lbl.FontName = f.ui;
                    lbl.FontColor = c.text;
                    lbl.BackgroundColor = c.panel;
                    switch row.Kind
                        case 'title'
                            lbl.FontSize = f.header + 2;
                            lbl.FontWeight = 'bold';
                        case 'section'
                            lbl.FontSize = f.header;
                            lbl.FontWeight = 'bold';
                        case 'bullet'
                            lbl.FontSize = f.base;
                            lbl.FontWeight = 'normal';
                            lbl.FontColor = c.text;
                        otherwise
                            lbl.FontSize = f.base;
                            lbl.FontWeight = 'normal';
                    end
                end
                lbl.UserData = struct('Kind',row.Kind);
                lbl.Layout.Row = k;
                lbl.Layout.Column = 1;
            end

            panel.SizeChangedFcn = @(src,~)ui.AboutView.resizeHolder(src,holder,holderHeight);
            ui.AboutView.resizeHolder(panel,holder,holderHeight);
        end

        function rows = rowsFromLines(lines)
            if isstring(lines)
                lines = cellstr(lines);
            end
            rows = struct('Kind',{},'Text',{});
            for k = 1:numel(lines)
                text = char(lines{k});
                trimmed = strtrim(text);
                if isempty(trimmed)
                    rows(end+1) = struct('Kind','spacer','Text',''); %#ok<AGROW>
                elseif k == 1
                    rows(end+1) = struct('Kind','title','Text',trimmed); %#ok<AGROW>
                elseif strcmp(trimmed,upper(trimmed)) && all(isstrprop(regexprep(trimmed,'[^A-Za-z]',''),'upper'))
                    rows(end+1) = struct('Kind','section','Text',ui.AboutView.titleCase(trimmed)); %#ok<AGROW>
                elseif startsWith(trimmed,'- ')
                    rows(end+1) = struct('Kind','bullet','Text',['- ' strtrim(extractAfter(trimmed,2))]); %#ok<AGROW>
                else
                    rows(end+1) = struct('Kind','body','Text',trimmed); %#ok<AGROW>
                end
            end
        end

        function heights = rowHeights(rows,f)
            heights = cell(1,numel(rows));
            for k = 1:numel(rows)
                switch rows(k).Kind
                    case 'spacer'
                        heights{k} = 8;
                    case 'title'
                        heights{k} = max(30,f.header + 12);
                    case 'section'
                        heights{k} = max(28,f.header + 10);
                    otherwise
                        textLen = strlength(string(rows(k).Text));
                        heights{k} = max(24,ceil(double(textLen)/58) * (f.base + 5));
                end
            end
        end

        function resizeHolder(parent,holder,minHeight)
            if ~isvalid(parent) || ~isvalid(holder)
                return;
            end
            pos = parent.Position;
            holder.Position = [0 0 max(pos(3)-20,260) max(minHeight,pos(4)-4)];
        end

        function out = titleCase(text)
            words = lower(split(string(text)));
            for k = 1:numel(words)
                word = char(words(k));
                if ~isempty(word)
                    words(k) = string([upper(word(1)) word(2:end)]);
                end
            end
            out = char(join(words,' '));
        end
    end
end