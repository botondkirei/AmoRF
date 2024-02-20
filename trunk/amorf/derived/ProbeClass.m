classdef ProbeClass < SignalClass
    properties
        disp=false;
    end
    methods
        function output=process(obj, input)
            process@SignalClass(input);
            output=input;
            if obj.disp
                switch obj.domain
                    case 'time'
                        T=length(obj.data)/obj.Fs;
                        x=1/obj.Fs:1/obj.Fs:T;
                        plot(x,obj.data);
                    case 'freq'
                        y=abs(fftshift(fft(obj.data)));
                        l=length(obj.data);
                        x=((1:l)/l*obj.Fs)-(obj.Fs/2);
                        plot(x,y);
                end
            end
        end
    end
end
