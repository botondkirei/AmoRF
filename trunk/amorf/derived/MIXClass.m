classdef MIXClass < TermalNoiseClass & NonlinearityClass & IQImbalanceClass & PhaseNoiseClass & CFOClass
    properties
        LOfreq
    end
    methods
        function output=process(obj,signal)
            [signal.Data,signal.Fs]=freqshift(obj,signal.Data,signal.Fs);
            signal=process@IQImbalanceClass(obj,signal);
            signal=process@CFOClass(obj,signal);
            signal=process@PhaseNoiseClass(obj,signal);
            signal=process@TermalNoiseClass(obj,signal);
            output=process@NonlinearityClass(obj,signal);
        end
        function update
        end
        function [outp,Fs]=freqshift(obj,inp, Fs)
            function outp=rotate(inp,m)
                    [a,b]=size(inp);
                    if m>0
                        outp=[inp(m:b) inp(1:m)];
                    else
                        outp=[inp(-m:b) inp(1:-m)];
                    end
            end
            [a,b]=size(inp);
            fft_inp=fftshift(fft(inp))/b;
            padlength=round(b*obj.LOfreq/(Fs+obj.LOfreq));
            Fs=Fs+obj.LOfreq;
            outp=ifft(rotate([zeros(1,padlength) fft_inp zeros(1,padlength)],padlength));
        end

    end
end