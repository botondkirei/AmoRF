classdef FilterClass < BaseClass
    properties
        fpass
        fstop
    end
    methods
        function obj=FilterClass(fpass,fstop)
            obj.fpass=fpass;
            obj.fstop=fstop;
        end
        function outp=process(obj,inp,Fs)
            [a,NesRF]=size(inp);
            mask=1:NesRF;
            lowlim=obj.fstop*NesRF/Fs;
            highlim=obj.fpass*NesRF/Fs;
            mask=(mask>(NesRF/2-lowlim))&(mask<(NesRF/2-highlim))|(mask>(NesRF/2+highlim))&(mask<(NesRF/2+lowlim));
            outp=ifft(fftshift(mask.*fftshift(fft(inp))));
        end
    end
end