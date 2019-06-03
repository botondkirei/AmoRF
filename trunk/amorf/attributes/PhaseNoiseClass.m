% PhaseNoiseClass - Phase noise attribute
%
% PhaseNoiseClass methods:
%   effect - Process an input signal
%   multiplier - Computes the multiplier signal.
%
% PhaseNoiseClass parents:
%   AttributeClass - functionalities and non-idealities
%
% See also: BaseClass, SignalClass, AttributeClass, BlockClass, TunerClass, 
% GainClass, NoiseClass,  FreqSelClass, PhaseNoiseClass, IQImbalClass.
classdef PhaseNoiseClass < AttributeClass
%% PhaseNoiseClass
% Parent class: <AttributeClass.html AttributeClass>.
% PhaseNoiseClass is a specific nonideality of a VCO. 

%% Methods
% * <PhaseNoiseClass.html#3 PhaseNoiseClass>
% * <PhaseNoiseClass.html#4 multiplier>
% * <PhaseNoiseClass.html#5 effect>
methods (Access=private)
        %% PhaseNoiseClass@PhaseNoiseClass
        %
        %  OBJ=PhaseNoiseClass(NAME)
        %
        % PhaseNoiseClass object contructor. The PhaseNoiseClass/Name property
        % is set to |NAME|.
        function obj=PhaseNoiseClass(name)
        % PhaseNoiseClass object constructor.
        %
        %   OBJ=PhaseNoiseClass(NAME) - The PhaseNoiseClass/Name property
        %   is set to NAME.
            obj=obj@AttributeClass(name);
        end
        %% multiplier@PhaseNoiseClass
        %
        %  OUTP=multiplier(OBJECT,INP)
        %
        % The method computed the multiplier of the phase noise effect.
        function outp=multiplier(obj,inp)
        % MULTIPLIER - phase noise multiplier.
        %
        %	OUTP=multiplier(OBJECT,INP) - The method computed the multiplier
        %	of the phase noise effect.
        %
        % See also: PhaseNoiseClass/effect.
            Data=inp.Samples;
            Fs=inp.Fs;
            l=length(inp.Samples);
            h=spectrum.welch;
            Hpsd=psd(h,Data,'Fs',Fs);%obtinerea spectrului semnalului
            Hpsd=sqrt(Hpsd);
            Hpsd=ifft(Hpsd);
            noise=rand(l,1);
            outp=conv(noise,Hpsd);
        end
    end
    methods
        %% effect@PhaseNoiseClass
        %
        %  OUTP=effect(OBJECT,INP)
        %
        % Applies the |OBJECT| phase noise to input signal |INP| and
        % returns the result in |OUTP|. The most general one is a phase
        % modulation: 
        %
        % $$ y(k)=x(k)\cdot e^{\phi(k)} $$
        %
        % where phi(k) is a time domain desciption of the phase noise.
        function outp=effect(obj,inp)
        % PROCESS Applies the phase noise attribute.
        %
        %	OUTP=effect(OBJECT,INP) - Applies the OBJECT phase noise to
        %	input signal INP and returns the result in OUTP. The most
        %	general one is a phase modulation: 
        % 
        %   y(k)=x(k) * e^(phi(k)),
        %
        %   where phi(k) is a time domain desciption of the phase noise.
        %
        % See also: PhaseNoiseClass/multiplier.
            m=obj.multiplier(inp);
            outp=inp.*m;
        end
    end
end
