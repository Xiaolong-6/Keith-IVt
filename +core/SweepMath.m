classdef SweepMath
    methods(Static)
        function X = buildScanVector(xStart,xStop,xStep)
            if xStep == 0
                error('Step cannot be zero.');
            end
            if xStart < xStop && xStep < 0
                error('Step sign is wrong: start < stop requires positive step.');
            end
            if xStart > xStop && xStep > 0
                error('Step sign is wrong: start > stop requires negative step. Example: start 5, stop -5, step -0.1.');
            end
            X = (xStart:xStep:xStop)';
        end

        function txt = estimateSweepTimeText(nPts,nplc,settleT)
            lineFreqHz = 50;
            readOverheadS = 0.15;
            t = nPts*(settleT + nplc/lineFreqHz + readOverheadS);
            if t < 60
                txt = sprintf('%d points, about %.1f s',nPts,t);
            elseif t < 3600
                txt = sprintf('%d points, about %.1f min',nPts,t/60);
            else
                txt = sprintf('%d points, about %.1f h',nPts,t/3600);
            end
        end

        function X = buildAdaptiveScanVector(xStart,xStop,rules)
            rules = core.SweepMath.validateAdaptiveRules(rules);
            if xStart == xStop
                X = xStart;
                return;
            end

            dirSign = sign(xStop - xStart);
            X = xStart;
            x = xStart;
            maxPoints = 1000000;

            while dirSign*(xStop - x) > 0
                step = core.SweepMath.adaptiveStepForValue(x,rules);
                xNext = x + dirSign*step;
                xNext = core.SweepMath.clampAdaptiveBoundary(x,xNext,rules);
                if dirSign*(xNext - xStop) > 0
                    xNext = xStop;
                end
                if xNext == x
                    error('Adaptive sweep step is too small to advance the source value.');
                end
                X(end+1,1) = xNext; %#ok<AGROW>
                x = xNext;
                if numel(X) > maxPoints
                    error('Adaptive sweep would create more than %d points. Increase the step size or reduce the range.',maxPoints);
                end
            end
            X = round(X*1e12)/1e12;
            X = X([true; diff(X) ~= 0]);
        end

        function rules = validateAdaptiveRules(rules)
            if istable(rules)
                rules = table2array(rules);
            elseif iscell(rules)
                rules = cell2mat(rules);
            end
            if size(rules,2) ~= 3
                error('Adaptive sweep table must have three columns: Abs From, Abs To, and Step.');
            end
            rules = double(rules);
            if isempty(rules) || any(~isfinite(rules(:)))
                error('Adaptive sweep table must contain finite numeric values.');
            end
            if any(rules(:,1) < 0) || any(rules(:,2) < 0)
                error('Adaptive sweep abs ranges cannot be negative.');
            end
            if any(rules(:,3) <= 0)
                error('Adaptive sweep steps must be positive.');
            end
            low = min(rules(:,1),rules(:,2));
            high = max(rules(:,1),rules(:,2));
            if any(high <= low)
                error('Each adaptive sweep row must have two different abs range values.');
            end
            rules = [low high rules(:,3)];
            [~,idx] = sort(rules(:,1));
            rules = rules(idx,:);
        end

        function validateAdaptiveCoverage(rules,xStart,xStop)
            rules = core.SweepMath.validateAdaptiveRules(rules);
            absNeeded = sort([abs(xStart) abs(xStop)]);
            if xStart*xStop <= 0
                absNeeded(1) = 0;
            end
            if absNeeded(2) == 0
                return;
            end

            low = rules(:,1);
            high = rules(:,2);
            if absNeeded(1) < low(1) && absNeeded(1) > 0
                error('Adaptive rules start at %g, but this sweep needs coverage from abs(source) = %g.',low(1),absNeeded(1));
            end

            currentHigh = high(1);
            for k = 2:size(rules,1)
                if low(k) > currentHigh && low(k) < absNeeded(2) && currentHigh > absNeeded(1)
                    error('Adaptive rules have a gap from abs(source) = %g to %g.',currentHigh,low(k));
                end
                currentHigh = max(currentHigh,high(k));
            end
            if absNeeded(2) > currentHigh
                error('Adaptive rules end at abs(source) = %g, but this sweep needs coverage to %g.',currentHigh,absNeeded(2));
            end
        end

        function calc = calcElectrical(mode,X,Y)
            X = X(:);
            Y = Y(:);
            if strcmp(mode,'VOLT')
                V = X;
                I = Y;
            else
                I = X;
                V = Y;
            end

            R = nan(size(V));
            G = nan(size(V));
            validI = isfinite(I) & abs(I) > 0;
            validV = isfinite(V) & abs(V) > 0;
            R(validI) = V(validI)./I(validI);
            G(validV) = I(validV)./V(validV);

            Rd = nan(size(V));
            valid = isfinite(V) & isfinite(I);
            if nnz(valid) >= 2
                Rd(valid) = gradient(V(valid))./gradient(I(valid));
            end

            calc = struct('R_shunt_ohm',R,'G_conductance_S',G,'R_diff_ohm',Rd);
        end

        function [hit,hitCount,maxRatio] = complianceHitSummary(Y,compliance)
            Y = Y(:);
            valid = isfinite(Y);
            if compliance <= 0 || ~any(valid)
                hit = false;
                hitCount = 0;
                maxRatio = NaN;
                return;
            end
            ratio = abs(Y(valid))./compliance;
            hitCount = nnz(ratio >= 0.98);
            hit = hitCount > 0;
            maxRatio = max(ratio);
        end

        function step = adaptiveStepForValue(x,rules)
            ax = abs(x);
            idx = find(ax > rules(:,1) & ax <= rules(:,2),1,'first');
            if isempty(idx)
                if ax < min(rules(:,1))
                    [~,idx] = min(rules(:,3));
                else
                    [~,idx] = max(rules(:,2));
                end
            end
            step = rules(idx,3);
        end

        function xNext = clampAdaptiveBoundary(x,xNext,rules)
            if x == 0 || xNext == 0
                return;
            end
            if sign(x) ~= sign(xNext)
                xNext = 0;
                return;
            end

            boundaries = unique(rules(:,1:2));
            ax = abs(x);
            axNext = abs(xNext);
            if axNext < ax
                crossed = boundaries(boundaries < ax & boundaries > axNext);
                if ~isempty(crossed)
                    xNext = sign(x)*max(crossed);
                end
            elseif axNext > ax
                crossed = boundaries(boundaries > ax & boundaries < axNext);
                if ~isempty(crossed)
                    xNext = sign(x)*min(crossed);
                end
            end
        end
    end
end
