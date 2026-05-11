classdef DebugSMU
    methods(Static)
        function [Y,profileName] = generateMeasurement(mode,X,deviceName,nplc,profileChoice)
            if nargin < 4
                nplc = 1;
            end
            if nargin < 5
                profileChoice = 'Auto random';
            end
            X = X(:);
            seed = hardware.DebugSMU.measurementSeed(deviceName);
            noiseScale = 1/sqrt(max(nplc,0.01));
            noise = noiseScale*hardware.DebugSMU.deterministicNoise(numel(X),seed);
            profileNames = {'resistor','diode','leaky nonlinear device','noisy contact'};
            profileChoice = lower(strtrim(char(string(profileChoice))));
            if strcmp(profileChoice,'auto random') || strcmp(profileChoice,'auto')
                profileIndex = mod(seed,4) + 1;
                profileName = profileNames{profileIndex};
            else
                idx = find(strcmp(profileChoice,profileNames),1,'first');
                if isempty(idx)
                    error('Unknown debug measurement profile: %s',profileChoice);
                end
                profileName = profileNames{idx};
            end

            switch profileName
                case 'resistor'
                    Y = hardware.DebugSMU.resistorResponse(mode,X,noise);
                case 'diode'
                    Y = hardware.DebugSMU.diodeResponse(mode,X,noise);
                case 'leaky nonlinear device'
                    Y = hardware.DebugSMU.leakyNonlinearResponse(mode,X,noise);
                otherwise
                    Y = hardware.DebugSMU.noisyContactResponse(mode,X,noise);
            end
        end

        function line = rawLine(mode,x,y,statusText)
            if nargin < 4
                statusText = '';
            end
            if strcmp(mode,'VOLT')
                voltage = x;
                current = y;
            else
                voltage = y;
                current = x;
            end
            if isempty(statusText)
                line = sprintf('%.12g,%.12g',voltage,current);
            else
                line = sprintf('%.12g,%.12g,%s',voltage,current,statusText);
            end
        end


        function [Y,hit] = applyMeasureRange(Y,rangeMode,rangeValue)
            hit = false;
            if nargin < 2 || isempty(rangeMode) || strcmp(rangeMode,'Auto range')
                return;
            end
            if nargin < 3 || ~isfinite(rangeValue) || rangeValue <= 0
                return;
            end
            over = abs(Y) > abs(rangeValue);
            hit = any(over,'all');
            Y(over) = NaN;
        end

        function [Y,hit] = applyCompliance(Y,compliance)
            if ~isfinite(compliance) || compliance <= 0
                hit = false;
                return;
            end
            limit = 0.98*abs(compliance);
            hit = any(abs(Y) > limit,'all');
            Y = min(max(Y,-limit),limit);
        end

        function seed = deviceSeed(deviceName)
            chars = double(char(string(deviceName)));
            if isempty(chars)
                seed = 1;
            else
                seed = mod(sum(chars.*(1:numel(chars))),997) + 1;
            end
        end

        function seed = measurementSeed(deviceName)
            randomPart = randi(9973);
            seed = mod(hardware.DebugSMU.deviceSeed(deviceName) + randomPart,9973) + 1;
        end

        function noise = deterministicNoise(n,seed)
            idx = (1:n)';
            noise = 0.55*sin(0.37*idx + seed) + 0.30*cos(0.11*idx + 0.3*seed) + 0.15*sin(1.7*idx);
        end

        function Y = resistorResponse(mode,X,noise)
            if strcmp(mode,'VOLT')
                resistance = 120e3;
                offset = 1.5e-9;
                Y = X./resistance + offset + 1.0e-8*noise;
            else
                resistance = 120e3;
                offset = 8.0e-4;
                Y = resistance*X + offset + 5.0e-4*noise;
            end
        end

        function Y = diodeResponse(mode,X,noise)
            if strcmp(mode,'VOLT')
                thermalVoltage = 0.075;
                saturationCurrent = 2.0e-10;
                seriesLeak = 2.0e-8*X;
                forwardCurrent = saturationCurrent*(exp(min(X,1.2)./thermalVoltage) - 1);
                reverseLeakage = -4.0e-8*(1 - exp(max(X,-5)./2.0));
                Y = seriesLeak + max(forwardCurrent,reverseLeakage) + 2.5e-9*noise;
            else
                current = X;
                saturationCurrent = 2.0e-10;
                thermalVoltage = 0.075;
                forwardV = thermalVoltage*log(max(current,0)./saturationCurrent + 1);
                reverseV = -2.0*tanh(abs(min(current,0))/2.0e-7);
                Y = forwardV + reverseV + 1.5e-3*noise;
            end
        end

        function Y = leakyNonlinearResponse(mode,X,noise)
            if strcmp(mode,'VOLT')
                conductance = 2.5e-6;
                leakage = 3.0e-9;
                turnOn = 1.2e-6*tanh(1.4*X);
                asymmetry = 1.5e-7*max(X,0).^2 - 0.8e-7*max(-X,0).^2;
                Y = conductance*X + leakage + turnOn + asymmetry + 2.0e-8*noise;
            else
                resistance = 8.2e3;
                contactOffset = 0.018*tanh(4.0e5*X);
                nonlinearity = 1.6e8*X.^3;
                Y = resistance*X + contactOffset + nonlinearity + 2.0e-4*noise;
            end
        end

        function Y = noisyContactResponse(mode,X,noise)
            if strcmp(mode,'VOLT')
                baseConductance = 7.5e-7;
                contactKnee = 4.0e-7*tanh(5.0*X);
                stepLikeShift = 1.5e-7*(X > median(X));
                Y = baseConductance*X + contactKnee + stepLikeShift + 8.0e-8*noise;
            else
                baseResistance = 35e3;
                contactKnee = 0.025*tanh(2.5e5*X);
                stepLikeShift = 0.015*(X > median(X));
                Y = baseResistance*X + contactKnee + stepLikeShift + 1.5e-3*noise;
            end
        end
    end
end
