classdef UiState
    methods(Static)
        function state = onOff(tf)
            if tf
                state = 'on';
            else
                state = 'off';
            end
        end
    end
end
