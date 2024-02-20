classdef IQImbalCompClass < IQImbalClass
    methods
        function obj = IQImbalCompClass(name)
            obj=obj@IQImbalClass(name);
        end
        function outp=effect(obj,inp)
            if isa(inp, 'SignalClass')
                samples=inp.Samples;
            else
                samples=inp;
            end
            [a,b] = size(samples);
            if b==1
                obj.estimate(samples, samples);
                output = obj.compensate(samples,samples);
            else
                signal = samples(:,1);
                image = samples(:,2);
                obj.estimate(signal,image);
                signal=compensate(signal,image);
                image=compensate(image,signal);
                output = [signal image];
            end
            if isa(inp, 'SignalClass')
                outp=inp;
                outp.Samples=output;
            else
                outp=output;
            end
        end
        function outp = compensate(obj,signal, image)
            outp=(conj(obj.k1).*signal-obj.k2.*conj(image))./(abs(obj.k1)^2-abs(obj.k2)^2);
        end
            
    end
end