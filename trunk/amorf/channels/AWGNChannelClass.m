classdef AWGNChannelClass < AttributeClass
    properties
        SNR
    end
    methods
        function obj=AWGNChannelClass(name)
            obj=obj@AttributeClass(name);
        end
        function outp=effect(obj,inp)
            outp=SignalClass(inp);
            outp.Samples=awgn(inp.Samples, obj.SNR, 'measured');
            outp.SNR=inp.SNR+obj.SNR;
        end
    end
end

