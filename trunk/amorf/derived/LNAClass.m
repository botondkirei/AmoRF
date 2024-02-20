classdef LNAClass < SignalClass & TermalNoiseClass & NonlinearityClass
    properties
        rin=50
        rout=50
    end
    methods
        function obj=LNAClass(varargin)
            obj@SignalClass(varargin{:})
        end
        function output=process(varargin)
            obj=varargin{1};
            signal=varargin{2};
            signal=process@NonlinearityClass(obj,signal);
            output=process@TermalNoiseClass(obj,signal);
            obj.Data=output.Data;
            obj.Fs=output.Fs;
        end
    end
end