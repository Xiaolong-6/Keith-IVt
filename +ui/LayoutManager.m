classdef LayoutManager
    methods(Static)
        function apply(app,root)
            if ~isfield(app,'leftContentGrid') || ~isvalid(app.leftContentGrid)
                return;
            end
            widths = ui.LayoutManager.responsiveWidths(app.fig.Position);
            root.RowHeight = ui.LayoutManager.responsiveRows(app.fig.Position);
            root.ColumnWidth{1} = widths.left;
            root.ColumnWidth{2} = '1x';

            % Left side is now a fixed navigation rail + one content column.
            % It should not collapse into the form controls when the window gets narrow.
            app.leftContentGrid.RowHeight = {'1x'};
            if isfield(app,'leftShell') && isvalid(app.leftShell)
                app.leftShell.RowHeight = {0,'1x'};
            end
            if isfield(app,'leftColumnGrid') && isvalid(app.leftColumnGrid)
                app.leftColumnGrid.RowHeight = {'1x'};
            end
            app.leftContentGrid.Visible = 'on';
            app.rightContentGrid.Visible = 'on';
        end

        function widths = responsiveWidths(figPosition)
            figW = figPosition(3);
            widths = struct();
            widths.left = min(max(round(figW*0.33),500),650);
            if figW < 1150
                % Low-resolution laptops: keep the left form usable but give the
                % plot and device table enough width to avoid horizontal scrolling.
                widths.left = min(max(round(figW*0.42),430),500);
            end
            if figW < 900
                widths.left = min(max(round(figW*0.48),390),430);
            end
        end

        function rows = responsiveRows(figPosition)
            figW = figPosition(3);
            if figW < 1150
                % At 1024x768, the device table is otherwise too short.
                rows = {'1.55x','1x',28};
            else
                rows = {'2.15x','1x',28};
            end
        end
    end
end
