classdef K2400Driver < handle
    properties
        PortName
        BaudRate
        Terminal
        InstrumentID = 'Unknown instrument ID'
        Profile = []
        Timeout = 30
    end

    properties(Access=private)
        Serial
        Mode = 'VOLT'
    end

    methods
        function obj = K2400Driver(portName,baudRate,terminal)
            obj.PortName = char(string(portName));
            obj.BaudRate = baudRate;
            obj.Terminal = char(string(terminal));
        end

        function connect(obj)
            obj.Serial = serialport(obj.PortName,obj.BaudRate);
            configureTerminator(obj.Serial,'CR/LF');
            obj.Serial.Timeout = obj.Timeout;

            try
                writeline(obj.Serial,'*IDN?');
                obj.InstrumentID = char(strtrim(readline(obj.Serial)));
            catch
                obj.InstrumentID = 'Unknown instrument ID';
            end
            obj.Profile = hardware.InstrumentProfile.fromIdn(obj.InstrumentID);

            writeline(obj.Serial,'*RST');
            pause(1.5);
            writeline(obj.Serial,'*CLS');
            writeline(obj.Serial,sprintf(':ROUT:TERM %s',obj.Terminal));
            writeline(obj.Serial,':FORM:ELEM VOLT,CURR');
            writeline(obj.Serial,':SYST:AZER:STAT ON');
            writeline(obj.Serial,':SOUR:VOLT 0');
            writeline(obj.Serial,':OUTP OFF');
        end

        function acceptedNplc = configureSweep(obj,mode,compliance,nplc,senseMode,rangeMode,rangeValue)
            if nargin < 6
                rangeMode = 'Auto range';
            end
            if nargin < 7
                rangeValue = NaN;
            end
            obj.Mode = char(string(mode));
            obj.configureSenseMode(senseMode);
            if strcmp(obj.Mode,'VOLT')
                writeline(obj.Serial,':SOUR:FUNC VOLT');
                writeline(obj.Serial,':SENS:FUNC ''CURR''');
                writeline(obj.Serial,':SOUR:VOLT:MODE FIXED');
                writeline(obj.Serial,':SOUR:VOLT:RANG:AUTO ON');
                obj.configureMeasureRange('CURR',rangeMode,rangeValue);
                writeline(obj.Serial,sprintf(':SENS:CURR:PROT %g',compliance));
                writeline(obj.Serial,sprintf(':SENS:CURR:NPLC %g',nplc));
                verifyCmd = ':SENS:CURR:NPLC?';
            else
                writeline(obj.Serial,':SOUR:FUNC CURR');
                writeline(obj.Serial,':SENS:FUNC ''VOLT''');
                writeline(obj.Serial,':SOUR:CURR:MODE FIXED');
                writeline(obj.Serial,':SOUR:CURR:RANG:AUTO ON');
                obj.configureMeasureRange('VOLT',rangeMode,rangeValue);
                writeline(obj.Serial,sprintf(':SENS:VOLT:PROT %g',compliance));
                writeline(obj.Serial,sprintf(':SENS:VOLT:NPLC %g',nplc));
                verifyCmd = ':SENS:VOLT:NPLC?';
            end

            acceptedNplc = '';
            try
                writeline(obj.Serial,verifyCmd);
                acceptedNplc = char(strtrim(readline(obj.Serial)));
            catch
            end
        end

        function autozeroOnce(obj)
            writeline(obj.Serial,':SYST:AZER:STAT ONCE');
        end

        function configureSenseMode(obj,senseMode)
            if nargin < 2 || isempty(senseMode)
                senseMode = '2-wire';
            end
            if strcmp(char(string(senseMode)),'4-wire')
                writeline(obj.Serial,':SYST:RSEN ON');
            else
                writeline(obj.Serial,':SYST:RSEN OFF');
            end
        end

        function configureMeasureRange(obj,measureFunction,rangeMode,rangeValue)
            measureFunction = char(string(measureFunction));
            if strcmp(measureFunction,'CURR')
                commandPrefix = ':SENS:CURR:RANG';
            else
                commandPrefix = ':SENS:VOLT:RANG';
            end

            if nargin < 3 || isempty(rangeMode) || strcmp(char(string(rangeMode)),'Auto range')
                writeline(obj.Serial,[commandPrefix ':AUTO ON']);
                return;
            end

            if nargin < 4 || isempty(rangeValue) || ~isfinite(rangeValue) || rangeValue <= 0
                error('Fixed measure range must be a positive finite value.');
            end
            writeline(obj.Serial,[commandPrefix ':AUTO OFF']);
            writeline(obj.Serial,sprintf('%s %.9g',commandPrefix,rangeValue));
        end

        function state = querySenseMode(obj)
            state = obj.query(':SYST:RSEN?');
        end

        function response = query(obj,command)
            writeline(obj.Serial,char(string(command)));
            response = char(strtrim(readline(obj.Serial)));
        end

        function outputOn(obj)
            writeline(obj.Serial,':OUTP ON');
        end

        function outputOff(obj)
            writeline(obj.Serial,':OUTP OFF');
        end

        function zeroSource(obj,mode)
            if nargin >= 2
                obj.Mode = char(string(mode));
            end
            if strcmp(obj.Mode,'VOLT')
                writeline(obj.Serial,':SOUR:VOLT 0');
            else
                writeline(obj.Serial,':SOUR:CURR 0');
            end
        end

        function [y,line] = readPoint(obj,mode,x)
            obj.Mode = char(string(mode));
            if strcmp(obj.Mode,'VOLT')
                writeline(obj.Serial,sprintf(':SOUR:VOLT %.9g',x));
            else
                writeline(obj.Serial,sprintf(':SOUR:CURR %.9g',x));
            end

            writeline(obj.Serial,':READ?');
            line = readline(obj.Serial);
            vals = str2num(line); %#ok<ST2NM>

            y = NaN;
            if strcmp(obj.Mode,'VOLT')
                if numel(vals) >= 2
                    y = vals(2);
                end
            else
                if numel(vals) >= 1
                    y = vals(1);
                end
            end
        end

        function safeOff(obj,mode)
            try
                if nargin >= 2
                    obj.zeroSource(mode);
                else
                    obj.zeroSource();
                end
                pause(0.1);
                obj.outputOff();
            catch
            end
        end

        function disconnect(obj)
            obj.safeOff();
            obj.Serial = [];
        end
    end
end
