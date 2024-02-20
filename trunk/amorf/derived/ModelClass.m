classdef ModelClass < SignalClass & TermalNoiseClass & NonlinearityClass &...
        PhaseNoiseClass & CFOClass & IQImbalanceClass
    methods
        function output=process(varargin)
            obj=varargin{1};
            signal=varargin{2};
            signal=process@IQImbalanceClass(obj,signal);
            signal=process@CFOClass(obj,signal);
            signal=process@PhaseNoiseClass(obj,signal);
            signal=process@TermalNoiseClass(obj,signal);
            output=process@NonlinearityClass(obj,signal);
            obj.Data=output.Data;
            obj.Fs=output.Fs;
        end
    end
end