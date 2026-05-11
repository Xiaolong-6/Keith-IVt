classdef StatusBarPanel
    methods(Static)
        function app = build(app,root,devilIcon,emojiFont)
            statusBar = uipanel(root,'Title','','BorderType','line','BackgroundColor',[1 1 1]);
            statusBar.Layout.Row = 3;
            statusBar.Layout.Column = [1 2];
            statusBarGrid = uigridlayout(statusBar,[1 8]);
            try, statusBarGrid.BackgroundColor = [1 1 1]; catch, end
            statusBarGrid.RowHeight = {'1x'};
            statusBarGrid.ColumnWidth = {22,140,16,'1x',16,110,16,230};
            statusBarGrid.Padding = [8 2 8 2];
            statusBarGrid.ColumnSpacing = 6;

            app.connLamp = uilamp(statusBarGrid,'Color',[0.85 0.05 0.05]);
            app.connLamp.Layout.Row = 1;
            app.connLamp.Layout.Column = 1;
            app.debugStatusIcon = uilabel(statusBarGrid,'Text',devilIcon,'FontName',emojiFont,'FontSize',17,'HorizontalAlignment','center','Visible','off');
            app.debugStatusIcon.Layout.Row = 1;
            app.debugStatusIcon.Layout.Column = 1;

            app.statusLabel = uilabel(statusBarGrid,'Text','Disconnected','FontWeight','bold');
            app.statusLabel.Layout.Row = 1;
            app.statusLabel.Layout.Column = 2;
            ui.StatusBarPanel.separator(statusBarGrid,3);

            app.connectionDetailLabel = uilabel(statusBarGrid,'Text','Not connected','FontColor',[0.45 0.49 0.52]);
            app.connectionDetailLabel.Layout.Row = 1;
            app.connectionDetailLabel.Layout.Column = 4;
            ui.StatusBarPanel.separator(statusBarGrid,5);

            app.runStateLabel = uilabel(statusBarGrid,'Text','Stopped','FontWeight','bold','FontColor',[0.45 0.49 0.52]);
            app.runStateLabel.Layout.Row = 1;
            app.runStateLabel.Layout.Column = 6;
            ui.StatusBarPanel.separator(statusBarGrid,7);

            app.estimateLabel = uilabel(statusBarGrid,'Text','Est. --','FontWeight','bold');
            app.estimateLabel.Layout.Row = 1;
            app.estimateLabel.Layout.Column = 8;
        end

        function sep = separator(parent,column)
            sep = uilabel(parent,'Text','|','FontColor',[0.72 0.75 0.75],'HorizontalAlignment','center');
            sep.Layout.Row = 1;
            sep.Layout.Column = column;
        end
    end
end
