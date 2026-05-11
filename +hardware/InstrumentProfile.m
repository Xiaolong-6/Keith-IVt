classdef InstrumentProfile
    methods(Static)
        function profile = fromIdn(idn)
            idn = char(string(idn));
            model = hardware.InstrumentProfile.modelFromIdn(idn);
            profile = hardware.InstrumentProfile.forModel(model,idn);
        end

        function model = modelFromIdn(idn)
            model = 'Unknown';
            tokens = regexp(idn,'MODEL\s*([0-9A-Za-z\-]+)|,([0-9]{4,5})\s*,','tokens','once');
            if isempty(tokens)
                tokens = regexp(idn,'([0-9]{4,5})','tokens','once');
                if ~isempty(tokens)
                    model = tokens{1};
                end
                return;
            end
            parts = tokens(~cellfun('isempty',tokens));
            if ~isempty(parts)
                model = parts{1};
            end
        end

        function profile = forModel(model,idn)
            model = char(string(model));
            profile = hardware.InstrumentProfile.baseProfile(model,idn);
            specs = hardware.InstrumentProfile.specTable();
            if isfield(specs,matlab.lang.makeValidName(model))
                modelSpecs = specs.(matlab.lang.makeValidName(model));
                fields = fieldnames(modelSpecs);
                for k = 1:numel(fields)
                    profile.(fields{k}) = modelSpecs.(fields{k});
                end
            else
                profile.Notes = ['Generic 2400-series fallback. Unknown model "' model ...
                    '". Confirm all source, measure, and power limits before use.'];
            end
        end

        function profile = baseProfile(model,idn)
            profile = struct();
            profile.Family = 'Keithley 2400 Series';
            profile.Model = char(string(model));
            profile.IDN = char(string(idn));
            profile.SupportsRemoteSense = true;
            profile.SupportsFrontRearTerminals = true;
            profile.SupportsPulseMode = false;
            profile.NPLCLimits = [0.01 10];
            profile.DefaultBaud = 9600;
            profile.SerialOverhead_s = 0.03;
            profile.LineFrequencyHz = 50;
            profile.VoltageMeasureRanges_V = [0.2 2 20 200];
            profile.CurrentMeasureRanges_A = [1e-6 10e-6 100e-6 1e-3 10e-3 100e-3 1];
            profile.VoltageSourceLimit_V = 200;
            profile.CurrentSourceLimit_A = 1;
            profile.MaxPower_W = 22;
            profile.SourceVoltageResolution_V = 5e-6;
            profile.MeasureVoltageResolution_V = 1e-6;
            profile.SourceCurrentResolution_A = 50e-12;
            profile.MeasureCurrentResolution_A = 10e-12;
            profile.SourceListPoints = 100;
            profile.BufferReadings = 2500;
            profile.ProfileStatus = 'generic';
            profile.Notes = 'Generic 2400-series profile. Confirm exact model limits against the manual before high-power use.';
        end

        function specs = specTable()
            specs = struct();

            specs.x2400 = hardware.InstrumentProfile.modelSpec( ...
                210,1.05,22,[0.2 2 20 200],[1e-6 10e-6 100e-6 1e-3 10e-3 100e-3 1], ...
                5e-6,1e-6,50e-12,10e-12,false, ...
                '22 W; operating envelope includes 21 V at 1.05 A or 210 V at 105 mA.');

            specs.x2401 = hardware.InstrumentProfile.modelSpec( ...
                20,1.05,20,[0.2 2 20],[1e-6 10e-6 100e-6 1e-3 10e-3 100e-3 1], ...
                5e-6,1e-6,50e-12,10e-12,false, ...
                '2401 low-voltage profile. Confirm exact ranges against the 2401 datasheet before high-power use.');

            specs.x2410 = hardware.InstrumentProfile.modelSpec( ...
                1100,1.05,22,[0.2 2 20 100 1000],[1e-6 10e-6 100e-6 1e-3 10e-3 20e-3 100e-3 1], ...
                5e-6,1e-6,50e-12,10e-12,false, ...
                '22 W high-voltage model; operating envelope includes 1100 V at 21 mA.');

            specs.x2420 = hardware.InstrumentProfile.modelSpec( ...
                63,3.15,66,[0.2 2 20 60],[10e-6 100e-6 1e-3 10e-3 100e-3 1 3], ...
                5e-6,1e-6,500e-12,100e-12,false, ...
                '66 W model; operating envelope includes 63 V at 1.05 A or 21 V at 3.15 A.');

            specs.x2425 = hardware.InstrumentProfile.modelSpec( ...
                105,3.15,110,[0.2 2 20 100],[10e-6 100e-6 1e-3 10e-3 100e-3 1 3], ...
                5e-6,1e-6,500e-12,100e-12,false, ...
                '110 W DC model; operating envelope includes 105 V at 1.05 A or 21 V at 3.15 A.');

            specs.x2430 = hardware.InstrumentProfile.modelSpec( ...
                105,10.5,110,[0.2 2 20 100],[10e-6 100e-6 1e-3 10e-3 100e-3 1 3 10], ...
                5e-6,1e-6,500e-12,100e-12,true, ...
                '110 W DC / 1.1 kW pulse model. This app uses DC source-measure mode only.');

            specs.x2440 = hardware.InstrumentProfile.modelSpec( ...
                42,5.25,66,[0.2 2 20 40],[10e-6 100e-6 1e-3 10e-3 100e-3 1 5], ...
                5e-6,1e-6,500e-12,100e-12,false, ...
                '66 W high-current model; operating envelope includes 42 V at 1.05 A or 10.5 V at 5.25 A.');
        end

        function s = modelSpec(vLimit,iLimit,powerW,vRanges,iRanges,vSrcRes,vMeasRes,iSrcRes,iMeasRes,pulse,notes)
            s = struct();
            s.VoltageSourceLimit_V = vLimit;
            s.CurrentSourceLimit_A = iLimit;
            s.MaxPower_W = powerW;
            s.VoltageMeasureRanges_V = vRanges;
            s.CurrentMeasureRanges_A = iRanges;
            s.SourceVoltageResolution_V = vSrcRes;
            s.MeasureVoltageResolution_V = vMeasRes;
            s.SourceCurrentResolution_A = iSrcRes;
            s.MeasureCurrentResolution_A = iMeasRes;
            s.SupportsPulseMode = pulse;
            s.ProfileStatus = 'model-specific';
            s.Notes = notes;
        end

        function label = displayLabel(profile)
            if isempty(profile) || ~isstruct(profile) || ~isfield(profile,'Model') || strcmp(profile.Model,'Unknown')
                label = 'Keithley 2400 Series';
            else
                label = ['Keithley ' profile.Model];
            end
        end
    end
end
